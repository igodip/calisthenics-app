// lib/profile.dart
import 'dart:typed_data';

import 'package:calisync/model/trainee.dart';
import 'package:calisync/theme/app_theme.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../l10n/app_localizations.dart';
import '../l10n/locale_controller.dart';
import 'login.dart';
import 'settings.dart';

final supabase = Supabase.instance.client;

class ProfileImageCache {
  static const String _baseKey = 'cached_profile_image_url';

  static Future<String?> loadForUser(String userId) async {
    final preferences = await SharedPreferences.getInstance();
    final cached = preferences.getString('$_baseKey:$userId');
    return cached?.trim().isEmpty ?? true ? null : cached;
  }

  static Future<void> saveForUser(String userId, String? imageUrl) async {
    final preferences = await SharedPreferences.getInstance();
    final key = '$_baseKey:$userId';
    final trimmed = imageUrl?.trim();
    if (trimmed == null || trimmed.isEmpty) {
      await preferences.remove(key);
      return;
    }
    await preferences.setString(key, trimmed);
  }
}

class UserProfileData {
  const UserProfileData({
    required this.userId,
    required this.email,
    required this.username,
    required this.isActive,
    required this.isPayed,
    this.profile,
  });

  final String userId;
  final String email;
  final String username;
  final bool isActive;
  final bool isPayed;
  final Trainee? profile;

  String displayName(AppLocalizations l10n) {
    final fullName = profile?.name?.trim();
    if (fullName != null && fullName.isNotEmpty) {
      return fullName;
    }
    if (username.trim().isNotEmpty) {
      return username;
    }
    if (email.trim().isNotEmpty) {
      return email.split('@').first;
    }
    return l10n.profileFallbackName;
  }

  String initials(AppLocalizations l10n) {
    final name = displayName(l10n);
    final nameParts = name.trim().split(RegExp(r'\s+'));
    if (nameParts.length == 1) {
      return nameParts.first.characters.take(2).toString().toUpperCase();
    }
    return nameParts.take(2).map((part) => part.characters.first).join().toUpperCase();
  }
}

Future<UserProfileData> getUserData() async {
  final user = supabase.auth.currentUser;
  if (user == null) {
    throw Exception('user-not-authenticated');
  }

  final profileResponse = await supabase
      .from('trainees')
      .select('id, name, weight, height, profile_image_url')
      .eq('id', user.id)
      .limit(1)
      .maybeSingle();

  if (profileResponse == null) {
    throw Exception('user-not-found');
  }

  var profile = Trainee.fromMap(profileResponse);
  final profileImageUrl = profile.profileImageUrl?.trim();
  if (profileImageUrl != null && profileImageUrl.isNotEmpty) {
    await ProfileImageCache.saveForUser(user.id, profileImageUrl);
  } else {
    final cachedImageUrl = await ProfileImageCache.loadForUser(user.id);
    if (cachedImageUrl != null && cachedImageUrl.isNotEmpty) {
      profile = profile.copyWith(profileImageUrl: cachedImageUrl);
    }
  }
  final name = profile.name ??
      (user.email != null ? user.email!.split('@').first : '');

  final paymentResponse = await supabase
      .from('trainee_monthly_payments')
      .select('paid, month_start')
      .eq('trainee_id', user.id)
      .order('month_start', ascending: false)
      .limit(1)
      .maybeSingle();

  final isPayed = paymentResponse?['paid'] as bool? ?? false;

  return UserProfileData(
    userId: user.id,
    email: user.email ?? '',
    username: name,
    isActive: true,
    isPayed: isPayed,
    profile: profile,
  );
}

