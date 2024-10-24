package com.example.audioplayer.audio_player

import android.content.Context
import android.media.AudioFormat
import android.media.MediaCodec
import android.media.MediaExtractor
import android.media.MediaFormat
import android.net.Uri
import android.os.Build
import android.os.Handler
import android.os.Looper
import android.util.Log
import com.google.android.exoplayer2.ExoPlayer
import com.google.android.exoplayer2.MediaItem
import com.google.android.exoplayer2.Player
import io.flutter.embedding.engine.plugins.FlutterPlugin
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel
import io.flutter.plugin.common.MethodChannel.MethodCallHandler
import kotlinx.coroutines.*
import java.io.File

/**
 * AudioCodecPlugin is a Flutter plugin that handles audio file processing using Android's MediaCodec and ExoPlayer.
 * It decodes PCM data from audio files and sends it to Flutter for further processing or playback control.
 */
class AudioCodecPlugin : FlutterPlugin, MethodCallHandler {
    private lateinit var channel: MethodChannel
    private var decoder: MediaCodec? = null
    private var extractor: MediaExtractor? = null
    private val scope = CoroutineScope(Dispatchers.IO)
    private val TAG = "AudioCodecPlugin"
    private lateinit var applicationContext: Context

    // Audio properties
    private var sampleRate: Int = 0
    private var channels: Int = 0
    private var pcmEncodingBit: Int = 16

    // ExoPlayer instance for playback
    private var exoPlayer: ExoPlayer? = null
    private var handler: Handler = Handler(Looper.getMainLooper())
    private var runnable: Runnable? = null
    private var updateFrequency: Long = 200 // Update interval for sending current playback position

    override fun onAttachedToEngine(binding: FlutterPlugin.FlutterPluginBinding) {
        channel = MethodChannel(binding.binaryMessenger, "audio_codec_channel")
        channel.setMethodCallHandler(this)
        applicationContext = binding.applicationContext
    }

    override fun onMethodCall(call: MethodCall, result: MethodChannel.Result) {
        when (call.method) {
            "processAudioFile" -> {
                val filePath = call.argument<String>("filePath")
                    ?: return result.error("INVALID_ARGUMENT", "filePath is required", null)

                scope.launch {
                    try {
                        decodeAndSendPcmData(filePath)
                        withContext(Dispatchers.Main) { result.success(null) }
                    } catch (e: Exception) {
                        Log.e(TAG, "Error processing file: ${e.message}", e)
                        withContext(Dispatchers.Main) {
                            result.error("PROCESSING_ERROR", e.message, null)
                        }
                    }
                }
            }

            "release" -> {
                cleanupResources()
                result.success(null)
            }

            "pausePlayer" -> pausePlayer(result)

            "playPlayer" -> playPlayer(result)

            "getCurrentDuration" -> sendCurrentDuration(result)

            "seekTo" -> {
                val seekDuration = call.argument<Int>("seekDuration")
                    ?: return result.error("INVALID_ARGUMENT", "seekDuration is required", null)

                seekPlayer(seekDuration, result)
            }

            else -> result.notImplemented()
        }
    }

    /**
     * Decodes the audio file and sends PCM data to Flutter.
     */
    private suspend fun decodeAndSendPcmData(filePath: String) = withContext(Dispatchers.IO) {
        try {
            cleanupResources()

            val file = File(filePath)
            if (!file.exists()) throw Exception("Audio file not found at path: $filePath")

            extractor = MediaExtractor().apply {
                setDataSource(file.absolutePath)
            }

            var audioTrackFound = false
            for (i in 0 until extractor!!.trackCount) {
                val format = extractor!!.getTrackFormat(i)
                val mime = format.getString(MediaFormat.KEY_MIME)

                if (mime?.startsWith("audio/") == true) {
                    extractor!!.selectTrack(i)
                    setupDecoder(format)
                    audioTrackFound = true
                    break
                }
            }

            if (!audioTrackFound) throw Exception("No audio track found in file")

            // Initialize ExoPlayer for playback
            withContext(Dispatchers.Main) { initializeExoPlayer(filePath) }

            processAudioData()

        } catch (e: Exception) {
            throw Exception("Failed to process audio file: ${e.message}")
        }
    }

