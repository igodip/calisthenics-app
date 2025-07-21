import 'dart:async';
import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:app_links/app_links.dart';

class GoogleLoginPage extends StatefulWidget {
  const GoogleLoginPage({super.key});

  @override
  State<GoogleLoginPage> createState() => _GoogleLoginPageState();
}

class _GoogleLoginPageState extends State<GoogleLoginPage> {
  StreamSubscription? _sub;
  bool loading = false;

  @override
  void initState() {
    super.initState();
    _listenForRedirect();
  }

  void _listenForRedirect() {
    final appLinks = AppLinks();
    _sub = appLinks.uriLinkStream.listen((Uri? uri) async {
      if (uri != null) {
        await Supabase.instance.client.auth.getSessionFromUrl(uri);
        setState(() {});
      }
    });
  }

  Future<void> _signInWithGoogle() async {
    try {
      setState(() => loading = true);
      await Supabase.instance.client.auth.signInWithOAuth(
        OAuthProvider.google,
        redirectTo: 'com.idipaolo.calisync://login-callback', // mobile deep link
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Google Sign-In failed: $e')),
      );
    } finally {
      setState(() => loading = false);
    }
  }

  @override
  void dispose() {
    _sub?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final user = Supabase.instance.client.auth.currentUser;

    return Scaffold(
      appBar: AppBar(title: const Text('Login')),
      body: Center(
        child: user == null
            ? ElevatedButton.icon(
          icon: const Icon(Icons.login),
          label: loading
              ? const CircularProgressIndicator()
              : const Text("Sign in with Google"),
          onPressed: loading ? null : _signInWithGoogle,
        )
            : Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text('Welcome, ${user.email ?? "Google User"}'),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () async {
                await Supabase.instance.client.auth.signOut();
                setState(() {});
              },
              child: const Text("Logout"),
            )
          ],
        ),
      ),
    );
  }
}