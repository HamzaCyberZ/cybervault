import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'features/auth/auth_provider.dart';
import 'features/auth/auth_screen.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await dotenv.load(fileName: '.env');
  await Supabase.initialize(
    url: dotenv.env['SUPABASE_URL']!,
    anonKey: dotenv.env['SUPABASE_ANON_KEY']!,
  );
  runApp(const ProviderScope(child: CyberVaultApp()));
}

class CyberVaultApp extends ConsumerWidget {
  const CyberVaultApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authState = ref.watch(authStateProvider);

    return MaterialApp(
      title: 'CyberVault',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF0F766E),
          brightness: Brightness.dark,
        ),
        useMaterial3: true,
      ),
      home: authState.when(
        data: (data) {
          final session = data.session;
          if (session != null) {
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
              body: Center(
                child: Text('Welcome, ${session.user.email}! ✅'),
              ),
            );
          }
          return const AuthScreen();
        },
        loading: () => const Scaffold(body: Center(child: CircularProgressIndicator())),
        error: (err, stack) => Scaffold(body: Center(child: Text('Error: $err'))),
      ),
    );
  }
}