import 'package:common/cache/preference.dart';
import 'package:flutter/material.dart';
import 'router.dart';
import 'package:common/data/auth_repository.dart';
import 'package:common/data/colors_repository.dart';
import 'package:common/viewmodels/auth_view_model.dart';
import 'package:common/viewmodels/colors_view_model.dart';
import 'package:provider/provider.dart';
import 'package:flutter_web_plugins/url_strategy.dart';
import 'package:flutter/foundation.dart';

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
  late MyAppRouterDelegate delegate;
  late MyAppRouteInformationParser parser;
  late AuthRepository authRepository;
  late ColorsRepository colorsRepository;

  @override
  void initState() {
    super.initState();
    authRepository = AuthRepository(Preference());
    colorsRepository = ColorsRepository();
    delegate = MyAppRouterDelegate(authRepository, colorsRepository);
    parser = MyAppRouteInformationParser();
  }

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider<AuthViewModel>(
          create: (_) => AuthViewModel(authRepository),
        ),
        ChangeNotifierProvider<ColorsViewModel>(
          create: (_) => ColorsViewModel(colorsRepository),
        ),
      ],
      /// 非常重要，只有通过router构造函数创建，浏览器的地址栏才会变化
      child: MaterialApp.router(
            routerDelegate: delegate,
            routeInformationParser: parser,
            backButtonDispatcher: RootBackButtonDispatcher(),
          ),
    );
  }
}
