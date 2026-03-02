import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter_application_deux/models/event.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class EventService {
  static const String baseUrl = 'http://localhost:3000/api/v1';

  String? get _token =>
      Supabase.instance.client.auth.currentSession?.accessToken;

  Map<String, String> get _headers => {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $_token',
      };

  Future<List<Event>> getEvents() async {
    final response = await http.get(
      Uri.parse('$baseUrl/events'),
      headers: _headers,
    );

    if (response.statusCode == 200) {
      final List<dynamic> data = jsonDecode(response.body);
      return data.map((map) => Event.fromMap(map)).toList();
    } else if (response.statusCode == 401) {
      throw Exception('Sesión expirada');
    }
    throw Exception('Error al obtener eventos');
  }

  Future<bool> createEvent({
    required String title,
    required String description,
    required DateTime date,
    DateTime? reminder,
  }) async {
    final response = await http.post(
      Uri.parse('$baseUrl/events'),
      headers: _headers,
      body: jsonEncode({
        'event': {
          'title': title,
          'description': description,
          'date': date.toIso8601String(),
          'reminder': reminder?.toIso8601String(),
        }
      }),
    );
    return response.statusCode == 201;
  }

  Future<bool> updateEvent({
    required String id,
    required String title,
    required String description,
    required DateTime date,
    DateTime? reminder,
  }) async {
    final response = await http.put(
      Uri.parse('$baseUrl/events/$id'),
      headers: _headers,
      body: jsonEncode({
        'event': {
          'title': title,
          'description': description,
          'date': date.toIso8601String(),
          'reminder': reminder?.toIso8601String(),
        }
      }),
    );
    return response.statusCode == 200;
  }

  Future<bool> deleteEvent(String id) async {
    final response = await http.delete(
      Uri.parse('$baseUrl/events/$id'),
      headers: _headers,
    );
    return response.statusCode == 200;
  }
}