Future<void> logout(BuildContext context) async {
  final scaffoldMessenger = ScaffoldMessenger.of(context);
  final l10n = AppLocalizations.of(context)!;
  try {
    await supabase.auth.signOut();
    if (context.mounted) {
      Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute(builder: (context) => const LoginPage()),
        (route) => false,
      );
    }
  } catch (e) {
    scaffoldMessenger.showSnackBar(
      SnackBar(content: Text(l10n.logoutError('$e'))),
    );
  }
}

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  late Future<UserProfileData> _profileFuture;

  @override
  void initState() {
    super.initState();
    _profileFuture = getUserData();
  }

  void _refreshProfile() {
    setState(() {
      _profileFuture = getUserData();
    });
  }

  void _showLanguagePicker() {
    final l10n = AppLocalizations.of(context)!;
    final controller = LocaleControllerScope.of(context);
    showModalBottomSheet<void>(
      context: context,
      builder: (context) => AnimatedBuilder(
        animation: controller,
        builder: (context, _) {
          final options = <(String?, String)>[
            (null, l10n.languageSystemLabel),
            ('en', l10n.languageEnglishLabel),
            ('es', l10n.languageSpanishLabel),
            ('it', l10n.languageItalianLabel),
          ];
          final currentCode = controller.locale?.languageCode;
          return SafeArea(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    l10n.profileLanguageSettingsTitle,
                    style: Theme.of(context)
                        .textTheme
                        .titleMedium
                        ?.copyWith(fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 12),
                  Card(
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                    child: RadioGroup<String?>(
                      groupValue: currentCode,
                      onChanged: (value) {
                        controller.setLocale(
                          value == null ? null : Locale(value),
                        );
                      },
                      child: Column(
                        children: [
                          for (final option in options)
                            RadioListTile<String?>(
                              value: option.$1,
                              title: Text(option.$2),
                            ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  String _currentLanguageLabel(AppLocalizations l10n, Locale? locale) {
    switch (locale?.languageCode) {
      case 'en':
        return l10n.languageEnglishLabel;
      case 'es':
        return l10n.languageSpanishLabel;
      case 'it':
        return l10n.languageItalianLabel;
      default:
        return l10n.languageSystemLabel;
    }
  }

  Future<void> _showEditProfile(UserProfileData data) async {
    final l10n = AppLocalizations.of(context)!;
    final updated = await showModalBottomSheet<bool>(
      context: context,
      isScrollControlled: true,
      builder: (context) => _EditProfileBottomSheet(data: data),
    );
    if (updated == true && mounted) {
      _refreshProfile();
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text(l10n.profileEditSuccess)));
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return Scaffold(
      body: SafeArea(
        child: FutureBuilder<UserProfileData>(
          future: _profileFuture,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            }

            if (snapshot.hasError) {
              final rawError = snapshot.error.toString();
              final errorText = rawError.contains('user-not-authenticated')
                  ? l10n.unauthenticated
                  : rawError.contains('user-not-found')
                      ? l10n.userNotFound
                      : rawError;
              return Center(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.error_outline, size: 48),
                      const SizedBox(height: 16),
                      Text(
                        l10n.profileLoadError,
                        style: Theme.of(context).textTheme.titleMedium,
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 8),
                      Text(
                        errorText,
                        style: Theme.of(context).textTheme.bodySmall,
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                ),
              );
            }

            final data = snapshot.data;
            if (data == null) {
              return Center(child: Text(l10n.profileNoData));
            }

            final theme = Theme.of(context);
            final colorScheme = theme.colorScheme;
            final appColors = theme.extension<AppColors>()!;
            final statusChipTextStyle =
                theme.textTheme.labelMedium?.copyWith(color: colorScheme.onPrimary);
            final displayName = data.displayName(l10n);
            final emailText = data.email.isEmpty ? l10n.profileEmailUnavailable : data.email;
            final weight = data.profile?.weight;
            final weightText = weight != null
                ? l10n.profileWeightValue(weight.toStringAsFixed(1))
                : l10n.profileNotSet;
            final height = data.profile?.height;
            final heightText = height != null
                ? l10n.profileHeightValue(height.toStringAsFixed(1))
                : l10n.profileNotSet;
            final profileImageUrl = data.profile?.profileImageUrl;
            final localeController = LocaleControllerScope.of(context);
            final currentLanguageLabel =
                _currentLanguageLabel(l10n, localeController.locale);

            return SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  const SizedBox(height: 16),
                  CircleAvatar(
                    radius: 40,
                    backgroundColor: colorScheme.surfaceContainerHighest,
                    backgroundImage:
                        profileImageUrl == null ? null : NetworkImage(profileImageUrl),
                    child: profileImageUrl == null
                        ? Text(
                            data.initials(l10n),
                            style: theme.textTheme.titleLarge
                                ?.copyWith(color: colorScheme.onSurface),
                          )
                        : null,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    displayName,
                    style: theme.textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    emailText,
                    style: theme.textTheme.bodyMedium?.copyWith(color: theme.colorScheme.onSurfaceVariant),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 16),
                  Wrap(
                    alignment: WrapAlignment.center,
                    spacing: 8,
                    runSpacing: 8,
                    children: [
                      Chip(
                        avatar: Icon(
                          data.isActive ? Icons.check_circle : Icons.pause_circle_filled,
                          color: colorScheme.onPrimary,
                        ),
                        label: Text(
                          data.isActive ? l10n.profileStatusActive : l10n.profileStatusInactive,
                          style: statusChipTextStyle,
                        ),
                        backgroundColor:
                            data.isActive ? appColors.success : colorScheme.outlineVariant,
                      ),
                      Chip(
                        avatar: Icon(
                          data.isPayed ? Icons.workspace_premium : Icons.lock_clock,
                          color: colorScheme.onPrimary,
                        ),
                        label: Text(
                          data.isPayed ? l10n.profilePlanActive : l10n.profilePlanExpired,
                          style: statusChipTextStyle,
                        ),
                        backgroundColor:
                            data.isPayed ? colorScheme.secondary : appColors.warning,
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),
                  Card(
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                    child: Column(
                      children: [
                        ListTile(
                          leading: const Icon(Icons.badge_outlined),
                          title: Text(l10n.profileUsername),
                          subtitle: Text(data.username.isEmpty ? '-' : data.username),
                        ),
                        const Divider(height: 0),
                        ListTile(
                          leading: const Icon(Icons.monitor_weight_outlined),
                          title: Text(l10n.profileWeight),
                          subtitle: Text(weightText),
                        ),
                        const Divider(height: 0),
                        ListTile(
                          leading: const Icon(Icons.height),
                          title: Text(l10n.profileHeight),
                          subtitle: Text(heightText),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),
                  Card(
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                    child: ListTile(
                      leading: const Icon(Icons.edit_outlined),
                      title: Text(l10n.profileEdit),
                      subtitle: Text(l10n.profileEditSubtitle),
                      onTap: () => _showEditProfile(data),
                    ),
                  ),
                  const SizedBox(height: 12),
                  Card(
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                    child: ListTile(
                      leading: const Icon(Icons.palette_outlined),
                      title: Text(l10n.profileThemeSettingsTitle),
                      subtitle: Text(l10n.profileThemeSettingsSubtitle),
                      onTap: () {
                        Navigator.of(context).push(
                          MaterialPageRoute(builder: (context) => const SettingsPage()),
                        );
                      },
                    ),
                  ),
                  const SizedBox(height: 12),
                  Card(
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                    child: ListTile(
                      leading: const Icon(Icons.language_outlined),
                      title: Text(l10n.profileLanguageSettingsTitle),
                      subtitle: Text(l10n.profileLanguageSettingsSubtitle),
                      trailing: Text(currentLanguageLabel),
                      onTap: _showLanguagePicker,
                    ),
                  ),
                  const SizedBox(height: 12),
                  SizedBox(
                    width: double.infinity,
                    child: FilledButton.icon(
                      onPressed: () => logout(context),
                      icon: const Icon(Icons.logout),
                      label: Text(l10n.logout),
                    ),
                  ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }
}

class _EditProfileBottomSheet extends StatefulWidget {
  const _EditProfileBottomSheet({required this.data});

  final UserProfileData data;

  @override
  State<_EditProfileBottomSheet> createState() => _EditProfileBottomSheetState();
}

class _EditProfileBottomSheetState extends State<_EditProfileBottomSheet> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _fullNameController;
  late final TextEditingController _weightController;
  late final TextEditingController _heightController;
  final ImagePicker _imagePicker = ImagePicker();
  Uint8List? _selectedImageBytes;
  String? _selectedImageName;
  String? _selectedImageUrl;
  bool _isSubmitting = false;

  @override
  void initState() {
    super.initState();
    _fullNameController = TextEditingController(text: widget.data.profile?.name ?? '');
    final weight = widget.data.profile?.weight;
    _weightController = TextEditingController(text: weight != null ? '$weight' : '');
    final height = widget.data.profile?.height;
    _heightController = TextEditingController(text: height != null ? '$height' : '');
    _selectedImageUrl = widget.data.profile?.profileImageUrl;
  }

  @override
  void dispose() {
    _fullNameController.dispose();
    _weightController.dispose();
    _heightController.dispose();
    super.dispose();
  }

  Future<void> _pickProfileImage() async {
    if (_isSubmitting) return;
    final image = await _imagePicker.pickImage(source: ImageSource.gallery, imageQuality: 85);
    if (image == null) return;
    final bytes = await image.readAsBytes();
    if (!mounted) return;
    setState(() {
      _selectedImageBytes = bytes;
      _selectedImageName = image.name;
    });
  }

  Future<String?> _uploadProfileImage() async {
    if (_selectedImageBytes == null || _selectedImageBytes!.isEmpty) {
      return _selectedImageUrl;
    }

    final safeName = (_selectedImageName ?? 'profile.jpg').replaceAll(' ', '_');
    final path = '${widget.data.userId}/$safeName';

    await supabase.storage.from('avatars').uploadBinary(
          path,
          _selectedImageBytes!,
          fileOptions: const FileOptions(upsert: true),
        );

    return supabase.storage.from('avatars').getPublicUrl(path);
  }

  Future<void> _submit() async {
    if (_isSubmitting) return;
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isSubmitting = true;
    });

    final fullName = _fullNameController.text.trim();
    final weightText = _weightController.text.trim().replaceAll(',', '.');
    final weightValue = weightText.isEmpty ? null : double.tryParse(weightText);
    final heightText = _heightController.text.trim().replaceAll(',', '.');
    final heightValue = heightText.isEmpty ? null : double.tryParse(heightText);
    String? imageUrl;

    try {
      imageUrl = await _uploadProfileImage();
    } catch (error) {
      if (!mounted) return;
      final l10n = AppLocalizations.of(context)!;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(l10n.profileEditError(error.toString()))),
      );
      setState(() {
        _isSubmitting = false;
      });
      return;
    }

    final updates = <String, dynamic>{
      'name': fullName.isEmpty ? null : fullName,
      'weight': weightValue,
      'height': heightValue,
      'profile_image_url': imageUrl,
    };

    try {
      await supabase.from('trainees').update(updates).eq('id', widget.data.userId);
      await ProfileImageCache.saveForUser(widget.data.userId, imageUrl);
      if (!mounted) return;
      Navigator.of(context).pop(true);
    } catch (error) {
      if (!mounted) return;
      final l10n = AppLocalizations.of(context)!;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(l10n.profileEditError(error.toString()))),
      );
      setState(() {
        _isSubmitting = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final bottomInset = MediaQuery.of(context).viewInsets.bottom;

    return Padding(
      padding: EdgeInsets.only(
        left: 24,
        right: 24,
        top: 24,
        bottom: bottomInset + 24,
      ),
      child: SafeArea(
        child: SingleChildScrollView(
          child: Form(
            key: _formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  l10n.profileEditTitle,
                  style: Theme.of(context)
                      .textTheme
                      .titleLarge
                      ?.copyWith(fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 16),
                Center(
                  child: Column(
                    children: [
                      CircleAvatar(
                        minRadius: 40,
                        maxRadius: 60,
                        backgroundColor: Theme.of(context)
                            .colorScheme
                            .surfaceContainerHighest,
                        backgroundImage: _selectedImageBytes == null
                            ? (_selectedImageUrl == null
                                ? null
                                : NetworkImage(_selectedImageUrl!))
                            : MemoryImage(_selectedImageBytes!),
                        child: (_selectedImageBytes == null && _selectedImageUrl == null)
                            ? Text(
                                widget.data.initials(l10n),
                                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                                      color: Theme.of(context).colorScheme.onSurface,
                                    ),
                              )
                            : null,
                      ),
                      const SizedBox(height: 8),
                      TextButton.icon(
                        onPressed: _pickProfileImage,
                        icon: const Icon(Icons.photo_camera_outlined),
                        label: Text(l10n.profilePhotoEdit),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _fullNameController,
                  decoration: InputDecoration(
                    labelText: l10n.profileEditFullNameLabel,
                    hintText: l10n.profileEditFullNameHint,
                  ),
                  textCapitalization: TextCapitalization.words,
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return l10n.profileEditFullNameHint;
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 12),
                TextFormField(
                  controller: _weightController,
                  decoration: InputDecoration(
                    labelText: l10n.profileEditWeightLabel,
                    hintText: l10n.profileEditWeightHint,
                  ),
                  keyboardType:
                      const TextInputType.numberWithOptions(decimal: true, signed: false),
                  validator: (value) {
                    final text = value?.trim();
                    if (text == null || text.isEmpty) {
                      return null;
                    }
                    final parsed = double.tryParse(text.replaceAll(',', '.'));
                    if (parsed == null || parsed <= 0) {
                      return l10n.profileEditWeightInvalid;
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 12),
                TextFormField(
                  controller: _heightController,
                  decoration: InputDecoration(
                    labelText: l10n.profileEditHeightLabel,
                    hintText: l10n.profileEditHeightHint,
                  ),
                  keyboardType:
                      const TextInputType.numberWithOptions(decimal: true, signed: false),
                  validator: (value) {
                    final text = value?.trim();
                    if (text == null || text.isEmpty) {
                      return null;
                    }
                    final parsed = double.tryParse(text.replaceAll(',', '.'));
                    if (parsed == null || parsed <= 0) {
                      return l10n.profileEditHeightInvalid;
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 24),
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton(
                        onPressed: _isSubmitting
                            ? null
                            : () {
                                Navigator.of(context).pop(false);
                              },
                        child: Text(l10n.profileEditCancel),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: FilledButton(
                        onPressed: _isSubmitting ? null : _submit,
                        child: _isSubmitting
                            ? SizedBox(
                                height: 20,
                                width: 20,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  valueColor: AlwaysStoppedAnimation<Color>(
                                    Theme.of(context).colorScheme.onPrimary,
                                  ),
                                ),
                              )
                            : Text(l10n.profileEditSave),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
