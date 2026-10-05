enum StandbyWidgetType { clock, weather, settings }

enum ActiveListeningStyle { milkdrop, vinyl }

enum AppThemeMode { dark, light }

class GeneralConfig {
  AppThemeMode themeMode;

  GeneralConfig({
    this.themeMode = AppThemeMode.dark,
  });
}

class ActiveListeningConfig {
  bool isEnabled;
  ActiveListeningStyle style;

  // Milkdrop conditional options
  double sensitivity; // 0.5 to 2.0
  bool showFPS;

  // Vinyl conditional options
  bool rotateVinyl;
  bool showProgressBar;

  ActiveListeningConfig({
    this.isEnabled = true,
    this.style = ActiveListeningStyle.milkdrop,
    this.sensitivity = 1.0,
    this.showFPS = false,
    this.rotateVinyl = true,
    this.showProgressBar = true,
  });
}

class StandbyWidgetConfig {
  final String id;
  String title;
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
    this.isAnalog = true,
    this.use24HourTime = false,
    this.showSeconds = true,
    this.useCelsius = false,
  });
}
