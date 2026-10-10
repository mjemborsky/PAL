import 'package:flutter/foundation.dart';
import '../models/phone_data_models.dart';

class MockWeatherService extends ChangeNotifier {
  final MockWeatherData _currentWeather = MockWeatherData(
    temperatureF: 68.0,
    tempMinF: 52.0,
    tempMaxF: 74.0,
    condition: 'Partly Cloudy',
    weatherCode: 2, // Open-Meteo code for partly cloudy
    humidity: 45,
    windSpeedMph: 8.5,
    locationName: 'Saint Paul, MN',
  );

  MockWeatherData get currentWeather => _currentWeather;

  void refreshWeather() {
    // Allows toggling mock conditions during UI testing
    notifyListeners();
  }
}
