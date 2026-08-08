import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/utils/app_translations.dart';
import '../../../settings/providers/settings_provider.dart';
import '../../providers/dashboard_provider.dart';

class TicketStatusChart extends ConsumerWidget {
  const TicketStatusChart({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final langCode = ref.watch(settingsProvider).languageCode;
    final dashboardData = ref.watch(dashboardProvider.notifier).data;
    final statusCounts = dashboardData?.statusCounts ?? {};

    final total = statusCounts['total'] ?? 0;
    final openCount = statusCounts['open'] ?? 0;
    final inProgressCount = statusCounts['in-progress'] ?? 0;
    final pendingReviewCount = statusCounts['pending-review'] ?? 0;
    final completedCount = statusCounts['completed'] ?? 0;
    final closedCount = statusCounts['closed'] ?? 0;

    int calcPct(int count) => total > 0 ? ((count / total) * 100).round() : 0;

    final statusData = [
      {'label': AppTranslations.translate('Open', langCode), 'percentage': calcPct(openCount), 'color': const Color(0xFF3B82F6)},
      {'label': AppTranslations.translate('In Progress', langCode), 'percentage': calcPct(inProgressCount), 'color': const Color(0xFFF59E0B)},
      {'label': AppTranslations.translate('Completed', langCode), 'percentage': calcPct(completedCount), 'color': const Color(0xFF10B981)},
      {'label': AppTranslations.translate('Pending Review', langCode), 'percentage': calcPct(pendingReviewCount), 'color': const Color(0xFF8B5CF6)},
      {'label': AppTranslations.translate('Closed', langCode), 'percentage': calcPct(closedCount), 'color': const Color(0xFF6B7280)},
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
              AppTranslations.translate('Ticket Status Distribution', langCode),
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                // Custom Donut Painter
                SizedBox(
                  width: 120,
                  height: 120,
                  child: CustomPaint(
                    painter: _DonutChartPainter(statusData),
                    child: const Center(
                      child: Text(
                        '100%',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 14,
                        ),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                // Legend
                Expanded(
                  child: Column(
                    children: statusData.map((item) {
                      return Padding(
                        padding: const EdgeInsets.symmetric(vertical: 3.0),
                        child: Row(
                          children: [
                            Container(
                              width: 10,
                              height: 10,
                              decoration: BoxDecoration(
                                color: item['color'] as Color,
                                shape: BoxShape.circle,
                              ),
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                item['label'] as String,
                                style: const TextStyle(fontSize: 11),
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                            Text(
                              '${item['percentage']}%',
                              style: const TextStyle(
                                fontSize: 11,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                      );
                    }).toList(),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _DonutChartPainter extends CustomPainter {
  final List<Map<String, dynamic>> items;

  _DonutChartPainter(this.items);

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = min(size.width, size.height) / 2;
    const strokeWidth = 16.0;

    final paint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth
      ..strokeCap = StrokeCap.round;

    double startAngle = -pi / 2;

    for (final item in items) {
      final percentage = (item['percentage'] as int) / 100.0;
      final sweepAngle = percentage * 2 * pi;

      if (sweepAngle > 0.01) {
        paint.color = item['color'] as Color;

        canvas.drawArc(
          Rect.fromCircle(center: center, radius: radius - strokeWidth / 2),
          startAngle,
          sweepAngle > 0.05 ? sweepAngle - 0.04 : sweepAngle,
          false,
          paint,
        );
      }

      startAngle += sweepAngle;
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}
