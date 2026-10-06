import 'package:flutter/material.dart';
import '../../models/widget_config.dart';

class WeatherWidget extends StatelessWidget {
  final StandbyWidgetConfig config;

  const WeatherWidget({super.key, required this.config});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    final primaryTextColor = isDark ? Colors.white : Colors.black87;
    final secondaryTextColor =
        isDark ? Colors.grey.shade400 : Colors.grey.shade600;

    return Center(
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(
            Icons.wb_sunny_rounded,
            color: Colors.amber,
            size: 110,
          ),
          const SizedBox(width: 32),
          Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                '72°F',
                style: TextStyle(
                  fontSize: 76,
                  fontWeight: FontWeight.bold,
                  color: primaryTextColor,
                  height: 1.0,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Partly Cloudy • Saint Paul',
                style: TextStyle(
                  fontSize: 22,
                  color: secondaryTextColor,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
