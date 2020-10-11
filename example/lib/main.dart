import 'dart:async';

import 'package:flutter/material.dart';
import 'package:mainstream_extended/mainstream_extended.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Home(),
    );
  }
}

final myStream = Stream<int>.periodic(Duration(seconds: 3), (x) {
  if (x == 2) throw Exception('Oops!');
  return (x == 3) ? null : x;
}).take(5);

class Home extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: MainStream<int>(
          stream: myStream,
          dataBuilder: (_, data) => Text(data.toString()),
        ),
      ),
    );
  }
}
