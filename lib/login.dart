// lib/login.dart
import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

final supabase = Supabase.instance.client;

class LoginPage extends StatefulWidget {
    const LoginPage({super.key});

    @override
    State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
    final emailController = TextEditingController();
    final passwordController = TextEditingController();
    String errorText = '';

  Future<void> login() async {
    setState(() {
        errorText = '';
    });

    try {
        final response = await supabase.auth.signInWithPassword(
            email: emailController.text.trim(),
            password: passwordController.text,
        );

        final user = response.user;
        if (user == null) {
            setState(() {
            errorText = 'Credenziali errate.';
            });
            return;
        }

        final userData = await supabase
            .from('users')
            .select()
            .eq('uuid', user.id)
            .limit(1)
            .maybeSingle();

        if (userData == null) {
            // Inserisci automaticamente una riga
            await supabase.from('users').insert({
            'uuid': user.id,
            'email': user.email,
            'username': user.email!.split('@').first,
            'active': true,
            'payed': false,
            });

            // final isActive = userData?['active'] == true;

            // if (!isActive) {
            // setState(() {
            //     errorText = 'Account disattivato.';
            // });
            // return;
            // }
        }

      Navigator.pushReplacementNamed(context, '/');
    } on AuthException catch (e) {
      setState(() {
        errorText = e.message;
      });
    } catch (e) {
      setState(() {
        errorText = 'Errore: ${e.toString()}';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Login')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            TextField(
              controller: emailController,
              decoration: const InputDecoration(labelText: 'Email'),
            ),
            TextField(
              controller: passwordController,
              decoration: const InputDecoration(labelText: 'Password'),
              obscureText: true,
            ),
            const SizedBox(height: 16),
            ElevatedButton(onPressed: login, child: const Text('Accedi')),
            if (errorText.isNotEmpty)
              Padding(
                padding: const EdgeInsets.only(top: 12),
                child: Text(
                    errorText,
                    style: const TextStyle(color: Colors.red),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
