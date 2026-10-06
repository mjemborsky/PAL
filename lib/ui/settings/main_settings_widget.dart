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
    return Scaffold(
      backgroundColor: Colors.black,
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
                    const VerticalDivider(color: Colors.white12, width: 1),
                    const SizedBox(width: 20),

                    // Right Side Dynamic Content Subpage
                    Expanded(
                      child: _buildRightSideContent(),
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

  Widget _buildRightSideContent() {
    // Priority: Detail Page
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
                icon: const Icon(Icons.arrow_back, color: Colors.cyanAccent),
                onPressed: () {
                  setState(() {
                    _selectedWidgetForDetail = null;
                  });
                },
              ),
              const SizedBox(height: 16),
              Text(
                '${_selectedWidgetForDetail!.title} Settings',
                style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Colors.white),
              ),
            ],
          );
      }
    }

    // Default left navigation category selection
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
        return _buildActiveListeningSection();
      case 2:
        return _buildAppearanceSection();
      default:
        return const SizedBox.shrink();
    }
  }

  Widget _buildActiveListeningSection() {
    final config = widget.activeListeningConfig;
    final isMilkdrop = config.style == ActiveListeningStyle.milkdrop;

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
          activeThumbColor: Colors.cyanAccent,
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
                selected: isMilkdrop,
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

        // Milkdrop Specific Options
        if (isMilkdrop) ...[
          const SizedBox(height: 20),
          const Divider(color: Colors.white12),
          const Padding(
            padding: EdgeInsets.symmetric(vertical: 8.0),
            child: Text(
              'MILKDROP ENGINE OPTIONS',
              style: TextStyle(
                color: Colors.cyanAccent,
                fontSize: 12,
                fontWeight: FontWeight.bold,
                letterSpacing: 1.2,
              ),
            ),
          ),
          SwitchListTile(
            title: const Text('Show FPS Counter',
                style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: Colors.white)),
            subtitle: Text('Display real-time rendering performance',
                style: TextStyle(fontSize: 13, color: Colors.grey.shade400)),
            value: config.showFPS,
            activeThumbColor: Colors.cyanAccent,
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
              const Text('Audio Sensitivity',
                  style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: Colors.white)),
              Text('${config.sensitivity.toStringAsFixed(1)}x',
                  style: const TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.bold,
                      color: Colors.cyanAccent)),
            ],
          ),
          Slider(
            value: config.sensitivity,
            min: 0.5,
            max: 2.0,
            divisions: 15,
            activeColor: Colors.cyanAccent,
            onChanged: (val) {
              setState(() {
                config.sensitivity = val;
              });
              widget.onUpdateConfig();
            },
          ),
        ],

        // Vinyl Specific Options
        if (!isMilkdrop) ...[
          const SizedBox(height: 20),
          const Divider(color: Colors.white12),
          const Padding(
            padding: EdgeInsets.symmetric(vertical: 8.0),
            child: Text(
              'VINYL ENGINE OPTIONS',
              style: TextStyle(
                color: Colors.cyanAccent,
                fontSize: 12,
                fontWeight: FontWeight.bold,
                letterSpacing: 1.2,
              ),
            ),
          ),
          ListTile(
            title: const Text('Turntable Speed',
                style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: Colors.white)),
            subtitle: Text('Standard playback rotation rate',
                style: TextStyle(fontSize: 13, color: Colors.grey.shade400)),
            trailing: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
              decoration: BoxDecoration(
                color: Colors.grey.shade900,
                borderRadius: BorderRadius.circular(6),
                border: Border.all(color: Colors.white24),
              ),
              child: const Text('33 RPM',
                  style: TextStyle(
                      color: Colors.cyanAccent, fontWeight: FontWeight.bold)),
            ),
          ),
        ],
      ],
    );
  }

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
          activeThumbColor: Colors.cyanAccent,
          onChanged: (val) {
            setState(() {
              general.themeMode = val ? AppThemeMode.dark : AppThemeMode.light;
            });
            widget.onUpdateConfig();
          },
        ),
      ],
    );
  }
}
