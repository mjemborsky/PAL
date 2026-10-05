import 'package:flutter/material.dart';
import '../../models/widget_config.dart';

/// Weather Placeholder with Dynamic Config
class WeatherWidget extends StatelessWidget {
  final StandbyWidgetConfig config;

  const WeatherWidget({super.key, required this.config});

  @override
  Widget build(BuildContext context) {
    final tempString = config.useCelsius ? '22°C' : '72°F';

    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.wb_sunny_outlined,
              size: 72, color: Colors.amberAccent),
          const SizedBox(height: 12),
          Text(
            tempString,
            style: const TextStyle(
                fontSize: 48, fontWeight: FontWeight.bold, color: Colors.white),
          ),
          const Text(
            'Partly Cloudy • Saint Paul',
            style: TextStyle(fontSize: 16, color: Colors.grey),
          ),
        ],
      ),
    );
  }
}
