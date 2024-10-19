// Mocks generated by Mockito 5.4.4 from annotations
// in audio_player/test/unit_test/audio_service/audio_service_test.dart.
// Do not manually edit this file.

// ignore_for_file: no_leading_underscores_for_library_prefixes
import 'dart:async' as _i5;
import 'dart:io' as _i3;

import 'package:audio_player/repositories/audio/audio_repository_impl.dart' as _i4;
import 'package:http/http.dart' as _i2;
import 'package:mockito/mockito.dart' as _i1;
import 'package:mockito/src/dummies.dart' as _i6;

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

class _FakeClient_0 extends _i1.SmartFake implements _i2.Client {
  _FakeClient_0(
    Object parent,
    Invocation parentInvocation,
  ) : super(
          parent,
          parentInvocation,
        );
}

class _FakeFile_1 extends _i1.SmartFake implements _i3.File {
  _FakeFile_1(
    Object parent,
    Invocation parentInvocation,
  ) : super(
          parent,
          parentInvocation,
        );
}

class _FakeUri_2 extends _i1.SmartFake implements Uri {
  _FakeUri_2(
    Object parent,
    Invocation parentInvocation,
  ) : super(
          parent,
          parentInvocation,
        );
}

class _FakeDirectory_3 extends _i1.SmartFake implements _i3.Directory {
  _FakeDirectory_3(
    Object parent,
    Invocation parentInvocation,
  ) : super(
          parent,
          parentInvocation,
        );
}

class _FakeFileSystemEntity_4 extends _i1.SmartFake implements _i3.FileSystemEntity {
  _FakeFileSystemEntity_4(
    Object parent,
    Invocation parentInvocation,
  ) : super(
          parent,
          parentInvocation,
        );
}

class _FakeFileStat_5 extends _i1.SmartFake implements _i3.FileStat {
  _FakeFileStat_5(
    Object parent,
    Invocation parentInvocation,
  ) : super(
          parent,
          parentInvocation,
        );
}

/// A class which mocks [AudioRepositoryImpl].
///
/// See the documentation for Mockito's code generation for more information.
class MockAudioRepositoryImpl extends _i1.Mock implements _i4.AudioRepositoryImpl {
  MockAudioRepositoryImpl() {
    _i1.throwOnMissingStub(this);
  }

