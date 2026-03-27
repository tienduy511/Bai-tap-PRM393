class Validators {
  static String? requiredField(String? value, String fieldName) {
    if (value == null || value.isEmpty) {
      return "$fieldName is required";
    }
    return null;
  }

  static String? email(String? value) {
    if (value == null || value.isEmpty) {
      return "Email is required";
    }
    if (!value.contains('@') || !value.contains('.')) {
      return "Enter a valid email";
    }
    return null;
  }

  /// 🔥 STRONG PASSWORD
  static String? password(String? value) {
    if (value == null || value.isEmpty) {
      return "Password is required";
    }
    if (value.length < 8) return "Min 8 characters";
    if (!RegExp(r'[A-Z]').hasMatch(value)) return "Need uppercase letter";
    if (!RegExp(r'[a-z]').hasMatch(value)) return "Need lowercase letter";
    if (!RegExp(r'[0-9]').hasMatch(value)) return "Need a number";
    if (!RegExp(r'[!@#\$&*~]').hasMatch(value)) return "Need special char";
    return null;
  }
}