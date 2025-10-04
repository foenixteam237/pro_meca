String formatAmount(dynamic amount) {
  // Convertir en nombre
  final amountNumber = _parseAmount(amount);

  // Formater avec séparateurs de milliers
  final formatted = _formatWithSeparators(amountNumber);

  return formatted;
  // return '$formatted FCFA';
}

num _parseAmount(dynamic amount) {
  if (amount is num) return amount;

  if (amount is String) {
    final cleaned = amount
        .replaceAll(RegExp(r'[^\d,.-]'), '')
        .replaceAll(',', '.');
    return double.tryParse(cleaned) ?? 0;
  }

  return 0;
}

String _formatWithSeparators(num number) {
  final isNegative = number < 0;
  final absoluteValue = number.abs().round();
  final numberString = absoluteValue.toString();

  final buffer = StringBuffer();
  if (isNegative) buffer.write('-');

  for (int i = 0; i < numberString.length; i++) {
    if (i > 0 && (numberString.length - i) % 3 == 0) {
      buffer.write(' ');
    }
    buffer.write(numberString[i]);
  }

  return buffer.toString();
}
