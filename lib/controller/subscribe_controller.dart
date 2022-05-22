import 'dart:developer';

import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:get/get.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class SubscibeController extends GetxController {
  static SubscibeController get to => Get.find();

  void subscribeTag(String name) async {
    await FirebaseMessaging.instance
        .subscribeToTopic(name)
        .then((value) => log('$name subscribed!'));

    FirebaseFirestore.instance.collection(name).add({
      "id": "2",
    });
  }

  void UnsubscribeTag(String name) async {
    await FirebaseMessaging.instance
        .unsubscribeFromTopic(name)
        .then((value) => log('$name unsubscribed!'));
  }
}
