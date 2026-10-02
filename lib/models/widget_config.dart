enum StandbyWidgetType { clock, weather, settings }

class StandbyWidgetConfig {
  final String id;
  final String title;
  final StandbyWidgetType type;
  bool isEnabled;

  StandbyWidgetConfig({
    required this.id,
    required this.title,
    required this.type,
    this.isEnabled = true,
  });
}
