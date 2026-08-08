import 'package:flutter/material.dart';

class StatusChip extends StatelessWidget {
  final String status;

  const StatusChip({super.key, required this.status});

  @override
  Widget build(BuildContext context) {
    Color bgColor;
    Color textColor;
    Color borderColor;
    IconData icon;

    switch (status.toLowerCase()) {
      case 'in-progress':
        bgColor = const Color(0xFFFEF3C7);
        textColor = const Color(0xFFD97706);
        borderColor = const Color(0xFFFDE68A);
        icon = Icons.access_time;
        break;
      case 'pending-review':
        bgColor = const Color(0xFFF3E8FF);
        textColor = const Color(0xFF9333EA);
        borderColor = const Color(0xFFE9D5FF);
        icon = Icons.error_outline;
        break;
      case 'completed':
        bgColor = const Color(0xFFECFDF5);
        textColor = const Color(0xFF059669);
        borderColor = const Color(0xFFA7F3D0);
        icon = Icons.check_circle_outline;
        break;
      case 'closed':
        bgColor = const Color(0xFFF3F4F6);
        textColor = const Color(0xFF4B5563);
        borderColor = const Color(0xFFE5E7EB);
        icon = Icons.check_circle_outline;
        break;
      default: // open
        bgColor = const Color(0xFFEFF6FF);
        textColor = const Color(0xFF2563EB);
        borderColor = const Color(0xFFBFDBFE);
        icon = Icons.radio_button_unchecked;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: borderColor),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: textColor, size: 12),
          const SizedBox(width: 4),
          Text(
            status.replaceAll('-', ' ').toUpperCase(),
            style: TextStyle(
              color: textColor,
              fontSize: 10,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}

