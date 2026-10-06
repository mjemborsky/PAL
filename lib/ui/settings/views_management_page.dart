import 'package:flutter/material.dart';
import '../../models/widget_config.dart';

class ViewsManagementPage extends StatelessWidget {
  final List<StandbyWidgetConfig> allWidgets;
  final Function(int oldIndex, int newIndex) onReorder;
  final Function(String id, bool enabled) onToggle;
  final Function(StandbyWidgetConfig widget) onSelectWidget;
  final Function(StandbyWidgetType type) onAddWidget;
  final VoidCallback onBack;

  const ViewsManagementPage({
    super.key,
    required this.allWidgets,
    required this.onReorder,
    required this.onToggle,
    required this.onSelectWidget,
    required this.onAddWidget,
    required this.onBack,
  });

  void _showAddWidgetDialog(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.grey.shade900,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (ctx) {
        return Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Add View',
                style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Colors.white),
              ),
              const SizedBox(height: 16),
              ListTile(
                leading: const Icon(Icons.access_time_filled,
                    color: Colors.cyanAccent),
                title: const Text('Clock View',
                    style: TextStyle(color: Colors.white)),
                onTap: () {
                  Navigator.pop(ctx);
                  onAddWidget(StandbyWidgetType.clock);
                },
              ),
              ListTile(
                leading: const Icon(Icons.wb_sunny, color: Colors.cyanAccent),
                title: const Text('Weather View',
                    style: TextStyle(color: Colors.white)),
                onTap: () {
                  Navigator.pop(ctx);
                  onAddWidget(StandbyWidgetType.weather);
                },
              ),
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      key: const ValueKey('ViewsSubPage'),
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            IconButton(
              icon: const Icon(Icons.arrow_back, color: Colors.cyanAccent),
              onPressed: onBack,
            ),
            const SizedBox(width: 4),
            const Expanded(
              child: Text(
                'Views Management',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
            ),
            IconButton(
              icon: const Icon(Icons.add_circle_outline,
                  color: Colors.cyanAccent, size: 26),
              onPressed: () => _showAddWidgetDialog(context),
            ),
          ],
        ),
        const SizedBox(height: 4),
        Text(
          'Tap view to configure options, or drag handles to reorder.',
          style: TextStyle(fontSize: 11, color: Colors.grey.shade400),
        ),
        const SizedBox(height: 8),
        const Divider(color: Colors.white24),
        Expanded(
          child: ReorderableListView.builder(
            itemCount: allWidgets.length,
            onReorder: onReorder,
            itemBuilder: (context, index) {
              final item = allWidgets[index];
              final isSettings = item.type == StandbyWidgetType.settings;

              return Card(
                key: ValueKey('list_item_${item.id}'),
                color: Colors.grey.shade900,
                margin: const EdgeInsets.symmetric(vertical: 4.0),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                  side: BorderSide(
                    color: item.isEnabled
                        ? Colors.cyanAccent.withValues(alpha: 0.3)
                        : Colors.transparent,
                  ),
                ),
                child: ListTile(
                  contentPadding:
                      const EdgeInsets.symmetric(horizontal: 12, vertical: 2),
                  onTap: isSettings ? null : () => onSelectWidget(item),
                  leading: Icon(
                    _getWidgetIcon(item.type),
                    color: item.isEnabled ? Colors.cyanAccent : Colors.grey,
                  ),
                  title: Text(
                    item.title,
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      decoration:
                          item.isEnabled ? null : TextDecoration.lineThrough,
                    ),
                  ),
                  subtitle: Text(
                    isSettings ? 'Always active' : 'Tap to customize',
                    style: TextStyle(
                      color: isSettings ? Colors.cyanAccent : Colors.grey,
                      fontSize: 11,
                    ),
                  ),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Switch(
                        value: item.isEnabled,
                        activeThumbColor: Colors.cyanAccent,
                        onChanged:
                            isSettings ? null : (val) => onToggle(item.id, val),
                      ),
                      const SizedBox(width: 4),
                      ReorderableDragStartListener(
                        index: index,
                        child: const Padding(
                          padding: EdgeInsets.all(6.0),
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
