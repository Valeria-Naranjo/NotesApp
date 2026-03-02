import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter_application_deux/models/note.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class NotesService {
  static const String baseUrl = 'http://localhost:3000/api/v1';

  // Tomamos el token de Supabase directamente
  String? get _token => Supabase.instance.client.auth.currentSession?.accessToken;

  Map<String, String> get _headers => {
    'Content-Type': 'application/json',
    'Authorization': 'Bearer $_token',
  };

  Future<List<Note>> getNotes() async {
    final response = await http.get(
      Uri.parse('$baseUrl/notes'),
      headers: _headers,
    );

    if (response.statusCode == 200) {
      final List<dynamic> data = jsonDecode(response.body);
      return data.map((map) => Note.fromMap(map)).toList();
    }
    return [];
  }

    Future<void> addNote(String title, String content, DateTime? reminder, {String? imageUrl}) async {
     await http.post(
       Uri.parse('$baseUrl/notes'),
       headers: _headers,
       body: jsonEncode({
         'note': {
           'title': title,
           'content': content,
           'reminder': reminder?.toIso8601String(),
           'image_url': imageUrl, // campo nuevo
         }
       }),
     );
    }
    
     Future<void> deleteNote(String id) async {
    await http.delete(
      Uri.parse('$baseUrl/notes/$id'),
      headers: _headers,
    );
  }
}