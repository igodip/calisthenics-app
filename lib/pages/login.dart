import 'dart:async';

import 'package:app_links/app_links.dart';
import 'package:calisync/theme/app_theme.dart';
import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
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
  bool passwordResetLoading = false;

  String? feedbackMessage;
  bool isError = false;
  late AppLocalizations l10n;
  bool _linksInitialized = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    l10n = AppLocalizations.of(context)!;
    if (!_linksInitialized) {
      _initializeLinkListener();
      _linksInitialized = true;
    }
  }

  @override
  void dispose() {
    emailController.dispose();
    passwordController.dispose();
    confirmPasswordController.dispose();
    _linkSubscription?.cancel();
    super.dispose();
  }

  void _initializeLinkListener() {
    final appLinks = AppLinks();
    Future<void> handleUri(Uri? uri) async {
      if (uri == null) return;
      try {
        final isRecovery = uri.queryParameters['type'] == 'recovery';
        await Supabase.instance.client.auth.getSessionFromUrl(uri);
        if (isRecovery && mounted) {
          WidgetsBinding.instance.addPostFrameCallback((_) {
            if (mounted) {
              _showPasswordResetDialog();
            }
          });
        }
      } on AuthException catch (e) {
        _setFeedback(e.message, true);
      } catch (e) {
        _setFeedback(l10n.redirectError('$e'), true);
      }
    }

    _linkSubscription = appLinks.uriLinkStream.listen(handleUri, onError: (error) {
      _setFeedback(l10n.linkError('$error'), true);
    });
  }

  Future<void> _submit() async {
    if (loading) return;

    final email = emailController.text.trim();
    final password = passwordController.text;
    final confirmPassword = confirmPasswordController.text;

    if (email.isEmpty || password.isEmpty || (!isLoginMode && confirmPassword.isEmpty)) {
      _setFeedback(l10n.missingFieldsError, true);
      return;
    }

    if (!isLoginMode && password != confirmPassword) {
      _setFeedback(l10n.passwordMismatch, true);
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
          _setFeedback(l10n.invalidCredentials, true);
          return;
        }

        await _ensureUserEntry(user);

        if (!mounted) return;
        Navigator.of(context).pushReplacementNamed('/');
      } else {
        final response = await supabase.auth.signUp(
          email: email,
          password: password,
        );

        final user = response.user ?? Supabase.instance.client.auth.currentUser;

        if (user != null && Supabase.instance.client.auth.currentSession != null) {
          await _ensureUserEntry(user);
        }

        if (!mounted) return;

        if (Supabase.instance.client.auth.currentSession != null) {
          Navigator.of(context).pushReplacementNamed('/');
        } else {
          _setFeedback(l10n.signupEmailCheck, false);
        }
      }
    } on AuthException catch (e) {
      _setFeedback(e.message, true);
    } catch (e) {
      _setFeedback(l10n.unexpectedError('$e'), true);
    } finally {
      if (mounted) {
        setState(() {
          loading = false;
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

  Future<void> _sendPasswordResetEmail() async {
    if (passwordResetLoading || loading) {
      return;
    }

    final email = emailController.text.trim();

    if (email.isEmpty) {
      _setFeedback(l10n.passwordResetEmailMissing, true);
      return;
    }

    FocusScope.of(context).unfocus();

    setState(() {
      passwordResetLoading = true;
    });
    _setFeedback(null, false);

    try {
      await supabase.auth.resetPasswordForEmail(
        email,
        redirectTo: 'com.idipaolo.calisync://login-callback',
      );
      _setFeedback(l10n.passwordResetEmailSent(email), false);
    } on AuthException catch (e) {
      _setFeedback(e.message, true);
    } catch (e) {
      _setFeedback(l10n.unexpectedError('$e'), true);
    } finally {
      if (mounted) {
        setState(() {
          passwordResetLoading = false;
        });
      }
    }
  }

  Future<void> _showPasswordResetDialog() async {
    final newPasswordController = TextEditingController();
    final confirmController = TextEditingController();

    await showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (context) {
        bool submitting = false;
        String? dialogError;

        return StatefulBuilder(
          builder: (dialogContext, setDialogState) {
            Future<void> submitWithState() async {
              if (submitting) return;

              final newPassword = newPasswordController.text;
              final confirmPassword = confirmController.text;

              if (newPassword.isEmpty || confirmPassword.isEmpty) {
                setDialogState(() {
                  dialogError = l10n.missingFieldsError;
                });
                return;
              }

              if (newPassword != confirmPassword) {
                setDialogState(() {
                  dialogError = l10n.passwordResetMismatch;
                });
                return;
              }

              FocusScope.of(dialogContext).unfocus();

              setDialogState(() {
                submitting = true;
                dialogError = null;
              });

              try {
                await supabase.auth.updateUser(
                  UserAttributes(password: newPassword),
                );
                if (mounted) {
                  Navigator.of(dialogContext).pop();
                  _setFeedback(l10n.passwordResetSuccess, false);
                }
              } on AuthException catch (e) {
                setDialogState(() {
                  dialogError = e.message;
                  submitting = false;
                });
              } catch (e) {
                setDialogState(() {
                  dialogError = l10n.unexpectedError('$e');
                  submitting = false;
                });
              }
            }

            return AlertDialog(
              title: Text(l10n.passwordResetDialogTitle),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Text(
                    l10n.passwordResetDialogDescription,
                    style: Theme.of(dialogContext).textTheme.bodyMedium,
                  ),
                  const SizedBox(height: 16),
                  TextField(
                    controller: newPasswordController,
                    obscureText: true,
                    decoration: InputDecoration(
                      labelText: l10n.passwordResetNewPasswordLabel,
                    ),
                  ),
                  const SizedBox(height: 12),
                  TextField(
                    controller: confirmController,
                    obscureText: true,
                    decoration: InputDecoration(
                      labelText: l10n.passwordResetConfirmPasswordLabel,
                    ),
                  ),
                  if (dialogError != null) ...[
                    const SizedBox(height: 12),
                    Text(
                      dialogError!,
                      style: Theme.of(dialogContext)
                          .textTheme
                          .bodySmall
                          ?.copyWith(color: Theme.of(dialogContext).colorScheme.error),
                    ),
                  ],
                ],
              ),
              actions: [
                TextButton(
                  onPressed: submitting
                      ? null
                      : () {
                          Navigator.of(dialogContext).pop();
                        },
                  child: Text(l10n.cancel),
                ),
                ElevatedButton(
                  onPressed: submitting ? null : submitWithState,
                  child: submitting
                      ? const SizedBox(
                          width: 18,
                          height: 18,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : Text(l10n.passwordResetSubmit),
                ),
              ],
            );
          },
        );
      },
    );

    newPasswordController.dispose();
    confirmController.dispose();
  }

  Future<void> _ensureUserEntry(User user) async {
    try {
      final existing = await supabase
          .from('users')
          .select('id')
          .eq('id', user.id)
          .limit(1)
          .maybeSingle();

      if (existing != null) {
        return;
      }

      final email = user.email;
      final metadata = user.userMetadata ?? {};
      final username = email != null && email.isNotEmpty
          ? email.split('@').first
          : (metadata['username'] as String?) ?? '';

      await supabase.from('users').insert({
        if (email != null) 'email': email,
        'username': username,
      });
    } catch (error, stackTrace) {
      debugPrint('Failed to ensure user entry: $error');
      debugPrintStack(stackTrace: stackTrace);
    }
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
                      l10n.appTitle,
                      style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: colorScheme.onSurface,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      isLoginMode ? l10n.loginGreeting : l10n.signupGreeting,
                      textAlign: TextAlign.center,
                      style: Theme.of(context)
                          .textTheme
                          .bodyMedium
                          ?.copyWith(color: colorScheme.onSurface.withValues(alpha: 0.72)),
                    ),
                    const SizedBox(height: 32),
                    AnimatedContainer(
                      duration: const Duration(milliseconds: 300),
                      padding: const EdgeInsets.all(24),
                      decoration: BoxDecoration(
                        color: colorScheme.surface.withValues(alpha: 0.78),
                        borderRadius: BorderRadius.circular(24),
                        border: Border.all(color: colorScheme.outlineVariant),
                        boxShadow: [
                          BoxShadow(
                            color: theme.shadowColor.withValues(alpha: 0.45),
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
                            label: l10n.emailLabel,
                            keyboardType: TextInputType.emailAddress,
                            icon: Icons.mail_outline,
                          ),
                          const SizedBox(height: 16),
                          _AuthTextField(
                            controller: passwordController,
                            label: l10n.passwordLabel,
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
                                      label: l10n.confirmPasswordLabel,
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
                                : Text(isLoginMode ? l10n.loginButton : l10n.signupButton),
                          ),
                          const SizedBox(height: 12),
                          if (isLoginMode)
                            Center(
                              child: TextButton(
                                onPressed:
                                    passwordResetLoading ? null : _sendPasswordResetEmail,
                                child: passwordResetLoading
                                    ? const SizedBox(
                                        width: 18,
                                        height: 18,
                                        child:
                                            CircularProgressIndicator(strokeWidth: 2),
                                      )
                                    : Text(l10n.forgotPasswordLink),
                              ),
                            ),
                          if (isLoginMode) const SizedBox(height: 12),
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
                                    ? l10n.noAccountPrompt
                                    : l10n.existingAccountPrompt,
                                style: theme.textTheme.bodyMedium?.copyWith(
                                  color: colorScheme.onSurface.withValues(alpha: 0.7),
                                ),
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
