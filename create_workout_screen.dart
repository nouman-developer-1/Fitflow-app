import 'package:flutter/material.dart';
import '../../models/workout_category.dart';

class CreateWorkoutScreen extends StatefulWidget {
  const CreateWorkoutScreen({super.key});

  @override
  State<CreateWorkoutScreen> createState() => _CreateWorkoutScreenState();
}

class _CreateWorkoutScreenState extends State<CreateWorkoutScreen> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _durationController = TextEditingController();

  String _selectedCategory = 'Full Body';
  String _selectedDifficulty = 'Intermediate';

  final List<String> _categories = [
    'Full Body',
    'Chest',
    'Back',
    'Arms',
    'Legs',
    'Shoulders',
    'Core'
  ];

  final List<String> _difficulties = [
    'Beginner',
    'Intermediate',
    'Advanced',
  ];

  @override
  void dispose() {
    _nameController.dispose();
    _durationController.dispose();
    super.dispose();
  }

  // Convert string difficulty to enum if DifficultyLevel exists
  DifficultyLevel? _getDifficultyLevel(String difficulty) {
    try {
      switch (difficulty.toLowerCase()) {
        case 'beginner':
          return DifficultyLevel.beginner;
        case 'intermediate':
          return DifficultyLevel.intermediate;
        case 'advanced':
          return DifficultyLevel.advanced;
        default:
          return DifficultyLevel.intermediate;
      }
    } catch (e) {
      // If enum doesn't exist, return null
      return null;
    }
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Create Workout'),
        backgroundColor: colorScheme.primary,
        foregroundColor: Colors.white,
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            TextFormField(
              controller: _nameController,
              decoration: const InputDecoration(
                labelText: 'Workout Name',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 16),

            // Category selection
            Text('Category', style: Theme.of(context).textTheme.titleMedium),
            Wrap(
              spacing: 8,
              children: _categories.map((category) {
                return ChoiceChip(
                  label: Text(category),
                  selected: _selectedCategory == category,
                  onSelected: (selected) {
                    if (selected) {
                      setState(() => _selectedCategory = category);
                    }
                  },
                );
              }).toList(),
            ),

            const SizedBox(height: 16),

            // Difficulty selection
            Text('Difficulty', style: Theme.of(context).textTheme.titleMedium),
            Wrap(
              spacing: 8,
              children: _difficulties.map((difficulty) {
                return ChoiceChip(
                  label: Text(difficulty),
                  selected: _selectedDifficulty == difficulty,
                  onSelected: (selected) {
                    if (selected) {
                      setState(() => _selectedDifficulty = difficulty);
                    }
                  },
                );
              }).toList(),
            ),

            const SizedBox(height: 16),

            TextFormField(
              controller: _durationController,
              decoration: const InputDecoration(
                labelText: 'Duration (minutes)',
                border: OutlineInputBorder(),
              ),
              keyboardType: TextInputType.number,
            ),

            const SizedBox(height: 32),

            ElevatedButton(
              onPressed: () {
                // Save workout logic would go here
                Navigator.pop(context);
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: colorScheme.primary,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 16),
              ),
              child: const Text('Create Workout'),
            ),
          ],
        ),
      ),
    );
  }
}
