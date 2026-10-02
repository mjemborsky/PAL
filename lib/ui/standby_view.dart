import 'dart:math';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../models/widget_config.dart';

class StandbyView extends StatefulWidget {
  const StandbyView({super.key});

  @override
  State<StandbyView> createState() => _StandbyViewState();
}

class _StandbyViewState extends State<StandbyView> {
  late PageController _pageController;
  int _activePageIndex = 0;

  final List<StandbyWidgetConfig> _allWidgets = [
    StandbyWidgetConfig(
      id: 'clock',
      title: 'Clock',
      type: StandbyWidgetType.clock,
      isEnabled: true,
      isAnalog: true,
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
  void initState() {
    super.initState();
    _activePageIndex = _allWidgets.where((w) => w.isEnabled).length - 1;
    _pageController = PageController(initialPage: _activePageIndex);
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  /// Toggle or reorder without causing index-mismatch visual glitches
  void _handleConfigUpdate({VoidCallback? onStateChange}) {
    // 1. Identify which widget the user is currently looking at BEFORE updating
    final activeBefore = _allWidgets.where((w) => w.isEnabled).toList();
    final currentConfig = (_activePageIndex < activeBefore.length)
        ? activeBefore[_activePageIndex]
        : null;

    setState(() {
      if (onStateChange != null) onStateChange();
    });

    // 2. Find the exact new index of that same widget AFTER state update
    if (currentConfig != null) {
      final activeAfter = _allWidgets.where((w) => w.isEnabled).toList();
      final newIndex = activeAfter.indexWhere((w) => w.id == currentConfig.id);

      if (newIndex != -1 && newIndex != _activePageIndex) {
        _activePageIndex = newIndex;
        // Jump immediately without waiting for post-frame rendering delays
        if (_pageController.hasClients) {
          _pageController.jumpToPage(newIndex);
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final activeWidgets = _allWidgets.where((w) => w.isEnabled).toList();

    return Scaffold(
      backgroundColor: Colors.black,
      body: PageView.builder(
        key: const ValueKey('StandbyPageView'),
        controller: _pageController,
        itemCount: activeWidgets.length,
        onPageChanged: (index) {
          _activePageIndex = index;
        },
        itemBuilder: (context, index) {
          final widgetConfig = activeWidgets[index];

          // KeyedSubtree prevents Flutter from reusing state or flickering wrong views on rebuild
          return KeyedSubtree(
            key: ValueKey(widgetConfig.id),
            child: _buildWidgetScreen(widgetConfig),
          );
        },
      ),
    );
  }

  Widget _buildWidgetScreen(StandbyWidgetConfig widgetConfig) {
    switch (widgetConfig.type) {
      case StandbyWidgetType.clock:
        return ClockWidget(config: widgetConfig);
      case StandbyWidgetType.weather:
        return WeatherWidget(config: widgetConfig);
      case StandbyWidgetType.settings:
        return MainSettingsWidget(
          allWidgets: _allWidgets,
          onReorder: (oldIdx, newIdx) {
            _handleConfigUpdate(onStateChange: () {
              if (newIdx > oldIdx) newIdx -= 1;
              final item = _allWidgets.removeAt(oldIdx);
              _allWidgets.insert(newIdx, item);
            });
          },
          onToggle: (id, enabled) {
            _handleConfigUpdate(onStateChange: () {
              final item = _allWidgets.firstWhere((w) => w.id == id);
              item.isEnabled = enabled;
            });
          },
          onUpdateConfig: () {
            _handleConfigUpdate();
          },
        );
    }
  }
}

enum SettingsSubScreen { root, views, viewDetail }

/// Settings menu that cleanly maintains active navigation depth
class MainSettingsWidget extends StatefulWidget {
  final List<StandbyWidgetConfig> allWidgets;
  final Function(int oldIndex, int newIndex) onReorder;
  final Function(String id, bool enabled) onToggle;
  final VoidCallback onUpdateConfig;

  const MainSettingsWidget({
    super.key,
    required this.allWidgets,
    required this.onReorder,
    required this.onToggle,
    required this.onUpdateConfig,
  });

  @override
  State<MainSettingsWidget> createState() => _MainSettingsWidgetState();
}

class _MainSettingsWidgetState extends State<MainSettingsWidget> {
  SettingsSubScreen _currentSubScreen = SettingsSubScreen.root;
  String? _selectedWidgetId;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 36.0),
      child: AnimatedSwitcher(
        duration: const Duration(milliseconds: 150),
        child: _buildCurrentSubScreen(),
      ),
    );
  }

  Widget _buildCurrentSubScreen() {
    switch (_currentSubScreen) {
      case SettingsSubScreen.root:
        return _buildRootSettingsMenu();
      case SettingsSubScreen.views:
        return _buildViewsSubPage();
      case SettingsSubScreen.viewDetail:
        return _buildViewDetailSubPage();
    }
  }

  Widget _buildRootSettingsMenu() {
    return Column(
      key: const ValueKey('RootSettings'),
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Row(
          children: [
            Icon(Icons.settings, color: Colors.cyanAccent, size: 28),
            SizedBox(width: 12),
            Text(
              'Settings',
              style: TextStyle(
                  fontSize: 26,
                  fontWeight: FontWeight.bold,
                  color: Colors.white),
            ),
          ],
        ),
        const SizedBox(height: 16),
        const Divider(color: Colors.white24),
        Card(
          color: Colors.grey.shade900,
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          child: ListTile(
            leading:
                const Icon(Icons.dashboard_customize, color: Colors.cyanAccent),
            title: const Text('Views',
                style: TextStyle(
                    color: Colors.white, fontWeight: FontWeight.w600)),
            subtitle: const Text('Reorder, toggle, and customize views',
                style: TextStyle(color: Colors.grey, fontSize: 12)),
            trailing: const Icon(Icons.chevron_right, color: Colors.white70),
            onTap: () {
              setState(() {
                _currentSubScreen = SettingsSubScreen.views;
              });
            },
          ),
        ),
      ],
    );
  }

  Widget _buildViewsSubPage() {
    return Column(
      key: const ValueKey('ViewsSubPage'),
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            IconButton(
              icon: const Icon(Icons.arrow_back, color: Colors.cyanAccent),
              onPressed: () {
                setState(() {
                  _currentSubScreen = SettingsSubScreen.root;
                });
              },
            ),
            const SizedBox(width: 8),
            const Text(
              'Views Management',
              style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Colors.white),
            ),
          ],
        ),
        const SizedBox(height: 6),
        Text(
          'Tap a view to configure options, or drag handles to reorder.',
          style: TextStyle(fontSize: 13, color: Colors.grey.shade400),
        ),
        const SizedBox(height: 12),
        const Divider(color: Colors.white24),
        Expanded(
          child: ReorderableListView.builder(
            itemCount: widget.allWidgets.length,
            onReorder: widget.onReorder,
            itemBuilder: (context, index) {
              final item = widget.allWidgets[index];
              final isSettings = item.type == StandbyWidgetType.settings;

              return Card(
                key: ValueKey('list_item_${item.id}'),
                color: Colors.grey.shade900,
                margin: const EdgeInsets.symmetric(vertical: 6.0),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                  side: BorderSide(
                    color: item.isEnabled
                        ? Colors.cyanAccent.withOpacity(0.3)
                        : Colors.transparent,
                  ),
                ),
                child: ListTile(
                  contentPadding:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                  onTap: isSettings
                      ? null
                      : () {
                          setState(() {
                            _selectedWidgetId = item.id;
                            _currentSubScreen = SettingsSubScreen.viewDetail;
                          });
                        },
                  leading: Icon(
                    _getWidgetIcon(item.type),
                    color: item.isEnabled ? Colors.cyanAccent : Colors.grey,
                  ),
                  title: Text(
                    item.title,
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.w600,
                      decoration:
                          item.isEnabled ? null : TextDecoration.lineThrough,
                    ),
                  ),
                  subtitle: Text(
                    isSettings ? 'Always active' : 'Tap to customize options',
                    style: TextStyle(
                      color: isSettings ? Colors.cyanAccent : Colors.grey,
                      fontSize: 12,
                    ),
                  ),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Switch(
                        value: item.isEnabled,
                        activeColor: Colors.cyanAccent,
                        onChanged: isSettings
                            ? null
                            : (val) => widget.onToggle(item.id, val),
                      ),
                      const SizedBox(width: 8),
                      ReorderableDragStartListener(
                        index: index,
                        child: const Padding(
                          padding: EdgeInsets.all(8.0),
                          child: Icon(Icons.drag_handle, color: Colors.white70),
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildViewDetailSubPage() {
    final item = widget.allWidgets.firstWhere(
      (w) => w.id == _selectedWidgetId,
      orElse: () => widget.allWidgets.first,
    );

    return Column(
      key: const ValueKey('ViewDetailSubPage'),
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            IconButton(
              icon: const Icon(Icons.arrow_back, color: Colors.cyanAccent),
              onPressed: () {
                setState(() {
                  _currentSubScreen = SettingsSubScreen.views;
                });
              },
            ),
            const SizedBox(width: 8),
            Text(
              '${item.title} Options',
              style: const TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Colors.white),
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
                  activeColor: Colors.cyanAccent,
                  onChanged: (val) {
                    setState(() {
                      item.isAnalog = val;
                    });
                    widget.onUpdateConfig();
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
                    activeColor: Colors.cyanAccent,
                    onChanged: (val) {
                      setState(() {
                        item.use24HourTime = val;
                      });
                      widget.onUpdateConfig();
                    },
                  ),
                ],
                SwitchListTile(
                  title: const Text('Show Seconds Hand / Counter',
                      style: TextStyle(color: Colors.white)),
                  subtitle: const Text('Display second hand or digital seconds',
                      style: TextStyle(color: Colors.grey, fontSize: 12)),
                  value: item.showSeconds,
                  activeColor: Colors.cyanAccent,
                  onChanged: (val) {
                    setState(() {
                      item.showSeconds = val;
                    });
                    widget.onUpdateConfig();
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
                  activeColor: Colors.cyanAccent,
                  onChanged: (val) {
                    setState(() {
                      item.useCelsius = val;
                    });
                    widget.onUpdateConfig();
                  },
                ),
              ],
            ],
          ),
        ),
      ],
    );
  }

  IconData _getWidgetIcon(StandbyWidgetType type) {
    switch (type) {
      case StandbyWidgetType.clock:
        return Icons.access_time_filled;
      case StandbyWidgetType.weather:
        return Icons.wb_sunny;
      case StandbyWidgetType.settings:
        return Icons.tune;
    }
  }
}

/// Clock Display with Analog & Digital modes
class ClockWidget extends StatelessWidget {
  final StandbyWidgetConfig config;

