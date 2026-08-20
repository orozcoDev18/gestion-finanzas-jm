import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'app.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  await initializeDateFormatting('es');

  SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);

  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.dark,
    ),
  );

  FlutterError.onError = (FlutterErrorDetails details) {
    FlutterError.presentError(details);
  };

  ErrorWidget.builder = (FlutterErrorDetails details) {
    return Material(
      color: Colors.red.shade50,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.error_outline, color: Colors.red, size: 40),
            const SizedBox(height: 8),
            Text(
              'Error de renderización',
              style: TextStyle(fontWeight: FontWeight.bold, color: Colors.red.shade700, fontSize: 16),
            ),
            const SizedBox(height: 8),
            Text(
              '${details.exception}',
              style: TextStyle(color: Colors.red.shade900, fontSize: 12),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(
              '${details.stack}',
              style: TextStyle(color: Colors.grey.shade700, fontSize: 10),
              textAlign: TextAlign.left,
              maxLines: 10,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
    );
  };

  runZonedGuarded(() {
    runApp(const MyApp());
  }, (error, stack) {
    debugPrint('Error no capturado: $error');
    debugPrint('$stack');
  });
}
