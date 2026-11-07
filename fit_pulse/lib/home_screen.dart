import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'state.dart';
import 'widgets.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final s = context.watch<AppState>();
    final cs = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;

    return PageFrame(
      title: 'Hi, ${s.userName} 👋',
      child: LayoutBuilder(builder: (ctx, c) {
        final cols = c.maxWidth >= 900 ? 4 : (c.maxWidth >= 600 ? 3 : 2);
        final pending = s.workouts.where((w) => !w.done && s.isToday(w.date)).toList();

        return ListView(padding: const EdgeInsets.all(16), children: [
          // Step ring
          AppCard(
            padding: const EdgeInsets.all(20),
            child: Wrap(
              alignment: WrapAlignment.center,
              crossAxisAlignment: WrapCrossAlignment.center,
              spacing: 28,
              runSpacing: 16,
              children: [
                ProgressRing(
                  progress: s.stepProgress,
                  size: 170,
                  color: cs.primary,
                  child: Column(mainAxisSize: MainAxisSize.min, children: [
                    Text('${s.steps}', style: tt.headlineMedium?.copyWith(fontWeight: FontWeight.bold)),
                    Text('of ${s.stepGoal} steps', style: tt.bodySmall),
                  ]),
                ),
                Column(crossAxisAlignment: CrossAxisAlignment.start, mainAxisSize: MainAxisSize.min, children: [
                  Text('Daily step goal', style: tt.titleLarge?.copyWith(fontWeight: FontWeight.bold)),
                  Text('${(s.stepProgress * 100).round()}% complete'),
                  const SizedBox(height: 14),
                  GradientButton(label: '+500 steps', icon: Icons.add, onPressed: () => s.addSteps(500)),
                  TextButton.icon(onPressed: s.resetSteps, icon: const Icon(Icons.refresh), label: const Text('Reset')),
                ]),
              ],
            ),
          ),
          const SizedBox(height: 16),

          // Responsive stat grid
          GridView.count(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            crossAxisCount: cols,
            childAspectRatio: 1.4,
            crossAxisSpacing: 12,
            mainAxisSpacing: 12,
            children: [
              StatCard(icon: Icons.local_fire_department, label: 'Calories today', value: '${s.todayCalories}', color: const Color(0xFFFF9F1C)),
              StatCard(icon: Icons.timer, label: 'Active minutes', value: '${s.todayMinutes}', color: const Color(0xFF4361EE)),
              StatCard(icon: Icons.check_circle, label: 'Workouts done', value: '${s.doneCount}', color: const Color(0xFF2EC4B6)),
              StatCard(icon: Icons.monitor_weight, label: 'BMI', value: s.bmi.toStringAsFixed(1), color: cs.primary),
            ],
          ),
          const SizedBox(height: 16),

          // Water tracker
          AppCard(
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text('Water  •  ${s.water}/8 glasses', style: tt.titleMedium?.copyWith(fontWeight: FontWeight.bold)),
              const SizedBox(height: 12),
              Wrap(spacing: 10, runSpacing: 10, children: [
                for (int i = 0; i < 8; i++)
                  GestureDetector(
                    onTap: () => s.setWater(s.water == i + 1 ? i : i + 1),
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 250),
                      width: 44,
                      height: 52,
                      decoration: BoxDecoration(
                        color: i < s.water ? const Color(0xFF4CC9F0) : cs.surfaceContainerHighest,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Icon(Icons.water_drop, color: i < s.water ? Colors.white : Colors.grey),
                    ),
                  ),
              ]),
            ]),
          ),
          const SizedBox(height: 16),

          // Today's pending workouts
          Text("Today's plan", style: tt.titleMedium?.copyWith(fontWeight: FontWeight.bold)),
          const SizedBox(height: 8),
          if (pending.isEmpty)
            const AppCard(child: Text('All done for today. Great job! 🎉'))
          else
            for (final w in pending)
              Card(
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                child: ListTile(
                  leading: Hero(
                    tag: 'w-home-${w.id}',
                    child: CircleAvatar(backgroundColor: colorFor(w.type).withOpacity(0.15), child: Icon(iconFor(w.type), color: colorFor(w.type))),
                  ),
                  title: Text(w.name),
                  subtitle: Text('${w.minutes} min • ${w.calories} kcal'),
                  trailing: IconButton(icon: const Icon(Icons.check_circle_outline), onPressed: () => s.toggleDone(w)),
                  onTap: () => Navigator.pushNamed(context, '/detail', arguments: w),
                ),
              ),
        ]);
      }),
    );
  }
}
