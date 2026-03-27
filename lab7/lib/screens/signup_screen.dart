import 'package:flutter/material.dart';
import '../utils/validators.dart';

class SignupScreen extends StatefulWidget {
  const SignupScreen({super.key});

  @override
  State<SignupScreen> createState() => _SignupScreenState();
}

class _SignupScreenState extends State<SignupScreen> {
  final _formKey = GlobalKey<FormState>();

  String name = '';
  String email = '';

  bool isLoading = false;
  bool obscurePassword = true;

  final passwordController = TextEditingController();
  final confirmController = TextEditingController();

  /// Focus
  final nameFocus = FocusNode();
  final emailFocus = FocusNode();
  final passFocus = FocusNode();
  final confirmFocus = FocusNode();

  /// 🔥 PASSWORD STRENGTH
  String getStrength(String pass) {
    int score = 0;
    if (pass.length >= 8) score++;
    if (RegExp(r'[A-Z]').hasMatch(pass)) score++;
    if (RegExp(r'[0-9]').hasMatch(pass)) score++;
    if (RegExp(r'[!@#\$&*~]').hasMatch(pass)) score++;

    if (score <= 1) return "Weak";
    if (score <= 3) return "Medium";
    return "Strong";
  }

  Color getColor(String strength) {
    switch (strength) {
      case "Weak":
        return Colors.red;
      case "Medium":
        return Colors.orange;
      case "Strong":
        return Colors.green;
      default:
        return Colors.grey;
    }
  }

  Future<void> submit() async {
    if (!_formKey.currentState!.validate()) return;

    _formKey.currentState!.save();

    setState(() => isLoading = true);

    await Future.delayed(const Duration(seconds: 2));

    if (email.startsWith("taken")) {
      setState(() => isLoading = false);

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Email already taken")),
      );
      return;
    }

    setState(() => isLoading = false);

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text("Signup Success 🎉")),
    );
  }

  @override
  Widget build(BuildContext context) {
    final strength = getStrength(passwordController.text);

    return GestureDetector(
      onTap: () => FocusScope.of(context).unfocus(),

      child: Scaffold(
        appBar: AppBar(title: const Text("Signup")),

        body: Padding(
          padding: const EdgeInsets.all(16),

          child: Form(
            key: _formKey,
            autovalidateMode:
            AutovalidateMode.onUserInteraction,

            child: ListView(
              children: [
                /// NAME
                TextFormField(
                  focusNode: nameFocus,
                  textInputAction: TextInputAction.next,
                  decoration: const InputDecoration(
                    labelText: "Full Name",
                    border: OutlineInputBorder(),
                  ),
                  validator: (v) =>
                      Validators.requiredField(v, "Name"),
                  onSaved: (v) => name = v!,
                  onFieldSubmitted: (_) =>
                      FocusScope.of(context).requestFocus(emailFocus),
                ),

                const SizedBox(height: 12),

                /// EMAIL
                TextFormField(
                  focusNode: emailFocus,
                  textInputAction: TextInputAction.next,
                  decoration: const InputDecoration(
                    labelText: "Email",
                    border: OutlineInputBorder(),
                  ),
                  validator: Validators.email,
                  onSaved: (v) => email = v!,
                  onFieldSubmitted: (_) =>
                      FocusScope.of(context).requestFocus(passFocus),
                ),

                const SizedBox(height: 12),

                /// PASSWORD
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    TextFormField(
                      controller: passwordController,
                      obscureText: obscurePassword,
                      focusNode: passFocus,
                      textInputAction: TextInputAction.next,

                      decoration: InputDecoration(
                        labelText: "Password",
                        border: const OutlineInputBorder(),

                        suffixIcon: IconButton(
                          icon: Icon(obscurePassword
                              ? Icons.visibility
                              : Icons.visibility_off),
                          onPressed: () {
                            setState(() {
                              obscurePassword = !obscurePassword;
                            });
                          },
                        ),
                      ),

                      validator: Validators.password,
                      onChanged: (_) => setState(() {}),
                      onFieldSubmitted: (_) =>
                          FocusScope.of(context)
                              .requestFocus(confirmFocus),
                    ),

                    const SizedBox(height: 6),

                    if (passwordController.text.isNotEmpty)
                      Row(
                        children: [
                          const Text("Strength: "),
                          Text(
                            strength,
                            style: TextStyle(
                              color: getColor(strength),
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                  ],
                ),

                const SizedBox(height: 12),

                /// CONFIRM PASSWORD
                TextFormField(
                  controller: confirmController,
                  obscureText: true,
                  focusNode: confirmFocus,
                  textInputAction: TextInputAction.done,

                  decoration: const InputDecoration(
                    labelText: "Confirm Password",
                    border: OutlineInputBorder(),
                  ),

                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return "Confirm password required";
                    }
                    if (value != passwordController.text) {
                      return "Passwords do not match";
                    }
                    return null;
                  },

                  onFieldSubmitted: (_) => submit(),
                ),

                const SizedBox(height: 20),

                ElevatedButton(
                  onPressed: isLoading ? null : submit,

                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                  ),

                  child: isLoading
                      ? const CircularProgressIndicator()
                      : const Text("Sign Up"),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}