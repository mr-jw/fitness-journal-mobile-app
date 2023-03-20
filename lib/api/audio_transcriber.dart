import 'dart:io';
import 'package:flutter/services.dart';
import 'package:google_speech/google_speech.dart';

class AudioTranscriber {
  bool _isTranscribing = false;
  String _transcribedMessage = '';

  bool isTranscribing() {
    return _isTranscribing;
  }

  Future transcribe(String audioSource) async {
    _isTranscribing = true;

    // link service account json
    final serviceAccount = ServiceAccount.fromString((await rootBundle
        .loadString('assets/service_account/service-account-file.json')));

    final speechToText = SpeechToText.viaServiceAccount(serviceAccount);

    final config = RecognitionConfig(
        encoding: AudioEncoding.LINEAR16,
        model: RecognitionModel.basic,
        enableAutomaticPunctuation: true,
        sampleRateHertz: 44100,
        languageCode: 'en-US');

    final audio = await _getAudioContent(audioSource);

    await speechToText.recognize(config, audio).then((value) {
      _transcribedMessage =
          value.results.map((e) => e.alternatives.first.transcript).join('');
    }).whenComplete(() {
      _isTranscribing = false;
    });
  }

  Future<List<int>> _getAudioContent(String name) async {
    return File(name).readAsBytesSync().toList();
  }

  String getTranscribedMessage() {
    return _transcribedMessage;
  }
}
