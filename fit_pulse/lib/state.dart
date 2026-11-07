import 'package:flutter/material.dart';

const workoutTypes = ['Cardio', 'Strength', 'Yoga', 'HIIT'];

IconData iconFor(String t) {
  switch (t) {
    case 'Cardio':
      return Icons.directions_run;
    case 'Strength':
      return Icons.fitness_center;
    case 'Yoga':
      return Icons.self_improvement;
    default:
      return Icons.local_fire_department;
  }
}

Color colorFor(String t) {
  switch (t) {
    case 'Cardio':
      return const Color(0xFF4361EE);
    case 'Strength':
      return const Color(0xFFFF4D6D);
    case 'Yoga':
      return const Color(0xFF2EC4B6);
    default:
      return const Color(0xFFFF9F1C);
  }
}

class Workout {
  final String id, name, type;
  final int minutes, calories;
  final DateTime date;
  bool done;
  Workout({
    required this.id,
    required this.name,
    required this.type,
    required this.minutes,
    required this.calories,
    required this.date,
    this.done = false,
  });
}

class AppState extends ChangeNotifier {
  bool loggedIn = false;
  String userName = 'Athlete';
  String email = '';
  double weightKg = 70, heightCm = 170;
  int stepGoal = 10000, steps = 4200, water = 3;
  ThemeMode themeMode = ThemeMode.light;
  final List<Workout> workouts = [];

  AppState() {
    DateTime d(int ago) {
      final n = DateTime.now();
      return DateTime(n.year, n.month, n.day).subtract(Duration(days: ago));
    }

    workouts.addAll([
      Workout(id: '1', name: 'Morning Run', type: 'Cardio', minutes: 30, calories: 280, date: d(0)),
      Workout(id: '2', name: 'Upper Body Strength', type: 'Strength', minutes: 45, calories: 320, date: d(0)),
      Workout(id: '3', name: 'Sunrise Yoga', type: 'Yoga', minutes: 25, calories: 110, date: d(1), done: true),
      Workout(id: '4', name: 'HIIT Blast', type: 'HIIT', minutes: 20, calories: 250, date: d(2), done: true),
      Workout(id: '5', name: 'Evening Jog', type: 'Cardio', minutes: 40, calories: 350, date: d(3), done: true),
      Workout(id: '6', name: 'Leg Day', type: 'Strength', minutes: 50, calories: 400, date: d(5), done: true),
    ]);
  }

  // ---------- derived values ----------
  bool isToday(DateTime x) {
    final n = DateTime.now();
    return x.year == n.year && x.month == n.month && x.day == n.day;
  }

  double get stepProgress => (steps / stepGoal).clamp(0.0, 1.0);
  int get doneCount => workouts.where((w) => w.done).length;
  int get totalMinutes => workouts.where((w) => w.done).fold(0, (a, w) => a + w.minutes);
  int get totalCalories => workouts.where((w) => w.done).fold(0, (a, w) => a + w.calories);

  int get todayMinutes =>
      workouts.where((w) => w.done && isToday(w.date)).fold(0, (a, w) => a + w.minutes);

  int get todayCalories =>
      workouts.where((w) => w.done && isToday(w.date)).fold(0, (a, w) => a + w.calories) +
      (steps * 0.04).round();

  double get bmi => weightKg / ((heightCm / 100) * (heightCm / 100));

  String get bmiCategory {
    if (bmi < 18.5) return 'Underweight';
    if (bmi < 25) return 'Healthy';
    if (bmi < 30) return 'Overweight';
    return 'Obese';
  }

  List<int> get weeklyMinutes {
    final n = DateTime.now();
    return List.generate(7, (i) {
      final day = DateTime(n.year, n.month, n.day).subtract(Duration(days: 6 - i));
      return workouts
          .where((w) => w.done && w.date.year == day.year && w.date.month == day.month && w.date.day == day.day)
          .fold(0, (a, w) => a + w.minutes);
    });
  }

  List<String> get weekLabels {
    const names = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
    final n = DateTime.now();
    return List.generate(7, (i) => names[n.subtract(Duration(days: 6 - i)).weekday - 1]);
  }

  // ---------- actions ----------
  void login(String name, String mail) {
    loggedIn = true;
    if (name.trim().isNotEmpty) userName = name.trim();
    email = mail;
    notifyListeners();
  }

  void logout() {
    loggedIn = false;
    notifyListeners();
  }

  void toggleDone(Workout w) {
    w.done = !w.done;
    notifyListeners();
  }

  void addWorkout(Workout w) {
    workouts.insert(0, w);
    notifyListeners();
  }

  void removeWorkout(Workout w) {
    workouts.remove(w);
    notifyListeners();
  }

  void addSteps(int n) {
    steps += n;
    notifyListeners();
  }

  void resetSteps() {
    steps = 0;
    notifyListeners();
  }

  void setWater(int n) {
    water = n;
    notifyListeners();
  }

  void updateProfile({required String name, required double weight, required double height, required int goal}) {
    userName = name;
    weightKg = weight;
    heightCm = height;
    stepGoal = goal;
    notifyListeners();
  }

  void toggleTheme() {
    themeMode = themeMode == ThemeMode.light ? ThemeMode.dark : ThemeMode.light;
    notifyListeners();
  }
}
