import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'services/mock_audio_service.dart';
import 'services/mock_notification_service.dart';
import 'services/mock_phone_status_service.dart';
import 'services/mock_photo_service.dart';
import 'services/mock_playback_service.dart';
import 'services/mock_weather_service.dart';
import 'ui/standby_view.dart';

void main() {
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => MockPlaybackService()),
        ChangeNotifierProvider(create: (_) => MockNotificationService()),
        ChangeNotifierProvider(create: (_) => MockWeatherService()),
        ChangeNotifierProvider(create: (_) => MockPhotoService()),
        ChangeNotifierProvider(create: (_) => MockPhoneStatusService()),
        Provider(create: (_) => MockAudioService()),
      ],
      child: const PALApp(),
    ),
  );
}

class PALApp extends StatelessWidget {
  const PALApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData.dark(),
      darkTheme: ThemeData.dark(),
      themeMode: ThemeMode.dark,
      home: const StandbyView(),
    );
  }
}
