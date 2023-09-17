import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'router.dart';
import 'package:flutter_web_plugins/url_strategy.dart';
void main() {
  if(kIsWeb){
    usePathUrlStrategy();
  }
  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  late SinglePageAppRouterDelegate delegate;
  late SinglePageAppRouteInformationParser parser;
  final _colors = Colors.primaries.reversed.toList();

  @override
  void initState() {
    super.initState();
    delegate = SinglePageAppRouterDelegate(colors: _colors);
    parser = SinglePageAppRouteInformationParser(colors: _colors);
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      debugShowCheckedModeBanner: false,
      routerDelegate: delegate,
      routeInformationParser: parser,
    );
  }
}
