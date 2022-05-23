import 'dart:developer';

import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:get/get.dart';
import 'package:fcm_exercise/second_view.dart';

class NotificationController extends GetxController {
  ///어디서든 controller를 호출할 수 있도록 한다.
  static NotificationController get to => Get.find();
  final FirebaseMessaging _messaging = FirebaseMessaging.instance;
  //messaging initialized
  FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
      FlutterLocalNotificationsPlugin();

  ///Android에서 푸쉬알림을 보내기 위해서는 [notification channel]을 생성해야한다.
  ///
  ///여러개의 channel을 생성할 수 있지만, 동일한 channel id로 중복 생성할 경우
  ///아무 일도 일어나지 않으므로 앱이 실행될 때 딱 한 번만 생성하기를 권장한다.
  AndroidNotificationChannel channel = const AndroidNotificationChannel(
    'high_importance_channel', //channel id
    'High Importance Notifications', //channel name
    description: 'This channel is used for important notifications.',
    importance: Importance.max,
  );

  @override
  void onInit() {
    initialSetting();
    _getToken();
    super.onInit();
  }

  ///FCM을 사용하기 위한 기본 설정 함수다.
  ///본 함수는 권한 요청
  void initialSetting() async {
    ///푸쉬 메시지를 띄우기 위해서는 FirebaseMessaging의 requestPermission()을 요청해서 알림 권한을 요청한다.
    ///
    ///앱을 설치할 때 기본 상태는 `not determined`이지만 [settings]을 통해
    ///권한을 요청하면 `granted`상태가 된다.
    NotificationSettings persmission = await _messaging.requestPermission(
        alert: true,
        announcement: true,
        badge: true,
        carPlay: true,
        criticalAlert: true,
        provisional: true,
        sound: true);
    log('User granted permission::: ${persmission.authorizationStatus}');

    switch (persmission.authorizationStatus) {
      case AuthorizationStatus.authorized:
        await initiatedAndroid();
        updateChannel();

        ///[Terminated상태]에서 클릭한 푸시 알림 메세지 핸들링
        ///`.getInitialMessage()`을 통해 도착한 메시지가 있는지 확인하고 이동해준다.
        FirebaseMessaging.instance
            .getInitialMessage()
            .then((RemoteMessage? message) async {
          if (message != null) {
            Get.to(() => SecondView());
          }

          /// 앱이 [background상태]에서 클릭한 푸시 알림 메세지 핸들링
          FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
            log('background에서 알림 클릭');
            Get.to(() => SecondView());
          });
        });

        ///foreground에서 noti 출력
        FirebaseMessaging.onMessage.listen((RemoteMessage message) {
          RemoteNotification? notification = message.notification;
          AndroidNotification? android = message.notification?.android;
          if (notification != null && android != null) {
            flutterLocalNotificationsPlugin.show(
              notification.hashCode,
              notification.title,
              notification.body,
              NotificationDetails(
                android: AndroidNotificationDetails(
                  channel.id,
                  channel.name,
                  importance: Importance.max,
                  priority: Priority.max,
                  channelDescription: channel.description,
                  icon: android.smallIcon,
                ),
              ),
            );
            log("onForegroundMessage data: ${message.data}");
            log('foreground message id: ${message.messageId}');
          }
        });
        break;

      case AuthorizationStatus.denied:
        log('User granted permission is denied');
        break;

      default:
        log('User declined or has not accepted permission');
    }
  }

  Future<dynamic> initiatedAndroid() async {
    ///안드로이드 알림 아이콘과 함께 초기화해준다.
    ///안드로이드 설정를 위한 Notification을 설정해주고 아래 앱 아이콘으로 설정을 바꾼다.
    ///현재는 기본 아이콘으로 설정되어있다.
    const initSettingsAndroid =
        AndroidInitializationSettings('@mipmap/ic_launcher');

    ///안드로이드, IOS 각각의 플랫폼마다 위에 초기화한 것을 setting해줄 수 있다.
    const initSettings = InitializationSettings(
      android: initSettingsAndroid,
    );

    ///onSelectNotification의 경우 알림을 눌렀을때 어플에서 실행되는 행동을 설정하는 부분이다.
    ///onSelectNotification는 없어도 되는 부분이며 아무런 행동을 취하게 하고 싶지 않다면 비워도 된다.
    await flutterLocalNotificationsPlugin.initialize(initSettings,
        onSelectNotification: (payload) {
      if (payload != null) {
        Get.to(() => SecondView(), arguments: payload);
      }
    });
  }

  ///앞에서 생성한 channel을 device로 생성한다.
  Future<void> updateChannel() async {
    await flutterLocalNotificationsPlugin
        .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin>()
        ?.createNotificationChannel(channel);
  }

//token을 못받을수도 있기 때문에 try-catch문 사용
  Future<String> _getToken() async {
    try {
      String? token = await _messaging.getToken();
      log(token ?? 'null');
    } catch (e) {
      return e.toString();
    }
    return 'success';
  }
}
