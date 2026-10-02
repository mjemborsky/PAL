enum StandbyWidgetType { clock, weather, settings }

class StandbyWidgetConfig {
  final String id;
  final String title;
  final StandbyWidgetType type;
  bool isEnabled;

  // Clock options
  bool isAnalog;
  bool use24HourTime;
  bool showSeconds;

  // Weather options
  bool useCelsius;

  StandbyWidgetConfig({
    required this.id,
    required this.title,
    required this.type,
    this.isEnabled = true,
    this.isAnalog = true, // Analog by default
    this.use24HourTime = false,
    this.showSeconds = true,
    this.useCelsius = false,
  });
}
