import 'package:flutter/material.dart';
import 'ui/standby_view.dart';

void main() {
  runApp(const PALApp());
}

class PALApp extends StatelessWidget {
  const PALApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData.dark(),
      home: const StandbyView(),
    );
  }
}
