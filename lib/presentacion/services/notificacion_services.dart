import 'package:firebase_messaging/firebase_messaging.dart';

class NotificationService {
  final FirebaseMessaging _messaging = FirebaseMessaging.instance;

  Future<void> setupFirebaseMessaging() async {
    NotificationSettings settings = await _messaging.requestPermission(
      alert: true,
      badge: true,
      sound: true,
    );

    if (settings.authorizationStatus == AuthorizationStatus.authorized) {
      print('Permisos concedidos');
    } else {
      print('Permisos denegados');
    }

    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      print('*** Notificación recibida en primer plano ***');
      print('Título: ${message.notification?.title}');
      print('Cuerpo: ${message.notification?.body}');
      // Si hay datos (payload extra):
      print('Data: ${message.data}');
    });

    FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
      print('*** Notificación abierta (app en segundo plano o cerrada) ***');
      print('Título: ${message.notification?.title}');
      print('Cuerpo: ${message.notification?.body}');
      print('Data: ${message.data}');
    });

    FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
      print('Notificación tocada: ${message.notification?.title}');
      print('Cuerpo: ${message.notification?.body}');
    });

    String? token = await _messaging.getToken();
    print('Token FCM: $token');
  }
}
