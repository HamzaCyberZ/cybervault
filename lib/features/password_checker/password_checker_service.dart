import 'dart:math';

enum PasswordStrength { weak, fair, good, strong }

class PasswordCheckerResult {
  final double score; // 0.0 to 1.0
  final PasswordStrength strength;
  final List<String> feedback;
  final double entropy;

  PasswordCheckerResult({
    required this.score,
    required this.strength,
    required this.feedback,
    required this.entropy,
  });
}

class PasswordCheckerService {
  static PasswordCheckerResult evaluate(String password) {
    if (password.isEmpty) {
      return PasswordCheckerResult(
        score: 0.0,
        strength: PasswordStrength.weak,
        feedback: ['Enter a password to evaluate.'],
        entropy: 0.0,
      );
    }

    final feedback = <String>[];
    int poolSize = 0;

    final hasLower = password.contains(RegExp(r'[a-z]'));
    final hasUpper = password.contains(RegExp(r'[A-Z]'));
    final hasDigits = password.contains(RegExp(r'[0-9]'));
    final hasSymbols = password.contains(RegExp(r'[!@#$%^&*(),.?":{}|<>]'));

    if (hasLower) poolSize += 26;
    if (hasUpper) poolSize += 26;
    if (hasDigits) poolSize += 10;
    if (hasSymbols) poolSize += 32;

    if (!hasUpper) feedback.add('Add uppercase letters (A-Z).');
    if (!hasDigits) feedback.add('Add numbers (0-9).');
    if (!hasSymbols) feedback.add('Add special characters (!@#...).');
    if (password.length < 12) feedback.add('Make it at least 12 characters long.');

    final entropy = password.length * (poolSize > 0 ? (log(poolSize) / log(2)) : 0);

    double score = (entropy / 80).clamp(0.0, 1.0);
    PasswordStrength strength;

    if (score < 0.35) {
      strength = PasswordStrength.weak;
    } else if (score < 0.6) {
      strength = PasswordStrength.fair;
    } else if (score < 0.8) {
      strength = PasswordStrength.good;
    } else {
      strength = PasswordStrength.strong;
    }

    return PasswordCheckerResult(
      score: score,
      strength: strength,
      feedback: feedback.isEmpty ? ['Great password! Very strong.'] : feedback,
      entropy: entropy,
    );
  }
}