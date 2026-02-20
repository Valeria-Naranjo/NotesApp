import 'package:supabase_flutter/supabase_flutter.dart';

class AuthService {
  final _auth = Supabase.instance.client.auth;

  Future<bool> login(String email, String password) async {
    try {
      final response = await _auth.signInWithPassword(
        email: email,
        password: password,
      );
      return response.user != null;
    } catch (e) {
      return false;
    }
  }

  Future<bool> register(String email, String password) async {
    try {
      final response = await _auth.signUp(
        email: email,
        password: password,
      );
      return response.user != null;
    } catch (e) {
      return false;
    }
  }

  Future<void> logout() async {
    await _auth.signOut();
  }

  String? get currentUserId => _auth.currentUser?.id;
}