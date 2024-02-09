import 'package:flutter/material.dart';
import 'package:speech_to_text/speech_to_text.dart';
import 'package:googleapis_auth/auth_io.dart';
import 'package:googleapis/dialogflow/v3.dart';
import 'dart:convert';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:flutter_tts/flutter_tts.dart';
import 'package:flutter/services.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final SpeechToText _speechToText = SpeechToText();
  final FlutterTts _flutterTts = FlutterTts();

  List<Map> _voices = [];
  Map? _currentVoice;

  int? _currentWordStart, _currentWordEnd;

  bool _speechEnabled = false;

  String _wordsSpoken = "";
  double _confidenceLevel = 0;

  @override
  void initState() {
    super.initState();

    initSpeech();
    initTTS();
  }

  void initTTS() {
    _flutterTts.setProgressHandler((text, start, end, word) {
      setState(() {
        _currentWordStart = start;
        _currentWordEnd = end;
      });
    });
    _flutterTts.getVoices.then((data) {
      try {
        List<Map> voices = List<Map>.from(data);
        setState(() {
          _voices =
              voices.where((voice) => voice["name"].contains("es")).toList();
          _currentVoice = _voices.first;
          setVoice(_currentVoice!);
        });
      } catch (e) {
        print(e);
      }
    });
  }

  void setVoice(Map voice) {
    _flutterTts.setVoice({"name": voice["name"], "locale": voice["locale"]});
  }

  void getAuthClient() async {
    //get json file from assets folder
    String jsonString =
        await rootBundle.loadString('grand-cosmos-413120-de3d5444e3c5.json');
    Map<String, dynamic> jsonMap = json.decode(jsonString);
    final credentials = ServiceAccountCredentials.fromJson(jsonMap);

    final client = await clientViaServiceAccount(
        credentials, ['https://www.googleapis.com/auth/cloud-platform']);
    DialogflowApi dialogflow = DialogflowApi(client,
        rootUrl: 'https://us-central1-dialogflow.googleapis.com/');
    GoogleCloudDialogflowCxV3DetectIntentResponse response =
        await dialogflow.projects.locations.agents.sessions.detectIntent(
            GoogleCloudDialogflowCxV3DetectIntentRequest.fromJson({
              "queryInput": {
                "text": {"text": "Ver Planes"},
                "languageCode": "en"
              },
              "queryParams": {"timeZone": "America/Los_Angeles"}
            }),
            'projects/grand-cosmos-413120/locations/us-central1/agents/6d6c016a-73a1-4f18-9f4f-d9cdfcb47466/sessions/1234567890');
    print(response.queryResult!.responseMessages?[0].text?.text?[0]);
  }

  void initSpeech() async {
    _speechEnabled = await _speechToText.initialize();
    setState(() {});
  }

  void _startListening() async {
    await _speechToText.listen(onResult: _onSpeechResult);
    setState(() {
      _confidenceLevel = 0;
    });
  }

  void _stopListening() async {
    await _speechToText.stop();
    setState(() {});
  }

  void _onSpeechResult(result) {
    setState(() {
      _wordsSpoken = "${result.recognizedWords}";
      _confidenceLevel = result.confidence;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.amberAccent,
        title: const Text(
          'Carreras.com Chatbot',
          style: TextStyle(
            color: Colors.white,
          ),
        ),
      ),
      body: Center(
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.all(16),
              child: Text(
                _speechToText.isListening
                    ? "Escuchando..."
                    : _speechEnabled
                        ? "Toca el botón de micrófono para empezar a escuchar..."
                        : "Micrófono no disponible",
                style: const TextStyle(fontSize: 20.0),
              ),
            ),
            Expanded(
              child: Container(
                padding: const EdgeInsets.all(16),
                child: Text(
                  _wordsSpoken,
                  style: const TextStyle(
                    fontSize: 25,
                    fontWeight: FontWeight.w300,
                  ),
                ),
              ),
            ),
            if (_speechToText.isNotListening && _confidenceLevel > 0)
              Padding(
                padding: const EdgeInsets.only(
                  bottom: 100,
                ),
                child: Text(
                  "Confiabilidad: ${(_confidenceLevel * 100).toStringAsFixed(1)}%",
                  style: const TextStyle(
                    fontSize: 30,
                    fontWeight: FontWeight.w200,
                  ),
                ),
              )
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: getAuthClient,
        tooltip: 'Listen',
        backgroundColor: Colors.amberAccent,
        child: Icon(
          _speechToText.isNotListening ? Icons.mic_off : Icons.mic,
          color: Colors.white,
        ),
      ),
    );
  }
}
