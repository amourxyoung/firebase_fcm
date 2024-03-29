import 'dart:convert';
import 'dart:developer';
import 'package:fcm_exercise/app.dart';
import 'package:fcm_exercise/controller/notification_controller.dart';
import 'package:fcm_exercise/second_view.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:get/get.dart';

///앱이 [background상태]일때 수신되는 message를 처리하는 부분이다.
Future<dynamic> onBackgroundHandler(RemoteMessage message) async {
  await Firebase.initializeApp();
  log("onBackgroundMessage: ${message.data}");
  log('Handling a background message ${message.notification!.body}');
}

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();

  ///[background상태]에서 푸쉬 알람 출력
  FirebaseMessaging.onBackgroundMessage(onBackgroundHandler);
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

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
        getPages: [
          GetPage(name: '/SencondView', page: () => const SecondView()),
        ]);
  }
}