    /**
     * Sets up the MediaCodec decoder with the given audio format.
     */
    private fun setupDecoder(format: MediaFormat) {
        val mime = format.getString(MediaFormat.KEY_MIME)
            ?: throw Exception("No MIME type found")

        decoder = MediaCodec.createDecoderByType(mime).apply {
            configure(format, null, null, 0)
            start()
        }

        sampleRate = format.getInteger(MediaFormat.KEY_SAMPLE_RATE)
        channels = format.getInteger(MediaFormat.KEY_CHANNEL_COUNT)
        pcmEncodingBit = if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.N) {
            when (format.getInteger(MediaFormat.KEY_PCM_ENCODING, AudioFormat.ENCODING_PCM_16BIT)) {
                AudioFormat.ENCODING_PCM_16BIT -> 16
                AudioFormat.ENCODING_PCM_8BIT -> 8
                AudioFormat.ENCODING_PCM_FLOAT -> 32
                else -> 16
            }
        } else 16
    }

    /**
     * Processes audio data by reading from the MediaExtractor and feeding it to the MediaCodec.
     */
    private suspend fun processAudioData() = withContext(Dispatchers.IO) {
        val codec = decoder ?: throw Exception("Decoder not initialized")

        var sawInputEOS = false
        var sawOutputEOS = false

        while (!sawOutputEOS) {
            if (!sawInputEOS) {
                val inputBufferId = codec.dequeueInputBuffer(TIMEOUT_US)
                if (inputBufferId >= 0) {
                    val inputBuffer = codec.getInputBuffer(inputBufferId)
                    inputBuffer?.let {
                        val sampleSize = extractor?.readSampleData(it, 0) ?: -1
                        val presentationTimeUs = extractor?.sampleTime ?: 0

                        if (sampleSize >= 0) {
                            codec.queueInputBuffer(inputBufferId, 0, sampleSize, presentationTimeUs, 0)
                            extractor?.advance()
                        } else {
                            sawInputEOS = true
                            codec.queueInputBuffer(
                                inputBufferId,
                                0,
                                0,
                                presentationTimeUs,
                                MediaCodec.BUFFER_FLAG_END_OF_STREAM
                            )
                        }
                    }
                }
            }

            val bufferInfo = MediaCodec.BufferInfo()
            val outputBufferId = codec.dequeueOutputBuffer(bufferInfo, TIMEOUT_US)

            when {
                outputBufferId >= 0 -> {
                    codec.getOutputBuffer(outputBufferId)?.let { outputBuffer ->
                        if (bufferInfo.size > 0) {
                            val pcmData = ByteArray(bufferInfo.size)
                            outputBuffer.get(pcmData)
                            sendPcmDataToFlutter(pcmData)
                        }
                    }
                    codec.releaseOutputBuffer(outputBufferId, false)
                    if (bufferInfo.flags and MediaCodec.BUFFER_FLAG_END_OF_STREAM != 0) {
                        sawOutputEOS = true
                        sendProcessingCompleteToFlutter()
                    }
                }

                outputBufferId == MediaCodec.INFO_OUTPUT_FORMAT_CHANGED -> {
                    // Handle output format change if necessary
                }

                outputBufferId == MediaCodec.INFO_TRY_AGAIN_LATER -> {
                    if (sawInputEOS) {
                        // No output buffer available at the moment
                    }
                }
            }
        }
    }

    /**
     * Sends PCM data to Flutter via the method channel.
     */
    private suspend fun sendPcmDataToFlutter(pcmData: ByteArray) = withContext(Dispatchers.Main) {
        val resultJson = mapOf(
            "pcmData" to pcmData,
            "sampleRate" to sampleRate,
            "channels" to channels,
            "pcmEncodingBit" to pcmEncodingBit
        )
        channel.invokeMethod("pcmData", resultJson)
    }

    /**
     * Notifies Flutter that the audio processing is complete.
     */
    private suspend fun sendProcessingCompleteToFlutter() = withContext(Dispatchers.Main) {
        channel.invokeMethod("processingComplete", null)
    }

    /**
     * Pauses ExoPlayer playback.
     */
    private fun pausePlayer(result: MethodChannel.Result) {
        try {
            exoPlayer?.pause() ?: run {
                result.error("PAUSE_ERROR", "Player is not initialized", null)
                return
            }
            stopListening()
            result.success(true)
        } catch (e: Exception) {
            result.error("PAUSE_ERROR", "Failed to pause the player", e.toString())
        }
    }

    /**
     * Starts ExoPlayer playback.
     */
    private fun playPlayer(result: MethodChannel.Result) {
        try {
            exoPlayer?.let {
                it.playWhenReady = true
                it.play()
                startListening()
                result.success(true)
            } ?: run {
                result.error("PLAY_ERROR", "Player is not initialized", null)
            }
        } catch (e: Exception) {
            result.error("PLAY_ERROR", "Failed to play the player", e.toString())
        }
    }

    /**
     * Seeks to the provided position in the audio file.
     */
    private fun seekPlayer(seekDuration: Int, result: MethodChannel.Result) {
        try {
            exoPlayer?.let {
                it.seekTo(seekDuration.toLong())
                result.success(true)
            } ?: run {
                result.error("SEEK_ERROR", "Player is not initialized", null)
            }
        } catch (e: Exception) {
            result.error("SEEK_ERROR", "Failed to seek to position", e.toString())
        }
    }

   /**
     * Initializes ExoPlayer for playing the provided file.
     * Must be called from the main thread.
     */
    private fun initializeExoPlayer(filePath: String) {
        check(Looper.myLooper() == Looper.getMainLooper()) {
            "ExoPlayer must be initialized on the main thread"
        }

        try {
            exoPlayer?.release()
            exoPlayer = ExoPlayer.Builder(applicationContext).build().apply {
                val uri = Uri.parse(filePath)
                val mediaItem = MediaItem.fromUri(uri)
                setMediaItem(mediaItem)
                prepare()
                addListener(object : Player.Listener {
                    override fun onPlayerStateChanged(playWhenReady: Boolean, playbackState: Int) {
                        when (playbackState) {
                            Player.STATE_BUFFERING -> Log.d(TAG, "Buffering...")
                            Player.STATE_READY -> Log.d(TAG, "Ready to play.")
                            Player.STATE_ENDED -> {
                                Log.d(TAG, "Playback ended.")
                                stopListening()
                                exoPlayer?.seekTo(0)
                                exoPlayer?.pause()
                                sendPlayerEndedToFlutter()
                            }

                            else -> Log.d(TAG, "Player state: $playbackState")
                        }
                    }
                })
            }
        } catch (e: Exception) {
            throw Exception("Failed to initialize ExoPlayer: ${e.message}")
        }
    }

    /**
     * Sends a message to Flutter when the player has ended.
     */
    private fun sendPlayerEndedToFlutter() {
        channel.invokeMethod("playerEnded", null)
    }



    /**
     * Sends the current playback position to Flutter.
     */
    private fun sendCurrentDuration(result: MethodChannel.Result) {
        try {
            exoPlayer?.let {
                val currentDuration = it.currentPosition
                result.success(currentDuration)
            } ?: run {
                result.error("DURATION_ERROR", "Player is not initialized", null)
            }
        } catch (e: Exception) {
            result.error("DURATION_ERROR", "Failed to get current duration", e.toString())
        }
    }

    /*
    * Sends the current playback position to Flutter.
    */
    private fun sendCurrentDurationToFlutter() {
        val currentPosition = exoPlayer?.currentPosition ?: 0
        channel.invokeMethod("currentDuration", currentPosition)
    }

    /**
     * Listens to ExoPlayer's progress and sends updates to Flutter.
     */
    private fun startListening() {
        runnable = object : Runnable {
            override fun run() {
                exoPlayer?.let {
                    sendCurrentDurationToFlutter()
                }
                handler.postDelayed(this, updateFrequency)
            }
        }
        handler.postDelayed(runnable!!, updateFrequency)
    }

    /**
     * Stops listening to ExoPlayer's progress.
     */
    private fun stopListening() {
        runnable?.let {
            handler.removeCallbacks(it)
            sendCurrentDurationToFlutter()
        }
    }

    /**
     * Releases all resources including the MediaCodec decoder and ExoPlayer.
     * Can be called from any thread.
     */
    private fun cleanupResources() {
        decoder?.let {
            try {
                it.stop()
                it.release()
            } catch (e: Exception) {
                Log.e(TAG, "Error releasing decoder: ${e.message}")
            }
            decoder = null
        }

        extractor?.let {
            try {
                it.release()
            } catch (e: Exception) {
                Log.e(TAG, "Error releasing extractor: ${e.message}")
            }
            extractor = null
        }

        // Release ExoPlayer on main thread
        if (exoPlayer != null) {
            val player = exoPlayer
            handler.post {
                try {
                    player?.release()
                } catch (e: Exception) {
                    Log.e(TAG, "Error releasing ExoPlayer: ${e.message}")
                }
                exoPlayer = null
            }
        }
    }

    override fun onDetachedFromEngine(binding: FlutterPlugin.FlutterPluginBinding) {
        cleanupResources()
        channel.setMethodCallHandler(null)
    }

    companion object {
        private const val TIMEOUT_US = 10000L
    }
}
