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
  int _currentPageIndex = 0;

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

  /// Keeps the PageView anchored to the current active widget when toggling/reordering
  void _updateWidgetsAndMaintainFocus(VoidCallback updateState) {
    final activeBefore = _widgets.where((w) => w.isEnabled).toList();
    final currentConfig =
        activeBefore.isNotEmpty && _currentPageIndex < activeBefore.length
            ? activeBefore[_currentPageIndex]
            : null;

    setState(() {
      updateState();
    });

    final activeAfter = _widgets.where((w) => w.isEnabled).toList();
    if (currentConfig != null) {
      final newIndex = activeAfter.indexWhere((w) => w.id == currentConfig.id);
      if (newIndex != -1 && newIndex != _currentPageIndex) {
        _currentPageIndex = newIndex;
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (_pageController.hasClients) {
            _pageController.jumpToPage(newIndex);
          }
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final activeWidgets = _widgets.where((w) => w.isEnabled).toList();

    return Scaffold(
      backgroundColor: Colors.black,
      body: PageView.builder(
        controller: _pageController,
        itemCount: activeWidgets.length,
        onPageChanged: (index) {
          _currentPageIndex = index;
        },
        itemBuilder: (context, index) {
          final widgetConfig = activeWidgets[index];
          switch (widgetConfig.type) {
            case StandbyWidgetType.clock:
              return const ClockWidget();
            case StandbyWidgetType.weather:
              return const WeatherWidget();
            case StandbyWidgetType.settings:
              return MainSettingsWidget(
                allWidgets: _widgets,
                onReorder: (oldIdx, newIdx) {
                  _updateWidgetsAndMaintainFocus(() {
                    if (newIdx > oldIdx) newIdx -= 1;
                    final item = _widgets.removeAt(oldIdx);
                    _widgets.insert(newIdx, item);
                  });
                },
                onToggle: (id, enabled) {
                  _updateWidgetsAndMaintainFocus(() {
                    final item = _widgets.firstWhere((w) => w.id == id);
                    item.isEnabled = enabled;
                  });
                },
              );
          }
        },
      ),
    );
  }
}

/// Root Settings Page with Navigation to Sub-Pages (e.g. "Views")
class MainSettingsWidget extends StatefulWidget {
  final List<StandbyWidgetConfig> allWidgets;
  final Function(int oldIndex, int newIndex) onReorder;
  final Function(String id, bool enabled) onToggle;

  const MainSettingsWidget({
    super.key,
    required this.allWidgets,
    required this.onReorder,
    required this.onToggle,
  });

  @override
  State<MainSettingsWidget> createState() => _MainSettingsWidgetState();
}

class _MainSettingsWidgetState extends State<MainSettingsWidget> {
  // Navigation state within Settings menu
  bool _showingViewsSubPage = false;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 36.0),
      child: AnimatedSwitcher(
        duration: const Duration(milliseconds: 200),
        child: _showingViewsSubPage
            ? _buildViewsSubPage()
            : _buildRootSettingsMenu(),
      ),
    );
  }

  /// Root Settings Menu
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
            subtitle: const Text('Reorder and toggle standby screens',
                style: TextStyle(color: Colors.grey, fontSize: 12)),
            trailing: const Icon(Icons.chevron_right, color: Colors.white70),
            onTap: () {
              setState(() {
                _showingViewsSubPage = true;
              });
            },
          ),
        ),
      ],
    );
  }

  /// "Views" Sub-Page inside Settings
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
                  _showingViewsSubPage = false;
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
          'Drag handles to reorder or use switches to enable/disable screens.',
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
                key: ValueKey(item.id),
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
                    isSettings
                        ? 'Always active'
                        : (item.isEnabled ? 'Active' : 'Disabled'),
                    style: TextStyle(
                      color: isSettings
                          ? Colors.cyanAccent
                          : (item.isEnabled
                              ? Colors.grey
                              : Colors.grey.shade600),
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

/// Weather Placeholder
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
