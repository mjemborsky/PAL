enum NotificationCategory { message, system, call, social }

class TrackInfo {
  final String id;
  final String title;
  final String artist;
  final String album;
  final Duration duration;
  final String albumArtUrl;
  final String genre;

  TrackInfo({
    required this.id,
    required this.title,
    required this.artist,
    required this.album,
    required this.duration,
    required this.albumArtUrl,
    required this.genre,
  });
}

class MockNotification {
  final String id;
  final String appName;
  final String title;
  final String body;
  final DateTime timestamp;
  final NotificationCategory category;
  final String? avatarUrl;

  MockNotification({
    required this.id,
    required this.appName,
    required this.title,
    required this.body,
    required this.timestamp,
    required this.category,
    this.avatarUrl,
  });
}

class MockWeatherData {
  final double temperatureF;
  final double tempMinF;
  final double tempMaxF;
  final String condition;
  final int weatherCode; // Open-Meteo standard
  final int humidity;
  final double windSpeedMph;
  final String locationName;

  MockWeatherData({
    required this.temperatureF,
    required this.tempMinF,
    required this.tempMaxF,
    required this.condition,
    required this.weatherCode,
    required this.humidity,
    required this.windSpeedMph,
    required this.locationName,
  });
}

class MockPhoto {
  final String id;
  final String url;
  final String caption;
  final DateTime takenAt;

  MockPhoto({
    required this.id,
    required this.url,
    required this.caption,
    required this.takenAt,
  });
}
