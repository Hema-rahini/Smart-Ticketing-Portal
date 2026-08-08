import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/utils/app_translations.dart';
import '../../../settings/providers/settings_provider.dart';
import '../../providers/dashboard_provider.dart';

class TicketPriorityChart extends ConsumerWidget {
  const TicketPriorityChart({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final langCode = ref.watch(settingsProvider).languageCode;
    final dashboardData = ref.watch(dashboardProvider.notifier).data;
    final priorityCounts = dashboardData?.priorityCounts ?? {};

    final highCount = priorityCounts['high'] ?? 0;
    final mediumCount = priorityCounts['medium'] ?? 0;
    final lowCount = priorityCounts['low'] ?? 0;

    final maxVal = max(1, max(highCount, max(mediumCount, lowCount)));

    final priorities = [
      {'label': AppTranslations.translate('High', langCode), 'count': highCount, 'max': maxVal, 'color': const Color(0xFFEF4444)},
      {'label': AppTranslations.translate('Medium', langCode), 'count': mediumCount, 'max': maxVal, 'color': const Color(0xFFF59E0B)},
      {'label': AppTranslations.translate('Low', langCode), 'count': lowCount, 'max': maxVal, 'color': const Color(0xFF10B981)},
    ];

    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(color: Colors.grey.withValues(alpha: 0.2)),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              AppTranslations.translate('Tickets by Priority', langCode),
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
            const SizedBox(height: 16),
            Column(
              children: priorities.map((item) {
                final count = item['count'] as int;
                final maxVal = item['max'] as int;
                final factor = count / maxVal;
                final color = item['color'] as Color;

                return Padding(
                  padding: const EdgeInsets.symmetric(vertical: 8.0),
                  child: Row(
                    children: [
                      SizedBox(
                        width: 70,
                        child: Text(
                          item['label'] as String,
                          style: const TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      Expanded(
                        child: Stack(
                          children: [
                            Container(
                              height: 24,
                              decoration: BoxDecoration(
                                color: Colors.grey.withValues(alpha: 0.1),
                                borderRadius: BorderRadius.circular(6),
                              ),
                            ),
                            FractionallySizedBox(
                              widthFactor: factor.clamp(0.05, 1.0),
                              child: Container(
                                height: 24,
                                decoration: BoxDecoration(
                                  color: color,
                                  borderRadius: BorderRadius.circular(6),
                                ),
                                alignment: Alignment.centerRight,
                                padding: const EdgeInsets.only(right: 8),
                                child: Text(
                                  '$count',
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 11,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                );
              }).toList(),
            ),
          ],
        ),
      ),
    );
  }
}
