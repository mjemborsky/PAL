import 'package:flutter/material.dart';
import '../../models/widget_config.dart';
import 'views_management_page.dart';
import 'details/clock_detail_widget.dart';

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
  StandbyWidgetConfig? _selectedWidgetForDetail;

  final List<String> _categories = [
    'Views Management',
    'Active Listening',
    'Appearance & System',
  ];

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      Icon(Icons.settings,
                          color: theme.colorScheme.primary, size: 28),
                      const SizedBox(width: 12),
                      Text(
                        'SETTINGS',
                        style: TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                          letterSpacing: 2.0,
                          color: isDark ? Colors.white : Colors.black87,
                        ),
                      ),
                    ],
                  ),
                  Text(
                    'PAL v1.0',
                    style: TextStyle(
                      fontSize: 14,
                      color:
                          isDark ? Colors.grey.shade600 : Colors.grey.shade500,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              Divider(color: theme.dividerColor, height: 1),
              const SizedBox(height: 16),

              // Main 2-Column Split View
              Expanded(
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Left Side Categories Navigation
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
                                  ? theme.colorScheme.primary
                                      .withValues(alpha: 0.15)
                                  : Colors.transparent,
                              borderRadius: BorderRadius.circular(8),
                              clipBehavior: Clip.antiAlias,
                              child: Container(
                                decoration: BoxDecoration(
                                  border: Border.all(
                                    color: isSelected
                                        ? theme.colorScheme.primary
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
                                          ? theme.colorScheme.primary
                                          : (isDark
                                              ? Colors.grey.shade400
                                              : Colors.grey.shade700),
                                    ),
                                  ),
                                  onTap: () {
                                    setState(() {
                                      _selectedCategoryIndex = index;
                                      _selectedWidgetForDetail = null;
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
                    VerticalDivider(color: theme.dividerColor, width: 1),
                    const SizedBox(width: 20),

                    // Right Side Dynamic Content Subpage
                    Expanded(
                      child: _buildRightSideContent(isDark),
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

  Widget _buildRightSideContent(bool isDark) {
    if (_selectedWidgetForDetail != null) {
      switch (_selectedWidgetForDetail!.type) {
        case StandbyWidgetType.clock:
          return ClockDetailWidget(
            config: _selectedWidgetForDetail!,
            onBack: () {
              setState(() {
                _selectedWidgetForDetail = null;
              });
            },
            onUpdateConfig: widget.onUpdateConfig,
          );
        case StandbyWidgetType.weather:
        case StandbyWidgetType.settings:
          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              IconButton(
                icon: Icon(Icons.arrow_back,
                    color: Theme.of(context).colorScheme.primary),
                onPressed: () {
                  setState(() {
                    _selectedWidgetForDetail = null;
                  });
                },
              ),
              const SizedBox(height: 16),
              Text(
                '${_selectedWidgetForDetail!.title} Settings',
                style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: isDark ? Colors.white : Colors.black87),
              ),
            ],
          );
      }
    }

    switch (_selectedCategoryIndex) {
      case 0:
        return ViewsManagementPage(
          allWidgets: widget.allWidgets,
          onReorder: widget.onReorder,
          onToggle: widget.onToggle,
          onAddWidget: widget.onAddWidget,
          onSelectWidget: (selectedWidget) {
            setState(() {
              _selectedWidgetForDetail = selectedWidget;
            });
          },
          onBack: () {
            setState(() {
              _selectedCategoryIndex = 0;
              _selectedWidgetForDetail = null;
            });
          },
        );
      case 1:
        return _buildActiveListeningSection(isDark);
      case 2:
        return _buildAppearanceSection(isDark);
      default:
        return const SizedBox.shrink();
    }
  }

  Widget _buildActiveListeningSection(bool isDark) {
    final config = widget.activeListeningConfig;
    final isMilkdrop = config.style == ActiveListeningStyle.milkdrop;
    final textColor = isDark ? Colors.white : Colors.black87;
    final subtitleColor = isDark ? Colors.grey.shade400 : Colors.grey.shade600;

    return ListView(
      children: [
        SwitchListTile(
          title: Text('Enable Overlay',
              style: TextStyle(
                  fontSize: 18, fontWeight: FontWeight.bold, color: textColor)),
          subtitle: Text('Swipe down from top edge to reveal overlay',
              style: TextStyle(fontSize: 14, color: subtitleColor)),
          value: config.isEnabled,
          activeThumbColor: Theme.of(context).colorScheme.primary,
          onChanged: (val) {
            setState(() {
              config.isEnabled = val;
            });
            widget.onUpdateConfig();
          },
        ),
        const SizedBox(height: 12),
        Text('Visualizer Style',
            style: TextStyle(
                fontSize: 16, fontWeight: FontWeight.bold, color: textColor)),
        const SizedBox(height: 8),
        Row(
          children: [
            Expanded(
              child: ChoiceChip(
                label: const Padding(
                  padding: EdgeInsets.symmetric(vertical: 8.0),
                  child: Text('Milkdrop Waves', style: TextStyle(fontSize: 15)),
                ),
                selected: isMilkdrop,
                selectedColor: Theme.of(context)
                    .colorScheme
                    .primary
                    .withValues(alpha: 0.3),
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
                selectedColor: Theme.of(context)
                    .colorScheme
                    .primary
                    .withValues(alpha: 0.3),
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
        if (isMilkdrop) ...[
          const SizedBox(height: 20),
          Divider(color: Theme.of(context).dividerColor),
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 8.0),
            child: Text(
              'MILKDROP ENGINE OPTIONS',
              style: TextStyle(
                color: Theme.of(context).colorScheme.primary,
                fontSize: 12,
                fontWeight: FontWeight.bold,
                letterSpacing: 1.2,
              ),
            ),
          ),
          SwitchListTile(
            title: Text('Show FPS Counter',
                style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: textColor)),
            subtitle: Text('Display real-time rendering performance',
                style: TextStyle(fontSize: 13, color: subtitleColor)),
            value: config.showFPS,
            activeThumbColor: Theme.of(context).colorScheme.primary,
            onChanged: (val) {
              setState(() {
                config.showFPS = val;
              });
              widget.onUpdateConfig();
            },
          ),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('Audio Sensitivity',
                  style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: textColor)),
              Text('${config.sensitivity.toStringAsFixed(1)}x',
                  style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.bold,
                      color: Theme.of(context).colorScheme.primary)),
            ],
          ),
          Slider(
            value: config.sensitivity,
            min: 0.5,
            max: 2.0,
            divisions: 15,
            activeColor: Theme.of(context).colorScheme.primary,
            onChanged: (val) {
              setState(() {
                config.sensitivity = val;
              });
              widget.onUpdateConfig();
            },
          ),
        ],
        if (!isMilkdrop) ...[
          const SizedBox(height: 20),
          Divider(color: Theme.of(context).dividerColor),
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 8.0),
            child: Text(
              'VINYL ENGINE OPTIONS',
              style: TextStyle(
                color: Theme.of(context).colorScheme.primary,
                fontSize: 12,
                fontWeight: FontWeight.bold,
                letterSpacing: 1.2,
              ),
            ),
          ),
          ListTile(
            title: Text('Turntable Speed',
                style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: textColor)),
            subtitle: Text('Standard playback rotation rate',
                style: TextStyle(fontSize: 13, color: subtitleColor)),
            trailing: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
              decoration: BoxDecoration(
                color: isDark ? Colors.grey.shade900 : Colors.grey.shade200,
                borderRadius: BorderRadius.circular(6),
                border: Border.all(color: Theme.of(context).dividerColor),
              ),
              child: Text('33 RPM',
                  style: TextStyle(
                      color: Theme.of(context).colorScheme.primary,
                      fontWeight: FontWeight.bold)),
            ),
          ),
        ],
      ],
    );
  }

  Widget _buildAppearanceSection(bool isDark) {
    final general = widget.generalConfig;
    final textColor = isDark ? Colors.white : Colors.black87;
    final subtitleColor = isDark ? Colors.grey.shade400 : Colors.grey.shade600;

    return ListView(
      children: [
        SwitchListTile(
          title: Text('Dark Mode Theme',
              style: TextStyle(
                  fontSize: 18, fontWeight: FontWeight.bold, color: textColor)),
          subtitle: Text(
            isDark ? 'Dark background enabled' : 'Light background enabled',
            style: TextStyle(fontSize: 14, color: subtitleColor),
          ),
          value: general.themeMode == AppThemeMode.dark,
          activeThumbColor: Theme.of(context).colorScheme.primary,
          onChanged: (val) {
            setState(() {
              general.themeMode = val ? AppThemeMode.dark : AppThemeMode.light;
            });
            // Propagate theme update up to StandbyView to trigger full App re-theme
            widget.onUpdateConfig();
          },
        ),
      ],
    );
  }
}
