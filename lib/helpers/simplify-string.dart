String simplifyString(String? str) {
  if (str == null) return '';

  return str
      .toLowerCase()
      .replaceAllMapped(' ', (match) => '');
}
