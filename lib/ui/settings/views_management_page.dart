import 'package:flutter/material.dart';
import '../../models/widget_config.dart';

class ViewsManagementPage extends StatelessWidget {
  final List<StandbyWidgetConfig> allWidgets;
  final Function(int oldIndex, int newIndex) onReorder;
  final Function(String id, bool enabled) onToggle;
  final Function(StandbyWidgetType type) onAddWidget;
  final Function(StandbyWidgetConfig widget) onSelectWidget;
  final VoidCallback onBack;

  const ViewsManagementPage({
    super.key,
    required this.allWidgets,
    required this.onReorder,
    required this.onToggle,
    required this.onAddWidget,
    required this.onSelectWidget,
    required this.onBack,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    final headerTextColor = isDark ? Colors.white : Colors.black87;
    final cardBgColor = isDark ? Colors.grey.shade900 : Colors.white;
    final itemTextColor = isDark ? Colors.white : Colors.black87;
    final subtitleColor = isDark ? Colors.grey.shade400 : Colors.grey.shade600;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              children: [
                IconButton(
                  icon:
                      Icon(Icons.arrow_back, color: theme.colorScheme.primary),
                  onPressed: onBack,
                ),
                const SizedBox(width: 8),
                Text(
                  'Views Management',
                  style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    color: headerTextColor,
                  ),
                ),
              ],
            ),
            PopupMenuButton<StandbyWidgetType>(
              icon: Icon(Icons.add_circle_outline,
                  color: theme.colorScheme.primary, size: 28),
              onSelected: onAddWidget,
              itemBuilder: (context) => [
                const PopupMenuItem(
                  value: StandbyWidgetType.clock,
                  child: Text('Add Clock Widget'),
                ),
                const PopupMenuItem(
                  value: StandbyWidgetType.weather,
                  child: Text('Add Weather Widget'),
                ),
                const PopupMenuItem(
                  value: StandbyWidgetType.koiPond,
                  child: Text('Add Koi Pond Widget'),
                ),
              ],
            ),
          ],
        ),
        const SizedBox(height: 4),
        Padding(
          padding: const EdgeInsets.only(left: 48.0),
          child: Text(
            'Tap view to configure options, or drag handles to reorder.',
            style: TextStyle(fontSize: 13, color: subtitleColor),
          ),
        ),
        const SizedBox(height: 16),
        Expanded(
          child: ReorderableListView.builder(
            itemCount: allWidgets.length,
            onReorder: onReorder,
            itemBuilder: (context, index) {
              final widgetItem = allWidgets[index];
              final isSettings = widgetItem.type == StandbyWidgetType.settings;

              return Container(
                key: ValueKey(widgetItem.id),
                margin: const EdgeInsets.only(bottom: 12),
                decoration: BoxDecoration(
                  color: cardBgColor,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: isDark ? Colors.white10 : Colors.black12,
                    width: 1,
                  ),
                  boxShadow: isDark
                      ? []
                      : [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.05),
                            blurRadius: 4,
                            offset: const Offset(0, 2),
                          ),
                        ],
                ),
                child: ListTile(
                  contentPadding:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                  leading: Icon(
                    _getWidgetIcon(widgetItem.type),
                    color: theme.colorScheme.primary,
                  ),
                  title: Text(
                    widgetItem.title,
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: itemTextColor,
                    ),
                  ),
                  subtitle: Text(
                    isSettings
                        ? 'Always active'
                        : widgetItem.type == StandbyWidgetType.clock
                            ? 'Tap to customize'
                            : 'Active view',
                    style: TextStyle(
                      fontSize: 12,
                      color: isSettings
                          ? theme.colorScheme.primary
                          : subtitleColor,
                    ),
                  ),
                  onTap: isSettings ? null : () => onSelectWidget(widgetItem),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Switch(
                        value: widgetItem.isEnabled,
                        activeThumbColor: theme.colorScheme.primary,
                        onChanged: isSettings
                            ? null
                            : (val) => onToggle(widgetItem.id, val),
                      ),
                      const SizedBox(width: 8),
                      ReorderableDragStartListener(
                        index: index,
                        child: Icon(Icons.drag_handle, color: subtitleColor),
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
        return Icons.access_time;
      case StandbyWidgetType.weather:
        return Icons.wb_sunny;
      case StandbyWidgetType.koiPond:
        return Icons.water;
      case StandbyWidgetType.settings:
        return Icons.tune;
    }
  }
}
