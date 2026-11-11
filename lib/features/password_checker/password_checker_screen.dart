import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'password_checker_service.dart';

class PasswordCheckerScreen extends StatefulWidget {
  const PasswordCheckerScreen({super.key});

  @override
  State<PasswordCheckerScreen> createState() => _PasswordCheckerScreenState();
}

class _PasswordCheckerScreenState extends State<PasswordCheckerScreen> {
  final _controller = TextEditingController();
  PasswordCheckerResult? _result;
  bool _obscureText = true;

  void _onPasswordChanged(String val) {
    setState(() {
      _result = PasswordCheckerService.evaluate(val);
    });
  }

  Future<void> _saveCheckToSupabase() async {
    if (_result == null || _controller.text.isEmpty) return;
    final user = Supabase.instance.client.auth.currentUser;
    if (user == null) return;

    try {
      await Supabase.instance.client.from('security_checks').insert({
        'user_id': user.id,
        'check_type': 'password_strength',
        'status': _result!.strength.name,
        'score_impact': (_result!.score * 100).toInt(),
        'details': {
          'entropy': _result!.entropy.toStringAsFixed(1),
          'length': _controller.text.length,
        },
      });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Result saved to security logs! ✅')),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to save log: $e')),
        );
      }
    }
  }

  Color _getStrengthColor(PasswordStrength? strength) {
    switch (strength) {
      case PasswordStrength.weak:
        return Colors.red;
      case PasswordStrength.fair:
        return Colors.orange;
      case PasswordStrength.good:
        return Colors.yellow.shade700;
      case PasswordStrength.strong:
        return Colors.green;
      default:
        return Colors.grey;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Password Strength Checker')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            TextField(
              controller: _controller,
              obscureText: _obscureText,
              onChanged: _onPasswordChanged,
              decoration: InputDecoration(
                labelText: 'Enter Password to Test',
                border: const OutlineInputBorder(),
                suffixIcon: IconButton(
                  icon: Icon(_obscureText ? Icons.visibility : Icons.visibility_off),
                  onPressed: () => setState(() => _obscureText = !_obscureText),
                ),
              ),
            ),
            const SizedBox(height: 24),
            if (_result != null && _controller.text.isNotEmpty) ...[
              LinearProgressIndicator(
                value: _result!.score,
                minHeight: 10,
                color: _getStrengthColor(_result!.strength),
                backgroundColor: Colors.grey.shade800,
              ),
              const SizedBox(height: 12),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Strength: ${_result!.strength.name.toUpperCase()}',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: _getStrengthColor(_result!.strength),
                    ),
                  ),
                  Text('Entropy: ${_result!.entropy.toStringAsFixed(1)} bits'),
                ],
              ),
              const SizedBox(height: 16),
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('Suggestions:', style: TextStyle(fontWeight: FontWeight.bold)),
                      const SizedBox(height: 8),
                      ..._result!.feedback.map((f) => Padding(
                            padding: const EdgeInsets.symmetric(vertical: 2),
                            child: Text('• $f'),
                          )),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 16),
              ElevatedButton.icon(
                onPressed: _saveCheckToSupabase,
                icon: const Icon(Icons.save),
                label: const Text('Log Check to Dashboard'),
              ),
            ],
          ],
        ),
      ),
    );
  }
}