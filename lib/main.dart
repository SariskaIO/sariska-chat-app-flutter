import 'package:flutter/material.dart';
import 'package:sariska_chat_app_flutter/pages/landing_page.dart';

import 'components/app_colors.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: AppColors.colorPrimary,
        ),
      ),
      home: const LandingPage(),
    );
  }
}
