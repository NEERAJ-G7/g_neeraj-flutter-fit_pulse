import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'state.dart';
import 'widgets.dart';

class AuthScreen extends StatefulWidget {
  const AuthScreen({super.key});
  @override
  State<AuthScreen> createState() => _AuthScreenState();
}

class _AuthScreenState extends State<AuthScreen> {
  final _form = GlobalKey<FormState>();
  final _name = TextEditingController();
  final _email = TextEditingController();
  final _pass = TextEditingController();
  bool _isLogin = true, _hide = true;

  @override
  void dispose() {
    _name.dispose();
    _email.dispose();
    _pass.dispose();
    super.dispose();
  }

  void _submit() {
    if (!_form.currentState!.validate()) return;
    context.read<AppState>().login(_name.text, _email.text.trim());
    Navigator.pushReplacementNamed(context, '/shell');
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Scaffold(
      body: LayoutBuilder(builder: (ctx, c) {
        final wide = c.maxWidth >= 800;
        final brand = Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [cs.primary, const Color(0xFFFF9F1C)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
          child: const Center(
            child: Column(mainAxisSize: MainAxisSize.min, children: [
              Icon(Icons.monitor_heart, size: 96, color: Colors.white),
              SizedBox(height: 12),
              Text('Fit Pulse', style: TextStyle(fontSize: 38, fontWeight: FontWeight.bold, color: Colors.white)),
              SizedBox(height: 6),
              Text('Track. Train. Transform.', style: TextStyle(color: Colors.white70, fontSize: 16)),
            ]),
          ),
        );

        final form = Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 420),
              child: Form(
                key: _form,
                child: Column(mainAxisSize: MainAxisSize.min, crossAxisAlignment: CrossAxisAlignment.stretch, children: [
                  if (!wide) ...[
                    Icon(Icons.monitor_heart, size: 64, color: cs.primary),
                    const SizedBox(height: 8),
                  ],
                  Text(_isLogin ? 'Welcome back' : 'Create account',
                      textAlign: TextAlign.center,
                      style: Theme.of(context).textTheme.headlineMedium?.copyWith(fontWeight: FontWeight.bold)),
                  const SizedBox(height: 24),
                  AnimatedSize(
                    duration: const Duration(milliseconds: 300),
                    child: _isLogin
                        ? const SizedBox(width: double.infinity)
                        : Padding(
                            padding: const EdgeInsets.only(bottom: 14),
                            child: TextFormField(
                              controller: _name,
                              decoration: const InputDecoration(labelText: 'Full name', prefixIcon: Icon(Icons.person)),
                              validator: (v) => (v == null || v.trim().length < 2) ? 'Enter your name' : null,
                            ),
                          ),
                  ),
                  TextFormField(
                    controller: _email,
                    keyboardType: TextInputType.emailAddress,
                    decoration: const InputDecoration(labelText: 'Email', prefixIcon: Icon(Icons.email)),
                    validator: (v) {
                      if (v == null || v.trim().isEmpty) return 'Email is required';
                      if (!RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]+$').hasMatch(v.trim())) return 'Enter a valid email';
                      return null;
                    },
                  ),
                  const SizedBox(height: 14),
                  TextFormField(
                    controller: _pass,
                    obscureText: _hide,
                    decoration: InputDecoration(
                      labelText: 'Password',
                      prefixIcon: const Icon(Icons.lock),
                      suffixIcon: IconButton(
                        icon: Icon(_hide ? Icons.visibility : Icons.visibility_off),
                        onPressed: () => setState(() => _hide = !_hide),
                      ),
                    ),
                    validator: (v) => (v == null || v.length < 6) ? 'At least 6 characters' : null,
                  ),
                  const SizedBox(height: 24),
                  Center(child: GradientButton(label: _isLogin ? 'Log in' : 'Sign up', onPressed: _submit)),
                  TextButton(
                    onPressed: () => setState(() => _isLogin = !_isLogin),
                    child: Text(_isLogin ? "New here? Create an account" : 'Have an account? Log in'),
                  ),
                ]),
              ),
            ),
          ),
        );

        return wide ? Row(children: [Expanded(child: brand), Expanded(child: form)]) : form;
      }),
    );
  }
}
