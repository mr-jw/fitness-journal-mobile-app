import 'package:permission_handler/permission_handler.dart';
import 'package:flutter_sound_lite/flutter_sound.dart';
import 'package:path_provider/path_provider.dart';

import 'dart:io';
import 'dart:typed_data';

class SoundRecorder {
  // sound recorder attributes.
  FlutterSoundRecorder? _audioRecorder;
  bool _isRecorderInitialised = false;
  bool get isRecording => _audioRecorder!.isRecording;
  bool finishedRecording = false;

  // file storage attributes.
  String completePath = "";
  String directoryPath = "";
  String filename = "audio-file";

  Future init() async {
    _audioRecorder = FlutterSoundRecorder();

    final statusMic = await Permission.microphone.request();
    if (statusMic != PermissionStatus.granted) {
      throw RecordingPermissionException('Microphone permission not granted');
    }

    final statusStorage = await Permission.storage.request();
    if (statusStorage != PermissionStatus.granted) {
      throw Exception('Storage permission required.');
    }

    await _audioRecorder!.openAudioSession();

    // initialise directory.
    directoryPath = await _directoryPath();
    completePath = await _completePath(directoryPath);

    _createDirectory();
    _createFile();

    // initialisation complete...
    _isRecorderInitialised = true;
    finishedRecording = false;
  }

  void dispose() {
    if (!_isRecorderInitialised) return;
    _audioRecorder!.closeAudioSession();
    _audioRecorder = null;
    _isRecorderInitialised = false;
  }

  Future record() async {
    if (!_isRecorderInitialised) return;
    await _audioRecorder!.startRecorder(
      toFile: completePath,
      numChannels: 1,
      sampleRate: 44100,
    );
  }

  Future stop() async {
    if (!_isRecorderInitialised) return;
    await _audioRecorder!.stopRecorder();
  }

  Future toggleRecording() async {
    if (_audioRecorder!.isStopped) {
      finishedRecording = false;
      await record();
    } else {
      finishedRecording = true;
      await stop();
    }
  }

  bool hasFinishedRecording() {
    return finishedRecording;
  }

  // ----- FILE STORAGE -----

  Future<String> _completePath(String directory) async {
    var fileName = _getFileName();
    return "$directory$fileName";
  }

  Future<String> _directoryPath() async {
    var directory = await getExternalStorageDirectory();
    var directoryPath = directory!.path;
    return "$directoryPath/recordings/";
  }

  String getCompletePath() {
    var fileName = _getFileName();
    return "$directoryPath$fileName";
  }

  String _getFileName() {
    return "$filename.wav";
  }

  void setFileName(String filename) {
    this.filename = filename;
  }

  Future _createFile() async {
    File(completePath).create(recursive: true).then((File file) async {
      // write to file.
      Uint8List bytes = await file.readAsBytes();
      file.writeAsBytes(bytes);
    });
  }

  void _createDirectory() async {
    bool directoryCreated = await Directory(directoryPath).exists();
    if (!directoryCreated) {
      Directory(directoryPath).create().then((Directory directory) {});
    }
  }

  Future changeFileNameOnly(File file, String newFileName) {
    var path = file.path;
    var lastSeparator = path.lastIndexOf(Platform.pathSeparator);
    var newPath = path.substring(0, lastSeparator + 1) + newFileName;
    return file.rename(newPath);
  }
}
