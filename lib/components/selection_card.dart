import 'package:flutter/material.dart';

class SelectionCard extends StatelessWidget {
  const SelectionCard({
    super.key,
    required this.title,
    required this.icon,
    this.onTap,
    this.subtitle,
    this.iconColor,
    this.tileColor,
    this.trailing,
  });

  final String title;
  final IconData icon;
  final VoidCallback? onTap;
  final String? subtitle;
  final Color? iconColor;
  final Color? tileColor;
  final Widget? trailing;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Card(
      clipBehavior: Clip.antiAlias,
      elevation: 3,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: ListTile(
        leading: Icon(
          icon,
          color: iconColor ?? theme.colorScheme.primary,
        ),
        title: Text(title),
        subtitle: subtitle != null ? Text(subtitle!) : null,
        trailing:
            trailing ?? (onTap != null ? const Icon(Icons.arrow_forward_ios) : null),
        onTap: onTap,
        tileColor: tileColor,
        contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 4),
      ),
    );
  }
}
