import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:travel_Mate/features/splashPage.dart';
import 'package:travel_Mate/theme/app_theme.dart';
//import 'package:travel_planer/splash/splashscreen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

  SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);
  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.light,
    ),
  );
  runApp(const TravelMateApp());
}

// ── InheritedWidget so child screens can call TravelMateApp.of(context) ──
class _TravelMateInherited extends InheritedWidget {
  final _TravelMateAppState state;
  const _TravelMateInherited({required this.state, required super.child});
  @override
  bool updateShouldNotify(_TravelMateInherited old) => true;
}

class TravelMateApp extends StatefulWidget {
  const TravelMateApp({super.key});

  /// Call this from any descendant widget to access theme toggle.
  static _TravelMateAppState? of(BuildContext context) {
    return context
        .dependOnInheritedWidgetOfExactType<_TravelMateInherited>()
        ?.state;
  }

  @override
  State<TravelMateApp> createState() => _TravelMateAppState();
}

class _TravelMateAppState extends State<TravelMateApp> {
  ThemeMode _mode = ThemeMode.system;

  void toggleTheme() => setState(
    () => _mode = _mode == ThemeMode.dark ? ThemeMode.light : ThemeMode.dark,
  );

  bool get isDark =>
      _mode == ThemeMode.dark ||
      (_mode == ThemeMode.system &&
          WidgetsBinding.instance.platformDispatcher.platformBrightness ==
              Brightness.dark);

  @override
  Widget build(BuildContext context) {
    return _TravelMateInherited(
      state: this,
      child: MaterialApp(
        title: 'TravelMate AI',
        debugShowCheckedModeBanner: false,
        theme: TravelMateTheme.light(),
        darkTheme: TravelMateTheme.dark(),
        themeMode: _mode,
        home: const SplashScreen(),
      ),
    );
  }
}