  @override
  _i2.Client get client => (super.noSuchMethod(
        Invocation.getter(#client),
        returnValue: _FakeClient_0(
          this,
          Invocation.getter(#client),
        ),
      ) as _i2.Client);

  @override
  set client(_i2.Client? _client) => super.noSuchMethod(
        Invocation.setter(
          #client,
          _client,
        ),
        returnValueForMissingStub: null,
      );

  @override
  _i5.Future<_i3.File> getAudio({
    required String? fileName,
    required _i3.Directory? tempDirectory,
    void Function(double)? onProgress,
  }) =>
      (super.noSuchMethod(
        Invocation.method(
          #getAudio,
          [],
          {
            #fileName: fileName,
            #tempDirectory: tempDirectory,
            #onProgress: onProgress,
          },
        ),
        returnValue: _i5.Future<_i3.File>.value(_FakeFile_1(
          this,
          Invocation.method(
            #getAudio,
            [],
            {
              #fileName: fileName,
              #tempDirectory: tempDirectory,
              #onProgress: onProgress,
            },
          ),
        )),
      ) as _i5.Future<_i3.File>);
}

/// A class which mocks [Directory].
///
/// See the documentation for Mockito's code generation for more information.
class MockDirectory extends _i1.Mock implements _i3.Directory {
  MockDirectory() {
    _i1.throwOnMissingStub(this);
  }

  @override
  String get path => (super.noSuchMethod(
        Invocation.getter(#path),
        returnValue: _i6.dummyValue<String>(
          this,
          Invocation.getter(#path),
        ),
      ) as String);

  @override
  Uri get uri => (super.noSuchMethod(
        Invocation.getter(#uri),
        returnValue: _FakeUri_2(
          this,
          Invocation.getter(#uri),
        ),
      ) as Uri);

  @override
  _i3.Directory get absolute => (super.noSuchMethod(
        Invocation.getter(#absolute),
        returnValue: _FakeDirectory_3(
          this,
          Invocation.getter(#absolute),
        ),
      ) as _i3.Directory);

  @override
  bool get isAbsolute => (super.noSuchMethod(
        Invocation.getter(#isAbsolute),
        returnValue: false,
      ) as bool);

  @override
  _i3.Directory get parent => (super.noSuchMethod(
        Invocation.getter(#parent),
        returnValue: _FakeDirectory_3(
          this,
          Invocation.getter(#parent),
        ),
      ) as _i3.Directory);

  @override
  _i5.Future<_i3.Directory> create({bool? recursive = false}) => (super.noSuchMethod(
        Invocation.method(
          #create,
          [],
          {#recursive: recursive},
        ),
        returnValue: _i5.Future<_i3.Directory>.value(_FakeDirectory_3(
          this,
          Invocation.method(
            #create,
            [],
            {#recursive: recursive},
          ),
        )),
      ) as _i5.Future<_i3.Directory>);

  @override
  void createSync({bool? recursive = false}) => super.noSuchMethod(
        Invocation.method(
          #createSync,
          [],
          {#recursive: recursive},
        ),
        returnValueForMissingStub: null,
      );

  @override
  _i5.Future<_i3.Directory> createTemp([String? prefix]) => (super.noSuchMethod(
        Invocation.method(
          #createTemp,
          [prefix],
        ),
        returnValue: _i5.Future<_i3.Directory>.value(_FakeDirectory_3(
          this,
          Invocation.method(
            #createTemp,
            [prefix],
          ),
        )),
      ) as _i5.Future<_i3.Directory>);

  @override
  _i3.Directory createTempSync([String? prefix]) => (super.noSuchMethod(
        Invocation.method(
          #createTempSync,
          [prefix],
        ),
        returnValue: _FakeDirectory_3(
          this,
          Invocation.method(
            #createTempSync,
            [prefix],
          ),
        ),
      ) as _i3.Directory);

  @override
  _i5.Future<String> resolveSymbolicLinks() => (super.noSuchMethod(
        Invocation.method(
          #resolveSymbolicLinks,
          [],
        ),
        returnValue: _i5.Future<String>.value(_i6.dummyValue<String>(
          this,
          Invocation.method(
            #resolveSymbolicLinks,
            [],
          ),
        )),
      ) as _i5.Future<String>);

  @override
  String resolveSymbolicLinksSync() => (super.noSuchMethod(
        Invocation.method(
          #resolveSymbolicLinksSync,
          [],
        ),
        returnValue: _i6.dummyValue<String>(
          this,
          Invocation.method(
            #resolveSymbolicLinksSync,
            [],
          ),
        ),
      ) as String);

  @override
  _i5.Future<_i3.Directory> rename(String? newPath) => (super.noSuchMethod(
        Invocation.method(
          #rename,
          [newPath],
        ),
        returnValue: _i5.Future<_i3.Directory>.value(_FakeDirectory_3(
          this,
          Invocation.method(
            #rename,
            [newPath],
          ),
        )),
      ) as _i5.Future<_i3.Directory>);

  @override
  _i3.Directory renameSync(String? newPath) => (super.noSuchMethod(
        Invocation.method(
          #renameSync,
          [newPath],
        ),
        returnValue: _FakeDirectory_3(
          this,
          Invocation.method(
            #renameSync,
            [newPath],
          ),
        ),
      ) as _i3.Directory);

  @override
  _i5.Future<_i3.FileSystemEntity> delete({bool? recursive = false}) => (super.noSuchMethod(
        Invocation.method(
          #delete,
          [],
          {#recursive: recursive},
        ),
        returnValue: _i5.Future<_i3.FileSystemEntity>.value(_FakeFileSystemEntity_4(
          this,
          Invocation.method(
            #delete,
            [],
            {#recursive: recursive},
          ),
        )),
      ) as _i5.Future<_i3.FileSystemEntity>);

  @override
  void deleteSync({bool? recursive = false}) => super.noSuchMethod(
        Invocation.method(
          #deleteSync,
          [],
          {#recursive: recursive},
        ),
        returnValueForMissingStub: null,
      );

  @override
  _i5.Stream<_i3.FileSystemEntity> list({
    bool? recursive = false,
    bool? followLinks = true,
  }) =>
      (super.noSuchMethod(
        Invocation.method(
          #list,
          [],
          {
            #recursive: recursive,
            #followLinks: followLinks,
          },
        ),
        returnValue: _i5.Stream<_i3.FileSystemEntity>.empty(),
      ) as _i5.Stream<_i3.FileSystemEntity>);

  @override
  List<_i3.FileSystemEntity> listSync({
    bool? recursive = false,
    bool? followLinks = true,
  }) =>
      (super.noSuchMethod(
        Invocation.method(
          #listSync,
          [],
          {
            #recursive: recursive,
            #followLinks: followLinks,
          },
        ),
        returnValue: <_i3.FileSystemEntity>[],
      ) as List<_i3.FileSystemEntity>);

  @override
  _i5.Future<bool> exists() => (super.noSuchMethod(
        Invocation.method(
          #exists,
          [],
        ),
        returnValue: _i5.Future<bool>.value(false),
      ) as _i5.Future<bool>);

  @override
  bool existsSync() => (super.noSuchMethod(
        Invocation.method(
          #existsSync,
          [],
        ),
        returnValue: false,
      ) as bool);

  @override
  _i5.Future<_i3.FileStat> stat() => (super.noSuchMethod(
        Invocation.method(
          #stat,
          [],
        ),
        returnValue: _i5.Future<_i3.FileStat>.value(_FakeFileStat_5(
          this,
          Invocation.method(
            #stat,
            [],
          ),
        )),
      ) as _i5.Future<_i3.FileStat>);

  @override
  _i3.FileStat statSync() => (super.noSuchMethod(
        Invocation.method(
          #statSync,
          [],
        ),
        returnValue: _FakeFileStat_5(
          this,
          Invocation.method(
            #statSync,
            [],
          ),
        ),
      ) as _i3.FileStat);

  @override
  _i5.Stream<_i3.FileSystemEvent> watch({
    int? events = 15,
    bool? recursive = false,
  }) =>
      (super.noSuchMethod(
        Invocation.method(
          #watch,
          [],
          {
            #events: events,
            #recursive: recursive,
          },
        ),
        returnValue: _i5.Stream<_i3.FileSystemEvent>.empty(),
      ) as _i5.Stream<_i3.FileSystemEvent>);
}
