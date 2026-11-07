import 'package:flutter/material.dart';

/// Page scaffold: app bar + content centred with a max width (desktop friendly).
class PageFrame extends StatelessWidget {
  final String title;
  final Widget child;
  final List<Widget>? actions;
  final Widget? fab;
  const PageFrame({super.key, required this.title, required this.child, this.actions, this.fab});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(title, style: const TextStyle(fontWeight: FontWeight.bold)),
        actions: actions,
      ),
      floatingActionButton: fab,
      body: Center(
        child: ConstrainedBox(constraints: const BoxConstraints(maxWidth: 1100), child: child),
      ),
    );
  }
}

/// Rounded card used everywhere for a consistent look.
class AppCard extends StatelessWidget {
  final Widget child;
  final EdgeInsets padding;
  final VoidCallback? onTap;
  const AppCard({super.key, required this.child, this.padding = const EdgeInsets.all(16), this.onTap});

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 1,
      clipBehavior: Clip.antiAlias,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      child: InkWell(onTap: onTap, child: Padding(padding: padding, child: child)),
    );
  }
}

class GradientButton extends StatelessWidget {
  final String label;
  final IconData? icon;
  final VoidCallback onPressed;
  const GradientButton({super.key, required this.label, required this.onPressed, this.icon});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Material(
      color: Colors.transparent,
      child: Ink(
        decoration: BoxDecoration(
          gradient: LinearGradient(colors: [cs.primary, const Color(0xFFFF9F1C)]),
          borderRadius: BorderRadius.circular(14),
        ),
        child: InkWell(
          borderRadius: BorderRadius.circular(14),
          onTap: onPressed,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 14),
            child: Row(mainAxisSize: MainAxisSize.min, children: [
              if (icon != null) ...[Icon(icon, color: Colors.white, size: 20), const SizedBox(width: 8)],
              Text(label, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
            ]),
          ),
        ),
      ),
    );
  }
}

/// Stat tile with a fade/scale-in animation.
class StatCard extends StatelessWidget {
  final IconData icon;
  final String label, value;
  final Color color;
  const StatCard({super.key, required this.icon, required this.label, required this.value, required this.color});

  @override
  Widget build(BuildContext context) {
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0, end: 1),
      duration: const Duration(milliseconds: 500),
      curve: Curves.easeOutBack,
      builder: (_, v, child) => Opacity(
        opacity: v.clamp(0.0, 1.0),
        child: Transform.scale(scale: 0.9 + 0.1 * v, child: child),
      ),
      child: AppCard(
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, mainAxisAlignment: MainAxisAlignment.center, children: [
          CircleAvatar(backgroundColor: color.withOpacity(0.15), child: Icon(icon, color: color)),
          const Spacer(),
          FittedBox(
            fit: BoxFit.scaleDown,
            child: Text(value, style: Theme.of(context).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold)),
          ),
          Text(label, style: Theme.of(context).textTheme.bodySmall),
        ]),
      ),
    );
  }
}

/// Animated circular progress ring drawn with CustomPaint.
class ProgressRing extends StatelessWidget {
  final double progress, size;
  final Color color;
  final Widget child;
  const ProgressRing({super.key, required this.progress, required this.size, required this.color, required this.child});

  @override
  Widget build(BuildContext context) {
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0, end: progress.clamp(0.0, 1.0)),
      duration: const Duration(milliseconds: 900),
      curve: Curves.easeOutCubic,
      builder: (_, v, __) => SizedBox(
        width: size,
        height: size,
        child: Stack(alignment: Alignment.center, children: [
          CustomPaint(
            size: Size.square(size),
            painter: _RingPainter(v, color, Theme.of(context).colorScheme.surfaceContainerHighest),
          ),
          child,
        ]),
      ),
    );
  }
}

class _RingPainter extends CustomPainter {
  final double p;
  final Color color, track;
  _RingPainter(this.p, this.color, this.track);

  @override
  void paint(Canvas canvas, Size s) {
    final rect = Rect.fromLTWH(8, 8, s.width - 16, s.height - 16);
    final paint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 14
      ..strokeCap = StrokeCap.round
      ..color = track;
    canvas.drawArc(rect, 0, 6.2832, false, paint);
    paint.color = color;
    canvas.drawArc(rect, -1.5708, 6.2832 * p, false, paint);
  }

  @override
  bool shouldRepaint(_RingPainter old) => old.p != p || old.color != color || old.track != track;
}

/// Weekly bar chart with animated bar heights.
class WeekBars extends StatelessWidget {
  final List<int> values;
  final List<String> labels;
  const WeekBars({super.key, required this.values, required this.labels});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final maxV = values.fold<int>(1, (a, b) => b > a ? b : a);
    return SizedBox(
      height: 190,
      child: Row(crossAxisAlignment: CrossAxisAlignment.end, children: [
        for (int i = 0; i < values.length; i++)
          Expanded(
            child: Column(mainAxisAlignment: MainAxisAlignment.end, children: [
              Text('${values[i]}', style: Theme.of(context).textTheme.labelSmall),
              const SizedBox(height: 4),
              TweenAnimationBuilder<double>(
                tween: Tween(begin: 0, end: values[i] / maxV * 130),
                duration: Duration(milliseconds: 500 + i * 80),
                curve: Curves.easeOut,
                builder: (_, h, __) => Container(
                  width: 22,
                  height: h < 4 ? 4 : h,
                  decoration: BoxDecoration(
                    color: i == values.length - 1 ? cs.primary : cs.primary.withOpacity(0.35),
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
              ),
              const SizedBox(height: 6),
              Text(labels[i], style: Theme.of(context).textTheme.labelSmall),
            ]),
          ),
      ]),
    );
  }
}
