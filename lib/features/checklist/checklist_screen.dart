import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'checklist_service.dart';

class ChecklistScreen extends StatefulWidget {
  const ChecklistScreen({super.key});

  @override
  State<ChecklistScreen> createState() => _ChecklistScreenState();
}

class _ChecklistScreenState extends State<ChecklistScreen> {
  List<String> _completedIds = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadProgress();
  }

  Future<void> _loadProgress() async {
    final user = Supabase.instance.client.auth.currentUser;
    if (user == null) return;

    final completed = await ChecklistService.fetchCompletedTaskIds(user.id);
    if (mounted) {
      setState(() {
        _completedIds = completed;
        _isLoading = false;
      });
    }
  }

  Future<void> _onChanged(String taskId, bool? val) async {
    final user = Supabase.instance.client.auth.currentUser;
    if (user == null || val == null) return;

    setState(() {
      if (val) {
        _completedIds.add(taskId);
      } else {
        _completedIds.remove(taskId);
      }
    });

    await ChecklistService.toggleTask(user.id, taskId, val);
  }

  @override
  Widget build(BuildContext context) {
    final progressPercentage = (_completedIds.length / ChecklistService.defaultTasks.length);

    return Scaffold(
      appBar: AppBar(title: const Text('Security Checklist')),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : Column(
              children: [
                Container(
                  padding: const EdgeInsets.all(20),
                  color: Colors.grey.shade900,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text('Your Security Posture', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                          Text('${(_completedIds.length)} / ${ChecklistService.defaultTasks.length} Done', style: const TextStyle(color: Colors.teal)),
                        ],
                      ),
                      const SizedBox(height: 12),
                      LinearProgressIndicator(
                        value: progressPercentage,
                        minHeight: 10,
                        backgroundColor: Colors.grey.shade800,
                        color: Colors.teal,
                      ),
                    ],
                  ),
                ),
                Expanded(
                  child: ListView.builder(
                    itemCount: ChecklistService.defaultTasks.length,
                    itemBuilder: (context, index) {
                      final task = ChecklistService.defaultTasks[index];
                      final isChecked = _completedIds.contains(task.id);

                      return CheckboxListTile(
                        title: Text(task.title, style: TextStyle(decoration: isChecked ? TextDecoration.lineThrough : null)),
                        subtitle: Text(task.description),
                        value: isChecked,
                        onChanged: (val) => _onChanged(task.id, val),
                        activeColor: Colors.teal,
                      );
                    },
                  ),
                ),
              ],
            ),
    );
  }
}