import 'package:flutter/material.dart';
import 'package:flutter_application_deux/models/note.dart';
import 'package:flutter_application_deux/services/notes_service.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final NotesService _notesService = NotesService();
  List<Note> notes = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadNotes();
  }

  Future<void> _loadNotes() async {
    setState(() => isLoading = true);
    final result = await _notesService.getNotes();
    setState(() {
      notes = result;
      isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Mis Notas')),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _addNote(context),
        child: const Icon(Icons.add),
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : notes.isEmpty
              ? const Center(
                  child: Text('No tienes notas aún. ¡Agrega una!',
                    style: TextStyle(fontSize: 18),
                  ),
                )
              : ListView.builder(
                  itemCount: notes.length,
                  itemBuilder: (context, index) {
                    final note = notes[index];
                    return ListTile(
                      title: Text(note.title),
                      subtitle: note.reminder != null
                          ? Text('Recordatorio: ${note.reminder}',
                              style: const TextStyle(color: Colors.red))
                          : null,
                      trailing: IconButton(
                        icon: const Icon(Icons.delete),
                        onPressed: () async {
                          await _notesService.deleteNote(note.id);
                          _loadNotes();
                        },
                      ),
                    );
                  },
                ),
    );
  }

  void _addNote(BuildContext context) async {
    final titleController = TextEditingController();
    final contentController = TextEditingController();
    DateTime? reminder;

    await showDialog(
      context: context,
      builder: (_) {
        return AlertDialog(
          title: const Text('Nueva Nota'),
          content: SingleChildScrollView(
            child: Column(
              children: [
                TextField(
                  controller: titleController,
                  decoration: const InputDecoration(labelText: 'Título'),
                ),
                const SizedBox(height: 8),
                TextField(
                  controller: contentController,
                  decoration: const InputDecoration(labelText: 'Contenido'),
                  maxLines: 3,
                ),
                const SizedBox(height: 12),
                ElevatedButton(
                  onPressed: () async {
                    final date = await showDatePicker(
                      context: context,
                      firstDate: DateTime.now(),
                      lastDate: DateTime(2100),
                      initialDate: DateTime.now(),
                    );
                    if (date == null) return;
                    final time = await showTimePicker(
                      context: context,
                      initialTime: TimeOfDay.now(),
                    );
                    if (time == null) return;
                    reminder = DateTime(
                      date.year, date.month, date.day,
                      time.hour, time.minute,
                    );
                  },
                  child: const Text('Agregar recordatorio'),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancelar'),
            ),
            ElevatedButton(
              onPressed: () async {
                if (titleController.text.isEmpty) return;
                await _notesService.addNote(
                  titleController.text,
                  contentController.text,
                  reminder,
                );
                if (context.mounted) Navigator.pop(context);
                _loadNotes();
              },
              child: const Text('Guardar'),
            ),
          ],
        );
      },
    );
  }
}