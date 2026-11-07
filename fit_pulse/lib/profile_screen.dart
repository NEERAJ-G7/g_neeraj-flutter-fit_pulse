import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'state.dart';
import 'widgets.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});
  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final _form = GlobalKey<FormState>();
  late final TextEditingController _name, _weight, _height, _goal;

  @override
  void initState() {
    super.initState();
    final s = context.read<AppState>();
    _name = TextEditingController(text: s.userName);
    _weight = TextEditingController(text: s.weightKg.toString());
    _height = TextEditingController(text: s.heightCm.toString());
    _goal = TextEditingController(text: s.stepGoal.toString());
  }

  @override
  void dispose() {
    _name.dispose();
    _weight.dispose();
    _height.dispose();
    _goal.dispose();
    super.dispose();
  }

  String? _num(String? v, double min, double max) {
    final n = double.tryParse(v ?? '');
    if (n == null) return 'Enter a number';
    if (n < min || n > max) return 'Between ${min.toInt()} and ${max.toInt()}';
    return null;
  }

  void _save() {
    if (!_form.currentState!.validate()) return;
    context.read<AppState>().updateProfile(
          name: _name.text.trim(),
          weight: double.parse(_weight.text),
          height: double.parse(_height.text),
          goal: double.parse(_goal.text).round(),
        );
    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Profile updated')));
  }

  @override
  Widget build(BuildContext context) {
    final s = context.watch<AppState>();
    return PageFrame(
      title: 'Profile',
      child: Align(
        alignment: Alignment.topCenter,
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 520),
          child: ListView(padding: const EdgeInsets.all(20), children: [
            Center(
              child: CircleAvatar(
                radius: 44,
                backgroundColor: Theme.of(context).colorScheme.primary,
                child: Text(s.userName.isEmpty ? '?' : s.userName[0].toUpperCase(),
                    style: const TextStyle(fontSize: 36, color: Colors.white, fontWeight: FontWeight.bold)),
              ),
            ),
            if (s.email.isNotEmpty) Center(child: Padding(padding: const EdgeInsets.only(top: 8), child: Text(s.email))),
            const SizedBox(height: 20),
            Form(
              key: _form,
              child: Column(children: [
                TextFormField(
                  controller: _name,
                  decoration: const InputDecoration(labelText: 'Name', prefixIcon: Icon(Icons.person)),
                  validator: (v) => (v == null || v.trim().length < 2) ? 'Enter your name' : null,
                ),
                const SizedBox(height: 14),
                TextFormField(
                  controller: _weight,
                  keyboardType: TextInputType.number,
                  decoration: const InputDecoration(labelText: 'Weight (kg)', prefixIcon: Icon(Icons.monitor_weight)),
                  validator: (v) => _num(v, 20, 300),
                ),
                const SizedBox(height: 14),
                TextFormField(
                  controller: _height,
                  keyboardType: TextInputType.number,
                  decoration: const InputDecoration(labelText: 'Height (cm)', prefixIcon: Icon(Icons.height)),
                  validator: (v) => _num(v, 100, 250),
                ),
                const SizedBox(height: 14),
                TextFormField(
                  controller: _goal,
                  keyboardType: TextInputType.number,
                  decoration: const InputDecoration(labelText: 'Daily step goal', prefixIcon: Icon(Icons.flag)),
                  validator: (v) => _num(v, 1000, 50000),
                ),
                const SizedBox(height: 18),
                GradientButton(label: 'Save changes', icon: Icons.save, onPressed: _save),
              ]),
            ),
            const SizedBox(height: 12),
            SwitchListTile(
              title: const Text('Dark mode'),
              secondary: const Icon(Icons.dark_mode),
              value: s.themeMode == ThemeMode.dark,
              onChanged: (_) => s.toggleTheme(),
            ),
            ListTile(
              leading: const Icon(Icons.logout),
              title: const Text('Log out'),
              onTap: () {
                s.logout();
                Navigator.pushNamedAndRemoveUntil(context, '/', (_) => false);
              },
            ),
          ]),
        ),
      ),
    );
  }
}
