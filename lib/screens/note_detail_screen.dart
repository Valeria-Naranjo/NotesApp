import 'package:flutter/material.dart';
import 'package:flutter_application_deux/models/note.dart';

class NoteDetailScreen extends StatelessWidget {
  final Note note;

  const NoteDetailScreen({super.key, required this.note});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Detalle de nota')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Imagen si existe
            if (note.imageUrl != null)
              ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: Image.network(
                  note.imageUrl!,
                  width: double.infinity,
                  height: 200,
                  fit: BoxFit.cover,
                  loadingBuilder: (context, child, progress) {
                    if (progress == null) return child;
                    return const SizedBox(
                      height: 200,
                      child: Center(child: CircularProgressIndicator()),
                    );
                  },
                  errorBuilder: (_, __, ___) => const SizedBox(
                    height: 200,
                    child: Center(child: Icon(Icons.broken_image, size: 48)),
                  ),
                ),
              ),
            if (note.imageUrl != null) const SizedBox(height: 16),

            Text(
              note.title,
              style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            if (note.reminder != null) ...[
              Row(
                children: [
                  const Icon(Icons.alarm, color: Colors.red, size: 18),
                  const SizedBox(width: 6),
                  Text(
                    'Recordatorio: ${note.reminder}',
                    style: const TextStyle(color: Colors.red),
                  ),
                ],
              ),
              const SizedBox(height: 16),
            ],
            const Divider(),
            const SizedBox(height: 16),
            Text(
              note.content.isEmpty ? 'Sin contenido' : note.content,
              style: const TextStyle(fontSize: 16),
            ),
          ],
        ),
      ),
    );
  }
}