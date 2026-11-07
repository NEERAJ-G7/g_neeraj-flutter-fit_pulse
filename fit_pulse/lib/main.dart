import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'state.dart';
import 'theme.dart';
import 'auth_screen.dart';
import 'shell.dart';
import 'workouts_screen.dart';

void main() => runApp(
      ChangeNotifierProvider(create: (_) => AppState(), child: const FitPulseApp()),
    );

class FitPulseApp extends StatelessWidget {
  const FitPulseApp({super.key});

  @override
  Widget build(BuildContext context) {
    final s = context.watch<AppState>();
    return MaterialApp(
      title: 'Fit Pulse',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.build(Brightness.light),
      darkTheme: AppTheme.build(Brightness.dark),
      themeMode: s.themeMode,
      initialRoute: '/',
      onGenerateRoute: _route,
    );
  }
}

// Named routes with a custom fade + slide transition.
Route<dynamic> _route(RouteSettings st) {
  Widget page;
  switch (st.name) {
    case '/shell':
      page = const ShellScreen();
      break;
    case '/add':
      page = const AddWorkoutScreen();
      break;
    case '/detail':
      page = WorkoutDetailScreen(workout: st.arguments as Workout);
      break;
    default:
      page = const AuthScreen();
  }
  return PageRouteBuilder(
    settings: st,
    transitionDuration: const Duration(milliseconds: 350),
    pageBuilder: (_, __, ___) => page,
    transitionsBuilder: (_, a, __, child) => FadeTransition(
      opacity: a,
      child: SlideTransition(
        position: Tween<Offset>(begin: const Offset(0.05, 0), end: Offset.zero)
            .animate(CurvedAnimation(parent: a, curve: Curves.easeOut)),
        child: child,
      ),
    ),
  );
}
