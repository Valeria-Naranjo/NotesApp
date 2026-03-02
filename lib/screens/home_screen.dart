import 'package:flutter/material.dart';
import 'package:flutter_application_deux/models/note.dart';
import 'package:flutter_application_deux/services/notes_service.dart';
import 'package:flutter_application_deux/screens/note_detail_screen.dart';
import 'package:flutter_application_deux/services/storage_service.dart';

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
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => NoteDetailScreen(note: note),
                          ),
                        );
                      },
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
  String? imageUrl;
  final storageService = StorageService();

  await showDialog(
    context: context,
    builder: (_) => StatefulBuilder(
      builder: (context, setDialogState) => AlertDialog(
        title: const Text('Nueva Nota'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
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

              // Recordatorio
              ElevatedButton.icon(
                icon: const Icon(Icons.alarm),
                label: Text(reminder != null
                    ? 'Recordatorio: ${reminder!.day}/${reminder!.month} ${reminder!.hour}:${reminder!.minute.toString().padLeft(2, '0')}'
                    : 'Agregar recordatorio'),
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
                  setDialogState(() {
                    reminder = DateTime(
                      date.year, date.month, date.day,
                      time.hour, time.minute,
                    );
                  });
                },
              ),

              const SizedBox(height: 12),

              // Imagen
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton.icon(
                      icon: const Icon(Icons.photo_library),
                      label: const Text('Galería'),
                      onPressed: () async {
                        final tempId = DateTime.now().millisecondsSinceEpoch.toString();
                        final url = await storageService.pickAndUpload(
                          fromCamera: false,
                          noteId: tempId,
                        );
                        print('=== imageUrl galería: $url');
                        if (url != null) setDialogState(() => imageUrl = url);
                      },
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: OutlinedButton.icon(
                      icon: const Icon(Icons.camera_alt),
                      label: const Text('Cámara'),
                      onPressed: () async {
                        final tempId = DateTime.now().millisecondsSinceEpoch.toString();
                        final url = await storageService.pickAndUpload(
                          fromCamera: true,
                          noteId: tempId,
                        );
                        print('=== imageUrl cámara: $url');
                        if (url != null) setDialogState(() => imageUrl = url);
                      },
                    ),
                  ),
                ],
              ),

              // Preview imagen
              if (imageUrl != null) ...[
                const SizedBox(height: 8),
                ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: Image.network(
                    imageUrl!,
                    height: 100,
                    width: double.infinity,
                    fit: BoxFit.cover,
                  ),
                ),
              ],
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
              print('=== imageUrl al guardar: $imageUrl');
              await _notesService.addNote(
                titleController.text,
                contentController.text,
                reminder,
                imageUrl: imageUrl,
              );
              if (context.mounted) Navigator.pop(context);
              _loadNotes();
            },
            child: const Text('Guardar'),
          ),
        ],
      ),
    ),
  );
}
}