part of 'dialogflow_bloc.dart';

sealed class DialogflowEvent extends Equatable {
  const DialogflowEvent();

  @override
  List<Object> get props => [];
}

class OnStartClient extends DialogflowEvent {
  final AutoRefreshingAuthClient httpClient;

  const OnStartClient(this.httpClient);

  @override
  List<Object> get props => [httpClient];
}

class OnStartDialogflowApi extends DialogflowEvent {
  final DialogflowApi dialogflowApi;

  const OnStartDialogflowApi(this.dialogflowApi);

  @override
  List<Object> get props => [dialogflowApi];
}

class OnResponse extends DialogflowEvent {
  final String response;

  const OnResponse(this.response);

  @override
  List<Object> get props => [response];
}
