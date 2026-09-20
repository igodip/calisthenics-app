import 'package:flutter/material.dart';

import '../../l10n/app_localizations.dart';
import '../admin_models.dart';
import '../admin_repository.dart';

class AdminConsolePage extends StatefulWidget {
  const AdminConsolePage({super.key});

  @override
  State<AdminConsolePage> createState() => _AdminConsolePageState();
}

class _AdminConsolePageState extends State<AdminConsolePage> {
  final _repository = AdminRepository();
  final _searchController = TextEditingController();
  final _busyUsers = <String>{};
  bool _loading = true;
  Object? _error;
  List<AdminUser> _users = const [];
  List<AdminAssignment> _assignments = const [];
  String _query = '';

  @override
  void initState() {
    super.initState();
    _load();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _load() async {
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      final results = await Future.wait([
        _repository.loadUsers(),
        _repository.loadAssignments(),
      ]);
      if (!mounted) return;
      setState(() {
        _users = results[0] as List<AdminUser>;
        _assignments = results[1] as List<AdminAssignment>;
      });
    } catch (error) {
      if (mounted) setState(() => _error = error);
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  void _showError(Object error) {
    if (!mounted) return;
    final l10n = AppLocalizations.of(context)!;
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(l10n.adminActionFailed('$error'))));
  }

