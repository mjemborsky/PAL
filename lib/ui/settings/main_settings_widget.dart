import 'package:flutter/material.dart';

import '../../models/widget_config.dart';
import 'active_listening_settings_page.dart';
import 'details/clock_detail_widget.dart';
import 'general_settings_page.dart';

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
  // Navigation Category Selection: 'views', 'active_listening', 'general', or specific widget id
  String _selectedSection = 'views';

  void _showAddWidgetSheet() {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    showModalBottomSheet(
      context: context,
      backgroundColor: isDark ? const Color(0xFF1E1E1E) : Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 16.0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  'Add New View',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: isDark ? Colors.white : Colors.black87,
                  ),
                ),
                const SizedBox(height: 12),
                ListTile(
                  leading:
                      Icon(Icons.access_time, color: theme.colorScheme.primary),
                  title: const Text('Clock View'),
                  onTap: () {
                    widget.onAddWidget(StandbyWidgetType.clock);
                    Navigator.pop(context);
                  },
                ),
                ListTile(
                  leading:
                      Icon(Icons.wb_sunny, color: theme.colorScheme.primary),
                  title: const Text('Weather View'),
                  onTap: () {
                    widget.onAddWidget(StandbyWidgetType.weather);
                    Navigator.pop(context);
                  },
                ),
                ListTile(
                  leading: Icon(Icons.water, color: theme.colorScheme.primary),
                  title: const Text('Koi Pond View'),
                  onTap: () {
                    widget.onAddWidget(StandbyWidgetType.koiPond);
                    Navigator.pop(context);
                  },
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildRightDetailPanel(bool isDark, ThemeData theme) {
    // 1. Clock Details Selected
    if (_selectedSection.startsWith('clock_') || _selectedSection == 'clock') {
      final clockConfig = widget.allWidgets.firstWhere(
        (w) => w.type == StandbyWidgetType.clock,
        orElse: () => widget.allWidgets.first,
      );
      return ClockDetailWidget(
        config: clockConfig,
        onBack: () => setState(() => _selectedSection = 'views'),
        onUpdateConfig: widget.onUpdateConfig,
      );
    }

    // 2. Active Listening Selected
    if (_selectedSection == 'active_listening') {
      return ActiveListeningSettingsPage(
        config: widget.activeListeningConfig,
        onBack: () => setState(() => _selectedSection = 'views'),
        onUpdateConfig: widget.onUpdateConfig,
      );
    }

    // 3. General Settings Selected
    if (_selectedSection == 'general') {
      return GeneralSettingsPage(
        config: widget.generalConfig,
        onBack: () => setState(() => _selectedSection = 'views'),
        onUpdateConfig: widget.onUpdateConfig,
      );
    }

    // 4. Default: Views Management List
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Views Order & Visibility',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: isDark ? Colors.white : Colors.black87,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          'Drag handles to reorder views or toggle enable/disable state.',
          style: TextStyle(
            fontSize: 13,
            color: isDark ? Colors.grey.shade400 : Colors.grey.shade600,
          ),
        ),
        const SizedBox(height: 16),
        Expanded(
          child: ReorderableListView.builder(
            itemCount: widget.allWidgets.length,
            onReorder: widget.onReorder,
            itemBuilder: (context, index) {
              final item = widget.allWidgets[index];
              final isSettings = item.type == StandbyWidgetType.settings;

              return Container(
                key: ValueKey(item.id),
                margin: const EdgeInsets.only(bottom: 8),
                decoration: BoxDecoration(
                  color: isDark ? const Color(0xFF1E1E1E) : Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: isDark ? Colors.white12 : Colors.black12,
                  ),
                ),
                child: ListTile(
                  leading: Icon(
                    item.type == StandbyWidgetType.clock
                        ? Icons.access_time
                        : item.type == StandbyWidgetType.weather
                            ? Icons.wb_sunny
                            : item.type == StandbyWidgetType.koiPond
                                ? Icons.water
                                : Icons.tune,
                    color: theme.colorScheme.primary,
                  ),
                  title: Text(
                    item.title,
                    style: TextStyle(
                      fontWeight: FontWeight.w600,
                      color: isDark ? Colors.white : Colors.black87,
                    ),
                  ),
                  subtitle: Text(
                    isSettings
                        ? 'Always active'
                        : item.type == StandbyWidgetType.clock
                            ? 'Tap to configure'
                            : 'Swipeable view',
                    style: TextStyle(
                      fontSize: 12,
                      color:
                          isDark ? Colors.grey.shade400 : Colors.grey.shade600,
                    ),
                  ),
                  onTap: isSettings
                      ? null
                      : () {
                          setState(() {
                            _selectedSection = item.id;
                          });
                        },
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      if (!isSettings)
                        Switch(
                          value: item.isEnabled,
                          activeThumbColor: theme.colorScheme.primary,
                          onChanged: (enabled) =>
                              widget.onToggle(item.id, enabled),
                        ),
                      const SizedBox(width: 8),
                      ReorderableDragStartListener(
                        index: index,
                        child: Icon(
                          Icons.drag_handle,
                          color: isDark
                              ? Colors.grey.shade600
                              : Colors.grey.shade400,
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        ),
        Padding(
          padding: const EdgeInsets.only(top: 12.0),
          child: OutlinedButton.icon(
            style: OutlinedButton.styleFrom(
              minimumSize: const Size.fromHeight(44),
              side: BorderSide(color: theme.colorScheme.primary),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            onPressed: _showAddWidgetSheet,
            icon: Icon(Icons.add, color: theme.colorScheme.primary),
            label: Text(
              'Add New View',
              style: TextStyle(color: theme.colorScheme.primary),
            ),
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Material(
      color: Colors.transparent,
      child: SafeArea(
        child: Row(
          children: [
            // LEFT COLUMN: Sidebar Categories Navigation
            SizedBox(
              width: 220,
              child: Container(
                margin: const EdgeInsets.all(12),
                padding: const EdgeInsets.symmetric(vertical: 12),
                decoration: BoxDecoration(
                  color: isDark
                      ? Colors.white.withValues(alpha: 0.03)
                      : Colors.black.withValues(alpha: 0.03),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: isDark ? Colors.white12 : Colors.black12,
                  ),
                ),
                child: ListView(
                  children: [
                    Padding(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 16, vertical: 8),
                      child: Text(
                        'SETTINGS',
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                          letterSpacing: 1.2,
                          color: isDark
                              ? Colors.grey.shade500
                              : Colors.grey.shade600,
                        ),
                      ),
                    ),
                    ListTile(
                      selected: _selectedSection == 'views',
                      selectedTileColor:
                          theme.colorScheme.primary.withValues(alpha: 0.15),
                      leading: Icon(
                        Icons.view_list,
                        color: _selectedSection == 'views'
                            ? theme.colorScheme.primary
                            : (isDark
                                ? Colors.grey.shade400
                                : Colors.grey.shade700),
                      ),
                      title: Text(
                        'Views Order',
                        style: TextStyle(
                          fontWeight: FontWeight.w600,
                          color: isDark ? Colors.white : Colors.black87,
                        ),
                      ),
                      onTap: () => setState(() => _selectedSection = 'views'),
                    ),
                    ListTile(
                      selected: _selectedSection == 'active_listening',
                      selectedTileColor:
                          theme.colorScheme.primary.withValues(alpha: 0.15),
                      leading: Icon(
                        Icons.music_note,
                        color: _selectedSection == 'active_listening'
                            ? theme.colorScheme.primary
                            : (isDark
                                ? Colors.grey.shade400
                                : Colors.grey.shade700),
                      ),
                      title: Text(
                        'Active Overlay',
                        style: TextStyle(
                          fontWeight: FontWeight.w600,
                          color: isDark ? Colors.white : Colors.black87,
                        ),
                      ),
                      onTap: () =>
                          setState(() => _selectedSection = 'active_listening'),
                    ),
                    ListTile(
                      selected: _selectedSection == 'general',
                      selectedTileColor:
                          theme.colorScheme.primary.withValues(alpha: 0.15),
                      leading: Icon(
                        Icons.tune,
                        color: _selectedSection == 'general'
                            ? theme.colorScheme.primary
                            : (isDark
                                ? Colors.grey.shade400
                                : Colors.grey.shade700),
                      ),
                      title: Text(
                        'General',
                        style: TextStyle(
                          fontWeight: FontWeight.w600,
                          color: isDark ? Colors.white : Colors.black87,
                        ),
                      ),
                      onTap: () => setState(() => _selectedSection = 'general'),
                    ),
                  ],
                ),
              ),
            ),

            // RIGHT COLUMN: Selected Detail Content Area
            Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(
                    horizontal: 16.0, vertical: 12.0),
                child: _buildRightDetailPanel(isDark, theme),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
