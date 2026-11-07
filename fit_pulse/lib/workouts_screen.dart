import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'state.dart';
import 'widgets.dart';

class WorkoutsScreen extends StatefulWidget {
  const WorkoutsScreen({super.key});
  @override
  State<WorkoutsScreen> createState() => _WorkoutsScreenState();
}

class _WorkoutsScreenState extends State<WorkoutsScreen> {
  String _filter = 'All';

  @override
  Widget build(BuildContext context) {
    final s = context.watch<AppState>();
    final list = s.workouts.where((w) => _filter == 'All' || w.type == _filter).toList();

    return PageFrame(
      title: 'Workouts',
      fab: FloatingActionButton.extended(
        onPressed: () => Navigator.pushNamed(context, '/add'),
        icon: const Icon(Icons.add),
        label: const Text('Add'),
      ),
      child: Column(children: [
        SizedBox(
          height: 56,
          child: ListView(scrollDirection: Axis.horizontal, padding: const EdgeInsets.symmetric(horizontal: 12), children: [
            for (final t in ['All', ...workoutTypes])
              Padding(
                padding: const EdgeInsets.all(6),
                child: ChoiceChip(label: Text(t), selected: _filter == t, onSelected: (_) => setState(() => _filter = t)),
              ),
          ]),
        ),
        Expanded(
          child: list.isEmpty
              ? const Center(child: Text('No workouts yet. Tap Add to create one.'))
              : ListView.builder(
                  padding: const EdgeInsets.fromLTRB(16, 4, 16, 90),
                  itemCount: list.length,
                  itemBuilder: (_, i) {
                    final w = list[i];
                    return Dismissible(
                      key: ValueKey(w.id),
                      direction: DismissDirection.endToStart,
                      background: Container(
                        alignment: Alignment.centerRight,
                        padding: const EdgeInsets.only(right: 20),
                        margin: const EdgeInsets.symmetric(vertical: 4),
                        decoration: BoxDecoration(color: Colors.red, borderRadius: BorderRadius.circular(16)),
                        child: const Icon(Icons.delete, color: Colors.white),
                      ),
                      onDismissed: (_) => s.removeWorkout(w),
                      child: Card(
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                        child: ListTile(
                          leading: Hero(
                            tag: 'w-${w.id}',
                            child: CircleAvatar(backgroundColor: colorFor(w.type).withOpacity(0.15), child: Icon(iconFor(w.type), color: colorFor(w.type))),
                          ),
                          title: Text(w.name, style: TextStyle(decoration: w.done ? TextDecoration.lineThrough : null)),
                          subtitle: Text('${w.type} • ${w.minutes} min • ${w.calories} kcal\n${w.date.day}/${w.date.month}/${w.date.year}'),
                          isThreeLine: true,
                          trailing: Checkbox(value: w.done, onChanged: (_) => s.toggleDone(w)),
                          onTap: () => Navigator.pushNamed(context, '/detail', arguments: w),
                        ),
                      ),
                    );
                  },
                ),
        ),
      ]),
    );
  }
}

/// Form screen with validation.
class AddWorkoutScreen extends StatefulWidget {
  const AddWorkoutScreen({super.key});
  @override
  State<AddWorkoutScreen> createState() => _AddWorkoutScreenState();
}

class _AddWorkoutScreenState extends State<AddWorkoutScreen> {
  final _form = GlobalKey<FormState>();
  final _name = TextEditingController();
  final _min = TextEditingController();
  final _cal = TextEditingController();
  String _type = workoutTypes.first;
  DateTime _date = DateTime.now();

  @override
  void dispose() {
    _name.dispose();
    _min.dispose();
    _cal.dispose();
    super.dispose();
  }

  Future<void> _pickDate() async {
    final d = await showDatePicker(
      context: context,
      initialDate: _date,
      firstDate: DateTime.now().subtract(const Duration(days: 365)),
      lastDate: DateTime.now().add(const Duration(days: 365)),
    );
    if (d != null) setState(() => _date = d);
  }

  void _save() {
    if (!_form.currentState!.validate()) return;
    context.read<AppState>().addWorkout(Workout(
          id: DateTime.now().microsecondsSinceEpoch.toString(),
          name: _name.text.trim(),
          type: _type,
          minutes: int.parse(_min.text),
          calories: int.parse(_cal.text),
          date: DateTime(_date.year, _date.month, _date.day),
        ));
    Navigator.pop(context);
    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Workout added')));
  }

  String? _intRule(String? v, int max) {
    final n = int.tryParse(v ?? '');
    if (n == null) return 'Enter a whole number';
    if (n < 1 || n > max) return 'Between 1 and $max';
    return null;
  }

