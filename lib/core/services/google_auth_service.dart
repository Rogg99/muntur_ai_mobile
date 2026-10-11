import 'package:google_sign_in/google_sign_in.dart';

/// OAuth "Web application" client id, required as `serverClientId` so the
/// id_token's audience matches what the backend verifies with
/// id_token.verify_oauth2_token() (c7, 2026-10-11) — distinct from the
/// per-platform Android/iOS client ids, which only gate the native
/// sign-in flow and are never referenced in code.
const String _googleServerClientId =
    '413253006066-d1di562okck18hf74n104ou1p835nmfj.apps.googleusercontent.com';

class GoogleAuthService {
  static final GoogleAuthService _instance = GoogleAuthService._internal();
  factory GoogleAuthService() => _instance;
  GoogleAuthService._internal();

  final _googleSignIn = GoogleSignIn(
    serverClientId: _googleServerClientId,
    scopes: const ['email'],
  );

  /// Null on cancellation or any failure — never throws, so callers don't
  /// need to special-case "user dismissed the picker" vs a real error.
  Future<String?> signInAndGetIdToken() async {
    try {
      final account = await _googleSignIn.signIn();
      if (account == null) return null; // user cancelled
      final auth = await account.authentication;
      return auth.idToken;
    } catch (_) {
      return null;
    }
  }

  Future<void> signOut() async {
    try {
      await _googleSignIn.signOut();
    } catch (_) {}
  }
}
