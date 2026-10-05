import 'package:flutter/material.dart';
import '../../models/widget_config.dart';

class GeneralSettingsPage extends StatelessWidget {
  final GeneralConfig config;
  final VoidCallback onBack;
  final VoidCallback onUpdateConfig;

  const GeneralSettingsPage({
    super.key,
    required this.config,
    required this.onBack,
    required this.onUpdateConfig,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = config.themeMode == AppThemeMode.dark;
    final textColor = isDark ? Colors.white : Colors.black87;
    final subtitleColor = isDark ? Colors.grey : Colors.grey.shade600;
    final primaryAccent = isDark ? Colors.cyanAccent : Colors.teal;

    return Column(
      key: const ValueKey('GeneralSettingsPage'),
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            IconButton(
              icon: Icon(Icons.arrow_back, color: primaryAccent),
              onPressed: onBack,
            ),
            const SizedBox(width: 8),
            Text(
              'General Settings',
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
                color: textColor,
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        Divider(color: isDark ? Colors.white24 : Colors.black12),
        Expanded(
          child: ListView(
            children: [
              Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
                child: Text(
                  'Appearance',
                  style: TextStyle(
                    color: primaryAccent,
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              RadioListTile<AppThemeMode>(
                title: Text('Dark Mode',
                    style: TextStyle(color: textColor, fontSize: 14)),
                subtitle: Text('OLED pitch black background',
                    style: TextStyle(color: subtitleColor, fontSize: 11)),
                value: AppThemeMode.dark,
                groupValue: config.themeMode,
                activeColor: primaryAccent,
                onChanged: (val) {
                  if (val != null) {
                    config.themeMode = val;
                    onUpdateConfig();
                  }
                },
              ),
              RadioListTile<AppThemeMode>(
                title: Text('Light Mode',
                    style: TextStyle(color: textColor, fontSize: 14)),
                subtitle: Text('Clean slate white background',
                    style: TextStyle(color: subtitleColor, fontSize: 11)),
                value: AppThemeMode.light,
                groupValue: config.themeMode,
                activeColor: primaryAccent,
                onChanged: (val) {
                  if (val != null) {
                    config.themeMode = val;
                    onUpdateConfig();
                  }
                },
              ),
            ],
          ),
        ),
      ],
    );
  }
}
