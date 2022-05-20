import 'package:flutter/material.dart';

import 'main.dart';

class App extends StatelessWidget {
  const App({Key? key}) : super(key: key);

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
            ElevatedButton(onPressed: ()=> SubscribeTag('scholarship'), child: Text('장학금')),
            ElevatedButton(onPressed: ()=> SubscribeTag('internship'), child: Text('계절학기')),
          ],
        ),
      ),
    );
  }
}
