import 'package:flutter/material.dart';
import '../../models/widget_config.dart';

class MainSettingsWidget extends StatefulWidget {
  final List<StandbyWidgetConfig> allWidgets;
  final ActiveListeningConfig activeListeningConfig;
  final GeneralConfig generalConfig;
  final Function(int oldIndex, int newIndex) onReorder;
  final Function(String id, bool enabled) onToggle;
  final Function(StandbyWidgetType type) onAddWidget;
  final VoidCallback onUpdateConfig;

  const MainSettingsWidget({
    super.key,
    required this.allWidgets,
    required this.activeListeningConfig,
    required this.generalConfig,
    required this.onReorder,
    required this.onToggle,
    required this.onAddWidget,
    required this.onUpdateConfig,
  });

  @override
  State<MainSettingsWidget> createState() => _MainSettingsWidgetState();
}

class _MainSettingsWidgetState extends State<MainSettingsWidget> {
  int _selectedCategoryIndex = 0;

  final List<String> _categories = [
    'Widgets & Order',
    'Active Listening',
    'Appearance & System',
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Settings Header
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: const [
                      Icon(Icons.settings, color: Colors.cyanAccent, size: 28),
                      SizedBox(width: 12),
                      Text(
                        'SETTINGS',
                        style: TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                          letterSpacing: 2.0,
                          color: Colors.white,
                        ),
                      ),
                    ],
                  ),
                  Text(
                    'PAL v1.0',
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.grey.shade600,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              const Divider(color: Colors.white12, height: 1),
              const SizedBox(height: 16),

              // 2-Column Settings View
              Expanded(
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Left Column: Navigation Tabs
                    SizedBox(
                      width: 220,
                      child: ListView.builder(
                        itemCount: _categories.length,
                        itemBuilder: (context, index) {
                          final isSelected = _selectedCategoryIndex == index;
                          return Container(
                            margin: const EdgeInsets.only(bottom: 8),
                            child: Material(
                              color: isSelected
                                  ? Colors.cyanAccent.withValues(alpha: 0.15)
                                  : Colors.transparent,
                              borderRadius: BorderRadius.circular(8),
                              clipBehavior: Clip.antiAlias,
                              child: Container(
                                decoration: BoxDecoration(
                                  border: Border.all(
                                    color: isSelected
                                        ? Colors.cyanAccent
                                        : Colors.transparent,
                                    width: 1.5,
                                  ),
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: ListTile(
                                  contentPadding: const EdgeInsets.symmetric(
                                      horizontal: 16, vertical: 4),
                                  title: Text(
                                    _categories[index],
                                    style: TextStyle(
                                      fontSize: 16,
                                      fontWeight: isSelected
                                          ? FontWeight.bold
                                          : FontWeight.w500,
                                      color: isSelected
                                          ? Colors.cyanAccent
                                          : Colors.grey.shade400,
                                    ),
                                  ),
                                  onTap: () {
                                    setState(() {
                                      _selectedCategoryIndex = index;
                                    });
                                  },
                                ),
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                    const SizedBox(width: 20),
                    const VerticalDivider(color: Colors.white12, width: 1),
                    const SizedBox(width: 20),

                    // Right Column: Tab Details / Options
                    Expanded(
                      child: _buildCategoryContent(),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildCategoryContent() {
    switch (_selectedCategoryIndex) {
      case 0:
        return _buildWidgetsAndOrderSection();
      case 1:
        return _buildActiveListeningSection();
      case 2:
        return _buildAppearanceSection();
      default:
        return const SizedBox.shrink();
    }
  }

  // Section 1: Reorder & Enable/Disable Widgets
  Widget _buildWidgetsAndOrderSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text(
              'Active Widgets',
              style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.white),
            ),
            PopupMenuButton<StandbyWidgetType>(
              icon: const Icon(Icons.add_circle_outline,
                  color: Colors.cyanAccent, size: 28),
              onSelected: (type) => widget.onAddWidget(type),
              itemBuilder: (context) => [
                const PopupMenuItem(
                  value: StandbyWidgetType.clock,
                  child:
                      Text('Add Clock Widget', style: TextStyle(fontSize: 16)),
                ),
                const PopupMenuItem(
                  value: StandbyWidgetType.weather,
                  child: Text('Add Weather Widget',
                      style: TextStyle(fontSize: 16)),
                ),
              ],
            ),
          ],
        ),
        const SizedBox(height: 8),
        Expanded(
          child: ReorderableListView.builder(
            itemCount: widget.allWidgets.length,
            onReorder: widget.onReorder,
            itemBuilder: (context, index) {
              final item = widget.allWidgets[index];
              if (item.type == StandbyWidgetType.settings) {
                return const SizedBox.shrink(key: ValueKey('settings_skip'));
              }

              return Container(
                key: ValueKey(item.id),
                margin: const EdgeInsets.only(bottom: 10),
                child: Material(
                  color: Colors.grey.shade900,
                  borderRadius: BorderRadius.circular(8),
                  clipBehavior: Clip.antiAlias,
                  child: Container(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: Colors.white10),
                    ),
                    child: ListTile(
                      contentPadding: const EdgeInsets.symmetric(
                          horizontal: 16, vertical: 4),
                      leading: Switch(
                        value: item.isEnabled,
                        activeColor: Colors.cyanAccent,
                        onChanged: (val) => widget.onToggle(item.id, val),
                      ),
                      title: Text(
                        item.title,
                        style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Colors.white),
                      ),
                      subtitle: Text(
                        item.type == StandbyWidgetType.clock
                            ? (item.isAnalog ? 'Analog Mode' : 'Digital Mode')
                            : 'Weather Display',
                        style: TextStyle(
                            fontSize: 14, color: Colors.grey.shade400),
                      ),
                      trailing: const Icon(Icons.drag_handle,
                          color: Colors.white38, size: 28),
                    ),
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  // Section 2: Active Listening Overlay Preferences
  Widget _buildActiveListeningSection() {
    final config = widget.activeListeningConfig;

    return ListView(
      children: [
        SwitchListTile(
          title: const Text('Enable Overlay',
              style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.white)),
          subtitle: Text('Swipe down from top edge to reveal overlay',
              style: TextStyle(fontSize: 14, color: Colors.grey.shade400)),
          value: config.isEnabled,
          activeColor: Colors.cyanAccent,
          onChanged: (val) {
            setState(() {
              config.isEnabled = val;
            });
            widget.onUpdateConfig();
          },
        ),
        const SizedBox(height: 12),
        const Text('Visualizer Style',
            style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: Colors.white)),
        const SizedBox(height: 8),
        Row(
          children: [
            Expanded(
              child: ChoiceChip(
                label: const Padding(
                  padding: EdgeInsets.symmetric(vertical: 8.0),
                  child: Text('Milkdrop Waves', style: TextStyle(fontSize: 15)),
                ),
                selected: config.style == ActiveListeningStyle.milkdrop,
                selectedColor: Colors.cyanAccent.withValues(alpha: 0.3),
                onSelected: (selected) {
                  if (selected) {
                    setState(() {
                      config.style = ActiveListeningStyle.milkdrop;
                    });
                    widget.onUpdateConfig();
                  }
                },
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: ChoiceChip(
                label: const Padding(
                  padding: EdgeInsets.symmetric(vertical: 8.0),
                  child: Text('Vinyl Disc', style: TextStyle(fontSize: 15)),
                ),
                selected: config.style == ActiveListeningStyle.vinyl,
                selectedColor: Colors.cyanAccent.withValues(alpha: 0.3),
                onSelected: (selected) {
                  if (selected) {
                    setState(() {
                      config.style = ActiveListeningStyle.vinyl;
                    });
                    widget.onUpdateConfig();
                  }
                },
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        const Text('Audio Sensitivity',
            style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: Colors.white)),
        Slider(
          value: config.sensitivity,
          min: 0.5,
          max: 2.0,
          divisions: 15,
          activeColor: Colors.cyanAccent,
          label: '${config.sensitivity.toStringAsFixed(1)}x',
          onChanged: (val) {
            setState(() {
              config.sensitivity = val;
            });
            widget.onUpdateConfig();
          },
        ),
      ],
    );
  }

  // Section 3: Theme & System Unit Toggles
  Widget _buildAppearanceSection() {
    final general = widget.generalConfig;

    return ListView(
      children: [
        SwitchListTile(
          title: const Text('Dark Mode Theme',
              style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.white)),
          subtitle: Text('Toggle high-contrast black backdrop',
              style: TextStyle(fontSize: 14, color: Colors.grey.shade400)),
          value: general.themeMode == AppThemeMode.dark,
          activeColor: Colors.cyanAccent,
          onChanged: (val) {
            setState(() {
              general.themeMode = val ? AppThemeMode.dark : AppThemeMode.light;
            });
            widget.onUpdateConfig();
          },
        ),
        const Divider(color: Colors.white12, height: 24),
        SwitchListTile(
          title: const Text('Show FPS Counter',
              style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.white)),
          subtitle: Text('Display real-time rendering statistics',
              style: TextStyle(fontSize: 14, color: Colors.grey.shade400)),
          value: widget.activeListeningConfig.showFPS,
          activeColor: Colors.cyanAccent,
          onChanged: (val) {
            setState(() {
              widget.activeListeningConfig.showFPS = val;
            });
            widget.onUpdateConfig();
          },
        ),
      ],
    );
  }
}
