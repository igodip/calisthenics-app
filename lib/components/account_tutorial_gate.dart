import 'dart:async';

import 'package:flutter/material.dart';

import '../data/account_access.dart';
import '../data/account_tutorial_repository.dart';
import '../pages/account_tutorial_page.dart';

/// Runs only inside an authenticated Home, after role/access lookup succeeds.
class AccountTutorialGate extends StatefulWidget {
  const AccountTutorialGate({
    super.key,
    required this.userId,
    required this.access,
    required this.child,
    this.repository,
  });
  final String userId;
  final AccountAccess? access;
  final Widget child;
  final AccountTutorialRepository? repository;

  @override
  State<AccountTutorialGate> createState() => _AccountTutorialGateState();
}

class _AccountTutorialGateState extends State<AccountTutorialGate>
    with WidgetsBindingObserver {
  late final _repository =
      widget.repository ?? AccountTutorialRepository(widget.userId);
  bool _checking = false, _checked = false, _visible = false;
  AccountAccess? _tutorialAccess;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    unawaited(_check());
  }

  @override
  void didUpdateWidget(covariant AccountTutorialGate oldWidget) {
    super.didUpdateWidget(oldWidget);
    unawaited(_check());
  }

  Future<void> _check() async {
    final access = widget.access;
    if (_checking ||
        widget.userId.isEmpty ||
        access == null ||
        !access.isActive) {
      return;
    }
    _checking = true;
    try {
      if (_checked) {
        await _repository.syncPending();
        return;
      }
      final completed = await _repository.hasCompleted();
      if (!mounted) return;
      setState(() {
        _checked = true;
        _visible = !completed;
        _tutorialAccess = access;
      });
    } catch (_) {
      // A failed completion lookup must not block profile/settings/logout.
      // Resume and subsequent role refreshes retry without marking it complete.
    } finally {
      _checking = false;
    }
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) unawaited(_check());
  }

  Future<void> _complete(bool skipped) async {
    await _repository.complete(skipped: skipped);
    if (mounted) setState(() => _visible = false);
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => Stack(
    fit: StackFit.expand,
    children: [
      ExcludeFocus(
        excluding: _visible,
        child: ExcludeSemantics(
          excluding: _visible,
          child: IgnorePointer(ignoring: _visible, child: widget.child),
        ),
      ),
      if (_visible)
        Positioned.fill(
          child: AccountTutorialPage(
            access: _tutorialAccess!,
            onComplete: _complete,
          ),
        ),
    ],
  );
}
