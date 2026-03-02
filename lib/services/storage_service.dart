import 'dart:io';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:image_picker/image_picker.dart';

class StorageService {
  final _supabase = Supabase.instance.client;
  final _picker = ImagePicker();

  // Seleccionar imagen de galería o cámara
  Future<File?> pickImage({required bool fromCamera}) async {
    final picked = await _picker.pickImage(
      source: fromCamera ? ImageSource.camera : ImageSource.gallery,
      maxWidth: 1024,   // limitamos el tamaño para no subir imágenes enormes
      maxHeight: 1024,
      imageQuality: 80, // comprimimos un poco para ahorrar espacio
    );

    if (picked == null) return null;
    return File(picked.path);
  }

  // Subir imagen a Supabase Storage y devolver la URL pública
 Future<String?> uploadImage(File imageFile, String noteId) async {
  try {
    final userId = _supabase.auth.currentUser!.id;
    final path = '$userId/$noteId.jpg';

    print('=== Subiendo imagen a path: $path');

    await _supabase.storage
        .from('note-images')
        .upload(
          path,
          imageFile,
          fileOptions: const FileOptions(upsert: true),
        );

    final url = _supabase.storage
        .from('note-images')
        .getPublicUrl(path);

    print('=== URL obtenida: $url');
    return url;
  } catch (e) {
    print('=== ERROR en upload: $e');
    return null;
  }
}
  // Eliminar imagen cuando se borra la nota
  Future<void> deleteImage(String noteId) async {
    try {
      final userId = _supabase.auth.currentUser!.id;
      final path = '$userId/$noteId.jpg';

      await _supabase.storage
          .from('note-images')
          .remove([path]);
    } catch (e) {
      // Si no existe la imagen simplemente ignoramos el error
    }
  }

  // Método conveniente que combina pick + upload
  Future<String?> pickAndUpload({
    required bool fromCamera,
    required String noteId,
  }) async {
    final file = await pickImage(fromCamera: fromCamera);
    if (file == null) return null;
    return await uploadImage(file, noteId);
  }
}