  @override
  Widget build(BuildContext context) {
    return PageFrame(
      title: 'New workout',
      child: Align(
        alignment: Alignment.topCenter,
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 520),
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(20),
            child: Form(
              key: _form,
              child: Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
                TextFormField(
                  controller: _name,
                  decoration: const InputDecoration(labelText: 'Workout name', prefixIcon: Icon(Icons.edit)),
                  validator: (v) => (v == null || v.trim().length < 3) ? 'At least 3 characters' : null,
                ),
                const SizedBox(height: 14),
                DropdownButtonFormField<String>(
                  value: _type,
                  decoration: const InputDecoration(labelText: 'Type', prefixIcon: Icon(Icons.category)),
                  items: [for (final t in workoutTypes) DropdownMenuItem(value: t, child: Text(t))],
                  onChanged: (v) => setState(() => _type = v!),
                ),
                const SizedBox(height: 14),
                TextFormField(
                  controller: _min,
                  keyboardType: TextInputType.number,
                  decoration: const InputDecoration(labelText: 'Duration (minutes)', prefixIcon: Icon(Icons.timer)),
                  validator: (v) => _intRule(v, 300),
                ),
                const SizedBox(height: 14),
                TextFormField(
                  controller: _cal,
                  keyboardType: TextInputType.number,
                  decoration: const InputDecoration(labelText: 'Calories (kcal)', prefixIcon: Icon(Icons.local_fire_department)),
                  validator: (v) => _intRule(v, 3000),
                ),
                const SizedBox(height: 14),
                ListTile(
                  shape: RoundedRectangleBorder(side: BorderSide(color: Theme.of(context).dividerColor), borderRadius: BorderRadius.circular(14)),
                  leading: const Icon(Icons.calendar_today),
                  title: Text('${_date.day}/${_date.month}/${_date.year}'),
                  trailing: const Icon(Icons.arrow_drop_down),
                  onTap: _pickDate,
                ),
                const SizedBox(height: 24),
                Center(child: GradientButton(label: 'Save workout', icon: Icons.check, onPressed: _save)),
              ]),
            ),
          ),
        ),
      ),
    );
  }
}

class WorkoutDetailScreen extends StatelessWidget {
  final Workout workout;
  const WorkoutDetailScreen({super.key, required this.workout});

  @override
  Widget build(BuildContext context) {
    final s = context.watch<AppState>();
    final w = workout;
    final c = colorFor(w.type);
    final tt = Theme.of(context).textTheme;

    return PageFrame(
      title: w.name,
      actions: [
        IconButton(
          icon: const Icon(Icons.delete_outline),
          onPressed: () {
            s.removeWorkout(w);
            Navigator.pop(context);
          },
        ),
      ],
      child: Align(
        alignment: Alignment.topCenter,
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 520),
          child: ListView(padding: const EdgeInsets.all(24), children: [
            Center(
              child: Hero(
                tag: 'w-${w.id}',
                child: CircleAvatar(radius: 56, backgroundColor: c.withOpacity(0.15), child: Icon(iconFor(w.type), size: 56, color: c)),
              ),
            ),
            const SizedBox(height: 16),
            Center(child: Text(w.type, style: tt.titleLarge?.copyWith(color: c, fontWeight: FontWeight.bold))),
            const SizedBox(height: 24),
            Row(children: [
              Expanded(child: StatCardSimple(label: 'Minutes', value: '${w.minutes}', icon: Icons.timer)),
              const SizedBox(width: 12),
              Expanded(child: StatCardSimple(label: 'Calories', value: '${w.calories}', icon: Icons.local_fire_department)),
            ]),
            const SizedBox(height: 12),
            AppCard(child: Row(children: [
              const Icon(Icons.calendar_today),
              const SizedBox(width: 12),
              Text('${w.date.day}/${w.date.month}/${w.date.year}'),
              const Spacer(),
              AnimatedSwitcher(
                duration: const Duration(milliseconds: 250),
                child: Chip(
                  key: ValueKey(w.done),
                  label: Text(w.done ? 'Completed' : 'Pending'),
                  backgroundColor: w.done ? Colors.green.withOpacity(0.2) : Colors.orange.withOpacity(0.2),
                ),
              ),
            ])),
            const SizedBox(height: 24),
            Center(
              child: GradientButton(
                label: w.done ? 'Mark as pending' : 'Mark as complete',
                icon: w.done ? Icons.undo : Icons.check,
                onPressed: () => s.toggleDone(w),
              ),
            ),
          ]),
        ),
      ),
    );
  }
}

class StatCardSimple extends StatelessWidget {
  final String label, value;
  final IconData icon;
  const StatCardSimple({super.key, required this.label, required this.value, required this.icon});

  @override
  Widget build(BuildContext context) {
    return AppCard(
      child: Column(children: [
        Icon(icon, color: Theme.of(context).colorScheme.primary),
        const SizedBox(height: 6),
        Text(value, style: Theme.of(context).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold)),
        Text(label),
      ]),
    );
  }
}
