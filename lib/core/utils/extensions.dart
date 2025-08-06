extension StringExtraction on String {
  String extractBefore(String delimiter) {
    final index = indexOf(delimiter);
    return (index != -1) ? substring(0, index).trim() : this;
  }
}
