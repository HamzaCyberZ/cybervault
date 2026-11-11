import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'password_generator_service.dart';

class PasswordGeneratorScreen extends StatefulWidget {
  const PasswordGeneratorScreen({super.key});

  @override
  State<PasswordGeneratorScreen> createState() => _PasswordGeneratorScreenState();
}

class _PasswordGeneratorScreenState extends State<PasswordGeneratorScreen> {
  double _length = 16;
  bool _useUpper = true;
  bool _useLower = true;
  bool _useDigits = true;
  bool _useSymbols = true;

  String _generatedPassword = '';

  @override
  void initState() {
    super.initState();
    _generate();
  }

  void _generate() {
    setState(() {
      _generatedPassword = PasswordGeneratorService.generate(
        length: _length.toInt(),
        includeUppercase: _useUpper,
        includeLowercase: _useLower,
        includeNumbers: _useDigits,
        includeSymbols: _useSymbols,
      );
    });
  }

  void _copyToClipboard() {
    if (_generatedPassword.isEmpty) return;
    Clipboard.setData(ClipboardData(text: _generatedPassword));
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Password copied to clipboard! 📋')),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Password Generator')),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.grey.shade900,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.teal.shade700),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: SelectableText(
                      _generatedPassword.isEmpty ? 'Select at least one option' : _generatedPassword,
                      style: const TextStyle(fontSize: 18, fontFamily: 'monospace', fontWeight: FontWeight.bold),
                    ),
                  ),
                  IconButton(icon: const Icon(Icons.refresh), onPressed: _generate),
                  IconButton(icon: const Icon(Icons.copy), onPressed: _copyToClipboard),
                ],
              ),
            ),
            const SizedBox(height: 24),
            Text('Length: ${_length.toInt()}'),
            Slider(
              value: _length,
              min: 8,
              max: 32,
              divisions: 24,
              label: _length.toInt().toString(),
              onChanged: (val) {
                setState(() => _length = val);
                _generate();
              },
            ),
            SwitchListTile(
              title: const Text('Include Uppercase (A-Z)'),
              value: _useUpper,
              onChanged: (val) {
                setState(() => _useUpper = val);
                _generate();
              },
            ),
            SwitchListTile(
              title: const Text('Include Lowercase (a-z)'),
              value: _useLower,
              onChanged: (val) {
                setState(() => _useLower = val);
                _generate();
              },
            ),
            SwitchListTile(
              title: const Text('Include Numbers (0-9)'),
              value: _useDigits,
              onChanged: (val) {
                setState(() => _useDigits = val);
                _generate();
              },
            ),
            SwitchListTile(
              title: const Text('Include Symbols (!@#\$)'),
              value: _useSymbols,
              onChanged: (val) {
                setState(() => _useSymbols = val);
                _generate();
              },
            ),
          ],
        ),
      ),
    );
  }
}