  const ClockWidget({super.key, required this.config});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<DateTime>(
      stream:
          Stream.periodic(const Duration(seconds: 1), (_) => DateTime.now()),
      builder: (context, snapshot) {
        final now = snapshot.data ?? DateTime.now();

        return Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              if (config.isAnalog) ...[
                SizedBox(
                  width: 220,
                  height: 220,
                  child: CustomPaint(
                    painter: AnalogClockPainter(
                        now: now, showSeconds: config.showSeconds),
                  ),
                ),
                const SizedBox(height: 20),
                Text(
                  DateFormat('EEEE, MMMM d').format(now),
                  style: TextStyle(fontSize: 18, color: Colors.grey.shade400),
                ),
              ] else ...[
                _buildDigitalClock(now),
              ],
            ],
          ),
        );
      },
    );
  }

  Widget _buildDigitalClock(DateTime now) {
    final formatPattern = config.use24HourTime
        ? (config.showSeconds ? 'HH:mm:ss' : 'HH:mm')
        : (config.showSeconds ? 'hh:mm:ss' : 'hh:mm');

    final timeString = DateFormat(formatPattern).format(now);
    final periodString =
        config.use24HourTime ? '' : DateFormat('a').format(now);
    final dateString = DateFormat('EEEE, MMMM d').format(now);

    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.baseline,
          textBaseline: TextBaseline.alphabetic,
          children: [
            Text(
              timeString,
              style: const TextStyle(
                fontSize: 72,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
            if (periodString.isNotEmpty) ...[
              const SizedBox(width: 8),
              Text(
                periodString,
                style: const TextStyle(
                  fontSize: 24,
                  color: Colors.cyanAccent,
                ),
              ),
            ],
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
    );
  }
}

/// CustomPainter drawing the analog clock face, tick marks, and rotating hands
class AnalogClockPainter extends CustomPainter {
  final DateTime now;
  final bool showSeconds;

  AnalogClockPainter({required this.now, required this.showSeconds});

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width / 2;

    // Outer Dial Ring
    final dialPaint = Paint()
      ..color = Colors.grey.shade900
      ..style = PaintingStyle.fill;
    canvas.drawCircle(center, radius, dialPaint);

    final borderPaint = Paint()
      ..color = Colors.cyanAccent.withOpacity(0.5)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 3;
    canvas.drawCircle(center, radius, borderPaint);

    // Tick Marks
    final tickPaint = Paint()
      ..color = Colors.white54
      ..strokeWidth = 2;

    for (int i = 0; i < 12; i++) {
      final angle = i * 30 * (pi / 180);
      final outerX = center.dx + radius * 0.88 * cos(angle);
      final outerY = center.dy + radius * 0.88 * sin(angle);
      final innerX = center.dx + radius * 0.78 * cos(angle);
      final innerY = center.dy + radius * 0.78 * sin(angle);
      canvas.drawLine(
          Offset(innerX, innerY), Offset(outerX, outerY), tickPaint);
    }

    // Hour Hand
    final hourAngle =
        ((now.hour % 12) + now.minute / 60) * 30 * (pi / 180) - (pi / 2);
    final hourHandPaint = Paint()
      ..color = Colors.white
      ..strokeWidth = 6
      ..strokeCap = StrokeCap.round;
    canvas.drawLine(
      center,
      Offset(center.dx + radius * 0.45 * cos(hourAngle),
          center.dy + radius * 0.45 * sin(hourAngle)),
      hourHandPaint,
    );

    // Minute Hand
    final minuteAngle =
        (now.minute + now.second / 60) * 6 * (pi / 180) - (pi / 2);
    final minuteHandPaint = Paint()
      ..color = Colors.white70
      ..strokeWidth = 4
      ..strokeCap = StrokeCap.round;
    canvas.drawLine(
      center,
      Offset(center.dx + radius * 0.65 * cos(minuteAngle),
          center.dy + radius * 0.65 * sin(minuteAngle)),
      minuteHandPaint,
    );

    // Second Hand
    if (showSeconds) {
      final secondAngle = now.second * 6 * (pi / 180) - (pi / 2);
      final secondHandPaint = Paint()
        ..color = Colors.cyanAccent
        ..strokeWidth = 2
        ..strokeCap = StrokeCap.round;
      canvas.drawLine(
        center,
        Offset(center.dx + radius * 0.8 * cos(secondAngle),
            center.dy + radius * 0.8 * sin(secondAngle)),
        secondHandPaint,
      );
    }

    // Center Pivot Pin
    final centerPinPaint = Paint()..color = Colors.cyanAccent;
    canvas.drawCircle(center, 5, centerPinPaint);
  }

  @override
  bool shouldRepaint(covariant AnalogClockPainter oldDelegate) {
    return oldDelegate.now.second != now.second ||
        oldDelegate.showSeconds != showSeconds;
  }
}

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
