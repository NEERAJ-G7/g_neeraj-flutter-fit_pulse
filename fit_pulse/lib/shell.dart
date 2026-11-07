import 'package:flutter/material.dart';
import 'home_screen.dart';
import 'workouts_screen.dart';
import 'progress_screen.dart';
import 'profile_screen.dart';

/// Responsive navigation: BottomNavigationBar (mobile), NavigationRail (tablet),
/// extended NavigationRail (desktop).
class ShellScreen extends StatefulWidget {
  const ShellScreen({super.key});
  @override
  State<ShellScreen> createState() => _ShellScreenState();
}

class _ShellScreenState extends State<ShellScreen> {
  int _i = 0;
  static const _pages = <Widget>[HomeScreen(), WorkoutsScreen(), ProgressScreen(), ProfileScreen()];
  static const _items = [
    (Icons.dashboard_outlined, Icons.dashboard, 'Home'),
    (Icons.fitness_center_outlined, Icons.fitness_center, 'Workouts'),
    (Icons.bar_chart_outlined, Icons.bar_chart, 'Progress'),
    (Icons.person_outline, Icons.person, 'Profile'),
  ];

  @override
  Widget build(BuildContext context) {
    final w = MediaQuery.of(context).size.width;
    final body = AnimatedSwitcher(
      duration: const Duration(milliseconds: 300),
      child: KeyedSubtree(key: ValueKey(_i), child: _pages[_i]),
    );

    if (w >= 600) {
      return Scaffold(
        body: Row(children: [
          NavigationRail(
            extended: w >= 900,
            selectedIndex: _i,
            onDestinationSelected: (v) => setState(() => _i = v),
            leading: Padding(
              padding: const EdgeInsets.symmetric(vertical: 16),
              child: Icon(Icons.monitor_heart, size: 36, color: Theme.of(context).colorScheme.primary),
            ),
            destinations: [
              for (final it in _items)
                NavigationRailDestination(icon: Icon(it.$1), selectedIcon: Icon(it.$2), label: Text(it.$3)),
            ],
          ),
          const VerticalDivider(width: 1),
          Expanded(child: body),
        ]),
      );
    }
    return Scaffold(
      body: body,
      bottomNavigationBar: NavigationBar(
        selectedIndex: _i,
        onDestinationSelected: (v) => setState(() => _i = v),
        destinations: [
          for (final it in _items)
            NavigationDestination(icon: Icon(it.$1), selectedIcon: Icon(it.$2), label: it.$3),
        ],
      ),
    );
  }
}
