import 'dart:convert';
import 'dart:math';
import 'dart:io';
import 'package:crypto/crypto.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_appauth/flutter_appauth.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../../../main.dart';

class AuthenticationService {
  String _generateRandomString() {
    final random = Random.secure();
    return base64Url.encode(List<int>.generate(16, (_) => random.nextInt(256)));
  }

  Future<AuthResponse> signInWithGoogle() async {
    final rawNonce = _generateRandomString();
    final hashedNonce = sha256.convert(utf8.encode(rawNonce)).toString();

    final clientId = Platform.isIOS
        ? '111665590189-e6gtooj0dmb0kmo969qafj57q5bap1ls.apps.googleusercontent.com'
        : '111665590189-gt5k2tbr85i87l3ud4pqo62rg0rj9hdp.apps.googleusercontent.com';

    final redirectUrl = '${clientId.split('.').reversed.join('.')}:/';

    const discoveryUrl =
        'https://accounts.google.com/.well-known/openid-configuration';

    const appAuth = FlutterAppAuth();

    final result = await appAuth.authorize(
      AuthorizationRequest(
        clientId,
        redirectUrl,
        discoveryUrl: discoveryUrl,
        nonce: hashedNonce,
        scopes: [
          'openid',
          'email',
        ],
      ),
    );

    if (result == null) {
      throw 'No result';
    }

    final tokenResult = await appAuth.token(
      TokenRequest(
        clientId,
        redirectUrl,
        authorizationCode: result.authorizationCode,
        discoveryUrl: discoveryUrl,
        codeVerifier: result.codeVerifier,
        nonce: result.nonce,
        scopes: [
          'openid',
          'email',
        ],
      ),
    );

    final idToken = tokenResult?.idToken;

    if (idToken == null) {
      throw 'No idToken';
    }

    final signInResponse = await supabase.auth.signInWithIdToken(
      provider: Provider.google,
      idToken: idToken,
      nonce: rawNonce,
    );

    // After successfully signing in with Google, add the user to the `customers` table
    await _addUserToCustomersTable(signInResponse.user!.id);

    return signInResponse;
  }

  Future<void> _addUserToCustomersTable(String userId) async {
    final response = await supabase.from('customers').upsert([
      {'customer_id': userId}
    ]).single(); // expecting a single row

    // If there's an error adding to the customers table, throw it
    if (response.error != null) {
      if (kDebugMode) {
        print("Error Details: ${response.error.message}");
      }
      throw response.error!;
    }
  }
}
