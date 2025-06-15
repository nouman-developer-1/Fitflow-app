import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:provider/provider.dart';
import 'package:fitflow/providers/user_provider.dart';
import 'package:fitflow/models/user_model.dart';
import 'package:fitflow/navigation/main_navigation.dart';

class LoginScreen extends StatefulWidget {
  final VoidCallback onShowSignup;

  const LoginScreen({super.key, required this.onShowSignup});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen>
    with SingleTickerProviderStateMixin {
  final _formKey = GlobalKey<FormState>();
  final _usernameController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _isLoading = false;
  bool _obscureText = true;
  late AnimationController _animationController;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1000),
    )..forward();
  }

  @override
  void dispose() {
    _usernameController.dispose();
    _passwordController.dispose();
    _animationController.dispose();
    super.dispose();
  }

  Future<void> _signIn() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    try {
      // In a real app, this would be a call to Firebase Auth
      // For demo purposes, we'll just simulate a successful login
      await Future.delayed(const Duration(seconds: 1));

      if (!mounted) return;

      final userProvider = Provider.of<UserProvider>(context, listen: false);
      userProvider.setUser(User(
        uid: 'user123',
        email: 'user@example.com',
        name: _usernameController.text,
      ));

      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (context) => const MainNavigation()),
      );
    } catch (e) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error signing in: $e')),
      );
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;

    return Scaffold(
      backgroundColor: const Color(0xFF0D1117),
      body: SafeArea(
        child: SingleChildScrollView(
          physics: BouncingScrollPhysics(),
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SizedBox(height: size.height * 0.04),

                  // Sign In text with underline
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Sign In',
                        style: TextStyle(
                          fontSize: 28,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                      Container(
                        width: 60,
                        height: 3,
                        margin: EdgeInsets.only(top: 5),
                        decoration: BoxDecoration(
                          color: const Color(0xFF4FBDBA),
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                    ],
                  ).animate(
                    controller: _animationController,
                    effects: [
                      FadeEffect(duration: 800.ms),
                      SlideEffect(
                        begin: const Offset(0, -10),
                        end: const Offset(0, 0),
                        duration: 800.ms,
                      ),
                    ],
                  ),

                  SizedBox(height: size.height * 0.06),

                  // Username field
                  _buildTextField(
                    controller: _usernameController,
                    hintText: 'Username',
                    prefixIcon: Icons.person_outline,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter your username';
                      }
                      return null;
                    },
                    delay: 200,
                  ),

                  SizedBox(height: 16),

                  // Password field
                  _buildTextField(
                    controller: _passwordController,
                    hintText: 'Password',
                    prefixIcon: Icons.lock_outline,
                    obscureText: _obscureText,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter your password';
                      }
                      if (value.length < 6) {
                        return 'Password must be at least 6 characters';
                      }
                      return null;
                    },
                    suffixIcon: IconButton(
                      icon: Icon(
                        _obscureText ? Icons.visibility_off : Icons.visibility,
                        color: Colors.grey,
                      ),
                      onPressed: () {
                        setState(() {
                          _obscureText = !_obscureText;
                        });
                      },
                    ),
                    delay: 400,
                  ),

                  SizedBox(height: size.height * 0.05),

                  // Sign in button and need help text in a row
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      // Done button
                      ElevatedButton(
                        onPressed: _isLoading ? null : _signIn,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF4FBDBA),
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(
                            horizontal: 50,
                            vertical: 15,
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(30),
                          ),
                          elevation: 0,
                          disabledBackgroundColor:
                              const Color(0xFF4FBDBA).withOpacity(0.6),
                        ),
                        child: _isLoading
                            ? SizedBox(
                                width: 20,
                                height: 20,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  color: Colors.white,
                                ),
                              )
                            : Text(
                                'Done',
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                      ).animate(
                        controller: _animationController,
                        effects: [
                          FadeEffect(duration: 800.ms, delay: 600.ms),
                        ],
                      ),

                      // Need help text
                      TextButton(
                        onPressed: () {
                          // Implement help functionality
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text('Help functionality coming soon!'),
                              duration: Duration(seconds: 2),
                            ),
                          );
                        },
                        style: TextButton.styleFrom(
                          foregroundColor: Colors.black54,
                        ),
                        child: Text(
                          'Need Help?',
                          style: TextStyle(
                            fontSize: 16,
                          ),
                        ),
                      ).animate(
                        controller: _animationController,
                        effects: [
                          FadeEffect(duration: 800.ms, delay: 600.ms),
                        ],
                      ),
                    ],
                  ),

                  SizedBox(height: size.height * 0.06),

                  // Don't have account and Sign up text
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        "Don't Have any account? ",
                        style: TextStyle(
                          fontSize: 16,
                          color: Colors.grey.shade400,
                        ),
                      ),
                      GestureDetector(
                        onTap: widget.onShowSignup,
                        child: Text(
                          'Sign up',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: const Color(0xFF4FBDBA),
                          ),
                        ),
                      ),
                    ],
                  ).animate(
                    controller: _animationController,
                    effects: [
                      FadeEffect(duration: 800.ms, delay: 800.ms),
                    ],
                  ),

                  SizedBox(height: size.height * 0.05),

                  // Image at bottom
                  Center(
                    child: Container(
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(20),
                        boxShadow: [
                          BoxShadow(
                            color: const Color(0xFF4FBDBA).withOpacity(0.2),
                            blurRadius: 15,
                            spreadRadius: 1,
                          ),
                        ],
                      ),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(20),
                        child: Image.asset(
                          'assets/Usersignupand login page pics add/images2.jpeg',
                          height: size.height * 0.25,
                          fit: BoxFit.contain,
                          errorBuilder: (context, error, stackTrace) {
                            return Container(
                              height: size.height * 0.25,
                              width: size.width * 0.7,
                              decoration: BoxDecoration(
                                color: const Color(0xFF1A1D24),
                                borderRadius: BorderRadius.circular(10),
                              ),
                              child: Center(
                                child: Icon(
                                  Icons.image_not_supported,
                                  size: 50,
                                  color: const Color(0xFF4FBDBA),
                                ),
                              ),
                            );
                          },
                        ),
                      ),
                    ),
                  ).animate(
                    controller: _animationController,
                    effects: [
                      FadeEffect(duration: 800.ms, delay: 1000.ms),
                      SlideEffect(
                        begin: const Offset(0, 30),
                        end: const Offset(0, 0),
                        duration: 800.ms,
                        delay: 1000.ms,
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String hintText,
    required IconData prefixIcon,
    required String? Function(String?) validator,
    bool obscureText = false,
    Widget? suffixIcon,
    required int delay,
  }) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(30),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.15),
            blurRadius: 10,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: TextFormField(
        controller: controller,
        obscureText: obscureText,
        validator: validator,
        style: TextStyle(color: Colors.white),
        decoration: InputDecoration(
          hintText: hintText,
          hintStyle: TextStyle(
            color: Colors.grey.shade500,
            fontSize: 16,
          ),
          prefixIcon: Icon(
            prefixIcon,
            color: const Color(0xFF4FBDBA),
          ),
          suffixIcon: suffixIcon,
          filled: true,
          fillColor: const Color(0xFF1A1D24),
          contentPadding: EdgeInsets.symmetric(vertical: 15),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(30),
            borderSide: BorderSide.none,
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(30),
            borderSide: BorderSide(
              color: Colors.grey.shade800,
              width: 1,
            ),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(30),
            borderSide: BorderSide(
              color: const Color(0xFF4FBDBA),
              width: 1,
            ),
          ),
          errorBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(30),
            borderSide: BorderSide(
              color: Colors.red.shade300,
              width: 1,
            ),
          ),
          focusedErrorBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(30),
            borderSide: BorderSide(
              color: Colors.red.shade300,
              width: 1,
            ),
          ),
        ),
      ).animate(
        controller: _animationController,
        effects: [
          FadeEffect(duration: 800.ms, delay: delay.ms),
          SlideEffect(
            begin: const Offset(0, 20),
            end: const Offset(0, 0),
            duration: 800.ms,
            delay: delay.ms,
          ),
        ],
      ),
    );
  }
}
