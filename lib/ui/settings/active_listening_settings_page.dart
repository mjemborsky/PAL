import 'package:flutter/material.dart';
import '../../models/widget_config.dart';

class ActiveListeningSettingsPage extends StatelessWidget {
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
  Widget build(BuildContext context) {
    return Column(
      key: const ValueKey('ActiveListeningSettingsPage'),
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            IconButton(
              icon: const Icon(Icons.arrow_back, color: Colors.cyanAccent),
              onPressed: onBack,
            ),
            const SizedBox(width: 8),
            const Text(
              'Active Listening',
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        const Divider(color: Colors.white24),
        Expanded(
          child: ListView(
            children: [
              // Master Feature Toggle
              SwitchListTile(
                title: const Text('Enable Active Overlay',
                    style: TextStyle(
                        color: Colors.white, fontWeight: FontWeight.bold)),
                subtitle: const Text('Allow top pull-down or audio triggers',
                    style: TextStyle(color: Colors.grey, fontSize: 11)),
                value: config.isEnabled,
                activeThumbColor: Colors.cyanAccent,
                onChanged: (val) {
                  config.isEnabled = val;
                  onUpdateConfig();
                },
              ),
              if (config.isEnabled) ...[
                const Divider(color: Colors.white12),
                const Padding(
                  padding:
                      EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
                  child: Text('Visualizer Style',
                      style: TextStyle(
                          color: Colors.cyanAccent,
                          fontSize: 13,
                          fontWeight: FontWeight.w600)),
                ),
                RadioListTile<ActiveListeningStyle>(
                  title: const Text('Milkdrop Visualizer',
                      style: TextStyle(color: Colors.white, fontSize: 14)),
                  value: ActiveListeningStyle.milkdrop,
                  groupValue: config.style,
                  activeColor: Colors.cyanAccent,
                  onChanged: (val) {
                    if (val != null) {
                      config.style = val;
                      onUpdateConfig();
                    }
                  },
                ),
                RadioListTile<ActiveListeningStyle>(
                  title: const Text('Rotating Vinyl & Track Info',
                      style: TextStyle(color: Colors.white, fontSize: 14)),
                  value: ActiveListeningStyle.vinyl,
                  groupValue: config.style,
                  activeColor: Colors.cyanAccent,
                  onChanged: (val) {
                    if (val != null) {
                      config.style = val;
                      onUpdateConfig();
                    }
                  },
                ),
                const Divider(color: Colors.white12),
                // CONDITIONAL OPTIONS: Milkdrop Mode
                if (config.style == ActiveListeningStyle.milkdrop) ...[
                  const Padding(
                    padding:
                        EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
                    child: Text('Milkdrop Options',
                        style: TextStyle(
                            color: Colors.cyanAccent,
                            fontSize: 13,
                            fontWeight: FontWeight.w600)),
                  ),
                  ListTile(
                    title: const Text('Audio Sensitivity',
                        style: TextStyle(color: Colors.white, fontSize: 14)),
                    subtitle: Slider(
                      value: config.sensitivity,
                      min: 0.5,
                      max: 2.0,
                      divisions: 15,
                      activeColor: Colors.cyanAccent,
                      label: '${config.sensitivity.toStringAsFixed(1)}x',
                      onChanged: (val) {
                        config.sensitivity = val;
                        onUpdateConfig();
                      },
                    ),
                  ),
                  SwitchListTile(
                    title: const Text('Show FPS Counter',
                        style: TextStyle(color: Colors.white, fontSize: 14)),
                    value: config.showFPS,
                    activeThumbColor: Colors.cyanAccent,
                    onChanged: (val) {
                      config.showFPS = val;
                      onUpdateConfig();
                    },
                  ),
                ],
                // CONDITIONAL OPTIONS: Vinyl Mode
                if (config.style == ActiveListeningStyle.vinyl) ...[
                  const Padding(
                    padding:
                        EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
                    child: Text('Vinyl Options',
                        style: TextStyle(
                            color: Colors.cyanAccent,
                            fontSize: 13,
                            fontWeight: FontWeight.w600)),
                  ),
                  SwitchListTile(
                    title: const Text('Spinning Record Animation',
                        style: TextStyle(color: Colors.white, fontSize: 14)),
                    value: config.rotateVinyl,
                    activeThumbColor: Colors.cyanAccent,
                    onChanged: (val) {
                      config.rotateVinyl = val;
                      onUpdateConfig();
                    },
                  ),
                  SwitchListTile(
                    title: const Text('Display Track Progress Bar',
                        style: TextStyle(color: Colors.white, fontSize: 14)),
                    value: config.showProgressBar,
                    activeThumbColor: Colors.cyanAccent,
                    onChanged: (val) {
                      config.showProgressBar = val;
                      onUpdateConfig();
                    },
                  ),
                ],
              ],
            ],
          ),
        ),
      ],
    );
  }
}
