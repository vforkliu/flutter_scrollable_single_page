import 'package:common/cache/preference.dart';
import 'package:flutter/material.dart';
import 'router.dart';
import 'package:common/data/auth_repository.dart';
import 'package:common/viewmodels/auth_view_model.dart';
import 'package:provider/provider.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  late MyAppRouterDelegate delegate;
  AuthRepository? authRepository;

  @override
  void initState() {
    super.initState();
    delegate = MyAppRouterDelegate(AuthRepository(Preference()));
    authRepository = AuthRepository(Preference());
  }

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider<AuthViewModel>(
      create: (_) => AuthViewModel(authRepository),
      child: MaterialApp(
          home: Router(
            routerDelegate: delegate,
            backButtonDispatcher: RootBackButtonDispatcher(),
          )),
    );
  }
}