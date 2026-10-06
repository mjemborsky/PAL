import 'package:flutter/material.dart';
import '../../models/widget_config.dart';

/// Weather Display scaled directly for 800x480
class WeatherWidget extends StatelessWidget {
  final StandbyWidgetConfig config;

  const WeatherWidget({super.key, required this.config});

  @override
  Widget build(BuildContext context) {
    final tempString = config.useCelsius ? '22°C' : '72°F';

    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 48.0),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            const Icon(Icons.wb_sunny_outlined,
                size: 140, color: Colors.amberAccent),
            const SizedBox(width: 48),
            Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  tempString,
                  style: const TextStyle(
                      fontSize: 88,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                      height: 1.0),
                ),
                const SizedBox(height: 12),
                const Text(
                  'Partly Cloudy • Saint Paul',
                  style: TextStyle(fontSize: 26, color: Colors.grey),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
