import 'package:bloc/bloc.dart';
import 'dart:convert';
import 'package:flutter/services.dart' show rootBundle;
import 'package:equatable/equatable.dart';
import 'package:meta/meta.dart';
import 'package:googleapis/dialogflow/v3.dart';
import 'package:googleapis_auth/auth_io.dart';
import 'package:http/http.dart' as http;
part 'dialogflow_event.dart';
part 'dialogflow_state.dart';

class DialogflowBloc extends Bloc<DialogflowEvent, DialogflowState> {
  DialogflowBloc() : super(DialogflowState()) {
    on<OnStartClient>((event, emit) {
      emit(state.copyWith(httpClient: event.httpClient));
    });

    on<OnStartDialogflowApi>((event, emit) {
      emit(state.copyWith(dialogflowApi: event.dialogflowApi));
    });
    on<OnResponse>((event, emit) {
      emit(state.copyWith(response: event.response));
    });
  }

  // StartClient() async {}

  startDialogflowApi() async {
    String jsonString = await rootBundle.loadString('assets/apiKey.json');

    Map<String, dynamic> jsonMap = json.decode(jsonString);

    // Pasa el mapa a la función fromJson
    final credentials = ServiceAccountCredentials.fromJson(jsonMap);
    final cliente = await clientViaServiceAccount(
        credentials, ['https://www.googleapis.com/auth/cloud-platform']);
    add(OnStartClient(cliente));
    DialogflowApi dialogflowApi = DialogflowApi(cliente,
        rootUrl: 'https://us-central1-dialogflow.googleapis.com/');
    add(OnStartDialogflowApi(dialogflowApi));
  }

  start() async {
    startDialogflowApi();
  }

  Future<String> sendMessage(String message) async {
    print(state.dialogflowApi);
    GoogleCloudDialogflowCxV3DetectIntentResponse response = await state
        .dialogflowApi!.projects.locations.agents.sessions
        .detectIntent(
            GoogleCloudDialogflowCxV3DetectIntentRequest.fromJson({
              "queryInput": {
                "text": {"text": message.toLowerCase()},
                "languageCode": "en"
              },
              "queryParams": {"timeZone": "America/Barbados"}
            }),
            "projects/ihc-voice-app/locations/us-central1/agents/d76a9b06-4647-45c0-a246-f320496b08bd/sessions/1234567899");
    String strResponse = "";

    // for on list of responseMessages
    response.queryResult?.responseMessages?.forEach((responseMessage) {
      responseMessage.text?.text?.forEach((text) {
        strResponse += "$text/n";
      });
    });

    print("Envio: " + message);
    print("Respuesta:  $strResponse");
    return strResponse;
  }
}
