extension StringExtensions on String {
  String capitalize() {
    if (isEmpty) return this;
    return this[0].toUpperCase() + substring(1).toLowerCase();
  }

  String toCleanNameFromEmail() {
    final localPart = split('@').first; // john13
    final lettersOnly = localPart.replaceAll(RegExp(r'[^a-zA-Z]'), '');
    if (lettersOnly.isEmpty) return 'User';
    return lettersOnly.capitalize();
  }
}
