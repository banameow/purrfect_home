import 'package:flutter/material.dart';

import 'core/constants/game_constants.dart';
import 'features/game/game_screen.dart';

class PurrfectHomeApp extends StatelessWidget {
  const PurrfectHomeApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Purrfect Home',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: GameColors.accent),
        useMaterial3: true,
      ),
      home: const GameScreen(),
    );
  }
}
