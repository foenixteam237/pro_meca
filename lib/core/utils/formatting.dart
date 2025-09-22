String formatAmount(int amount) {
  // Convertir le montant en chaîne de caractères
  String amountString = amount.toString();

  // Ajouter des espaces comme séparateurs de milliers
  StringBuffer formattedAmount = StringBuffer();
  int length = amountString.length;

  for (int i = 0; i < length; i++) {
    // Ajouter un espace tous les 3 chiffres, sauf à la fin
    if (i > 0 && (length - i) % 3 == 0) {
      formattedAmount.write(' ');
    }
    formattedAmount.write(amountString[i]);
  }

  return formattedAmount.toString();
  // Ajouter le symbole FCFA à la fin
  // return '${formattedAmount.toString()} FCFA';
}
