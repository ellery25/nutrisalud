/// Form-field validators. Return null when valid (TextFormField contract).
abstract final class Validators {
  static String? requiredField(String? value, {String label = 'This field'}) {
    if (value == null || value.trim().isEmpty) return '$label is required';
    return null;
  }

  static String? username(String? value) {
    final required = requiredField(value, label: 'Username');
    if (required != null) return required;
    if (value!.trim().length < 3) {
      return 'Username must be at least 3 characters';
    }
    if (!RegExp(r'^[a-zA-Z0-9._-]+$').hasMatch(value.trim())) {
      return 'Only letters, numbers, ".", "_" and "-" allowed';
    }
    return null;
  }

  static String? password(String? value) {
    final required = requiredField(value, label: 'Password');
    if (required != null) return required;
    if (value!.length < 8) return 'Password must be at least 8 characters';
    return null;
  }
}
