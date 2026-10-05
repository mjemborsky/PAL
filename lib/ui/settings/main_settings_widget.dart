import 'package:flutter/material.dart';
import '../../models/widget_config.dart';
import 'active_listening_settings_page.dart';
import 'general_settings_page.dart';
import 'view_detail_page.dart';
import 'views_management_page.dart';

enum SettingsSubScreen { root, general, views, viewDetail, activeListening }

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

class _MainSettingsWidgetState extends State<MainSettingsWidget>
    with AutomaticKeepAliveClientMixin {
  SettingsSubScreen _currentSubScreen = SettingsSubScreen.root;
  String? _selectedWidgetId;

  @override
  bool get wantKeepAlive => true;

  @override
  Widget build(BuildContext context) {
    super.build(context);
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 24.0),
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

      case SettingsSubScreen.general:
        return GeneralSettingsPage(
          config: widget.generalConfig,
          onBack: () {
            setState(() {
              _currentSubScreen = SettingsSubScreen.root;
            });
          },
          onUpdateConfig: () {
            setState(() {});
            widget.onUpdateConfig();
          },
        );

      case SettingsSubScreen.views:
        return ViewsManagementPage(
          allWidgets: widget.allWidgets,
          onReorder: widget.onReorder,
          onToggle: widget.onToggle,
          onAddWidget: widget.onAddWidget,
          onSelectWidget: (id) {
            setState(() {
              _selectedWidgetId = id;
              _currentSubScreen = SettingsSubScreen.viewDetail;
            });
          },
          onBack: () {
            setState(() {
              _currentSubScreen = SettingsSubScreen.root;
            });
          },
        );

      case SettingsSubScreen.viewDetail:
        final selectedWidget = widget.allWidgets.firstWhere(
          (w) => w.id == _selectedWidgetId,
          orElse: () => widget.allWidgets.first,
        );

        return ViewDetailPage(
          item: selectedWidget,
          onBack: () {
            setState(() {
              _currentSubScreen = SettingsSubScreen.views;
            });
          },
          onUpdateConfig: () {
            setState(() {});
            widget.onUpdateConfig();
          },
        );

      case SettingsSubScreen.activeListening:
        return ActiveListeningSettingsPage(
          config: widget.activeListeningConfig,
          onBack: () {
            setState(() {
              _currentSubScreen = SettingsSubScreen.root;
            });
          },
          onUpdateConfig: () {
            setState(() {});
            widget.onUpdateConfig();
          },
        );
    }
  }

  Widget _buildRootSettingsMenu() {
    final isDark = widget.generalConfig.themeMode == AppThemeMode.dark;
    final textColor = isDark ? Colors.white : Colors.black87;
    final subtitleColor = isDark ? Colors.grey : Colors.grey.shade600;
    final cardBgColor = isDark ? Colors.grey.shade900 : Colors.grey.shade200;
    final primaryAccent = isDark ? Colors.cyanAccent : Colors.teal;

    return Column(
      key: const ValueKey('RootSettings'),
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(Icons.settings, color: primaryAccent, size: 26),
            const SizedBox(width: 10),
            Text(
              'Settings',
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
                color: textColor,
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Divider(color: isDark ? Colors.white24 : Colors.black12),
        Card(
          color: cardBgColor,
          elevation: isDark ? 0 : 1,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          child: ListTile(
            leading: Icon(
              Icons.dashboard_customize,
              color: primaryAccent,
            ),
            title: Text(
              'Views',
              style: TextStyle(color: textColor, fontWeight: FontWeight.w600),
            ),
            subtitle: Text(
              'Add, reorder, toggle, and customize views',
              style: TextStyle(color: subtitleColor, fontSize: 11),
            ),
            trailing: Icon(Icons.chevron_right,
                color: isDark ? Colors.white70 : Colors.black54),
            onTap: () {
              setState(() {
                _currentSubScreen = SettingsSubScreen.views;
              });
            },
          ),
        ),
        const SizedBox(height: 8),
        Card(
          color: cardBgColor,
          elevation: isDark ? 0 : 1,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          child: ListTile(
            leading: Icon(
              Icons.graphic_eq,
              color: primaryAccent,
            ),
            title: Text(
              'Active Listening Overlay',
              style: TextStyle(color: textColor, fontWeight: FontWeight.w600),
            ),
            subtitle: Text(
              widget.activeListeningConfig.isEnabled
                  ? 'Active (${widget.activeListeningConfig.style.name.toUpperCase()})'
                  : 'Disabled',
              style: TextStyle(
                color: widget.activeListeningConfig.isEnabled
                    ? primaryAccent
                    : subtitleColor,
                fontSize: 11,
              ),
            ),
            trailing: Icon(Icons.chevron_right,
                color: isDark ? Colors.white70 : Colors.black54),
            onTap: () {
              setState(() {
                _currentSubScreen = SettingsSubScreen.activeListening;
              });
            },
          ),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 8.0),
          child: Divider(
              color: isDark ? Colors.white12 : Colors.black12, height: 1),
        ),
        Card(
          color: cardBgColor,
          elevation: isDark ? 0 : 1,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          child: ListTile(
            leading: Icon(
              Icons.tune,
              color: primaryAccent,
            ),
            title: Text(
              'General',
              style: TextStyle(color: textColor, fontWeight: FontWeight.w600),
            ),
            subtitle: Text(
              'Theme: ${isDark ? "DARK" : "LIGHT"}',
              style: TextStyle(color: subtitleColor, fontSize: 11),
            ),
            trailing: Icon(Icons.chevron_right,
                color: isDark ? Colors.white70 : Colors.black54),
            onTap: () {
              setState(() {
                _currentSubScreen = SettingsSubScreen.general;
              });
            },
          ),
        ),
      ],
    );
  }
}
