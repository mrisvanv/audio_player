// Mocks generated by Mockito 5.4.4 from annotations
// in audio_player/test/widget_test/home_page/home_page_test.dart.
// Do not manually edit this file.

// ignore_for_file: no_leading_underscores_for_library_prefixes
import 'dart:async' as _i6;

import 'package:audio_player/blocs/audio_player/audio_player_bloc.dart' as _i5;
import 'package:audio_player/blocs/audio_player/audio_player_event.dart' as _i7;
import 'package:audio_player/blocs/audio_player/audio_player_state.dart' as _i4;
import 'package:audio_player/services/audio_service.dart' as _i2;
import 'package:audio_waveforms/audio_waveforms.dart' as _i3;
import 'package:flutter_bloc/flutter_bloc.dart' as _i8;
import 'package:mockito/mockito.dart' as _i1;

// ignore_for_file: type=lint
// ignore_for_file: avoid_redundant_argument_values
// ignore_for_file: avoid_setters_without_getters
// ignore_for_file: comment_references
// ignore_for_file: deprecated_member_use
// ignore_for_file: deprecated_member_use_from_same_package
// ignore_for_file: implementation_imports
// ignore_for_file: invalid_use_of_visible_for_testing_member
// ignore_for_file: prefer_const_constructors
// ignore_for_file: unnecessary_parenthesis
// ignore_for_file: camel_case_types
// ignore_for_file: subtype_of_sealed_class

class _FakeAudioService_0 extends _i1.SmartFake implements _i2.AudioService {
  _FakeAudioService_0(
    Object parent,
    Invocation parentInvocation,
  ) : super(
          parent,
          parentInvocation,
        );
}

class _FakePlayerController_1 extends _i1.SmartFake implements _i3.PlayerController {
  _FakePlayerController_1(
    Object parent,
    Invocation parentInvocation,
  ) : super(
          parent,
          parentInvocation,
        );
}

class _FakeAudioPlayerState_2 extends _i1.SmartFake implements _i4.AudioPlayerState {
  _FakeAudioPlayerState_2(
    Object parent,
    Invocation parentInvocation,
  ) : super(
          parent,
          parentInvocation,
        );
}

/// A class which mocks [AudioPlayerBloc].
///
/// See the documentation for Mockito's code generation for more information.
class MockAudioPlayerBloc extends _i1.Mock implements _i5.AudioPlayerBloc {
  MockAudioPlayerBloc() {
    _i1.throwOnMissingStub(this);
  }

  @override
  _i2.AudioService get audioService => (super.noSuchMethod(
        Invocation.getter(#audioService),
        returnValue: _FakeAudioService_0(
          this,
          Invocation.getter(#audioService),
        ),
      ) as _i2.AudioService);

  @override
  _i3.PlayerController get playerController => (super.noSuchMethod(
        Invocation.getter(#playerController),
        returnValue: _FakePlayerController_1(
          this,
          Invocation.getter(#playerController),
        ),
      ) as _i3.PlayerController);

  @override
  _i4.AudioPlayerState get state => (super.noSuchMethod(
        Invocation.getter(#state),
        returnValue: _FakeAudioPlayerState_2(
          this,
          Invocation.getter(#state),
        ),
      ) as _i4.AudioPlayerState);

  @override
  _i6.Stream<_i4.AudioPlayerState> get stream => (super.noSuchMethod(
        Invocation.getter(#stream),
        returnValue: _i6.Stream<_i4.AudioPlayerState>.empty(),
      ) as _i6.Stream<_i4.AudioPlayerState>);

  @override
  bool get isClosed => (super.noSuchMethod(
        Invocation.getter(#isClosed),
        returnValue: false,
      ) as bool);

  @override
  _i6.Future<void> close() => (super.noSuchMethod(
        Invocation.method(
          #close,
          [],
        ),
        returnValue: _i6.Future<void>.value(),
        returnValueForMissingStub: _i6.Future<void>.value(),
      ) as _i6.Future<void>);

  @override
  void add(_i7.AudioPlayerEvent? event) => super.noSuchMethod(
        Invocation.method(
          #add,
          [event],
        ),
        returnValueForMissingStub: null,
      );

  @override
  void onEvent(_i7.AudioPlayerEvent? event) => super.noSuchMethod(
        Invocation.method(
          #onEvent,
          [event],
        ),
        returnValueForMissingStub: null,
      );

  @override
  void emit(_i4.AudioPlayerState? state) => super.noSuchMethod(
        Invocation.method(
          #emit,
          [state],
        ),
        returnValueForMissingStub: null,
      );

  @override
  void on<E extends _i7.AudioPlayerEvent>(
    _i8.EventHandler<E, _i4.AudioPlayerState>? handler, {
    _i8.EventTransformer<E>? transformer,
  }) =>
      super.noSuchMethod(
        Invocation.method(
          #on,
          [handler],
          {#transformer: transformer},
        ),
        returnValueForMissingStub: null,
      );

  @override
  void onTransition(_i8.Transition<_i7.AudioPlayerEvent, _i4.AudioPlayerState>? transition) => super.noSuchMethod(
        Invocation.method(
          #onTransition,
          [transition],
        ),
        returnValueForMissingStub: null,
      );

  @override
  void onChange(_i8.Change<_i4.AudioPlayerState>? change) => super.noSuchMethod(
        Invocation.method(
          #onChange,
          [change],
        ),
        returnValueForMissingStub: null,
      );

  @override
  void addError(
    Object? error, [
    StackTrace? stackTrace,
  ]) =>
      super.noSuchMethod(
        Invocation.method(
          #addError,
          [
            error,
            stackTrace,
          ],
        ),
        returnValueForMissingStub: null,
      );

  @override
  void onError(
    Object? error,
    StackTrace? stackTrace,
  ) =>
      super.noSuchMethod(
        Invocation.method(
          #onError,
          [
            error,
            stackTrace,
          ],
        ),
        returnValueForMissingStub: null,
      );
}
