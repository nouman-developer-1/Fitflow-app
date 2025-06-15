import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:provider/provider.dart';
import 'package:fitflow/providers/user_provider.dart';
import 'package:fitflow/navigation/main_navigation.dart';
import 'package:fitflow/models/user_model.dart';

class SignupScreen extends StatefulWidget {
  final VoidCallback onShowLogin;

  const SignupScreen({super.key, required this.onShowLogin});

  @override
  State<SignupScreen> createState() => _SignupScreenState();
}

class _SignupScreenState extends State<SignupScreen>
    with SingleTickerProviderStateMixin {
  final _formKey = GlobalKey<FormState>();
  final _usernameController = TextEditingController();
  final _passwordController = TextEditingController();
  final _phoneController = TextEditingController();
  final _emailController = TextEditingController();
  bool _isLoading = false;
  bool _obscurePassword = true;
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
    _phoneController.dispose();
    _emailController.dispose();
    _animationController.dispose();
    super.dispose();
  }

  // Basic email validation function
  bool _isValidEmail(String email) {
    final emailRegExp = RegExp(r'^[^@]+@[^@]+\.[^@]+');
    return emailRegExp.hasMatch(email);
  }

  // Phone number validation function
  bool _isValidPhone(String phone) {
    // Basic validation to check if the phone number contains only digits
    // and has a reasonable length
    final phoneRegExp = RegExp(r'^\d{10,15}$');
    return phoneRegExp.hasMatch(phone);
  }

  Future<void> _signUp() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    try {
      // For demo purposes, we'll just simulate a successful registration
      await Future.delayed(const Duration(seconds: 1));

      if (!mounted) return;

      final userProvider = Provider.of<UserProvider>(context, listen: false);
      userProvider.setUser(User(
        uid: 'new-user-${DateTime.now().millisecondsSinceEpoch}',
        email: _emailController.text,
        name: _usernameController.text,
      ));

      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (context) => const MainNavigation()),
      );
    } catch (e) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error signing up: $e')),
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

                  // Sign Up text with underline
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Sign Up',
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

                  SizedBox(height: size.height * 0.04),

                  // Username field
                  _buildTextField(
                    controller: _usernameController,
                    hintText: 'Username',
                    prefixIcon: Icons.person_outline,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter a username';
                      }
                      if (value.length < 3) {
                        return 'Username must be at least 3 characters';
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
                    obscureText: _obscurePassword,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter a password';
                      }
                      if (value.length < 6) {
                        return 'Password must be at least 6 characters';
                      }
                      return null;
                    },
                    suffixIcon: IconButton(
                      icon: Icon(
                        _obscurePassword
                            ? Icons.visibility_off
                            : Icons.visibility,
                        color: Colors.grey,
                      ),
                      onPressed: () {
                        setState(() {
                          _obscurePassword = !_obscurePassword;
                        });
                      },
                    ),
                    delay: 300,
                  ),

                  SizedBox(height: 16),

                  // Phone number field
                  _buildTextField(
                    controller: _phoneController,
                    hintText: 'Enter your number',
                    prefixIcon: Icons.phone_outlined,
                    keyboardType: TextInputType.phone,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter your phone number';
                      }
                      if (!_isValidPhone(value.replaceAll(RegExp(r'\D'), ''))) {
                        return 'Please enter a valid phone number';
                      }
                      return null;
                    },
                    delay: 400,
                  ),

                  SizedBox(height: 16),

                  // Email field
                  _buildTextField(
                    controller: _emailController,
                    hintText: 'Enter your email',
                    prefixIcon: Icons.email_outlined,
                    keyboardType: TextInputType.emailAddress,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter your email';
                      }
                      if (!_isValidEmail(value)) {
                        return 'Please enter a valid email address';
                      }
                      return null;
                    },
                    delay: 500,
                  ),

                  SizedBox(height: size.height * 0.04),

                  // Sign up button
                  Center(
                    child: ElevatedButton(
                      onPressed: _isLoading ? null : _signUp,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF4FBDBA),
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(
                          horizontal: 80,
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
                    ),
                  ).animate(
                    controller: _animationController,
                    effects: [
                      FadeEffect(duration: 800.ms, delay: 600.ms),
                    ],
                  ),

                  SizedBox(height: 16),

                  // Or text
                  Center(
                    child: Text(
                      'Or',
                      style: TextStyle(
                        fontSize: 16,
                        color: Colors.grey.shade400,
                      ),
                    ),
                  ).animate(
                    controller: _animationController,
                    effects: [
                      FadeEffect(duration: 800.ms, delay: 700.ms),
                    ],
                  ),

                  SizedBox(height: 16),

                  // Social login icons
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      _buildSocialIcon(Colors.blue, Icons.facebook, 0),
                      SizedBox(width: 20),
                      _buildSocialIcon(
                          Colors.red, Icons.g_mobiledata_rounded, 1),
                      SizedBox(width: 20),
                      _buildSocialIcon(Colors.lightBlue, Icons.telegram, 2),
                    ],
                  ).animate(
                    controller: _animationController,
                    effects: [
                      FadeEffect(duration: 800.ms, delay: 800.ms),
                    ],
                  ),

                  SizedBox(height: size.height * 0.03),

                  // Already have account text
                  Center(
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          'Already have an account? ',
                          style: TextStyle(
                            fontSize: 16,
                            color: Colors.grey.shade400,
                          ),
                        ),
                        GestureDetector(
                          onTap: widget.onShowLogin,
                          child: Text(
                            'Sign In',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: const Color(0xFF4FBDBA),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ).animate(
                    controller: _animationController,
                    effects: [
                      FadeEffect(duration: 800.ms, delay: 900.ms),
                    ],
                  ),

                  SizedBox(height: size.height * 0.03),

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
                          'assets/Usersignupand login page pics add/images3.jpeg',
                          height: size.height * 0.15,
                          fit: BoxFit.contain,
                          errorBuilder: (context, error, stackTrace) {
                            return Container(
                              height: size.height * 0.15,
                              width: size.width * 0.6,
                              decoration: BoxDecoration(
                                color: const Color(0xFF1A1D24),
                                borderRadius: BorderRadius.circular(10),
                              ),
                              child: Center(
                                child: Icon(
                                  Icons.image_not_supported,
                                  size: 40,
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
    TextInputType? keyboardType,
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
        keyboardType: keyboardType,
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

  Widget _buildSocialIcon(Color color, IconData icon, int index) {
    return GestureDetector(
      onTap: () {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Social login coming soon!'),
            duration: Duration(seconds: 2),
          ),
        );
      },
      child: Container(
        width: 40,
        height: 40,
        decoration: BoxDecoration(
          color: color,
          shape: BoxShape.circle,
        ),
        child: Icon(
          icon,
          color: Colors.white,
          size: 28,
        ),
      ),
    ).animate(
      controller: _animationController,
      effects: [
        FadeEffect(duration: 800.ms, delay: 800.ms + (index * 100).ms),
        ScaleEffect(
          begin: const Offset(0.7, 0.7),
          end: const Offset(1, 1),
          duration: 800.ms,
          delay: 800.ms + (index * 100).ms,
        ),
      ],
    );
  }
}
