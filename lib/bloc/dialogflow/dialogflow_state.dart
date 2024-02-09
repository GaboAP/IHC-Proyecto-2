part of 'dialogflow_bloc.dart';

class DialogflowState extends Equatable {
  final AutoRefreshingAuthClient? httpClient;
  final DialogflowApi? dialogflowApi;
  final String response;

  const DialogflowState({
    this.httpClient,
    this.dialogflowApi,
    this.response = "",
  });

  DialogflowState copyWith({
    AutoRefreshingAuthClient? httpClient,
    DialogflowApi? dialogflowApi,
    String? response,
  }) =>
      DialogflowState(
        httpClient: httpClient ?? this.httpClient,
        dialogflowApi: dialogflowApi ?? this.dialogflowApi,
        response: response ?? this.response,
      );

  @override
  List<Object?> get props => [httpClient, dialogflowApi, response];
}
