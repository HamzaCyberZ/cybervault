import 'package:supabase_flutter/supabase_flutter.dart';

class ChecklistItem {
  final String id;
  final String title;
  final String description;

  const ChecklistItem({required this.id, required this.title, required this.description});
}

class ChecklistService {
  static const List<ChecklistItem> defaultTasks = [
    ChecklistItem(id: 'task_2fa', title: 'Enable Two-Factor Authentication (2FA)', description: 'Secure your important accounts with an authenticator app or hardware key.'),
    ChecklistItem(id: 'task_password_mgr', title: 'Use a Password Manager', description: 'Stop reusing passwords and generate unique ones for every site.'),
    ChecklistItem(id: 'task_recovery', title: 'Update Recovery Email & Phone', description: 'Ensure your account recovery details are up to date and secure.'),
    ChecklistItem(id: 'task_updates', title: 'Enable Automatic Software Updates', description: 'Keep your OS, browsers, and security tools patched against vulnerabilities.'),
    ChecklistItem(id: 'task_phishing', title: 'Complete Phishing Awareness Training', description: 'Learn to recognize suspicious links, fake login pages, and social engineering.'),
  ];

  static Future<List<String>> fetchCompletedTaskIds(String userId) async {
    try {
      final response = await Supabase.instance.client
          .from('checklist_progress')
          .select('task_id')
          .eq('user_id', userId)
          .eq('is_completed', true);

      return (response as List).map((row) => row['task_id'].toString()).toList();
    } catch (e) {
      return [];
    }
  }

  static Future<void> toggleTask(String userId, String taskId, bool isCompleted) async {
    await Supabase.instance.client.from('checklist_progress').upsert({
      'user_id': userId,
      'task_id': taskId,
      'is_completed': isCompleted,
      'updated_at': DateTime.now().toIso8601String(),
    }, onConflict: 'user_id,task_id');
  }
}