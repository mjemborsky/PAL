import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../models/widget_config.dart';

class StandbyView extends StatefulWidget {
  const StandbyView({super.key});

  @override
  State<StandbyView> createState() => _StandbyViewState();
}

class _StandbyViewState extends State<StandbyView> {
  final PageController _pageController = PageController();

  // Active widgets list that users can toggle on/off in settings
  final List<StandbyWidgetConfig> _widgets = [
    StandbyWidgetConfig(
      id: 'clock',
      title: 'Clock',
      type: StandbyWidgetType.clock,
      isEnabled: true,
    ),
    StandbyWidgetConfig(
      id: 'weather',
      title: 'Weather',
      type: StandbyWidgetType.weather,
      isEnabled: true,
    ),
    StandbyWidgetConfig(
      id: 'settings',
      title: 'Settings',
      type: StandbyWidgetType.settings,
      isEnabled: true,
    ),
  ];

  @override
  Widget build(BuildContext context) {
    // Filter active widgets
    final activeWidgets = _widgets.where((w) => w.isEnabled).toList();

    return Scaffold(
      backgroundColor: Colors.black,
      body: PageView.builder(
        controller: _pageController,
        itemCount: activeWidgets.length,
        itemBuilder: (context, index) {
          final widgetConfig = activeWidgets[index];
          switch (widgetConfig.type) {
            case StandbyWidgetType.clock:
              return const ClockWidget();
            case StandbyWidgetType.weather:
              return const WeatherWidget();
            case StandbyWidgetType.settings:
              return SettingsWidget(
                allWidgets: _widgets,
                onWidgetToggled: (updatedConfig) {
                  setState(() {
                    final target =
                        _widgets.firstWhere((w) => w.id == updatedConfig.id);
                    target.isEnabled = updatedConfig.isEnabled;
                  });
                },
              );
          }
        },
      ),
    );
  }
}

/// Digital Clock Display
class ClockWidget extends StatelessWidget {
  const ClockWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<DateTime>(
      stream:
          Stream.periodic(const Duration(seconds: 1), (_) => DateTime.now()),
      builder: (context, snapshot) {
        final now = snapshot.data ?? DateTime.now();
        final timeString = DateFormat('hh:mm').format(now);
        final periodString = DateFormat('a').format(now);
        final dateString = DateFormat('EEEE, MMMM d').format(now);

        return Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.baseline,
                textBaseline: TextBaseline.alphabetic,
                children: [
                  Text(
                    timeString,
                    style: const TextStyle(
                      fontSize: 80,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    periodString,
                    style: const TextStyle(
                      fontSize: 24,
                      color: Colors.cyanAccent,
                    ),
                  ),
                ],
              ),
              Text(
                dateString,
                style: TextStyle(
                  fontSize: 18,
                  color: Colors.grey.shade400,
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

/// Weather Placeholder (Will connect to Open-Meteo in Phase 4)
class WeatherWidget extends StatelessWidget {
  const WeatherWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return const Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.wb_sunny_outlined, size: 72, color: Colors.amberAccent),
          SizedBox(height: 12),
          Text(
            '72°F',
            style: TextStyle(
                fontSize: 48, fontWeight: FontWeight.bold, color: Colors.white),
          ),
          Text(
            'Partly Cloudy • Saint Paul',
            style: TextStyle(fontSize: 16, color: Colors.grey),
          ),
        ],
      ),
    );
  }
}

/// Settings Screen for Managing Active Display Widgets
class SettingsWidget extends StatelessWidget {
  final List<StandbyWidgetConfig> allWidgets;
  final Function(StandbyWidgetConfig) onWidgetToggled;

  const SettingsWidget({
    super.key,
    required this.allWidgets,
    required this.onWidgetToggled,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(24.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 32),
          const Text(
            'Standby Widgets',
            style: TextStyle(
                fontSize: 24, fontWeight: FontWeight.bold, color: Colors.white),
          ),
          const Text(
            'Enable or disable swipe pages on your screen.',
            style: TextStyle(fontSize: 14, color: Colors.grey),
          ),
          const Divider(color: Colors.grey),
          Expanded(
            child: ListView.builder(
              itemCount: allWidgets.length,
              itemBuilder: (context, index) {
                final item = allWidgets[index];
                // Prevent disabling settings itself
                final isSettings = item.type == StandbyWidgetType.settings;

                return SwitchListTile(
                  title: Text(item.title,
                      style: const TextStyle(color: Colors.white)),
                  value: item.isEnabled,
                  activeColor: Colors.cyanAccent,
                  onChanged: isSettings
                      ? null
                      : (val) {
                          item.isEnabled = val;
                          onWidgetToggled(item);
                        },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
