import 'package:flutter/material.dart';
import '../../../models/widget_config.dart';

class ClockDetailWidget extends StatefulWidget {
  final StandbyWidgetConfig config;
  final VoidCallback onBack;
  final VoidCallback onUpdateConfig;

  const ClockDetailWidget({
    super.key,
    required this.config,
    required this.onBack,
    required this.onUpdateConfig,
  });

  @override
  State<ClockDetailWidget> createState() => _ClockDetailWidgetState();
}

class _ClockDetailWidgetState extends State<ClockDetailWidget> {
  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Subpage Navigation Header
        Row(
          children: [
            IconButton(
              icon: const Icon(Icons.arrow_back, color: Colors.cyanAccent),
              onPressed: widget.onBack,
              tooltip: 'Back to Views',
            ),
            const SizedBox(width: 8),
            Text(
              '${widget.config.title} Settings',
              style: const TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        const Divider(color: Colors.white12, height: 1),
        const SizedBox(height: 16),

        // Clock Specific Controls
        Expanded(
          child: ListView(
            children: [
              const Text(
                'Display Mode',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Colors.white70,
                ),
              ),
              const SizedBox(height: 10),
              Row(
                children: [
                  Expanded(
                    child: ChoiceChip(
                      label: const Padding(
                        padding: EdgeInsets.symmetric(vertical: 8.0),
                        child: Text('Digital', style: TextStyle(fontSize: 15)),
                      ),
                      selected: !widget.config.isAnalog,
                      selectedColor: Colors.cyanAccent.withValues(alpha: 0.3),
                      onSelected: (selected) {
                        if (selected) {
                          setState(() {
                            widget.config.isAnalog = false;
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
                        child: Text('Analog', style: TextStyle(fontSize: 15)),
                      ),
                      selected: widget.config.isAnalog,
                      selectedColor: Colors.cyanAccent.withValues(alpha: 0.3),
                      onSelected: (selected) {
                        if (selected) {
                          setState(() {
                            widget.config.isAnalog = true;
                          });
                          widget.onUpdateConfig();
                        }
                      },
                    ),
                  ),
                ],
              ),
              const Divider(color: Colors.white12, height: 28),

              // Calendar Toggle
              SwitchListTile(
                title: const Text('Show Calendar Date',
                    style: TextStyle(
                        fontSize: 17,
                        fontWeight: FontWeight.bold,
                        color: Colors.white)),
                subtitle: Text('Displays side-by-side date and day information',
                    style:
                        TextStyle(fontSize: 14, color: Colors.grey.shade400)),
                value: widget.config.showCalendar,
                activeThumbColor: Colors.cyanAccent,
                onChanged: (val) {
                  setState(() {
                    widget.config.showCalendar = val;
                  });
                  widget.onUpdateConfig();
                },
              ),

              const Divider(color: Colors.white12, height: 20),

              // Show Seconds Toggle
              SwitchListTile(
                title: const Text('Show Seconds',
                    style: TextStyle(
                        fontSize: 17,
                        fontWeight: FontWeight.bold,
                        color: Colors.white)),
                subtitle: Text(
                    'Applies to digital timer readout and analog sweeping hand',
                    style:
                        TextStyle(fontSize: 14, color: Colors.grey.shade400)),
                value: widget.config.showSeconds,
                activeThumbColor: Colors.cyanAccent,
                onChanged: (val) {
                  setState(() {
                    widget.config.showSeconds = val;
                  });
                  widget.onUpdateConfig();
                },
              ),

              if (!widget.config.isAnalog) ...[
                const Divider(color: Colors.white12, height: 20),
                // 24-Hour Format Toggle
                SwitchListTile(
                  title: const Text('24-Hour Time Format',
                      style: TextStyle(
                          fontSize: 17,
                          fontWeight: FontWeight.bold,
                          color: Colors.white)),
                  subtitle: Text(
                      'Toggle between 12-hour AM/PM and 24-hour military time',
                      style:
                          TextStyle(fontSize: 14, color: Colors.grey.shade400)),
                  value: widget.config.use24HourTime,
                  activeThumbColor: Colors.cyanAccent,
                  onChanged: (val) {
                    setState(() {
                      widget.config.use24HourTime = val;
                    });
                    widget.onUpdateConfig();
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
