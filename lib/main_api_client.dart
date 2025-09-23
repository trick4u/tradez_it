import 'package:http/http.dart' as http;

import 'data/repositories/calendar_api_client.dart';

class MainApiClient {
  final String baseUrl;
  final String bearerToken;
  final http.Client _httpClient;

  late final CalendarApiClient calendarApiClient;


  MainApiClient({
    required this.baseUrl,
    required this.bearerToken,
    http.Client? httpClient,
  }) : _httpClient = httpClient ?? http.Client() {
    // Initialize API clients
    calendarApiClient = CalendarApiClient(
      baseUrl: baseUrl,
      bearerToken: bearerToken,
      httpClient: _httpClient,
    );
    // Initialize other API clients here as needed
  }

  // Dispose method to clean up resources
  void dispose() {
    _httpClient.close();
  }
}