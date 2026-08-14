import 'package:flutter/material.dart';

class TrainerResponsiveList extends StatelessWidget {
  const TrainerResponsiveList({
    super.key,
    required this.children,
    required this.onRefresh,
    this.maxWidth = 960,
  });

  final List<Widget> children;
  final Future<void> Function() onRefresh;
  final double maxWidth;

  static double horizontalPadding(double width) {
    if (width < 360) return 8;
    if (width < 600) return 12;
    if (width < 1000) return 20;
    return 28;
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final padding = horizontalPadding(constraints.maxWidth);
        return RefreshIndicator(
          onRefresh: onRefresh,
          child: ListView(
            keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
            padding: EdgeInsets.fromLTRB(padding, 12, padding, 24),
            children: [
              Center(
                child: ConstrainedBox(
                  key: const ValueKey('trainer-responsive-content'),
                  constraints: BoxConstraints(maxWidth: maxWidth),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: children,
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
