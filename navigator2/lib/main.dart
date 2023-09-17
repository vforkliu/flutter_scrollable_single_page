import 'package:flutter/material.dart';
import 'router.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatefulWidget {
  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  final delegate = MyAppRouterDelegate();

  @override
  Widget build(BuildContext context) {
    return MaterialApp(home: Router(routerDelegate: delegate));
  }
}
