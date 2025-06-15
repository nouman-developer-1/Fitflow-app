import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/user_provider.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:intl/intl.dart';
import '../../widgets/optimized_background.dart';
import '../../widgets/hd_background_container.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _nameController;
  late TextEditingController _weightController;
  late TextEditingController _heightController;
  late TextEditingController _ageController;
  String _selectedGoal = 'General Fitness';
  bool _isEditing = false;
  final List<Color> _goalColors = [
    Colors.redAccent,
    Colors.blueAccent,
    Colors.purpleAccent,
    Colors.greenAccent,
    Colors.orangeAccent,
  ];

  final List<String> _fitnessGoals = [
    'Weight Loss',
    'Muscle Gain',
    'Strength Training',
    'General Fitness',
    'Endurance',
  ];

  @override
  void initState() {
    super.initState();
    final userProvider = context.read<UserProvider>();
    _nameController =
        TextEditingController(text: userProvider.userData?['name'] ?? '');
    _weightController =
        TextEditingController(text: userProvider.weight.toString());
    _heightController =
        TextEditingController(text: userProvider.height.toString());
    _ageController = TextEditingController(text: userProvider.age.toString());
    _selectedGoal = userProvider.fitnessGoal;
  }

  @override
  void dispose() {
    _nameController.dispose();
    _weightController.dispose();
    _heightController.dispose();
    _ageController.dispose();
    super.dispose();
  }

  Future<void> _saveChanges() async {
    if (!_formKey.currentState!.validate()) return;

    try {
      await context.read<UserProvider>().updateUserData({
        'name': _nameController.text.trim(),
        'weight': double.parse(_weightController.text),
        'height': double.parse(_heightController.text),
        'age': int.parse(_ageController.text),
        'fitnessGoal': _selectedGoal,
      });

      if (mounted) {
        setState(() => _isEditing = false);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Profile updated successfully'),
            backgroundColor: Colors.green,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.all(Radius.circular(10)),
            ),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error updating profile: $e'),
            backgroundColor: Colors.red,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.all(Radius.circular(10)),
            ),
          ),
        );
      }
    }
  }

  Future<void> _signOut() async {
    try {
      await FirebaseAuth.instance.signOut();
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error signing out: $e'),
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.all(Radius.circular(10)),
            ),
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final userProvider = context.watch<UserProvider>();
    final isLoading = userProvider.isLoading;
    final size = MediaQuery.of(context).size;
    final isTablet = size.width > 600;
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    // Format join date
    final joinDate = userProvider.userData?['createdAt'] != null
        ? DateTime.parse(userProvider.userData!['createdAt'])
        : DateTime.now();
    final joinDateFormatted = DateFormat('MMMM d, y').format(joinDate);

    return Scaffold(
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : CustomScrollView(
              slivers: [
                SliverAppBar(
                  expandedHeight: 200,
                  pinned: true,
                  flexibleSpace: FlexibleSpaceBar(
                    title: Text(
                      _isEditing ? 'Edit Profile' : 'My Profile',
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                    background: Container(
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                          colors: [
                            theme.colorScheme.primary,
                            theme.colorScheme.primaryContainer,
                          ],
                        ),
                      ),
                      child: Stack(
                        children: [
                          Positioned(
                            right: -50,
                            bottom: -10,
                            child: Icon(
                              Icons.fitness_center,
                              size: 180,
                              color: Colors.white.withOpacity(0.1),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  actions: [
                    if (!_isEditing)
                      IconButton(
                        icon: const Icon(Icons.edit, color: Colors.white),
                        onPressed: () => setState(() => _isEditing = true),
                      ),
                    IconButton(
                      icon: const Icon(Icons.logout, color: Colors.white),
                      onPressed: _signOut,
                    ),
                  ],
                ),
                SliverToBoxAdapter(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Profile image and info section
                      Container(
                        padding: const EdgeInsets.symmetric(vertical: 24.0),
                        child: Row(
                          children: [
                            // Profile image
                            Container(
                              width: 80,
                              height: 80,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                border: Border.all(
                                  color: Theme.of(context).colorScheme.primary,
                                  width: 2,
                                ),
                                boxShadow: [
                                  BoxShadow(
                                    color: Theme.of(context)
                                        .colorScheme
                                        .primary
                                        .withOpacity(0.3),
                                    blurRadius: 10,
                                    spreadRadius: 2,
                                  ),
                                ],
                              ),
                              child: ClipOval(
                                child: OptimizedImage(
                                  imagePath:
                                      'assets/images/profile_placeholder.jpg',
                                  width: 80,
                                  height: 80,
                                ),
                              ),
                            )
                                .animate()
                                .fadeIn(duration: 600.ms, curve: Curves.easeOut)
                                .slideX(
                                    begin: -0.2,
                                    end: 0,
                                    duration: 500.ms,
                                    curve: Curves.easeOutQuint),

                            const SizedBox(width: 20),

                            // User info
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    _nameController.text,
                                    style: const TextStyle(
                                      fontSize: 22,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    userProvider.userData?['email'] ?? '',
                                    style: TextStyle(
                                      fontSize: 16,
                                      color: Colors.grey[400],
                                    ),
                                  ),
                                ],
                              )
                                  .animate()
                                  .fadeIn(duration: 600.ms, delay: 100.ms)
                                  .slideX(
                                      begin: 0.2,
                                      end: 0,
                                      duration: 500.ms,
                                      delay: 100.ms),
                            ),
                          ],
                        ),
                      ),

                      // Stats cards
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const SizedBox(height: 16),
                            const Text(
                              'Fitness Statistics',
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 16),
                            // Stats cards grid
                            GridView.count(
                              physics: const NeverScrollableScrollPhysics(),
                              shrinkWrap: true,
                              crossAxisCount: isTablet ? 3 : 2,
                              childAspectRatio: 1.4,
                              crossAxisSpacing: 10,
                              mainAxisSpacing: 10,
                              children: [
                                _buildStatsCard(
                                  title: 'BMI',
                                  value: userProvider.bmi.toStringAsFixed(1),
                                  icon: Icons.monitor_weight,
                                ),
                                _buildStatsCard(
                                  title: 'Weight',
                                  value: '${userProvider.weight} kg',
                                  icon: Icons.fitness_center,
                                ),
                                _buildStatsCard(
                                  title: 'Height',
                                  value: '${userProvider.height} cm',
                                  icon: Icons.height,
                                ),
                                _buildStatsCard(
                                  title: 'Age',
                                  value: '${userProvider.age}',
                                  icon: Icons.cake,
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),

                      // User fitness goal card
                      Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Card(
                          elevation: 4,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
                          ),
                          child: Padding(
                            padding: const EdgeInsets.all(16.0),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text(
                                  'Your Fitness Goal',
                                  style: TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                const SizedBox(height: 12),
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 16,
                                    vertical: 12,
                                  ),
                                  decoration: BoxDecoration(
                                    color: _getGoalColor(_selectedGoal)
                                        .withOpacity(0.2),
                                    borderRadius: BorderRadius.circular(12),
                                    border: Border.all(
                                      color: _getGoalColor(_selectedGoal),
                                      width: 1,
                                    ),
                                  ),
                                  child: Row(
                                    children: [
                                      Icon(
                                        _getGoalIcon(_selectedGoal),
                                        color: _getGoalColor(_selectedGoal),
                                        size: 32,
                                      ),
                                      const SizedBox(width: 16),
                                      Expanded(
                                        child: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            Text(
                                              _selectedGoal,
                                              style: TextStyle(
                                                fontSize: 18,
                                                fontWeight: FontWeight.bold,
                                                color: _getGoalColor(
                                                    _selectedGoal),
                                              ),
                                            ),
                                            const SizedBox(height: 4),
                                            Text(
                                              _getGoalDescription(
                                                  _selectedGoal),
                                              style: const TextStyle(
                                                fontSize: 14,
                                                color: Colors.grey,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),

                      // Edit profile form
                      if (_isEditing)
                        Padding(
                          padding: const EdgeInsets.all(16.0),
                          child: Form(
                            key: _formKey,
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text(
                                  'Edit Profile Information',
                                  style: TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                const SizedBox(height: 16),
                                TextFormField(
                                  controller: _nameController,
                                  decoration: InputDecoration(
                                    labelText: 'Full Name',
                                    prefixIcon: const Icon(Icons.person),
                                    border: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                  ),
                                  validator: (value) {
                                    if (value == null || value.isEmpty) {
                                      return 'Please enter your name';
                                    }
                                    return null;
                                  },
                                ),
                                const SizedBox(height: 16),
                                Row(
                                  children: [
                                    Expanded(
                                      child: TextFormField(
                                        controller: _weightController,
                                        keyboardType: const TextInputType
                                            .numberWithOptions(decimal: true),
                                        decoration: InputDecoration(
                                          labelText: 'Weight (kg)',
                                          prefixIcon:
                                              const Icon(Icons.monitor_weight),
                                          border: OutlineInputBorder(
                                            borderRadius:
                                                BorderRadius.circular(12),
                                          ),
                                        ),
                                        validator: (value) {
                                          if (value == null || value.isEmpty) {
                                            return 'Required';
                                          }
                                          final weight = double.tryParse(value);
                                          if (weight == null ||
                                              weight < 30 ||
                                              weight > 300) {
                                            return 'Invalid weight';
                                          }
                                          return null;
                                        },
                                      ),
                                    ),
                                    const SizedBox(width: 16),
                                    Expanded(
                                      child: TextFormField(
                                        controller: _heightController,
                                        keyboardType: const TextInputType
                                            .numberWithOptions(decimal: true),
                                        decoration: InputDecoration(
                                          labelText: 'Height (cm)',
                                          prefixIcon: const Icon(Icons.height),
                                          border: OutlineInputBorder(
                                            borderRadius:
                                                BorderRadius.circular(12),
                                          ),
                                        ),
                                        validator: (value) {
                                          if (value == null || value.isEmpty) {
                                            return 'Required';
                                          }
                                          final height = double.tryParse(value);
                                          if (height == null ||
                                              height < 100 ||
                                              height > 250) {
                                            return 'Invalid height';
                                          }
                                          return null;
                                        },
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 16),
                                TextFormField(
                                  controller: _ageController,
                                  keyboardType: TextInputType.number,
                                  decoration: InputDecoration(
                                    labelText: 'Age',
                                    prefixIcon:
                                        const Icon(Icons.calendar_today),
                                    border: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                  ),
                                  validator: (value) {
                                    if (value == null || value.isEmpty) {
                                      return 'Required';
                                    }
                                    final age = int.tryParse(value);
                                    if (age == null || age < 13 || age > 100) {
                                      return 'Invalid age';
                                    }
                                    return null;
                                  },
                                ),
                                const SizedBox(height: 16),
                                DropdownButtonFormField<String>(
                                  value: _selectedGoal,
                                  decoration: InputDecoration(
                                    labelText: 'Fitness Goal',
                                    prefixIcon: const Icon(Icons.flag),
                                    border: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                  ),
                                  items: _fitnessGoals.map((String goal) {
                                    return DropdownMenuItem<String>(
                                      value: goal,
                                      child: Text(goal),
                                    );
                                  }).toList(),
                                  onChanged: (String? newValue) {
                                    if (newValue != null) {
                                      setState(() => _selectedGoal = newValue);
                                    }
                                  },
                                ),
                                const SizedBox(height: 24),
                                Row(
                                  children: [
                                    Expanded(
                                      child: OutlinedButton(
                                        onPressed: () {
                                          setState(() => _isEditing = false);
                                          // Reset form
                                          _nameController.text =
                                              userProvider.userData?['name'] ??
                                                  '';
                                          _weightController.text =
                                              userProvider.weight.toString();
                                          _heightController.text =
                                              userProvider.height.toString();
                                          _ageController.text =
                                              userProvider.age.toString();
                                          _selectedGoal =
                                              userProvider.fitnessGoal;
                                        },
                                        style: OutlinedButton.styleFrom(
                                          padding: const EdgeInsets.symmetric(
                                              vertical: 16),
                                          shape: RoundedRectangleBorder(
                                            borderRadius:
                                                BorderRadius.circular(12),
                                          ),
                                        ),
                                        child: const Text('CANCEL'),
                                      ),
                                    ),
                                    const SizedBox(width: 16),
                                    Expanded(
                                      child: ElevatedButton(
                                        onPressed: _saveChanges,
                                        style: ElevatedButton.styleFrom(
                                          backgroundColor:
                                              theme.colorScheme.primary,
                                          foregroundColor: Colors.white,
                                          padding: const EdgeInsets.symmetric(
                                              vertical: 16),
                                          shape: RoundedRectangleBorder(
                                            borderRadius:
                                                BorderRadius.circular(12),
                                          ),
                                        ),
                                        child: const Text('SAVE CHANGES'),
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ).animate().fadeIn().slideY(),
                        ),

                      const SizedBox(height: 40),
                    ],
                  ),
                ),
              ],
            ),
    );
  }

  Widget _buildStatsCard({
    required String title,
    required String value,
    required IconData icon,
  }) {
    return HDBackgroundContainer(
      addAnimation: true,
      borderRadius: 12,
      elevation: 3.0,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(
              icon,
              color: Theme.of(context).colorScheme.primary,
              size: 24,
            ),
            const SizedBox(height: 12),
            Text(
              value,
              style: const TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              title,
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey[400],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Color _getBmiColor(double bmi) {
    if (bmi <= 0) return Colors.grey;
    if (bmi < 18.5) return Colors.blue;
    if (bmi < 25) return Colors.green;
    if (bmi < 30) return Colors.orange;
    return Colors.red;
  }

  Color _getGoalColor(String goal) {
    switch (goal) {
      case 'Weight Loss':
        return Colors.redAccent;
      case 'Muscle Gain':
        return Colors.blueAccent;
      case 'Strength Training':
        return Colors.purpleAccent;
      case 'Endurance':
        return Colors.orangeAccent;
      case 'General Fitness':
      default:
        return Colors.greenAccent;
    }
  }

  IconData _getGoalIcon(String goal) {
    switch (goal) {
      case 'Weight Loss':
        return Icons.trending_down;
      case 'Muscle Gain':
        return Icons.fitness_center;
      case 'Strength Training':
        return Icons.sports_gymnastics;
      case 'Endurance':
        return Icons.directions_run;
      case 'General Fitness':
      default:
        return Icons.favorite;
    }
  }

  String _getGoalDescription(String goal) {
    switch (goal) {
      case 'Weight Loss':
        return 'Focus on cardio and calorie deficit workouts';
      case 'Muscle Gain':
        return 'Focus on strength training and protein intake';
      case 'Strength Training':
        return 'Focus on heavy lifts with moderate reps';
      case 'Endurance':
        return 'Focus on long duration, lower intensity workouts';
      case 'General Fitness':
      default:
        return 'Balanced approach to overall health and fitness';
    }
  }
}
