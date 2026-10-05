import 'package:flutter/material.dart';
import '../models/widget_config.dart';
import 'settings/main_settings_widget.dart';
import 'widgets/active_listening_widget.dart';
import 'widgets/clock_widget.dart';
import 'widgets/weather_widget.dart';

class StandbyView extends StatefulWidget {
  const StandbyView({super.key});

  @override
  State<StandbyView> createState() => _StandbyViewState();
}

class _StandbyViewState extends State<StandbyView> {
  late PageController _pageController;
  int _activePageIndex = 0;
  bool _isBooting = true;
  bool _showActiveListeningOverlay = false;

  final GeneralConfig _generalConfig = GeneralConfig();
  final ActiveListeningConfig _activeListeningConfig = ActiveListeningConfig();

  final List<StandbyWidgetConfig> _allWidgets = [
    StandbyWidgetConfig(
      id: 'clock_1',
      title: 'Clock',
      type: StandbyWidgetType.clock,
      isEnabled: true,
      isAnalog: true,
    ),
    StandbyWidgetConfig(
      id: 'weather_1',
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
    _activePageIndex = 0;
    _pageController = PageController(initialPage: _activePageIndex);

    Future.delayed(const Duration(milliseconds: 1800), () {
      if (mounted) {
        setState(() {
          _isBooting = false;
        });
      }
    });
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  void _handleConfigUpdate({
    VoidCallback? onStateChange,
    String? targetWidgetId,
  }) {
    final activeBefore = _allWidgets.where((w) => w.isEnabled).toList();
    final currentConfig = (_activePageIndex < activeBefore.length)
        ? activeBefore[_activePageIndex]
        : null;

    final targetId = targetWidgetId ?? currentConfig?.id;

    setState(() {
      if (onStateChange != null) onStateChange();
    });

    if (targetId != null) {
      final activeAfter = _allWidgets.where((w) => w.isEnabled).toList();
      final newIndex = activeAfter.indexWhere((w) => w.id == targetId);

      if (newIndex != -1 && newIndex != _activePageIndex) {
        _activePageIndex = newIndex;
        if (_pageController.hasClients) {
          _pageController.jumpToPage(newIndex);
        }
      }
    }
  }

  void _handleAddWidget(StandbyWidgetType type) {
    final settingsIdx =
        _allWidgets.indexWhere((w) => w.type == StandbyWidgetType.settings);
    final countOfType = _allWidgets.where((w) => w.type == type).length + 1;
    final typeName = type == StandbyWidgetType.clock ? 'Clock' : 'Weather';

    final newWidget = StandbyWidgetConfig(
      id: '${type.name}_$countOfType',
      title: '$typeName $countOfType',
      type: type,
      isEnabled: true,
    );

    _handleConfigUpdate(
      targetWidgetId: 'settings',
      onStateChange: () {
        if (settingsIdx != -1) {
          _allWidgets.insert(settingsIdx, newWidget);
        } else {
          _allWidgets.add(newWidget);
        }
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final activeWidgets = _allWidgets.where((w) => w.isEnabled).toList();
    final isDark = _generalConfig.themeMode == AppThemeMode.dark;

    final themeData = isDark
        ? ThemeData.dark().copyWith(
            scaffoldBackgroundColor: Colors.black,
            colorScheme: const ColorScheme.dark(primary: Colors.cyanAccent),
          )
        : ThemeData.light().copyWith(
            scaffoldBackgroundColor: const Color(0xFFAFAFAF),
            colorScheme: const ColorScheme.light(primary: Colors.teal),
          );

    final appBackgroundColor = isDark ? Colors.black : const Color(0xFFAFAFAF);

    return Theme(
      data: themeData,
      child: Scaffold(
        backgroundColor: appBackgroundColor,
        body: Stack(
          children: [
            // Main Standby Carousel View
            GestureDetector(
              onVerticalDragUpdate: (details) {
                if (_activeListeningConfig.isEnabled &&
                    details.delta.dy > 8 &&
                    details.globalPosition.dy < 120) {
                  setState(() {
                    _showActiveListeningOverlay = true;
                  });
                }
              },
              child: PageView.builder(
                key: const ValueKey('StandbyPageView'),
                controller: _pageController,
                itemCount: activeWidgets.length,
                onPageChanged: (index) {
                  _activePageIndex = index;
                },
                itemBuilder: (context, index) {
                  final widgetConfig = activeWidgets[index];

                  return KeyedSubtree(
                    key: ValueKey(widgetConfig.id),
                    child: _buildWidgetScreen(widgetConfig),
                  );
                },
              ),
            ),
            // Pull down handle hint
            if (_activeListeningConfig.isEnabled)
              Positioned(
                top: 6,
                left: 0,
                right: 0,
                child: Center(
                  child: Container(
                    width: 36,
                    height: 4,
                    decoration: BoxDecoration(
                      color: isDark ? Colors.white24 : Colors.black26,
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                ),
              ),
            // Active Listening Pull-down Overlay
            if (_activeListeningConfig.isEnabled)
              AnimatedPositioned(
                duration: const Duration(milliseconds: 300),
                curve: Curves.easeOut,
                top: _showActiveListeningOverlay
                    ? 0
                    : -MediaQuery.of(context).size.height,
                left: 0,
                right: 0,
                height: MediaQuery.of(context).size.height,
                child: GestureDetector(
                  onVerticalDragUpdate: (details) {
                    if (details.delta.dy < -8) {
                      setState(() {
                        _showActiveListeningOverlay = false;
                      });
                    }
                  },
                  child: Container(
                    color: Colors.black,
                    child: Stack(
                      children: [
                        ActiveListeningWidget(config: _activeListeningConfig),
                        Positioned(
                          top: 16,
                          right: 16,
                          child: IconButton(
                            icon: const Icon(Icons.keyboard_arrow_up,
                                color: Colors.white70, size: 32),
                            onPressed: () {
                              setState(() {
                                _showActiveListeningOverlay = false;
                              });
                            },
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            // Boot Screen Overlay
            AnimatedOpacity(
              opacity: _isBooting ? 1.0 : 0.0,
              duration: const Duration(milliseconds: 600),
              curve: Curves.easeOut,
              child: _isBooting ? _buildBootScreen() : const SizedBox.shrink(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBootScreen() {
    return Container(
      color: Colors.black,
      alignment: Alignment.center,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            'P A L',
            style: TextStyle(
              fontSize: 56,
              fontWeight: FontWeight.w900,
              letterSpacing: 14,
              color: Colors.cyanAccent,
              shadows: [
                Shadow(
                  color: Colors.cyanAccent.withValues(alpha: 0.6),
                  blurRadius: 20,
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),
          Text(
            'Portable Ambient Link',
            style: TextStyle(
              fontSize: 12,
              letterSpacing: 4,
              color: Colors.grey.shade500,
            ),
          ),
          const SizedBox(height: 48),
          const SizedBox(
            width: 24,
            height: 24,
            child: CircularProgressIndicator(
              strokeWidth: 2,
              color: Colors.cyanAccent,
            ),
          ),
        ],
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
          activeListeningConfig: _activeListeningConfig,
          generalConfig: _generalConfig,
          onReorder: (oldIdx, newIdx) {
            _handleConfigUpdate(
              targetWidgetId: 'settings',
              onStateChange: () {
                if (newIdx > oldIdx) newIdx -= 1;
                final item = _allWidgets.removeAt(oldIdx);
                _allWidgets.insert(newIdx, item);
              },
            );
          },
          onToggle: (id, enabled) {
            _handleConfigUpdate(
              targetWidgetId: 'settings',
              onStateChange: () {
                final item = _allWidgets.firstWhere((w) => w.id == id);
                item.isEnabled = enabled;
              },
            );
          },
          onAddWidget: _handleAddWidget,
          onUpdateConfig: () {
            _handleConfigUpdate(targetWidgetId: 'settings');
          },
        );
    }
  }
}
