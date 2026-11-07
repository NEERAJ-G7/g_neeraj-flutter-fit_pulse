import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'state.dart';
import 'widgets.dart';

class ProgressScreen extends StatelessWidget {
  const ProgressScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final s = context.watch<AppState>();
    final tt = Theme.of(context).textTheme;
    final bmiPos = ((s.bmi.clamp(15.0, 35.0) - 15) / 20).toDouble();

    return PageFrame(
      title: 'Progress',
      child: LayoutBuilder(builder: (ctx, c) {
        final chart = AppCard(
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text('Active minutes – last 7 days', style: tt.titleMedium?.copyWith(fontWeight: FontWeight.bold)),
            const SizedBox(height: 16),
            WeekBars(values: s.weeklyMinutes, labels: s.weekLabels),
          ]),
        );
        final summary = Column(children: [
          StatCard(icon: Icons.timer, label: 'Total minutes', value: '${s.totalMinutes}', color: const Color(0xFF4361EE)),
          const SizedBox(height: 12),
          StatCard(icon: Icons.local_fire_department, label: 'Total calories', value: '${s.totalCalories}', color: const Color(0xFFFF9F1C)),
        ].map((e) => SizedBox(height: 110, child: e)).toList());
        final bmi = AppCard(
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text('Body Mass Index', style: tt.titleMedium?.copyWith(fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            Text('${s.bmi.toStringAsFixed(1)}  •  ${s.bmiCategory}', style: tt.headlineSmall),
            const SizedBox(height: 12),
            TweenAnimationBuilder<double>(
              tween: Tween(begin: 0, end: bmiPos),
              duration: const Duration(milliseconds: 700),
              builder: (_, v, __) => LinearProgressIndicator(value: v, minHeight: 10, borderRadius: BorderRadius.circular(8)),
            ),
            const SizedBox(height: 6),
            const Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [Text('15'), Text('25'), Text('35')]),
          ]),
        );

        return ListView(padding: const EdgeInsets.all(16), children: [
          if (c.maxWidth >= 800)
            Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Expanded(flex: 2, child: chart),
              const SizedBox(width: 12),
              Expanded(child: summary),
            ])
          else ...[
            chart,
            const SizedBox(height: 12),
            summary,
          ],
          const SizedBox(height: 12),
          bmi,
        ]);
      }),
    );
  }
}
