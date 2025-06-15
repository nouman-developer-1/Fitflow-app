import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:confetti/confetti.dart';
import 'dart:math';
import 'package:intl/intl.dart';
import '../../models/workout_category.dart';
import '../../services/workout_tracker_service.dart';
import '../../widgets/premium_background.dart';
import '../../screens/home/home_screen.dart';

class WorkoutCompletionScreen extends StatefulWidget {
  final WorkoutCategory category;
  final Duration duration;
  final int caloriesBurned;

  const WorkoutCompletionScreen({
    super.key,
    required this.category,
    required this.duration,
    required this.caloriesBurned,
  });

  @override
  State<WorkoutCompletionScreen> createState() =>
      _WorkoutCompletionScreenState();
}

class _WorkoutCompletionScreenState extends State<WorkoutCompletionScreen>
    with SingleTickerProviderStateMixin {
  late ConfettiController _confettiController;
  late AnimationController _animationController;
  final WorkoutTrackerService _trackerService = WorkoutTrackerService();
  bool _isSavingWorkout = false;
  bool _workoutSaved = false;
  String? _notes;
  final TextEditingController _notesController = TextEditingController();

  @override
  void initState() {
    super.initState();

    _confettiController = ConfettiController(
      duration: const Duration(seconds: 3),
    );

    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    )..forward();

    // Start confetti animation after a short delay
    Future.delayed(const Duration(milliseconds: 500), () {
      _confettiController.play();
    });
  }

  @override
  void dispose() {
    _confettiController.dispose();
    _animationController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  Future<void> _saveWorkout() async {
    if (_workoutSaved) return;

    setState(() => _isSavingWorkout = true);

    try {
      await _trackerService.recordWorkout(
        category: widget.category,
        duration: widget.duration,
        caloriesBurned: widget.caloriesBurned,
        completedAt: DateTime.now(),
        notes: _notes,
      );

      setState(() {
        _workoutSaved = true;
        _isSavingWorkout = false;
      });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Workout saved successfully!'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      setState(() => _isSavingWorkout = false);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error saving workout: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  void _finishAndGoHome() {
    Navigator.of(context).pushAndRemoveUntil(
      MaterialPageRoute(builder: (context) => const HomeScreen()),
      (route) => false,
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final formatter = NumberFormat('#,###');

    return WillPopScope(
      onWillPop: () async {
        if (!_workoutSaved) {
          final shouldSave = await _showSaveConfirmationDialog();
          if (shouldSave == true) {
            await _saveWorkout();
          }
        }
        return true;
      },
      child: Scaffold(
        body: Stack(
          children: [
            // Background
            PremiumBackground(
              startColor: widget.category.color.withOpacity(0.8),
              endColor: theme.colorScheme.primary,
              child: const SizedBox.expand(),
            ),

            // Confetti overlay
            Align(
              alignment: Alignment.topCenter,
              child: ConfettiWidget(
                confettiController: _confettiController,
                blastDirection: pi / 2, // straight up
                emissionFrequency: 0.8,
                numberOfParticles: 20,
                maxBlastForce: 20,
                minBlastForce: 10,
                gravity: 0.2,
                particleDrag: 0.05,
                colors: const [
                  Colors.green,
                  Colors.blue,
                  Colors.pink,
                  Colors.orange,
                  Colors.purple,
                  Colors.yellow,
                ],
              ),
            ),

            // Main content
            SafeArea(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24.0),
                child: SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      const SizedBox(height: 40),

                      // Success icon and title
                      Icon(
                        Icons.emoji_events,
                        size: 80,
                        color: Colors.amberAccent,
                      ).animate(controller: _animationController).scale(
                            begin: const Offset(0.5, 0.5),
                            end: const Offset(1.0, 1.0),
                            curve: Curves.elasticOut,
                            duration: const Duration(milliseconds: 1000),
                          ),

                      const SizedBox(height: 20),

                      Text(
                        'Workout Complete!',
                        style: theme.textTheme.headlineMedium?.copyWith(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          shadows: [
                            Shadow(
                              color: Colors.black38,
                              blurRadius: 4,
                              offset: const Offset(0, 2),
                            ),
                          ],
                        ),
                        textAlign: TextAlign.center,
                      )
                          .animate(controller: _animationController)
                          .fadeIn(duration: 400.ms, delay: 300.ms)
                          .slideY(
                              begin: 0.3,
                              end: 0,
                              duration: 500.ms,
                              delay: 300.ms),

                      const SizedBox(height: 8),

                      Text(
                        'You\'ve crushed your ${widget.category.name} workout!',
                        style: theme.textTheme.titleMedium?.copyWith(
                          color: Colors.white.withOpacity(0.9),
                        ),
                        textAlign: TextAlign.center,
                      )
                          .animate(controller: _animationController)
                          .fadeIn(duration: 400.ms, delay: 500.ms)
                          .slideY(
                              begin: 0.3,
                              end: 0,
                              duration: 500.ms,
                              delay: 500.ms),

                      const SizedBox(height: 40),

                      // Stats cards
                      Row(
                        children: [
                          Expanded(
                            child: _buildStatCard(
                              Icons.timer,
                              'Duration',
                              _formatDuration(widget.duration),
                              theme,
                              0,
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: _buildStatCard(
                              Icons.local_fire_department,
                              'Calories',
                              formatter.format(widget.caloriesBurned),
                              theme,
                              1,
                            ),
                          ),
                        ],
                      ),

                      const SizedBox(height: 16),

                      // Notes card
                      HDCardBackground(
                        child: Padding(
                          padding: const EdgeInsets.all(16.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Workout Notes',
                                style: theme.textTheme.titleMedium?.copyWith(
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const SizedBox(height: 8),
                              TextField(
                                controller: _notesController,
                                maxLines: 3,
                                decoration: const InputDecoration(
                                  hintText:
                                      'How was your workout? Add notes here...',
                                  border: OutlineInputBorder(),
                                ),
                                onChanged: (value) {
                                  setState(() => _notes = value);
                                },
                              ),
                            ],
                          ),
                        ),
                      )
                          .animate(controller: _animationController)
                          .fadeIn(duration: 400.ms, delay: 900.ms)
                          .slideY(
                              begin: 0.3,
                              end: 0,
                              duration: 500.ms,
                              delay: 900.ms),

                      const SizedBox(height: 32),

                      // Action buttons
                      Row(
                        children: [
                          if (!_workoutSaved)
                            Expanded(
                              child: ElevatedButton.icon(
                                onPressed:
                                    _isSavingWorkout ? null : _saveWorkout,
                                icon: _isSavingWorkout
                                    ? const SizedBox(
                                        width: 20,
                                        height: 20,
                                        child: CircularProgressIndicator(
                                          color: Colors.white,
                                          strokeWidth: 2,
                                        ),
                                      )
                                    : const Icon(Icons.save),
                                label: const Text('SAVE WORKOUT'),
                                style: ElevatedButton.styleFrom(
                                  padding:
                                      const EdgeInsets.symmetric(vertical: 16),
                                  backgroundColor: Colors.green,
                                  foregroundColor: Colors.white,
                                ),
                              )
                                  .animate(controller: _animationController)
                                  .fadeIn(duration: 400.ms, delay: 1100.ms)
                                  .slideY(
                                      begin: 0.3,
                                      end: 0,
                                      duration: 500.ms,
                                      delay: 1100.ms),
                            )
                          else
                            Expanded(
                              child: ElevatedButton.icon(
                                onPressed: null,
                                icon: const Icon(Icons.check_circle),
                                label: const Text('WORKOUT SAVED'),
                                style: ElevatedButton.styleFrom(
                                  backgroundColor:
                                      Colors.green.withOpacity(0.7),
                                  foregroundColor: Colors.white,
                                ),
                              ),
                            ),
                        ],
                      ),

                      const SizedBox(height: 16),

                      OutlinedButton.icon(
                        onPressed: _finishAndGoHome,
                        icon: const Icon(Icons.home),
                        label: const Text('RETURN HOME'),
                        style: OutlinedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 24, vertical: 16),
                          foregroundColor: Colors.white,
                          side: const BorderSide(color: Colors.white),
                        ),
                      )
                          .animate(controller: _animationController)
                          .fadeIn(duration: 400.ms, delay: 1300.ms)
                          .slideY(
                              begin: 0.3,
                              end: 0,
                              duration: 500.ms,
                              delay: 1300.ms),

                      const SizedBox(height: 40),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatCard(
    IconData icon,
    String title,
    String value,
    ThemeData theme,
    int index,
  ) {
    return HDCardBackground(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Icon(
              icon,
              size: 32,
              color: theme.colorScheme.primary,
            ),
            const SizedBox(height: 8),
            Text(
              title,
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              value,
              style: theme.textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
                color: theme.colorScheme.primary,
              ),
            ),
          ],
        ),
      ),
    )
        .animate(controller: _animationController)
        .fadeIn(duration: 400.ms, delay: 700.ms + (index * 100).ms)
        .slideY(
            begin: 0.3,
            end: 0,
            duration: 500.ms,
            delay: 700.ms + (index * 100).ms);
  }

  Future<bool?> _showSaveConfirmationDialog() {
    return showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Save Workout?'),
        content: const Text(
          'Do you want to save this workout to your history?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('NO'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: const Text('YES'),
          ),
        ],
      ),
    );
  }

  String _formatDuration(Duration duration) {
    String twoDigits(int n) => n.toString().padLeft(2, '0');
    String twoDigitMinutes = twoDigits(duration.inMinutes.remainder(60));
    String twoDigitSeconds = twoDigits(duration.inSeconds.remainder(60));
    return '${duration.inHours > 0 ? '${duration.inHours}:' : ''}$twoDigitMinutes:$twoDigitSeconds';
  }
}
