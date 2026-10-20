import 'package:calisync/admin/admin_models.dart';
import 'package:calisync/admin/admin_repository.dart';
import 'package:flutter/material.dart';

import '../../l10n/app_localizations.dart';

class AdminBugReportsPage extends StatefulWidget {
  const AdminBugReportsPage({super.key});

  @override
  State<AdminBugReportsPage> createState() => _AdminBugReportsPageState();
}

class _AdminBugReportsPageState extends State<AdminBugReportsPage> {
  final _repository = AdminRepository();
  final _searchController = TextEditingController();
  late Future<List<BugReport>> _reportsFuture;
  String _query = '';

  @override
  void initState() {
    super.initState();
    _reportsFuture = _repository.loadBugReports();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _refresh() {
    final future = _repository.loadBugReports();
    setState(() => _reportsFuture = future);
    return future.then<void>(
      (_) {},
      onError: (Object error, StackTrace stackTrace) {},
    );
  }

  Future<bool> _updateReportStatus(BugReport report, String status) async {
    final l10n = AppLocalizations.of(context)!;
    try {
      await _repository.updateBugReportStatus(
        reportId: report.id,
        status: status,
      );
      if (!mounted) return false;
      setState(() {
        _reportsFuture = _reportsFuture.then(
          (reports) => reports
              .map(
                (item) => item.id == report.id
                    ? item.copyWith(status: status)
                    : item,
              )
              .toList(),
        );
      });
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(l10n.adminBugReportStatusUpdated)));
      return true;
    } catch (error) {
      if (!mounted) return false;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(l10n.adminBugReportUpdateFailed('$error'))),
      );
      return false;
    }
  }

  bool _matchesQuery(BugReport report) {
    final query = _query.trim().toLowerCase();
    if (query.isEmpty) return true;

    return [
      report.title,
      report.description,
      report.reproductionSteps,
      report.expectedBehavior,
      report.actualBehavior,
      report.platform,
      report.appVersion,
      report.reporterId,
      report.status,
    ].any((value) => value.toLowerCase().contains(query));
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return Scaffold(
      body: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 760),
            child: RefreshIndicator(
              onRefresh: _refresh,
              child: FutureBuilder<List<BugReport>>(
                future: _reportsFuture,
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return ListView(
                      physics: const AlwaysScrollableScrollPhysics(),
                      padding: const EdgeInsets.fromLTRB(20, 24, 20, 28),
                      children: [
                        _pageHeading(context, l10n),
                        const SizedBox(height: 48),
                        const Center(child: CircularProgressIndicator()),
                      ],
                    );
                  }

                  if (snapshot.hasError) {
                    return ListView(
                      physics: const AlwaysScrollableScrollPhysics(),
                      padding: const EdgeInsets.fromLTRB(20, 24, 20, 28),
                      children: [
                        _pageHeading(context, l10n),
                        const SizedBox(height: 24),
                        _LoadError(
                          message: l10n.adminBugReportsLoadError(
                            '${snapshot.error}',
                          ),
                          retryLabel: l10n.trainerRetry,
                          onRetry: _refresh,
                        ),
                      ],
                    );
                  }

                  final reports = snapshot.data ?? const <BugReport>[];
                  final filteredReports = reports.where(_matchesQuery).toList();

                  return ListView(
                    physics: const AlwaysScrollableScrollPhysics(),
                    padding: const EdgeInsets.fromLTRB(20, 24, 20, 28),
                    children: [
                      _pageHeading(context, l10n),
                      if (reports.isEmpty) ...[
                        const SizedBox(height: 32),
                        _EmptyState(
                          icon: Icons.inbox_outlined,
                          message: l10n.adminBugReportsEmpty,
                        ),
                      ] else ...[
                        const SizedBox(height: 24),
                        _StatusSummary(reports: reports, l10n: l10n),
                        const SizedBox(height: 20),
                        TextField(
                          controller: _searchController,
                          onChanged: (value) => setState(() => _query = value),
                          decoration: InputDecoration(
                            labelText: l10n.adminBugReportsSearch,
                            prefixIcon: const Icon(Icons.search),
                            suffixIcon: _query.isEmpty
                                ? null
                                : IconButton(
                                    tooltip: MaterialLocalizations.of(
                                      context,
                                    ).closeButtonTooltip,
                                    onPressed: () {
                                      _searchController.clear();
                                      setState(() => _query = '');
                                    },
                                    icon: const Icon(Icons.close),
                                  ),
                            border: const OutlineInputBorder(),
                          ),
                        ),
                        const SizedBox(height: 16),
                        if (filteredReports.isEmpty)
                          _EmptyState(
                            icon: Icons.search_off,
                            message: l10n.adminBugReportsNoResults,
                          )
                        else
                          ...filteredReports.map(
                            (report) => Padding(
                              padding: const EdgeInsets.only(bottom: 12),
                              child: _BugReportCard(
                                report: report,
                                l10n: l10n,
                                onStatusChanged: (status) =>
                                    _updateReportStatus(report, status),
                              ),
                            ),
                          ),
                      ],
                    ],
                  );
                },
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _pageHeading(BuildContext context, AppLocalizations l10n) {
    final theme = Theme.of(context);
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: 48,
          height: 48,
          decoration: BoxDecoration(
            color: theme.colorScheme.primaryContainer,
            borderRadius: BorderRadius.circular(16),
          ),
          child: Icon(
            Icons.bug_report_outlined,
            color: theme.colorScheme.onPrimaryContainer,
          ),
        ),
        const SizedBox(width: 14),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                l10n.adminBugReportsTitle,
                style: theme.textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                l10n.adminBugReportsSubtitle,
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                ),
              ),
            ],
          ),
        ),
        IconButton(
          tooltip: l10n.refresh,
          onPressed: _refresh,
          icon: const Icon(Icons.refresh),
        ),
      ],
    );
  }
}

