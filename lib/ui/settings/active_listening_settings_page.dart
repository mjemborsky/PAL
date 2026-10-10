import 'package:flutter/material.dart';

import '../../models/widget_config.dart';

class ActiveListeningSettingsPage extends StatefulWidget {
  final ActiveListeningConfig config;
  final VoidCallback onBack;
  final VoidCallback onUpdateConfig;

  const ActiveListeningSettingsPage({
    super.key,
    required this.config,
    required this.onBack,
    required this.onUpdateConfig,
  });

  @override
  State<ActiveListeningSettingsPage> createState() =>
      _ActiveListeningSettingsPageState();
}

class _ActiveListeningSettingsPageState
    extends State<ActiveListeningSettingsPage> {
  late bool _isEnabled;
  late ActiveListeningStyle _selectedStyle;
  late double _sensitivity;
  late bool _showFPS;
  late bool _rotateVinyl;
  late bool _showProgressBar;

  @override
  void initState() {
    super.initState();
    _isEnabled = widget.config.isEnabled;
    _selectedStyle = widget.config.style;
    _sensitivity = widget.config.sensitivity;
    _showFPS = widget.config.showFPS;
    _rotateVinyl = widget.config.rotateVinyl;
    _showProgressBar = widget.config.showProgressBar;
  }

  void _update() {
    widget.config.isEnabled = _isEnabled;
    widget.config.style = _selectedStyle;
    widget.config.sensitivity = _sensitivity;
    widget.config.showFPS = _showFPS;
    widget.config.rotateVinyl = _rotateVinyl;
    widget.config.showProgressBar = _showProgressBar;
    widget.onUpdateConfig();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Header with Back Button
        Row(
          children: [
            IconButton(
              icon: const Icon(Icons.arrow_back),
              onPressed: widget.onBack,
            ),
            const SizedBox(width: 8),
            Text(
              'Active Overlay',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: isDark ? Colors.white : Colors.black87,
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),

        Expanded(
          child: ListView(
            padding: const EdgeInsets.only(right: 8.0),
            children: [
              // Global Overlay Toggle
              SwitchListTile(
                title: const Text('Enable Active Listening Overlay'),
                subtitle: const Text('Slide down overlay on audio playback'),
                value: _isEnabled,
                activeThumbColor: theme.colorScheme.primary,
                onChanged: (val) {
                  setState(() => _isEnabled = val);
                  _update();
                },
              ),
              const Divider(),
              const SizedBox(height: 12),

              Text(
                'VISUALIZER MODE',
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                  color: theme.colorScheme.primary,
                  letterSpacing: 1.2,
                ),
              ),
              const SizedBox(height: 12),

              // Visualizer Mode Cards
              Row(
                children: [
                  Expanded(
                    child: _StyleCard(
                      title: 'Vinyl Mode',
                      description: 'Rotating album wax, artwork, and metadata.',
                      icon: Icons.album,
                      isSelected: _selectedStyle == ActiveListeningStyle.vinyl,
                      onTap: () {
                        setState(
                            () => _selectedStyle = ActiveListeningStyle.vinyl);
                        _update();
                      },
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _StyleCard(
                      title: 'Milkdrop Mode',
                      description:
                          'Audio reactive canvas and music visualizer.',
                      icon: Icons.graphic_eq,
                      isSelected:
                          _selectedStyle == ActiveListeningStyle.milkdrop,
                      onTap: () {
                        setState(() =>
                            _selectedStyle = ActiveListeningStyle.milkdrop);
                        _update();
                      },
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),

              Text(
                'MODE OPTIONS',
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                  color: theme.colorScheme.primary,
                  letterSpacing: 1.2,
                ),
              ),
              const SizedBox(height: 8),

              // Vinyl Mode Options
              if (_selectedStyle == ActiveListeningStyle.vinyl) ...[
                SwitchListTile(
                  title: const Text('Rotate Vinyl Record'),
                  subtitle: const Text('Spin record disc during playback'),
                  value: _rotateVinyl,
                  activeThumbColor: theme.colorScheme.primary,
                  onChanged: (val) {
                    setState(() => _rotateVinyl = val);
                    _update();
                  },
                ),
                SwitchListTile(
                  title: const Text('Show Progress Bar'),
                  subtitle:
                      const Text('Display track timeline and duration counter'),
                  value: _showProgressBar,
                  activeThumbColor: theme.colorScheme.primary,
                  onChanged: (val) {
                    setState(() => _showProgressBar = val);
                    _update();
                  },
                ),
              ],

              // Milkdrop Mode Options
              if (_selectedStyle == ActiveListeningStyle.milkdrop) ...[
                ListTile(
                  title: const Text('Audio Sensitivity'),
                  subtitle: Text(_sensitivity.toStringAsFixed(1)),
                ),
                Slider(
                  value: _sensitivity,
                  min: 0.5,
                  max: 2.0,
                  divisions: 15,
                  activeColor: theme.colorScheme.primary,
                  label: _sensitivity.toStringAsFixed(1),
                  onChanged: (val) {
                    setState(() => _sensitivity = val);
                    _update();
                  },
                ),
                SwitchListTile(
                  title: const Text('Show FPS Counter'),
                  subtitle: const Text('Display rendering frame rate overlay'),
                  value: _showFPS,
                  activeThumbColor: theme.colorScheme.primary,
                  onChanged: (val) {
                    setState(() => _showFPS = val);
                    _update();
                  },
                ),
              ],
            ],
          ),
        ),
      ],
    );
  }
}

class _StyleCard extends StatelessWidget {
  final String title;
  final String description;
  final IconData icon;
  final bool isSelected;
  final VoidCallback onTap;

  const _StyleCard({
    required this.title,
    required this.description,
    required this.icon,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSelected
                ? theme.colorScheme.primary
                : (isDark ? Colors.white12 : Colors.black12),
            width: isSelected ? 2.0 : 1.0,
          ),
          color: isSelected
              ? theme.colorScheme.primary.withValues(alpha: 0.1)
              : Colors.transparent,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(
              icon,
              size: 28,
              color: isSelected
                  ? theme.colorScheme.primary
                  : theme.iconTheme.color,
            ),
            const SizedBox(height: 10),
            Text(
              title,
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 15,
                color: isDark ? Colors.white : Colors.black87,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              description,
              style: TextStyle(
                fontSize: 12,
                color: isDark ? Colors.grey.shade400 : Colors.grey.shade600,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
