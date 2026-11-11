import 'dart:math';

class PasswordGeneratorService {
  static String generate({
    int length = 16,
    bool includeUppercase = true,
    bool includeLowercase = true,
    bool includeNumbers = true,
    bool includeSymbols = true,
  }) {
    const lowercase = 'abcdefghijklmnopqrstuvwxyz';
    const uppercase = 'ABCDEFGHIJKLMNOPQRSTUVWXYZ';
    const numbers = '0123456789';
    const symbols = '!@#\$%^&*()_+-=[]{}|;:,.<>?';

    String allowed = '';
    if (includeLowercase) allowed += lowercase;
    if (includeUppercase) allowed += uppercase;
    if (includeNumbers) allowed += numbers;
    if (includeSymbols) allowed += symbols;

    if (allowed.isEmpty) return '';

    final rand = Random.secure();
    return List.generate(length, (_) => allowed[rand.nextInt(allowed.length)]).join();
  }
}