class _StatusSummary extends StatelessWidget {
  const _StatusSummary({required this.reports, required this.l10n});

  final List<BugReport> reports;
  final AppLocalizations l10n;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final statuses = [
      (
        l10n.adminBugReportStatusOpen,
        _countStatus(reports, 'open'),
        theme.colorScheme.error,
      ),
      (
        l10n.adminBugReportStatusInProgress,
        _countStatus(reports, 'in_progress'),
        theme.colorScheme.tertiary,
      ),
      (
        l10n.adminBugReportStatusResolved,
        _countStatus(reports, 'resolved'),
        theme.colorScheme.primary,
      ),
    ];

    return Card(
      margin: EdgeInsets.zero,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 8),
        child: Row(
          children: [
            for (var index = 0; index < statuses.length; index++) ...[
              if (index > 0)
                SizedBox(
                  height: 36,
                  child: VerticalDivider(
                    width: 1,
                    color: theme.colorScheme.outlineVariant,
                  ),
                ),
              Expanded(
                child: Column(
                  children: [
                    Text(
                      '${statuses[index].$2}',
                      style: theme.textTheme.titleLarge?.copyWith(
                        color: statuses[index].$3,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      statuses[index].$1,
                      textAlign: TextAlign.center,
                      style: theme.textTheme.labelSmall?.copyWith(
                        color: theme.colorScheme.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  int _countStatus(List<BugReport> reports, String status) => reports
      .where((report) => _normalizedStatus(report.status) == status)
      .length;
}

class _BugReportCard extends StatefulWidget {
  const _BugReportCard({
    required this.report,
    required this.l10n,
    required this.onStatusChanged,
  });

  final BugReport report;
  final AppLocalizations l10n;
  final Future<bool> Function(String status) onStatusChanged;

  @override
  State<_BugReportCard> createState() => _BugReportCardState();
}

class _BugReportCardState extends State<_BugReportCard> {
  late String _selectedStatus;
  bool _isUpdating = false;

  @override
  void initState() {
    super.initState();
    _selectedStatus = _normalizedStatus(widget.report.status);
  }

  @override
  void didUpdateWidget(covariant _BugReportCard oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.report.status != widget.report.status) {
      _selectedStatus = _normalizedStatus(widget.report.status);
    }
  }

  Future<void> _changeStatus(String? status) async {
    if (status == null || status == _selectedStatus || _isUpdating) return;
    setState(() => _isUpdating = true);
    final updated = await widget.onStatusChanged(status);
    if (!mounted) return;
    setState(() {
      if (updated) _selectedStatus = status;
      _isUpdating = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final report = widget.report;
    final l10n = widget.l10n;
    final status = _selectedStatus;
    final (statusLabel, statusColor) = switch (status) {
      'open' => (l10n.adminBugReportStatusOpen, theme.colorScheme.error),
      'in_progress' => (
        l10n.adminBugReportStatusInProgress,
        theme.colorScheme.tertiary,
      ),
      'resolved' => (
        l10n.adminBugReportStatusResolved,
        theme.colorScheme.primary,
      ),
      _ => (
        report.status.isEmpty ? l10n.adminBugReportUnavailable : report.status,
        theme.colorScheme.onSurfaceVariant,
      ),
    };

    return Card(
      clipBehavior: Clip.antiAlias,
      margin: EdgeInsets.zero,
      child: ExpansionTile(
        leading: Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            color: statusColor.withValues(alpha: 0.12),
            shape: BoxShape.circle,
          ),
          child: Icon(Icons.bug_report_outlined, color: statusColor, size: 21),
        ),
        title: Text(
          report.title.trim().isEmpty
              ? l10n.adminBugReportUnavailable
              : report.title,
          style: theme.textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.w600,
          ),
        ),
        subtitle: Padding(
          padding: const EdgeInsets.only(top: 6),
          child: Wrap(
            spacing: 8,
            runSpacing: 6,
            crossAxisAlignment: WrapCrossAlignment.center,
            children: [
              _StatusBadge(label: statusLabel, color: statusColor),
              if (report.platform.isNotEmpty)
                Text(
                  '${l10n.adminBugReportPlatform}: ${report.platform}',
                  style: theme.textTheme.labelMedium?.copyWith(
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                ),
              if (report.appVersion.isNotEmpty)
                Text(
                  '${l10n.adminBugReportAppVersion}: ${report.appVersion}',
                  style: theme.textTheme.labelMedium?.copyWith(
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                ),
            ],
          ),
        ),
        childrenPadding: const EdgeInsets.fromLTRB(16, 0, 16, 18),
        children: [
          Align(
            alignment: Alignment.centerLeft,
            child: SizedBox(
              width: double.infinity,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Divider(height: 1),
                  const SizedBox(height: 8),
                  _ReportDetail(
                    label: l10n.adminBugReportDescription,
                    value: report.description,
                  ),
                  _ReportDetail(
                    label: l10n.adminBugReportReproductionSteps,
                    value: report.reproductionSteps,
                  ),
                  _ReportDetail(
                    label: l10n.adminBugReportExpectedBehavior,
                    value: report.expectedBehavior,
                  ),
                  _ReportDetail(
                    label: l10n.adminBugReportActualBehavior,
                    value: report.actualBehavior,
                  ),
                  Padding(
                    padding: const EdgeInsets.only(top: 16),
                    child: DropdownButtonFormField<String>(
                      initialValue: status,
                      isExpanded: true,
                      decoration: InputDecoration(
                        labelText: l10n.adminBugReportStatus,
                        helperText: l10n.adminBugReportChangeStatus,
                        border: const OutlineInputBorder(),
                        suffixIcon: _isUpdating
                            ? const Padding(
                                padding: EdgeInsets.all(12),
                                child: SizedBox(
                                  width: 18,
                                  height: 18,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                  ),
                                ),
                              )
                            : null,
                      ),
                      items: [
                        DropdownMenuItem(
                          value: 'open',
                          child: Text(l10n.adminBugReportStatusOpen),
                        ),
                        DropdownMenuItem(
                          value: 'in_progress',
                          child: Text(l10n.adminBugReportStatusInProgress),
                        ),
                        DropdownMenuItem(
                          value: 'resolved',
                          child: Text(l10n.adminBugReportStatusResolved),
                        ),
                        if (!const ['open', 'in_progress', 'resolved'].contains(
                          status,
                        ))
                          DropdownMenuItem(
                            value: status,
                            child: Text(
                              report.status.isEmpty
                                  ? l10n.adminBugReportUnavailable
                                  : report.status,
                            ),
                          ),
                      ],
                      onChanged: _isUpdating ? null : _changeStatus,
                    ),
                  ),
                  _ReportDetail(
                    label: l10n.adminBugReportReporter,
                    value: report.reporterId,
                  ),
                  _ReportDetail(
                    label: l10n.adminBugReportSubmittedAt,
                    value: _formattedDate(context, report.createdAt, l10n),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  String _formattedDate(
    BuildContext context,
    DateTime? date,
    AppLocalizations l10n,
  ) {
    if (date == null) return l10n.adminBugReportUnavailable;

    final localDate = date.toLocal();
    final time = TimeOfDay.fromDateTime(localDate).format(context);
    return '${MaterialLocalizations.of(context).formatMediumDate(localDate)} · $time';
  }
}

class _StatusBadge extends StatelessWidget {
  const _StatusBadge({required this.label, required this.color});

  final String label;
  final Color color;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 4),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        label,
        style: theme.textTheme.labelSmall?.copyWith(
          color: color,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}

class _ReportDetail extends StatelessWidget {
  const _ReportDetail({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.only(top: 14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            textAlign: TextAlign.left,
            style: theme.textTheme.labelLarge?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            value.trim().isEmpty ? '—' : value,
            textAlign: TextAlign.left,
            style: theme.textTheme.bodyMedium,
          ),
        ],
      ),
    );
  }
}

class _EmptyState extends StatelessWidget {
  const _EmptyState({required this.icon, required this.message});

  final IconData icon;
  final String message;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Card(
      margin: EdgeInsets.zero,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 36),
        child: Column(
          children: [
            Icon(icon, size: 38, color: theme.colorScheme.onSurfaceVariant),
            const SizedBox(height: 12),
            Text(
              message,
              textAlign: TextAlign.center,
              style: theme.textTheme.bodyLarge?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _LoadError extends StatelessWidget {
  const _LoadError({
    required this.message,
    required this.retryLabel,
    required this.onRetry,
  });

  final String message;
  final String retryLabel;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Card(
      margin: EdgeInsets.zero,
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          children: [
            Icon(
              Icons.cloud_off_outlined,
              size: 38,
              color: theme.colorScheme.error,
            ),
            const SizedBox(height: 12),
            Text(message, textAlign: TextAlign.center),
            const SizedBox(height: 16),
            FilledButton.icon(
              onPressed: onRetry,
              icon: const Icon(Icons.refresh),
              label: Text(retryLabel),
            ),
          ],
        ),
      ),
    );
  }
}

String _normalizedStatus(String status) =>
    status.trim().toLowerCase().replaceAll(RegExp(r'[\s-]+'), '_');
