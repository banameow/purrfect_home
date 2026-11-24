import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'app.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  // Portrait only: the room is designed for a portrait phone screen.
  await SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);
  runApp(const PurrfectHomeApp());
}
