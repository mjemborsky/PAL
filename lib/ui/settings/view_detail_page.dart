import 'package:flutter/material.dart';
import '../../models/widget_config.dart';

class ViewDetailPage extends StatelessWidget {
  final StandbyWidgetConfig item;
  final VoidCallback onBack;
  final VoidCallback onUpdateConfig;

  const ViewDetailPage({
    super.key,
    required this.item,
    required this.onBack,
    required this.onUpdateConfig,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      key: const ValueKey('ViewDetailSubPage'),
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            IconButton(
              icon: const Icon(Icons.arrow_back, color: Colors.cyanAccent),
              onPressed: onBack,
            ),
            const SizedBox(width: 8),
            Text(
              '${item.title} Options',
              style: const TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        const Divider(color: Colors.white24),
        Expanded(
          child: ListView(
            children: [
              if (item.type == StandbyWidgetType.clock) ...[
                SwitchListTile(
                  title: const Text('Analog Display',
                      style: TextStyle(color: Colors.white)),
                  subtitle: const Text(
                      'Switch between Analog clock face and Digital readout',
                      style: TextStyle(color: Colors.grey, fontSize: 12)),
                  value: item.isAnalog,
                  activeThumbColor: Colors.cyanAccent,
                  onChanged: (val) {
                    item.isAnalog = val;
                    onUpdateConfig();
                  },
                ),
                if (!item.isAnalog) ...[
                  SwitchListTile(
                    title: const Text('24-Hour Format',
                        style: TextStyle(color: Colors.white)),
                    subtitle: const Text(
                        'Display time in 24-hour style (e.g. 14:30)',
                        style: TextStyle(color: Colors.grey, fontSize: 12)),
                    value: item.use24HourTime,
                    activeThumbColor: Colors.cyanAccent,
                    onChanged: (val) {
                      item.use24HourTime = val;
                      onUpdateConfig();
                    },
                  ),
                ],
                SwitchListTile(
                  title: const Text('Show Seconds Hand / Counter',
                      style: TextStyle(color: Colors.white)),
                  subtitle: const Text('Display second hand or digital seconds',
                      style: TextStyle(color: Colors.grey, fontSize: 12)),
                  value: item.showSeconds,
                  activeThumbColor: Colors.cyanAccent,
                  onChanged: (val) {
                    item.showSeconds = val;
                    onUpdateConfig();
                  },
                ),
              ],
              if (item.type == StandbyWidgetType.weather) ...[
                SwitchListTile(
                  title: const Text('Use Celsius (°C)',
                      style: TextStyle(color: Colors.white)),
                  subtitle: const Text(
                      'Display temperatures in Celsius instead of Fahrenheit',
                      style: TextStyle(color: Colors.grey, fontSize: 12)),
                  value: item.useCelsius,
                  activeThumbColor: Colors.cyanAccent,
                  onChanged: (val) {
                    item.useCelsius = val;
                    onUpdateConfig();
                  },
                ),
              ],
            ],
          ),
        ),
      ],
    );
  }
}
