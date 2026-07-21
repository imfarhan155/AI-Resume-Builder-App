import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../repositories/auth_repository.dart';
import '../utils/validators.dart';
import '../widgets/custom_text_field.dart';
import '../widgets/primary_button.dart';

class AuthScreen extends StatefulWidget {
  const AuthScreen({super.key});

  @override
  State<AuthScreen> createState() => _AuthScreenState();
}

class _AuthScreenState extends State<AuthScreen> {
  final _formKey = GlobalKey<FormState>();
  final _email = TextEditingController();
  final _password = TextEditingController();
  bool _isLogin = true;
  bool _loading = false;
  bool _obscurePassword = true;

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    final auth = context.read<AuthRepository>();

    setState(() => _loading = true);
    try {
      if (_isLogin) {
        await auth.signIn(
            email: _email.text.trim(), password: _password.text.trim());
      } else {
        await auth.signUp(
            email: _email.text.trim(), password: _password.text.trim());
      }
      if (!mounted) return;
      Navigator.pushReplacementNamed(context, '/home');
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Authentication failed: $e')),
      );
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Color(0xFF0F172A), Color(0xFF1E2937)],
          ),
        ),
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 420),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // Logo
                  Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        colors: [Colors.tealAccent, Colors.cyan],
                      ),
                      borderRadius: BorderRadius.circular(24),
                    ),
                    child: const Text("🤖", style: TextStyle(fontSize: 62)),
                  ),

                  const SizedBox(height: 32),

                  Text(
                    _isLogin ? "Welcome Back" : "Create Account",
                    style: const TextStyle(
                      fontSize: 32,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),

                  const SizedBox(height: 8),
                  Text(
                    _isLogin
                        ? "Sign in to continue building resumes"
                        : "Join us and create amazing resumes",
                    style: TextStyle(fontSize: 16, color: Colors.grey[400]),
                    textAlign: TextAlign.center,
                  ),

                  const SizedBox(height: 40),

                  // Form Card
                  Container(
                    padding: const EdgeInsets.all(24),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.08),
                      borderRadius: BorderRadius.circular(28),
                      border: Border.all(color: Colors.white.withOpacity(0.1)),
                    ),
                    child: Form(
                      key: _formKey,
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          // Email Field - Light Gray
                          CustomTextField(
                            label: "Email",
                            controller: _email,
                            validator: Validators.email,
                            keyboardType: TextInputType.emailAddress,
                            prefixIcon: Icons.email_outlined,
                            fillColor: Colors.white,
                            // Agar CustomTextField mein backgroundColor parameter hai to use karo
                            // backgroundColor: Colors.grey[200],
                          ),
                          const SizedBox(height: 16),

                          // Password Field - Light Gray
                          CustomTextField(
                            label: "Password",
                            controller: _password,
                            validator: (v) =>
                                Validators.requiredField(v, "Password"),
                            prefixIcon: Icons.lock_outline,
                            fillColor: Colors.white,
                            obscureText: _obscurePassword,
                            suffixIcon: IconButton(
                              icon: Icon(
                                _obscurePassword
                                    ? Icons.visibility_off
                                    : Icons.visibility,
                                color: Colors.black,
                              ),
                              onPressed: () {
                                setState(() {
                                  _obscurePassword = !_obscurePassword;
                                });
                              },
                            ),
                          ),
                          const SizedBox(height: 20),

                          PrimaryButton(
                            label: _loading
                                ? "Please wait..."
                                : (_isLogin ? "Login" : "Sign Up"),
                            onPressed: _loading ? null : _submit,
                            icon:
                                _isLogin ? Icons.login : Icons.person_add_alt_1,
                          ),

                          const SizedBox(height: 8),

                          TextButton(
                            onPressed: _loading
                                ? null
                                : () => setState(() => _isLogin = !_isLogin),
                            child: Text(
                              _isLogin
                                  ? "Don't have an account? Sign up"
                                  : "Already have an account? Login",
                              style: const TextStyle(
                                color: Colors.tealAccent,
                                fontSize: 15,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
