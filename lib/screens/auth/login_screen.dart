import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../services/auth_service.dart';
import '../../widgets/styled/glass_morphism.dart';
import '../../widgets/styled/gradient_background.dart';

class LoginScreen extends StatefulWidget {
  final VoidCallback onSignUpTap;

  const LoginScreen({
    super.key,
    required this.onSignUpTap,
  });

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _authService = AuthService();

  bool _isLoading = false;
  bool _obscurePassword = true;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _handleLogin() async {
    if (_emailController.text.isEmpty || _passwordController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please fill all fields')),
      );
      return;
    }
    setState(() => _isLoading = true);

    // Mock Login for Frontend UI Testing
    await Future.delayed(const Duration(seconds: 1));
    if (mounted) {
      setState(() => _isLoading = false);
      // Navigate to Home screen
      context.go('/');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset:
          false, // Disables keyboard resizing to prevent yellow/black strips
      body: Stack(
        children: [
          // Theme Background
          const GradientBackground(child: SizedBox.expand()),

          // Non-scrollable content filling screen flex height
          SafeArea(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Spacer(flex: 3), // Dynamic top spacing

                // Image / Portrait replacing logo_white with logo
                Flexible(
                  flex: 5,
                  child: Image.asset(
                    'public/logo.png',
                    fit: BoxFit.contain,
                  ),
                ),

                Spacer(flex: 2), // Dynamic mid spacing

                // Bottom layout Container (No Expandeds needed, takes natural height at bottom)
                Container(
                  width: double.infinity,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [
                        const Color(0xFFF98E9B)
                            .withOpacity(0.0), // Transparent top edge
                        const Color(0xFFE56A7A)
                            .withOpacity(0.9), // Strong theme pink blur
                      ],
                    ),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.only(bottom: 30),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        const SizedBox(height: 20),
                        // Title Text matching "Welcome to Filo!" aesthetics
                        RichText(
                          text: const TextSpan(
                            style: TextStyle(
                                fontSize: 28,
                                fontWeight: FontWeight.normal,
                                color: Colors.white),
                            children: [
                              TextSpan(text: 'Welcome to '),
                              TextSpan(
                                  text: 'NanheNest',
                                  style:
                                      TextStyle(fontWeight: FontWeight.bold)),
                              TextSpan(text: '!'),
                            ],
                          ),
                        ),
                        const SizedBox(height: 12),
                        const Padding(
                          padding: EdgeInsets.symmetric(horizontal: 40),
                          child: Text(
                            'Sign in to your account. Stay connected with the community and track your journey.',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                                fontSize: 13,
                                color: Colors.white70,
                                height: 1.4),
                          ),
                        ),
                        const SizedBox(height: 20),

                        // Input Fields wrapped in transparent style to match glass effect
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 24),
                          child: Container(
                            decoration: BoxDecoration(
                              color: Colors.white.withOpacity(
                                  0.2), // Very subtle white underlay
                              borderRadius: BorderRadius.circular(30),
                            ),
                            child: TextField(
                              controller: _emailController,
                              keyboardType: TextInputType.emailAddress,
                              style: const TextStyle(color: Colors.white),
                              decoration: const InputDecoration(
                                hintText: 'Email Address',
                                hintStyle: TextStyle(color: Colors.white70),
                                prefixIcon: Icon(Icons.email_outlined,
                                    color: Colors.white),
                                border: InputBorder.none,
                                contentPadding:
                                    EdgeInsets.symmetric(vertical: 18),
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(height: 16),

                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 24),
                          child: Container(
                            decoration: BoxDecoration(
                              color: Colors.white.withOpacity(0.2),
                              borderRadius: BorderRadius.circular(30),
                            ),
                            child: TextField(
                              controller: _passwordController,
                              obscureText: _obscurePassword,
                              style: const TextStyle(color: Colors.white),
                              decoration: InputDecoration(
                                hintText: 'Password',
                                hintStyle:
                                    const TextStyle(color: Colors.white70),
                                prefixIcon: const Icon(Icons.lock_outline,
                                    color: Colors.white),
                                suffixIcon: IconButton(
                                  icon: Icon(
                                    _obscurePassword
                                        ? Icons.visibility_off
                                        : Icons.visibility,
                                    color: Colors.white70,
                                  ),
                                  onPressed: () => setState(() =>
                                      _obscurePassword = !_obscurePassword),
                                ),
                                border: InputBorder.none,
                                contentPadding:
                                    const EdgeInsets.symmetric(vertical: 18),
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(height: 24),

                        // Two Buttons stacked like the picture
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 24),
                          child: _isLoading
                              ? const CircularProgressIndicator(
                                  color: Colors.white)
                              : GlassButton(
                                  text: 'Sign In',
                                  isPrimary:
                                      true, // White solid background with colored text
                                  onPressed: _handleLogin,
                                ),
                        ),
                        const SizedBox(height: 12),

                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 24),
                          child: GlassButton(
                            text: 'Create new account',
                            isPrimary:
                                false, // Transparent outline glass button
                            onPressed: widget.onSignUpTap,
                          ),
                        ),
                        const SizedBox(height: 10),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
