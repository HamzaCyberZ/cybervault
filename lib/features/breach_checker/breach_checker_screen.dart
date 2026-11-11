import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'breach_checker_service.dart';

class BreachCheckerScreen extends StatefulWidget {
  const BreachCheckerScreen({super.key});

  @override
  State<BreachCheckerScreen> createState() => _BreachCheckerScreenState();
}

class _BreachCheckerScreenState extends State<BreachCheckerScreen> {
  final _emailController = TextEditingController();
  bool _isLoading = false;
  List<BreachModel> _breaches = [];
  String? _errorMessage;
  bool _searched = false;

  @override
  void dispose() {
    _emailController.dispose();
    super.dispose();
  }

  Future<void> _performCheck() async {
    final email = _emailController.text.trim();
    if (email.isEmpty || !email.contains('@')) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter a valid email address')),
      );
      return;
    }

    setState(() {
      _isLoading = true;
      _errorMessage = null;
      _breaches = [];
      _searched = false;
    });

    try {
      final results = await BreachCheckerService.checkEmail(email);
      setState(() {
        _breaches = results;
        _searched = true;
      });

      // Supabase mein history save karna agar breaches milti hain
      if (results.isNotEmpty) {
        await _saveBreachHistory(email, results.first.title);
      }
    } catch (e) {
      setState(() {
        _errorMessage = e.toString();
      });
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _saveBreachHistory(String email, String breachName) async {
    final user = Supabase.instance.client.auth.currentUser;
    if (user == null) return;

    try {
      await Supabase.instance.client.from('breach_history').insert({
        'user_id': user.id,
        'searched_email': email,
        'breach_name': breachName,
      });
    } catch (e) {
      debugPrint('Failed to save breach history: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Data Breach Checker')),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Text(
              'Check if your email address has been compromised in any known data breaches.',
              style: TextStyle(color: Colors.grey),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _emailController,
              keyboardType: TextInputType.emailAddress,
              decoration: const InputDecoration(
                labelText: 'Enter Email Address',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.email),
              ),
            ),
            const SizedBox(height: 16),
            _isLoading
                ? const Center(child: CircularProgressIndicator())
                : ElevatedButton.icon(
                    onPressed: _performCheck,
                    icon: const Icon(Icons.search),
                    label: const Text('Check for Breaches'),
                    style: ElevatedButton.styleFrom(minimumSize: const Size.fromHeight(50)),
                  ),
            const SizedBox(height: 20),
            if (_errorMessage != null)
              Text(_errorMessage!, style: const TextStyle(color: Colors.red))
            else if (_searched && _breaches.isEmpty)
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.green.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.green),
                ),
                child: const Row(
                  children: [
                    Icon(Icons.check_circle, color: Colors.green),
                    SizedBox(width: 12),
                    Text('Good news! No breaches found for this email.', style: TextStyle(color: Colors.green, fontWeight: FontWeight.bold)),
                  ],
                ),
              )
            else if (_searched && _breaches.isNotEmpty) ...[
              Text(
                'Found in ${_breaches.length} breach(es):',
                style: const TextStyle(color: Colors.red, fontWeight: FontWeight.bold, fontSize: 16),
              ),
              const SizedBox(height: 10),
              Expanded(
                child: ListView.builder(
                  itemCount: _breaches.length,
                  itemBuilder: (context, index) {
                    final breach = _breaches[index];
                    return Card(
                      margin: const EdgeInsets.symmetric(vertical: 6),
                      child: Padding(
                        padding: const EdgeInsets.all(12.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(breach.title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: Colors.orange)),
                            const SizedBox(height: 4),
                            Text('Breach Date: ${breach.breachDate}', style: const TextStyle(fontSize: 12, color: Colors.grey)),
                            const SizedBox(height: 8),
                            Text('Compromised data: ${breach.dataClasses.join(', ')}', style: const TextStyle(fontSize: 13)),
                          ],
                        ),
                      ),
                    );
                  },
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}