import 'package:flutter/material.dart';

class PasswordValidator {
  static bool hasMinLength(String password) => password.length >= 6;
  static bool hasUppercase(String password) =>
      password.contains(RegExp(r'[A-Z]'));
  static bool hasLowercase(String password) =>
      password.contains(RegExp(r'[a-z]'));
  static bool hasDigits(String password) => password.contains(RegExp(r'[0-9]'));
  static bool hasSpecialChars(String password) =>
      password.contains(RegExp(r'[!@#$%^&*(),.?":{}|<>]'));

  static Map<String, bool> validate(String password) {
    return {
      'length': hasMinLength(password),
      'uppercase': hasUppercase(password),
      'lowercase': hasLowercase(password),
      'digits': hasDigits(password),
      'special': hasSpecialChars(password),
    };
  }
}

class PasswordCriteriaWidget extends StatelessWidget {
  final Map<String, bool> criteria;
  final Map<String, String> labels = const {
    'length': '6 caractères minimum',
    'uppercase': 'Lettre majuscule',
    'lowercase': 'Lettre minuscule',
    'digits': 'Au moins un chiffre',
    'special': 'Caractère spécial',
  };

  const PasswordCriteriaWidget({super.key, required this.criteria});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: criteria.entries.map((entry) {
        return Padding(
          padding: const EdgeInsets.symmetric(vertical: 2),
          child: Row(
            children: [
              Icon(
                entry.value ? Icons.check_circle : Icons.circle_outlined,
                size: 16,
                color: entry.value ? Colors.green : Colors.grey,
              ),
              const SizedBox(width: 8),
              Text(
                labels[entry.key]!,
                style: TextStyle(
                  fontSize: 12,
                  color: entry.value ? Colors.green : Colors.grey,
                ),
              ),
            ],
          ),
        );
      }).toList(),
    );
  }
}
