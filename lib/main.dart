import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:eventify/config/theme/app_theme.dart';
import 'package:eventify/config/theme/router/app_router.dart';
import 'package:eventify/presentacion/services/notificacion_services.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:firebase_core/firebase_core.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  Platform.isAndroid
      ? await Firebase.initializeApp(
          options: const FirebaseOptions(
          apiKey: 'AIzaSyA0j_toLFCavNPuxbzb38FWlYF-BE2uqCY',
          appId: '1:792265517367:android:a1cb47ccf65fa29b9152b2',
          messagingSenderId: '792265517367',
          projectId: 'eventify-b6cd1',
        ))
      : await Firebase.initializeApp();

  FirebaseFirestore.instance.settings = const Settings(
    persistenceEnabled: false,
  );

  final notificationService = NotificationService();
  await notificationService.setupFirebaseMessaging();

  runApp(const ProviderScope(child: MyApp()));
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      debugShowCheckedModeBanner: false,
      title: 'Eventify',
      routerConfig: appRouter,
      theme: AppTheme().getTheme(),
    );
  }
}