  Future<bool> _confirm(String title, String message) async {
    final l10n = AppLocalizations.of(context)!;
    return await showDialog<bool>(
          context: context,
          builder: (context) => AlertDialog(
            title: Text(title),
            content: Text(message),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context, false),
                child: Text(l10n.adminCancel),
              ),
              FilledButton(
                onPressed: () => Navigator.pop(context, true),
                child: Text(l10n.adminConfirm),
              ),
            ],
          ),
        ) ??
        false;
  }

  Future<void> _setTrainer(AdminUser user, bool enabled) async {
    final l10n = AppLocalizations.of(context)!;
    if (!enabled &&
        !await _confirm(
          l10n.adminConfirmRevokeTitle,
          l10n.adminConfirmRevokeMessage(user.name),
        )) {
      return;
    }
    setState(() => _busyUsers.add(user.id));
    try {
      await _repository.setTrainer(user, enabled);
      if (!mounted) return;
      setState(() {
        _users = _users
            .map(
              (item) =>
                  item.id == user.id ? item.copyWith(isTrainer: enabled) : item,
            )
            .toList();
        if (!enabled) {
          _assignments = _assignments
              .where((item) => item.trainerId != user.id)
              .toList();
        }
      });
    } catch (error) {
      _showError(error);
    } finally {
      if (mounted) setState(() => _busyUsers.remove(user.id));
    }
  }

  Future<void> _setSuspended(AdminUser user, bool suspended) async {
    final l10n = AppLocalizations.of(context)!;
    if (suspended &&
        !await _confirm(
          l10n.adminConfirmSuspendTitle,
          l10n.adminConfirmSuspendMessage(user.name),
        )) {
      return;
    }
    setState(() => _busyUsers.add(user.id));
    try {
      await _repository.setSuspended(user, suspended);
      if (!mounted) return;
      setState(() {
        _users = _users
            .map(
              (item) => item.id == user.id
                  ? item.copyWith(isSuspended: suspended)
                  : item,
            )
            .toList();
      });
    } catch (error) {
      _showError(error);
    } finally {
      if (mounted) setState(() => _busyUsers.remove(user.id));
    }
  }

  Future<void> _addAssignment() async {
    final l10n = AppLocalizations.of(context)!;
    final trainees = _users.where((user) => user.isTrainee).toList();
    final trainers = _users.where((user) => user.isTrainer).toList();
    String? traineeId;
    String? trainerId;
    final selection = await showDialog<(String, String)>(
      context: context,
      builder: (dialogContext) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          title: Text(l10n.adminAddAssignment),
          content: SizedBox(
            width: 420,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                DropdownButtonFormField<String>(
                  initialValue: trainerId,
                  decoration: InputDecoration(
                    labelText: l10n.adminAssignmentTrainer,
                  ),
                  items: trainers
                      .map(
                        (user) => DropdownMenuItem(
                          value: user.id,
                          child: Text(user.name),
                        ),
                      )
                      .toList(),
                  onChanged: (value) => setDialogState(() => trainerId = value),
                ),
                const SizedBox(height: 16),
                DropdownButtonFormField<String>(
                  initialValue: traineeId,
                  decoration: InputDecoration(
                    labelText: l10n.adminAssignmentTrainee,
                  ),
                  items: trainees
                      .map(
                        (user) => DropdownMenuItem(
                          value: user.id,
                          child: Text(user.name),
                        ),
                      )
                      .toList(),
                  onChanged: (value) => setDialogState(() => traineeId = value),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(dialogContext),
              child: Text(l10n.adminCancel),
            ),
            FilledButton(
              onPressed: traineeId == null || trainerId == null
                  ? null
                  : () =>
                        Navigator.pop(dialogContext, (traineeId!, trainerId!)),
              child: Text(l10n.adminConfirm),
            ),
          ],
        ),
      ),
    );
    if (selection == null) return;
    try {
      await _repository.setAssignment(
        traineeId: selection.$1,
        trainerId: selection.$2,
        assigned: true,
      );
      await _load();
    } catch (error) {
      _showError(error);
    }
  }

  Future<void> _removeAssignment(AdminAssignment assignment) async {
    try {
      await _repository.setAssignment(
        traineeId: assignment.traineeId,
        trainerId: assignment.trainerId,
        assigned: false,
      );
      if (!mounted) return;
      setState(() {
        _assignments = _assignments
            .where(
              (item) =>
                  item.traineeId != assignment.traineeId ||
                  item.trainerId != assignment.trainerId,
            )
            .toList();
      });
    } catch (error) {
      _showError(error);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    if (_loading && _users.isEmpty) {
      return const Center(child: CircularProgressIndicator());
    }
    if (_error != null && _users.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(l10n.adminLoadError('$_error'), textAlign: TextAlign.center),
              const SizedBox(height: 12),
              FilledButton(onPressed: _load, child: Text(l10n.trainerRetry)),
            ],
          ),
        ),
      );
    }

    return DefaultTabController(
      length: 3,
      child: Column(
        children: [
          TabBar(
            tabs: [
              Tab(text: l10n.adminOverview, icon: const Icon(Icons.dashboard)),
              Tab(text: l10n.adminUsers, icon: const Icon(Icons.people)),
              Tab(
                text: l10n.adminAssignments,
                icon: const Icon(Icons.account_tree),
              ),
            ],
          ),
          Expanded(
            child: TabBarView(
              children: [
                _buildOverview(l10n),
                _buildUsers(l10n),
                _buildAssignments(l10n),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildOverview(AppLocalizations l10n) {
    final metrics = [
      (l10n.adminTotalUsers, _users.length, Icons.people_outline),
      (
        l10n.adminTrainees,
        _users.where((user) => user.isTrainee).length,
        Icons.fitness_center,
      ),
      (
        l10n.adminTrainers,
        _users.where((user) => user.isTrainer).length,
        Icons.sports,
      ),
      (
        l10n.adminSuspended,
        _users.where((user) => user.isSuspended).length,
        Icons.person_off_outlined,
      ),
    ];
    return RefreshIndicator(
      onRefresh: _load,
      child: GridView.builder(
        padding: const EdgeInsets.all(16),
        gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
          maxCrossAxisExtent: 260,
          mainAxisExtent: 150,
          crossAxisSpacing: 12,
          mainAxisSpacing: 12,
        ),
        itemCount: metrics.length,
        itemBuilder: (context, index) {
          final metric = metrics[index];
          return Card(
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Icon(metric.$3, color: Theme.of(context).colorScheme.primary),
                  const Spacer(),
                  Text(
                    '${metric.$2}',
                    style: Theme.of(context).textTheme.headlineMedium,
                  ),
                  Text(metric.$1),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildUsers(AppLocalizations l10n) {
    final query = _query.toLowerCase();
    final users = _users.where((user) {
      return query.isEmpty ||
          user.name.toLowerCase().contains(query) ||
          user.email.toLowerCase().contains(query);
    }).toList();
    return RefreshIndicator(
      onRefresh: _load,
      child: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          TextField(
            controller: _searchController,
            decoration: InputDecoration(
              prefixIcon: const Icon(Icons.search),
              labelText: l10n.adminSearchUsers,
              suffixIcon: _query.isEmpty
                  ? null
                  : IconButton(
                      onPressed: () {
                        _searchController.clear();
                        setState(() => _query = '');
                      },
                      icon: const Icon(Icons.clear),
                    ),
            ),
            onChanged: (value) => setState(() => _query = value.trim()),
          ),
          const SizedBox(height: 12),
          if (users.isEmpty)
            Padding(
              padding: const EdgeInsets.all(32),
              child: Center(child: Text(l10n.adminNoUsers)),
            ),
          for (final user in users) _buildUserCard(user, l10n),
        ],
      ),
    );
  }

  Widget _buildUserCard(AdminUser user, AppLocalizations l10n) {
    final current = user.id == _repository.currentUserId;
    final busy = _busyUsers.contains(user.id);
    final roles = [
      if (user.isAdmin) l10n.adminRoleAdmin,
      if (user.isTrainer) l10n.adminRoleTrainer,
      if (user.isTrainee) l10n.adminRoleTrainee,
    ].join(' · ');
    return Card(
      margin: const EdgeInsets.only(bottom: 10),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Row(
          children: [
            CircleAvatar(
              child: busy
                  ? const SizedBox(
                      width: 18,
                      height: 18,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : Text(user.name.isEmpty ? '?' : user.name[0].toUpperCase()),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    user.name,
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                  if (user.email.isNotEmpty) Text(user.email),
                  Text(roles),
                  Text(
                    current
                        ? l10n.adminCurrentAccount
                        : user.isSuspended
                        ? l10n.adminAccessSuspended
                        : l10n.adminAccessActive,
                    style: TextStyle(
                      color: user.isSuspended
                          ? Theme.of(context).colorScheme.error
                          : Theme.of(context).colorScheme.primary,
                    ),
                  ),
                ],
              ),
            ),
            PopupMenuButton<String>(
              enabled: !busy,
              onSelected: (action) {
                if (action == 'trainer') {
                  _setTrainer(user, !user.isTrainer);
                } else if (action == 'access') {
                  _setSuspended(user, !user.isSuspended);
                }
              },
              itemBuilder: (context) => [
                PopupMenuItem(
                  value: 'trainer',
                  child: Text(
                    user.isTrainer
                        ? l10n.adminRevokeTrainer
                        : l10n.adminGrantTrainer,
                  ),
                ),
                if (!current)
                  PopupMenuItem(
                    value: 'access',
                    child: Text(
                      user.isSuspended
                          ? l10n.adminRestoreAccess
                          : l10n.adminSuspend,
                    ),
                  ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAssignments(AppLocalizations l10n) {
    return RefreshIndicator(
      onRefresh: _load,
      child: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Align(
            alignment: Alignment.centerRight,
            child: FilledButton.icon(
              onPressed: _addAssignment,
              icon: const Icon(Icons.add),
              label: Text(l10n.adminAddAssignment),
            ),
          ),
          const SizedBox(height: 12),
          if (_assignments.isEmpty)
            Padding(
              padding: const EdgeInsets.all(32),
              child: Center(child: Text(l10n.adminNoAssignments)),
            ),
          for (final assignment in _assignments)
            Card(
              child: ListTile(
                leading: const Icon(Icons.account_tree_outlined),
                title: Text(assignment.traineeName),
                subtitle: Text(assignment.trainerName),
                trailing: IconButton(
                  tooltip: l10n.adminRemoveAssignment,
                  onPressed: () => _removeAssignment(assignment),
                  icon: const Icon(Icons.link_off),
                ),
              ),
            ),
        ],
      ),
    );
  }
}
