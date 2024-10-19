# Audio Player with Equalizer Visualization

A Flutter application that plays MP3 files with an interactive equalizer effect.

## Overview

This project showcases a full-featured audio player built using Flutter. It allows users to stream and play audio files with an eye-catching equalizer visualization that dynamically reacts to the sound frequencies. The player offers basic playback control and an engaging UI experience.

## Key Features

- **Audio Streaming**: Stream MP3 files from a provided URL using the `http` package.
- **Playback Controls**: Easily play or pause the audio with intuitive controls.
- **Real-Time Equalizer**: Visualize audio frequencies in real-time with smooth and fluid animations.
- **Playback Progress**: A progress bar tracks and displays the current playback status.
- **State Management**: Managed by the `flutter_bloc` package, ensuring a robust and maintainable state structure.

## Screenshots

<div style="display: flex; justify-content: space-around; flex-wrap: wrap;">
  <img src="https://github.com/mrisvanv/audio_player/blob/master/assets/images/downloading.jpg" alt="Downloading" width="25%" />
  <img src="https://github.com/mrisvanv/audio_player/blob/master/assets/images/playing.jpg" alt="Playing" width="25%" />
  <img src="https://github.com/mrisvanv/audio_player/blob/master/assets/images/paused.jpg" alt="Paused" width="25%" />
  <img src="https://github.com/mrisvanv/audio_player/blob/master/assets/images/error.jpg" alt="Error" width="25%" />
</div>

## Installation & Setup

Follow the instructions below to set up and run the application:

1. **Clone the repository**:
   ```bash
   git clone https://github.com/mrisvanv/audio_player.git
   cd audio_player
   ```

2. **Install required dependencies**:
   ```bash
   fvm flutter pub get
   ```

3. **Build the APK**:
   ```bash
   fvm flutter build apk
   ```

## Project Focus Areas

- **UI Design Fidelity**: Ensures accurate implementation of design specifications, including colors, spacing, and layout structure.
- **API Integration**: Correctly integrates APIs for audio streaming, handling loading states, and error conditions smoothly.
- **State Management**: Follows the BLoC pattern for consistent state transitions, providing a reliable user experience.
- **Code Quality**: Prioritizes clean, maintainable code, following Dart and Flutter best practices. The project structure is modular and well-documented for easy extensibility.
- **Enhanced Animations**: Features a polished equalizer animation for a seamless visual experience.
- **Testing**: Includes unit, widget, and integration tests to ensure the reliability and stability of the application.

## Future Enhancements

- Add features like playlists, shuffle, and repeat functionality.
- Support additional audio sources, such as local files and other streaming platforms.

## License

This project is licensed under the MIT License. Refer to the LICENSE file for more details.
