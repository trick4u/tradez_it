import 'package:http/http.dart' as http;
import 'dart:convert';

import '../models/dashboard_metric_model.dart';

class CalendarApiClient {
  final String baseUrl;
  final String bearerToken;
  final http.Client _httpClient;

  CalendarApiClient({
    required this.baseUrl,
    required this.bearerToken,
    http.Client? httpClient,
  }) : _httpClient = httpClient ?? http.Client();

  Future<List<dynamic>> fetchCalendarData({
    required String accountId,
    required String startDate,
    required String endDate,
  }) async {
    try {
      final response = await _httpClient.post(
        Uri.parse('$baseUrl/api/v1/reports/calendar-data/'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $bearerToken',
        },
        body: jsonEncode({
          'account_id': accountId,
          'start_date': startDate,
          'end_date': endDate,
        }),
      );

      if (response.statusCode == 200) {
        final Map<String, dynamic> body = jsonDecode(response.body);
        if (body['status'] == 'success') {
          return body['data']['daily_trades'] as List<dynamic>;
        } else {
          throw Exception(body['message'] ?? 'Unknown error occurred');
        }
      } else {
        throw Exception(
          'Failed to fetch calendar data: ${response.statusCode}',
        );
      }
    } catch (e) {
      throw Exception('Error fetching calendar data: $e');
    } finally {
      // Note: Do not close _httpClient here as it is managed by MainApiClient
    }
  }

  Future<DashBoardMetricModel> fetchDashBoardMetrics({
    required String accountId,
    required String startDate,
    required String endDate,
  }) async {
    try {
      final response = await _httpClient.post(
        Uri.parse('$baseUrl/api/v1/reports/dashboard-metrics/'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $bearerToken',
        },
        body: jsonEncode({
          'account_id': accountId,
          'start_date': startDate,
          'end_date': endDate,
        }),
      );

      if (response.statusCode == 200) {
        final Map<String, dynamic> body = jsonDecode(response.body);
        if (body['status'] == 'success') {
          return DashBoardMetricModel.fromJson(body);
        } else {
          throw Exception(body['message'] ?? 'Unknown error occurred');
        }
      } else {
        throw Exception(
          'Failed to fetch dashboard metrics: ${response.statusCode}',
        );
      }
    } catch (e) {
      throw Exception('Error fetching dashboard metrics: $e');
    } finally {
      // Note: Do not close _httpClient here as it is managed by MainApiClient
    }
  }

  
}
