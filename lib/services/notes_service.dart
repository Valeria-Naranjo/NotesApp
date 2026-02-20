import 'package:flutter_application_deux/main.dart';
import 'package:flutter_application_deux/models/note.dart';

class NotesService {

  Future<List<Note>> getNotes() async {
    final userId = supabase.auth.currentUser!.id;

    final response = await supabase
        .from('notes')
        .select()
        .eq('user_id', userId)
        .order('created_at', ascending: false);

    return (response as List).map((map) => Note.fromMap(map)).toList();
  }

  Future<void> addNote(String title, String content, DateTime? reminder) async {
    final userId = supabase.auth.currentUser!.id;

    await supabase.from('notes').insert({
      'user_id': userId,
      'title': title,
      'content': content,
      'reminder': reminder?.toIso8601String(),
    });
  }

  Future<void> deleteNote(String id) async {
    await supabase.from('notes').delete().eq('id', id);
  }
}