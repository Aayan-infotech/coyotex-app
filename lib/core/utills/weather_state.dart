import 'package:flutter/material.dart';

class WeatherStat extends StatelessWidget {
  final IconData icon;
  final String value;
  final String label;
  final Color color;

  const WeatherStat({super.key, 
    required this.icon,
    required this.value,
    required this.label,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Icon(icon, color: color, size: 22),
        const SizedBox(height: 4),
        Text(value, 
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.bold,
            color: Colors.red.shade900
          ),
        ),
        Text(label,
          style: TextStyle(
            fontSize: 12,
            color: Colors.grey.shade600
          ),
        ),
      ],
    );
  }
}
   