import 'package:http/http.dart' as http;

import 'data/repositories/calendar_api_client.dart';

import 'package:http/http.dart' as http;

import 'data/repositories/calendar_api_client.dart';

class MainApiClient {
  final String baseUrl;
  final String bearerToken;
  final String accountId; // Add accountId here
  final http.Client _httpClient;

  late final CalendarApiClient calendarApiClient;

  MainApiClient({
    required this.baseUrl,
    required this.bearerToken,
    required this.accountId, // Require accountId
    http.Client? httpClient,
  }) : _httpClient = httpClient ?? http.Client() {
    // Initialize API clients
    calendarApiClient = CalendarApiClient(
      baseUrl: baseUrl,
      bearerToken: bearerToken,
      httpClient: _httpClient,
    );
  }

  // Dispose method to clean up resources
  void dispose() {
    _httpClient.close();
  }
}