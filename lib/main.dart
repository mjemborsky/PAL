import 'package:flutter/gestures.dart';
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

class DesktopScrollBehavior extends MaterialScrollBehavior {
  @override
  Set<PointerDeviceKind> get dragDevices => {
        PointerDeviceKind.touch,
        PointerDeviceKind.mouse,
        PointerDeviceKind.trackpad,
      };
}

class PALApp extends StatelessWidget {
  const PALApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      scrollBehavior: DesktopScrollBehavior(),
      theme: ThemeData.dark(),
      darkTheme: ThemeData.dark(),
      themeMode: ThemeMode.dark,
      home: const StandbyView(),
    );
  }
}