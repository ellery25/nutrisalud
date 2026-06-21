import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../../../core/themes/app_spacing.dart';

/// Minimal 7-day bar chart (no chart package). Values are 0..1, oldest→today.
class WeekBarChart extends StatelessWidget {
  const WeekBarChart({
    super.key,
    required this.values,
    this.height = 96,
    this.labels,
  });

  /// 7 normalized values (0..1), index 0 = six days ago, index 6 = today.
  final List<double> values;
  final double height;

  /// Optional weekday labels; defaults to locale weekday initials.
  final List<String>? labels;

  List<String> _defaultLabels() {
    final today = DateTime.now();
    final format = DateFormat.E();
    return List.generate(values.length, (i) {
      final day = today.subtract(Duration(days: values.length - 1 - i));
      final name = format.format(day);
      return name.isEmpty ? '' : name.substring(0, 1);
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final dayLabels = labels ?? _defaultLabels();

    return SizedBox(
      height: height,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          for (var i = 0; i < values.length; i++)
            Expanded(
              child: Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: AppSpacing.xs / 2),
                child: Column(
                  children: [
                    Expanded(
                      child: Container(
                        width: double.infinity,
                        clipBehavior: Clip.antiAlias,
                        decoration: BoxDecoration(
                          color: theme.colorScheme.surfaceContainerHighest,
                          borderRadius: BorderRadius.circular(AppRadius.sm),
                        ),
                        child: Align(
                          alignment: Alignment.bottomCenter,
                          child: TweenAnimationBuilder<double>(
                            tween: Tween(
                              begin: 0,
                              end: values[i].clamp(0.0, 1.0),
                            ),
                            duration: const Duration(milliseconds: 300),
                            curve: Curves.easeOut,
                            builder: (context, factor, _) =>
                                FractionallySizedBox(
                              heightFactor: factor,
                              widthFactor: 1,
                              child: DecoratedBox(
                                decoration: BoxDecoration(
                                  color: values[i] >= 1.0
                                      ? theme.colorScheme.primary
                                      : theme.colorScheme.primary
                                          .withValues(alpha: 0.6),
                                  borderRadius:
                                      BorderRadius.circular(AppRadius.sm),
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: AppSpacing.xs),
                    Text(
                      i < dayLabels.length ? dayLabels[i] : '',
                      style: theme.textTheme.labelSmall?.copyWith(
                        color: theme.colorScheme.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
              ),
            ),
        ],
      ),
    );
  }
}
