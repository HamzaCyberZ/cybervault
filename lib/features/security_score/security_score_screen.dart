import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class SecurityScoreScreen extends StatefulWidget {
  const SecurityScoreScreen({super.key});

  @override
  State<SecurityScoreScreen> createState() => _SecurityScoreScreenState();
}

class _SecurityScoreScreenState extends State<SecurityScoreScreen> {
  int _score = 50; // Base score
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _calculateScore();
  }

  Future<void> _calculateScore() async {
    final user = Supabase.instance.client.auth.currentUser;
    if (user == null) return;

    try {
      // Checklist completion count
      final checklistRes = await Supabase.instance.client
          .from('checklist_progress')
          .select('task_id')
          .eq('user_id', user.id)
          .eq('is_completed', true);

      int checklistBonus = (checklistRes as List).length * 10;

      // Security checks count
      final checksRes = await Supabase.instance.client
          .from('security_checks')
          .select('id')
          .eq('user_id', user.id);

      int checksBonus = ((checksRes as List).length * 5).clamp(0, 30);

      setState(() {
        _score = (50 + checklistBonus + checksBonus).clamp(0, 100);
        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Security Score & Audit')),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : Center(
              child: Padding(
                padding: const EdgeInsets.all(24.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Container(
                      width: 160,
                      height: 160,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        border: Border.all(color: _score > 75 ? Colors.green : (_score > 50 ? Colors.orange : Colors.red), width: 8),
                      ),
                      child: Center(
                        child: Text(
                          '$_score%',
                          style: const TextStyle(fontSize: 40, fontWeight: FontWeight.bold),
                        ),
                      ),
                    ),
                    const SizedBox(height: 32),
                    Text(
                      _score > 75 ? 'Strong Security Posture! 🛡️' : (_score > 50 ? 'Moderate Risk. Complete your checklist.' : 'High Risk! Immediate action required.'),
                      style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 16),
                    const Text(
                      'Your score is calculated based on password strength tests completed and your security checklist progress.',
                      textAlign: TextAlign.center,
                      style: TextStyle(color: Colors.grey),
                    ),
                  ],
                ),
              ),
            ),
    );
  }
}