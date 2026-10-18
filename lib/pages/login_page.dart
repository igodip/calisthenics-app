import 'dart:async';

import 'package:app_links/app_links.dart';
import 'package:calisync/theme/app_theme.dart';
import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../l10n/app_localizations.dart';
import '../components/privacy_policy_link.dart';
import '../components/auth_visuals.dart';

final supabase = Supabase.instance.client;

class LoginPage extends StatefulWidget {
  const LoginPage({super.key, this.initialLoginMode = true});

  final bool initialLoginMode;

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final emailController = TextEditingController();
  final passwordController = TextEditingController();
  final confirmPasswordController = TextEditingController();

  StreamSubscription<Uri?>? _linkSubscription;

  late bool isLoginMode;

  @override
  void initState() {
    super.initState();
    isLoginMode = widget.initialLoginMode;
  }

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

    _linkSubscription = appLinks.uriLinkStream.listen(
      handleUri,
      onError: (error) {
        _setFeedback(l10n.linkError('$error'), true);
      },
    );
  }

  Future<void> _submit() async {
    if (loading) return;

    final email = emailController.text.trim();
    final password = passwordController.text;
    final confirmPassword = confirmPasswordController.text;

    if (email.isEmpty ||
        password.isEmpty ||
        (!isLoginMode && confirmPassword.isEmpty)) {
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

        await _ensureTraineeEntry(user);

        if (!mounted) return;
        Navigator.of(context).pushReplacementNamed('/');
      } else {
        final response = await supabase.auth.signUp(
          email: email,
          password: password,
        );

        final user = response.user ?? Supabase.instance.client.auth.currentUser;

        if (user != null &&
            Supabase.instance.client.auth.currentSession != null) {
          await _ensureTraineeEntry(user);
        }

        if (!mounted) return;

        if (Supabase.instance.client.auth.currentSession != null) {
          Navigator.of(context).pushReplacementNamed('/');
        } else {
          _setFeedback(l10n.signupEmailCheck, false);
        }
      }
    } on AuthException catch (e) {
      _setFeedback(_authErrorMessage(e), true);
    } catch (_) {
      _setFeedback(l10n.authOperationFailed, true);
    } finally {
      if (mounted) {
        setState(() {
          loading = false;
        });
      }
    }
  }

  String _authErrorMessage(AuthException exception) {
    switch (exception.code) {
      case 'invalid_credentials':
      case 'user_not_found':
        return isLoginMode ? l10n.invalidCredentials : l10n.authOperationFailed;
      case 'email_not_confirmed':
        return l10n.emailNotConfirmed;
      case 'email_exists':
      case 'user_already_exists':
        return l10n.emailAlreadyRegistered;
      case 'weak_password':
        return l10n.weakPassword;
      case 'email_address_invalid':
        return l10n.invalidEmail;
      case 'signup_disabled':
      case 'email_provider_disabled':
      case 'provider_disabled':
        return l10n.signupDisabled;
      case 'over_email_send_rate_limit':
      case 'over_request_rate_limit':
        return l10n.authTooManyRequests;
      case 'request_timeout':
        return l10n.authServiceUnavailable;
    }

    final statusCode = int.tryParse(exception.statusCode ?? '');
    if (statusCode == 429) return l10n.authTooManyRequests;
    if (statusCode != null && statusCode >= 500) {
      return l10n.authServiceUnavailable;
    }

    return l10n.authOperationFailed;
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
                final dialogNavigator = Navigator.of(dialogContext);
                await supabase.auth.updateUser(
                  UserAttributes(password: newPassword),
                );
                if (mounted) {
                  dialogNavigator.pop();
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
                      style: Theme.of(dialogContext).textTheme.bodySmall
                          ?.copyWith(
                            color: Theme.of(dialogContext).colorScheme.error,
                          ),
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

  Future<void> _ensureTraineeEntry(User user) async {
    try {
      final trainer = await supabase
          .from('trainers')
          .select('id')
          .eq('id', user.id)
          .maybeSingle();
      if (trainer != null) return;

      final existing = await supabase
          .from('trainees')
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

      await supabase.from('trainees').insert({'id': user.id, 'name': username});
    } catch (error, stackTrace) {
      debugPrint('Failed to ensure trainee entry: $error');
      debugPrintStack(stackTrace: stackTrace);
    }
  }

  @override
  Widget build(BuildContext context) => Theme(
    data: AuthVisuals.theme(context),
    child: Builder(builder: _buildContent),
  );

  Widget _buildContent(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final appColors = theme.extension<AppColors>()!;
    return Scaffold(
      body: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 520),
            child: LayoutBuilder(
              builder: (context, constraints) {
                final keyboardOpen =
                    MediaQuery.viewInsetsOf(context).bottom > 0;
                return SingleChildScrollView(
                  keyboardDismissBehavior:
                      ScrollViewKeyboardDismissBehavior.onDrag,
                  child: AutofillGroup(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        Padding(
                          padding: const EdgeInsets.fromLTRB(24, 16, 24, 0),
                          child: AuthBrand(title: l10n.appTitle),
                        ),
                        AuthArtwork(
                          asset: 'assets/auth/rings.webp',
                          fit: BoxFit.cover,
                          height: keyboardOpen
                              ? 80
                              : (constraints.maxHeight * .29)
                                    .clamp(120.0, 260.0)
                                    .toDouble(),
                        ),
                        Padding(
                          padding: const EdgeInsets.fromLTRB(24, 0, 24, 16),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: [
                              Text(
                                isLoginMode
                                    ? l10n.authWelcomeTitle
                                    : l10n.signupButton,
                                style: theme.textTheme.headlineLarge?.copyWith(
                                  fontWeight: FontWeight.w800,
                                ),
                              ),
                              const SizedBox(height: 8),
                              Text(
                                isLoginMode
                                    ? l10n.loginGreeting
                                    : l10n.signupGreeting,
                                style: theme.textTheme.bodyLarge?.copyWith(
                                  color: AuthVisuals.muted,
                                ),
                              ),
                              const SizedBox(height: 28),
                              _AuthTextField(
                                controller: emailController,
                                label: l10n.emailLabel,
                                keyboardType: TextInputType.emailAddress,
                                icon: Icons.mail_outline,
                                autofillHints: const [AutofillHints.email],
                              ),
                              const SizedBox(height: 18),
                              _AuthTextField(
                                controller: passwordController,
                                label: l10n.passwordLabel,
                                isPassword: true,
                                icon: Icons.lock_outline,
                                autofillHints: [
                                  isLoginMode
                                      ? AutofillHints.password
                                      : AutofillHints.newPassword,
                                ],
                                onSubmitted: isLoginMode
                                    ? (_) => _submit()
                                    : null,
                              ),
                              if (!isLoginMode) ...[
                                const SizedBox(height: 18),
                                _AuthTextField(
                                  controller: confirmPasswordController,
                                  label: l10n.confirmPasswordLabel,
                                  isPassword: true,
                                  icon: Icons.lock_reset,
                                  autofillHints: const [
                                    AutofillHints.newPassword,
                                  ],
                                  onSubmitted: (_) => _submit(),
                                ),
                                const SizedBox(height: 18),
                                Text(
                                  l10n.registrationPrivacyNotice,
                                  style: theme.textTheme.bodySmall,
                                ),
                                const PrivacyPolicyLink(),
                              ],
                              if (isLoginMode)
                                Align(
                                  alignment: Alignment.centerRight,
                                  child: TextButton(
                                    onPressed: passwordResetLoading || loading
                                        ? null
                                        : _sendPasswordResetEmail,
                                    child: passwordResetLoading
                                        ? const SizedBox(
                                            width: 18,
                                            height: 18,
                                            child: CircularProgressIndicator(
                                              strokeWidth: 2,
                                            ),
                                          )
                                        : Text(l10n.forgotPasswordLink),
                                  ),
                                ),
                              if (feedbackMessage != null) ...[
                                const SizedBox(height: 12),
                                Semantics(
                                  liveRegion: true,
                                  child: Container(
                                    padding: const EdgeInsets.all(12),
                                    decoration: BoxDecoration(
                                      color: isError
                                          ? scheme.errorContainer
                                          : appColors.successContainer,
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                    child: Text(
                                      feedbackMessage!,
                                      style: TextStyle(
                                        color: isError
                                            ? scheme.onErrorContainer
                                            : appColors.success,
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                              const SizedBox(height: 20),
                              FilledButton(
                                onPressed: loading || passwordResetLoading
                                    ? null
                                    : _submit,
                                child: loading
                                    ? const SizedBox(
                                        width: 20,
                                        height: 20,
                                        child: CircularProgressIndicator(
                                          strokeWidth: 2,
                                        ),
                                      )
                                    : Text(
                                        isLoginMode
                                            ? l10n.loginButton
                                            : l10n.signupButton,
                                      ),
                              ),
                              const SizedBox(height: 8),
                              TextButton(
                                onPressed: loading || passwordResetLoading
                                    ? null
                                    : () => setState(() {
                                        isLoginMode = !isLoginMode;
                                        confirmPasswordController.clear();
                                        feedbackMessage = null;
                                      }),
                                child: Text(
                                  isLoginMode
                                      ? l10n.noAccountPrompt
                                      : l10n.existingAccountPrompt,
                                  textAlign: TextAlign.center,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
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
    this.autofillHints,
    this.onSubmitted,
  });

  final TextEditingController controller;
  final String label;
  final bool isPassword;
  final TextInputType? keyboardType;
  final IconData? icon;
  final Iterable<String>? autofillHints;
  final ValueChanged<String>? onSubmitted;

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

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(widget.label, style: theme.textTheme.labelLarge),
        const SizedBox(height: 8),
        TextField(
          controller: widget.controller,
          autofillHints: widget.autofillHints,
          onSubmitted: widget.onSubmitted,
          textInputAction: widget.onSubmitted == null
              ? TextInputAction.next
              : TextInputAction.done,
          autocorrect: false,
          enableSuggestions: !isPassword,
          obscureText: isPassword ? obscure : false,
          keyboardType: widget.keyboardType,
          style: theme.textTheme.bodyLarge?.copyWith(
            color: colorScheme.onSurface,
          ),
          decoration: InputDecoration(
            hintText: widget.label,
            prefixIcon: widget.icon != null
                ? Icon(widget.icon, color: colorScheme.onSurfaceVariant)
                : null,
            suffixIcon: isPassword
                ? IconButton(
                    tooltip: obscure
                        ? AppLocalizations.of(context)!.authShowPassword
                        : AppLocalizations.of(context)!.authHidePassword,
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
        ),
      ],
    );
  }
}
