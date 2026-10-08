import 'package:flutter/material.dart';

import '../models/widget_config.dart';
import 'settings/main_settings_widget.dart';
import 'widgets/milkdrop_active_listening_widget.dart';
import 'widgets/vinyl_active_listening_widget.dart';
import 'widgets/clock_widget.dart';
import 'widgets/weather_widget.dart';

class StandbyView extends StatefulWidget {
  const StandbyView({super.key});

  @override
  State<StandbyView> createState() => _StandbyViewState();
}

class _StandbyViewState extends State<StandbyView> {
  bool _isOverlayVisible = false;

  // Configuration State
  late ActiveListeningConfig _activeListeningConfig;
  late GeneralConfig _generalConfig;
  late List<StandbyWidgetConfig> _widgets;

  @override
  void initState() {
    super.initState();
    _activeListeningConfig = ActiveListeningConfig();
    _generalConfig = GeneralConfig();
    _widgets = [
      StandbyWidgetConfig(
        id: 'clock_1',
        title: 'Clock',
        type: StandbyWidgetType.clock,
        isEnabled: true,
      ),
      StandbyWidgetConfig(
        id: 'weather_1',
        title: 'Weather',
        type: StandbyWidgetType.weather,
        isEnabled: true,
      ),
      StandbyWidgetConfig(
        id: 'settings_1',
        title: 'Settings',
        type: StandbyWidgetType.settings,
        isEnabled: true,
      ),
    ];
  }

  void _showOverlay() {
    if (_activeListeningConfig.isEnabled && !_isOverlayVisible) {
      setState(() {
        _isOverlayVisible = true;
      });
    }
  }

  void _hideOverlay() {
    if (_isOverlayVisible) {
      setState(() {
        _isOverlayVisible = false;
      });
    }
  }

  void _handleVerticalDragEnd(DragEndDetails details) {
    if (!_activeListeningConfig.isEnabled) return;

    final velocityY = details.primaryVelocity ?? 0.0;
    const velocityThreshold = 200.0;

    if (velocityY > velocityThreshold) {
      _showOverlay();
    } else if (velocityY < -velocityThreshold) {
      _hideOverlay();
    }
  }

  Widget _buildActiveWidget(StandbyWidgetConfig config) {
    switch (config.type) {
      case StandbyWidgetType.clock:
        return ClockWidget(config: config);
      case StandbyWidgetType.weather:
        return WeatherWidget(config: config);
      case StandbyWidgetType.settings:
        return MainSettingsWidget(
          allWidgets: _widgets,
          activeListeningConfig: _activeListeningConfig,
          generalConfig: _generalConfig,
          onReorder: (oldIndex, newIndex) {
            setState(() {
              if (newIndex > oldIndex) newIndex -= 1;
              final item = _widgets.removeAt(oldIndex);
              _widgets.insert(newIndex, item);
            });
          },
          onToggle: (id, enabled) {
            setState(() {
              final w = _widgets.firstWhere((element) => element.id == id);
              w.isEnabled = enabled;
            });
          },
          onAddWidget: (type) {
            setState(() {
              _widgets.add(StandbyWidgetConfig(
                id: '${type.name}_${DateTime.now().millisecondsSinceEpoch}',
                title: type.name.toUpperCase(),
                type: type,
              ));
            });
          },
          onUpdateConfig: () {
            // Trigger rebuild when any config changes, including theme toggles
            setState(() {});
          },
        );
    }
  }

  Widget _buildActiveListeningWidget() {
    switch (_activeListeningConfig.style) {
      case ActiveListeningStyle.vinyl:
        return VinylActiveListeningWidget(
          config: _activeListeningConfig,
          onDismiss: _hideOverlay,
          onReveal: _showOverlay,
        );
      case ActiveListeningStyle.milkdrop:
        return MilkdropActiveListeningWidget(
          config: _activeListeningConfig,
          onDismiss: _hideOverlay,
          onReveal: _showOverlay,
        );
    }
  }

  @override
  Widget build(BuildContext context) {
    final activeWidgets = _widgets.where((w) => w.isEnabled).toList();
    final isDarkMode = _generalConfig.themeMode == AppThemeMode.dark;

    final themeData = isDarkMode
        ? ThemeData.dark().copyWith(
            scaffoldBackgroundColor: Colors.black,
            colorScheme: const ColorScheme.dark(
              primary: Colors.cyanAccent,
              surface: Colors.black,
            ),
            dividerColor: Colors.white12,
          )
        : ThemeData.light().copyWith(
            scaffoldBackgroundColor: const Color(0xFFF5F5F7),
            colorScheme: const ColorScheme.light(
              primary: Colors.cyan,
              surface: Color(0xFFF5F5F7),
            ),
            dividerColor: Colors.black12,
          );

    return Theme(
      data: themeData,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 250),
        color: themeData.scaffoldBackgroundColor,
        child: Scaffold(
          backgroundColor: Colors.transparent,
          body: GestureDetector(
            behavior: HitTestBehavior.opaque,
            onVerticalDragEnd: _handleVerticalDragEnd,
            child: Stack(
              children: [
                if (activeWidgets.isNotEmpty)
                  PageView.builder(
                    itemCount: activeWidgets.length,
                    itemBuilder: (context, index) {
                      return _buildActiveWidget(activeWidgets[index]);
                    },
                  )
                else
                  Center(
                    child: Text(
                      'No Active Widgets Enabled',
                      style: TextStyle(
                        color: isDarkMode ? Colors.white54 : Colors.black54,
                        fontSize: 18,
                      ),
                    ),
                  ),

                // Sliding Opaque Active Listening Overlay (stays dark for visualizer)
                AnimatedPositioned(
                  duration: const Duration(milliseconds: 350),
                  curve: Curves.easeOutCubic,
                  top: _isOverlayVisible
                      ? 0
                      : -MediaQuery.of(context).size.height,
                  left: 0,
                  right: 0,
                  height: MediaQuery.of(context).size.height,
                  child: Container(
                    color: Colors.black,
                    child: _buildActiveListeningWidget(),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
