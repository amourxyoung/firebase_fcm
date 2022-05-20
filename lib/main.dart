import 'dart:convert';
import 'dart:developer';
import 'package:awesome_notifications/awesome_notifications.dart';
import 'package:fcm_exercise/app.dart';
import 'package:fcm_exercise/controller/notification_controller.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();

  FirebaseMessaging.onBackgroundMessage(_firebasePushHandler);

  AwesomeNotifications().initialize(
      'resource://drawable/logo',
      [            // notification icon
        NotificationChannel(
          channelGroupKey: 'basic_test',
          channelKey: 'basic',
          channelName: 'Basic notifications',
          channelDescription: 'Notification channel for basic tests',
          channelShowBadge: true,
          importance: NotificationImportance.High,
          enableVibration: true,
        ),

      ]
  );

  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      initialBinding: BindingsBuilder(() {
        Get.put(NotificationController());
      }),
      home: App(),
    );
  }
}

void SubscribeTag(String name) async{
  await FirebaseMessaging.instance.subscribeToTopic(name).then((value)=>log('${name} subscribed!'));

  FirebaseMessaging.onMessage.listen((RemoteMessage message){
    AwesomeNotifications().createNotification(
        content: NotificationContent(
          id: 1,
          channelKey: 'basic',
          title: message.notification?.title,
          body: message.notification?.body,
        ),
    );
  });
}

Future<void> _firebasePushHandler(RemoteMessage message) async {
  log('Message from push noti is ${message.data}');
  AwesomeNotifications().createNotificationFromJsonData(message.data);
}
