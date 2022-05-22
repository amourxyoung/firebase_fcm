import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'second_view.dart';
import 'main.dart';
import 'controller/subscribe_controller.dart';

class App extends StatelessWidget {
  SubscibeController subscibeController = Get.put(SubscibeController());
  App({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Firebase cloud message'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            ElevatedButton(
                onPressed: () => subscibeController.subscribeTag('scholarship'),
                child: Text('장학금 구독')),
            ElevatedButton(
                onPressed: () => subscibeController.subscribeTag('internship'),
                child: Text('계절학기 구독')),
          ],
        ),
      ),
    );
  }
}
