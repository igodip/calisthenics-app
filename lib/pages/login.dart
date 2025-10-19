import 'dart:async';

import 'package:app_links/app_links.dart';
import 'package:calisync/theme/app_theme.dart';
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
  final confirmPasswordController = TextEditingController();

  StreamSubscription<Uri?>? _linkSubscription;

  bool isLoginMode = true;
  bool loading = false;
  bool oauthLoading = false;

  String? feedbackMessage;
  bool isError = false;

  @override
  void initState() {
    super.initState();
    _listenForRedirect();
  }

  @override
  void dispose() {
    emailController.dispose();
    passwordController.dispose();
    confirmPasswordController.dispose();
    _linkSubscription?.cancel();
    super.dispose();
  }

  void _listenForRedirect() {
    final appLinks = AppLinks();
    Future<void> handleUri(Uri? uri) async {
      if (uri == null) return;
      try {
        await Supabase.instance.client.auth.getSessionFromUrl(uri);
      } on AuthException catch (e) {
        _setFeedback(e.message, true);
      } catch (e) {
        _setFeedback('Errore durante il reindirizzamento: $e', true);
      }
    }

    _linkSubscription = appLinks.uriLinkStream.listen(handleUri, onError: (error) {
      _setFeedback('Errore collegamento: $error', true);
    });
  }

  Future<void> _submit() async {
    if (loading) return;

    final email = emailController.text.trim();
    final password = passwordController.text;
    final confirmPassword = confirmPasswordController.text;

    if (email.isEmpty || password.isEmpty || (!isLoginMode && confirmPassword.isEmpty)) {
      _setFeedback('Compila tutti i campi richiesti.', true);
      return;
    }

    if (!isLoginMode && password != confirmPassword) {
      _setFeedback('Le password non coincidono.', true);
      return;
    }

    FocusScope.of(context).unfocus();

    setState(() {
      loading = true;
    });
    _setFeedback(null, false);

    try {
      if (isLoginMode) {
        final response = await supabase.auth.signInWithPassword(
          email: email,
          password: password,
        );

        final user = response.user;
        if (user == null) {
          _setFeedback('Credenziali errate.', true);
          return;
        }

        if (!mounted) return;
        Navigator.of(context).pushReplacementNamed('/');
      } else {
        final response = await supabase.auth.signUp(
          email: email,
          password: password,
        );

        final user = response.user ?? Supabase.instance.client.auth.currentUser;

        if (!mounted) return;

        if (Supabase.instance.client.auth.currentSession != null) {
          Navigator.of(context).pushReplacementNamed('/');
        } else {
          _setFeedback(
            'Registrazione completata! Controlla la tua email per confermare l\'account.',
            false,
          );
        }
      }
    } on AuthException catch (e) {
      _setFeedback(e.message, true);
    } catch (e) {
      _setFeedback('Errore inatteso: $e', true);
    } finally {
      if (mounted) {
        setState(() {
          loading = false;
        });
      }
    }
  }

  Future<void> _signInWithGoogle() async {
    if (oauthLoading) return;
    setState(() {
      oauthLoading = true;
    });
    _setFeedback(null, false);

    try {
      await Supabase.instance.client.auth.signInWithOAuth(
        OAuthProvider.google,
        redirectTo: 'com.idipaolo.calisync://login-callback',
      );
    } on AuthException catch (e) {
      _setFeedback(e.message, true);
    } catch (e) {
      _setFeedback('Google Sign-In fallito: $e', true);
    } finally {
      if (mounted) {
        setState(() {
          oauthLoading = false;
        });
      }
    }
  }

  void _setFeedback(String? message, bool error) {
    if (!mounted) return;
    setState(() {
      feedbackMessage = message;
      isError = error;
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final appColors = theme.extension<AppColors>()!;

    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: appColors.primaryGradient,
        ),
        child: SafeArea(
          child: Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 420),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      Icons.fitness_center,
                      size: 64,
                      color: colorScheme.primary,
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'Calisync',
                      style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: colorScheme.onBackground,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      isLoginMode
                          ? 'Bentornato! Accedi per continuare il tuo allenamento.'
                          : 'Crea un account per sbloccare tutti gli allenamenti.',
                      textAlign: TextAlign.center,
                      style: Theme.of(context)
                          .textTheme
                          .bodyMedium
                          ?.copyWith(color: colorScheme.onBackground.withOpacity(0.72)),
                    ),
                    const SizedBox(height: 32),
                    AnimatedContainer(
                      duration: const Duration(milliseconds: 300),
                      padding: const EdgeInsets.all(24),
                      decoration: BoxDecoration(
                        color: colorScheme.surface.withOpacity(0.78),
                        borderRadius: BorderRadius.circular(24),
                        border: Border.all(color: colorScheme.outlineVariant),
                        boxShadow: [
                          BoxShadow(
                            color: theme.shadowColor.withOpacity(0.45),
                            blurRadius: 28,
                            offset: const Offset(0, 18),
                          ),
                        ],
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          _AuthTextField(
                            controller: emailController,
                            label: 'Email',
                            keyboardType: TextInputType.emailAddress,
                            icon: Icons.mail_outline,
                          ),
                          const SizedBox(height: 16),
                          _AuthTextField(
                            controller: passwordController,
                            label: 'Password',
                            isPassword: true,
                            icon: Icons.lock_outline,
                          ),
                          AnimatedSwitcher(
                            duration: const Duration(milliseconds: 250),
                            child: isLoginMode
                                ? const SizedBox.shrink()
                                : Padding(
                                    padding: const EdgeInsets.only(top: 16),
                                    child: _AuthTextField(
                                      controller: confirmPasswordController,
                                      label: 'Conferma Password',
                                      isPassword: true,
                                      icon: Icons.lock_reset,
                                    ),
                                  ),
                          ),
                          const SizedBox(height: 24),
                          ElevatedButton(
                            onPressed: loading ? null : _submit,
                            child: loading
                                ? const SizedBox(
                                    width: 20,
                                    height: 20,
                                    child: CircularProgressIndicator(strokeWidth: 2),
                                  )
                                : Text(isLoginMode ? 'Accedi' : 'Registrati'),
                          ),
                          const SizedBox(height: 12),
                          Center(
                            child: TextButton(
                              onPressed: loading
                                  ? null
                                  : () {
                                      setState(() {
                                        isLoginMode = !isLoginMode;
                                        feedbackMessage = null;
                                      });
                                    },
                              child: Text(
                                isLoginMode
                                    ? 'Non hai un account? Registrati'
                                    : 'Hai già un account? Accedi',
                                style: theme.textTheme.bodyMedium?.copyWith(
                                  color: colorScheme.onBackground.withOpacity(0.7),
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(height: 12),
                          Row(
                            children: [
                              Expanded(
                                child: Container(
                                  height: 1,
                                  color: colorScheme.outlineVariant,
                                ),
                              ),
                              Padding(
                                padding: const EdgeInsets.symmetric(horizontal: 12),
                                child: Text(
                                  'oppure',
                                  style: theme.textTheme.labelLarge?.copyWith(
                                    color: colorScheme.onBackground.withOpacity(0.6),
                                  ),
                                ),
                              ),
                              Expanded(
                                child: Container(
                                  height: 1,
                                  color: colorScheme.outlineVariant,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 12),
                          OutlinedButton.icon(
                            onPressed: oauthLoading ? null : _signInWithGoogle,
                            icon: oauthLoading
                                ? const SizedBox(
                                    width: 18,
                                    height: 18,
                                    child: CircularProgressIndicator(strokeWidth: 2),
                                  )
                                : Image.asset(
                                    'assets/google_logo.png',
                                    width: 18,
                                    height: 18,
                                    errorBuilder: (_, __, ___) => const Icon(Icons.login, size: 18),
                                  ),
                            label: Text(
                              oauthLoading ? 'Connessione...' : 'Continua con Google',
                              style: theme.textTheme.titleMedium?.copyWith(
                                color: colorScheme.onSurface,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                          if (feedbackMessage != null) ...[
                            const SizedBox(height: 20),
                            Container(
                              padding: const EdgeInsets.all(12),
                              decoration: BoxDecoration(
                                color: isError
                                    ? colorScheme.errorContainer
                                    : appColors.successContainer,
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(
                                  color: isError ? colorScheme.error : appColors.success,
                                ),
                              ),
                              child: Text(
                                feedbackMessage!,
                                style: TextStyle(
                                  color: isError ? colorScheme.error : appColors.success,
                                  fontWeight: FontWeight.w500,
                                ),
                                textAlign: TextAlign.center,
                              ),
                            ),
                          ],
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _AuthTextField extends StatefulWidget {
  const _AuthTextField({
    required this.controller,
    required this.label,
    this.isPassword = false,
    this.keyboardType,
    this.icon,
  });

  final TextEditingController controller;
  final String label;
  final bool isPassword;
  final TextInputType? keyboardType;
  final IconData? icon;

  @override
  State<_AuthTextField> createState() => _AuthTextFieldState();
}

class _AuthTextFieldState extends State<_AuthTextField> {
  bool obscure = true;

  @override
  Widget build(BuildContext context) {
    final isPassword = widget.isPassword;
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return TextField(
      controller: widget.controller,
      obscureText: isPassword ? obscure : false,
      keyboardType: widget.keyboardType,
      style: theme.textTheme.bodyLarge?.copyWith(color: colorScheme.onSurface),
      decoration: InputDecoration(
        labelText: widget.label,
        prefixIcon: widget.icon != null
            ? Icon(widget.icon, color: colorScheme.onSurfaceVariant)
            : null,
        suffixIcon: isPassword
            ? IconButton(
                icon: Icon(
                  obscure ? Icons.visibility_off : Icons.visibility,
                  color: colorScheme.onSurfaceVariant,
                ),
                onPressed: () {
                  setState(() {
                    obscure = !obscure;
                  });
                },
              )
            : null,
      ),
      cursorColor: colorScheme.primary,
    );
  }
}
