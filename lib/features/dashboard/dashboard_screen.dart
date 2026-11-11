import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../auth/auth_provider.dart';
import '../password_checker/password_checker_screen.dart';
import '../password_generator/password_generator_screen.dart';

class DashboardScreen extends ConsumerWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('CyberVault Dashboard'),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () => ref.read(authRepositoryProvider).signOut(),
          )
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          ListTile(
            leading: const Icon(Icons.security, color: Colors.teal),
            title: const Text('Password Strength Checker'),
            subtitle: const Text('Check entropy & test strength'),
            trailing: const Icon(Icons.chevron_right),
            onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const PasswordCheckerScreen())),
          ),
          const Divider(),
          ListTile(
            leading: const Icon(Icons.key, color: Colors.teal),
            title: const Text('Password Generator'),
            subtitle: const Text('Generate strong, secure passwords'),
            trailing: const Icon(Icons.chevron_right),
            onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const PasswordGeneratorScreen())),
          ),
        ],
      ),
    );
  }
}