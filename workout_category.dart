import 'package:flutter/material.dart';
import '../utils/asset_resolver.dart';

enum DifficultyLevel { beginner, intermediate, advanced }

class WorkoutCategory {
  final String name;
  final IconData icon;
  final Color color;
  final String? videoPath;
  final String? imagePath;
  final String description;
  final List<Exercise> exercises;
  final DifficultyLevel difficulty;
  final int estimatedDurationMinutes;
  final int estimatedCaloriesBurn;
  final List<String> targetMuscleGroups;

  WorkoutCategory({
    required this.name,
    required this.icon,
    required this.color,
    this.videoPath,
    this.imagePath,
    required this.description,
    required this.exercises,
    this.difficulty = DifficultyLevel.intermediate,
    this.estimatedDurationMinutes = 30,
    this.estimatedCaloriesBurn = 250,
    this.targetMuscleGroups = const [],
  });

  // Helper method to get proper video path
  String? get resolvedVideoPath =>
      videoPath != null ? AssetResolver.resolveVideoPath(videoPath!) : null;

  // Helper method to get proper image path
  String get resolvedImagePath =>
      imagePath ?? AssetResolver.resolveImagePath(name.toLowerCase());

  static List<WorkoutCategory> getAllCategories() {
    return [
      WorkoutCategory(
        name: 'Chest',
        icon: Icons.fitness_center,
        color: Colors.redAccent,
        videoPath: 'chest',
        imagePath: 'assets/workouts/chest workout pic.jpeg',
        description:
            'Build a stronger, more defined chest with these effective exercises. Our chest workouts focus on developing the pectoral muscles through a combination of pressing and fly movements.',
        exercises: _getChestExercises(),
        difficulty: DifficultyLevel.intermediate,
        estimatedDurationMinutes: 45,
        estimatedCaloriesBurn: 350,
        targetMuscleGroups: [
          'Pectoralis Major',
          'Pectoralis Minor',
          'Anterior Deltoids',
          'Triceps'
        ],
      ),
      WorkoutCategory(
        name: 'Back',
        icon: Icons.accessibility_new,
        color: Colors.purpleAccent,
        videoPath: 'back',
        imagePath: 'assets/workouts/back wokrout pic.jpeg',
        description:
            'Develop a strong, muscular back with these powerful back exercises. Our back workouts target all the major muscles of the back including the lats, rhomboids, and erector spinae.',
        exercises: _getBackExercises(),
        difficulty: DifficultyLevel.intermediate,
        estimatedDurationMinutes: 50,
        estimatedCaloriesBurn: 380,
        targetMuscleGroups: [
          'Latissimus Dorsi',
          'Rhomboids',
          'Trapezius',
          'Erector Spinae'
        ],
      ),
      WorkoutCategory(
        name: 'Arms',
        icon: Icons.sports_gymnastics,
        color: Colors.blueAccent,
        videoPath: 'arms',
        imagePath: 'assets/workouts/Arms workout image.jpeg',
        description:
            'Sculpt impressive arms with these targeted bicep and tricep exercises. Our arm workouts will help you build stronger, more defined arms through a variety of curling and extension movements.',
        exercises: _getArmExercises(),
        difficulty: DifficultyLevel.beginner,
        estimatedDurationMinutes: 35,
        estimatedCaloriesBurn: 280,
        targetMuscleGroups: [
          'Biceps Brachii',
          'Triceps Brachii',
          'Brachialis',
          'Forearms'
        ],
      ),
      WorkoutCategory(
        name: 'Legs',
        icon: Icons.directions_run,
        color: Colors.orangeAccent,
        videoPath: 'legs',
        imagePath: 'assets/workouts/leg workout pic.jpeg',
        description:
            'Build powerful legs with these effective lower body exercises. Our leg workouts focus on developing strength and muscle in your quadriceps, hamstrings, and calves through compound movements.',
        exercises: _getLegExercises(),
        difficulty: DifficultyLevel.intermediate,
        estimatedDurationMinutes: 55,
        estimatedCaloriesBurn: 450,
        targetMuscleGroups: ['Quadriceps', 'Hamstrings', 'Glutes', 'Calves'],
      ),
      WorkoutCategory(
        name: 'Shoulders',
        icon: Icons.sports_martial_arts,
        color: Colors.greenAccent,
        videoPath: 'shoulders',
        imagePath: 'assets/workouts/shoulder workouy.jpeg',
        description:
            'Build impressive shoulders with these targeted deltoid exercises. Our shoulder workouts aim to develop all three heads of the deltoid muscle for balanced, strong shoulders.',
        exercises: _getShoulderExercises(),
        difficulty: DifficultyLevel.intermediate,
        estimatedDurationMinutes: 40,
        estimatedCaloriesBurn: 300,
        targetMuscleGroups: [
          'Anterior Deltoid',
          'Lateral Deltoid',
          'Posterior Deltoid',
          'Trapezius'
        ],
      ),
      WorkoutCategory(
        name: 'Core',
        icon: Icons.flash_on,
        color: Colors.tealAccent,
        videoPath: 'core',
        imagePath: 'assets/workouts/abs wrokout.jpg',
        description:
            'Strengthen your core with these effective abdominal and lower back exercises. A strong core is essential for overall fitness and stability.',
        exercises: _getCoreExercises(),
        difficulty: DifficultyLevel.beginner,
        estimatedDurationMinutes: 30,
        estimatedCaloriesBurn: 250,
        targetMuscleGroups: [
          'Rectus Abdominis',
          'Obliques',
          'Transverse Abdominis',
          'Lower Back'
        ],
      ),
      WorkoutCategory(
        name: 'Cardio',
        icon: Icons.directions_run,
        color: Colors.pinkAccent,
        videoPath: 'cardio',
        imagePath: 'assets/images/fitnessphoto.jpeg',
        description:
            'Boost your heart rate and burn calories with these effective cardio workouts. Our cardio exercises improve endurance and cardiovascular health.',
        exercises: _getCardioExercises(),
        difficulty: DifficultyLevel.beginner,
        estimatedDurationMinutes: 45,
        estimatedCaloriesBurn: 400,
        targetMuscleGroups: ['Heart', 'Lungs', 'Full Body'],
      ),
      WorkoutCategory(
        name: 'Yoga',
        icon: Icons.self_improvement,
        color: Colors.indigoAccent,
        videoPath: 'yoga',
        imagePath: 'assets/images/fitnessphoto1.jpeg',
        description:
            'Improve flexibility, strength, and mindfulness with these yoga flows. Our yoga exercises promote balance between body and mind.',
        exercises: _getYogaExercises(),
        difficulty: DifficultyLevel.beginner,
        estimatedDurationMinutes: 60,
        estimatedCaloriesBurn: 200,
        targetMuscleGroups: ['Full Body', 'Core', 'Balance', 'Flexibility'],
      ),
      WorkoutCategory(
        name: 'HIIT',
        icon: Icons.local_fire_department,
        color: Colors.deepOrangeAccent,
        videoPath: 'hiit',
        imagePath: 'assets/images/fitness3.jpeg',
        description:
            'High-Intensity Interval Training to maximize calorie burn and improve conditioning. These workouts alternate between intense bursts of activity and fixed periods of less-intense activity or rest.',
        exercises: _getHiitExercises(),
        difficulty: DifficultyLevel.advanced,
        estimatedDurationMinutes: 25,
        estimatedCaloriesBurn: 450,
        targetMuscleGroups: [
          'Full Body',
          'Cardiovascular System',
          'Fast-twitch Muscle Fibers'
        ],
      ),
      WorkoutCategory(
        name: 'Functional',
        icon: Icons.sports_handball,
        color: Colors.lightBlue,
        videoPath: 'functional',
        imagePath: 'assets/images/fintessphoto2.jpeg',
        description:
            'Functional training focuses on movements that help in daily activities. These exercises train your muscles to work together and prepare them for daily tasks by simulating common movements.',
        exercises: _getFunctionalExercises(),
        difficulty: DifficultyLevel.intermediate,
        estimatedDurationMinutes: 40,
        estimatedCaloriesBurn: 320,
        targetMuscleGroups: ['Full Body', 'Core', 'Balance', 'Coordination'],
      ),
    ];
  }

  // Helper methods to get exercises by category
  static List<Exercise> _getChestExercises() {
    return [
      Exercise(
        name: 'Bench Press',
        sets: 4,
        reps: '8-12',
        imagePath: 'assets/workouts/chest workout pic.jpeg',
        description:
            'Lie on a flat bench with feet on the ground. Grip the barbell with hands slightly wider than shoulder-width. Lower the bar to your chest and press back up to starting position.',
        tips: 'Keep your back flat on the bench and feet on the floor.',
        difficulty: DifficultyLevel.intermediate,
        targetMuscles: [
          'Pectoralis Major',
          'Pectoralis Minor',
          'Anterior Deltoids',
          'Triceps'
        ],
        equipment: ['Barbell'],
      ),
      Exercise(
        name: 'Incline Dumbbell Press',
        sets: 3,
        reps: '10-12',
        imagePath: 'assets/workouts/chest workout pic.jpeg',
        description:
            'Set an adjustable bench to a 30-45 degree angle. Hold a dumbbell in each hand at shoulder level. Press the weights up until your arms are extended, then lower back down.',
        tips: 'Focus on the upper chest by maintaining proper incline angle.',
        difficulty: DifficultyLevel.intermediate,
        targetMuscles: [
          'Pectoralis Major',
          'Pectoralis Minor',
          'Anterior Deltoids',
          'Triceps'
        ],
        equipment: ['Dumbbell'],
      ),
      Exercise(
        name: 'Cable Fly',
        sets: 3,
        reps: '12-15',
        imagePath: 'assets/images/fitnessphoto.jpeg',
        description:
            'Stand between two cable machines with cables set at chest height. Grab handles with palms facing forward. With a slight bend in the elbows, bring hands together in front of your chest.',
        tips: 'Keep a slight bend in your elbows throughout the movement.',
        difficulty: DifficultyLevel.intermediate,
        targetMuscles: [
          'Pectoralis Major',
          'Pectoralis Minor',
          'Anterior Deltoids',
          'Triceps'
        ],
        equipment: ['Cables'],
      ),
      Exercise(
        name: 'Push-Ups',
        sets: 3,
        reps: '15-20',
        imagePath: 'assets/images/fitnessphoto.jpeg',
        description:
            'Start in a plank position with hands slightly wider than shoulder-width. Lower your body until your chest nearly touches the floor, then push back up.',
        tips: 'Keep your body in a straight line from head to heels.',
        difficulty: DifficultyLevel.beginner,
        targetMuscles: [
          'Pectoralis Major',
          'Pectoralis Minor',
          'Anterior Deltoids',
          'Triceps'
        ],
        equipment: ['None'],
      ),
    ];
  }

  static List<Exercise> _getBackExercises() {
    return [
      Exercise(
        name: 'Pull-Ups',
        sets: 4,
        reps: '8-12',
        imagePath: 'assets/workouts/back wokrout pic.jpeg',
        description:
            'Hang from a pull-up bar with hands slightly wider than shoulder-width. Pull your body up until your chin is over the bar, then lower back down with control.',
        tips: 'Focus on pulling with your back muscles, not your arms.',
        difficulty: DifficultyLevel.intermediate,
        targetMuscles: [
          'Latissimus Dorsi',
          'Rhomboids',
          'Trapezius',
          'Erector Spinae'
        ],
        equipment: ['Pull-up Bar'],
      ),
      Exercise(
        name: 'Bent Over Rows',
        sets: 4,
        reps: '10-12',
        imagePath: 'assets/images/fitness3.jpeg',
        description:
            'Stand with feet shoulder-width apart, holding a barbell. Bend at the hips with a slight knee bend. Pull the bar to your lower chest, then lower it back down.',
        tips: 'Keep your back flat and core engaged throughout the movement.',
        difficulty: DifficultyLevel.intermediate,
        targetMuscles: [
          'Latissimus Dorsi',
          'Rhomboids',
          'Trapezius',
          'Erector Spinae'
        ],
        equipment: ['Barbell'],
      ),
      Exercise(
        name: 'Lat Pulldown',
        sets: 3,
        reps: '10-15',
        imagePath: 'assets/images/fitness3.jpeg',
        description:
            'Sit at a lat pulldown machine with knees secured. Grab the bar with a wide grip. Pull the bar down to your chest, then control it back up.',
        tips: 'Keep your chest up and avoid leaning back excessively.',
        difficulty: DifficultyLevel.intermediate,
        targetMuscles: [
          'Latissimus Dorsi',
          'Rhomboids',
          'Trapezius',
          'Erector Spinae'
        ],
        equipment: ['Lat Pulldown Machine'],
      ),
      Exercise(
        name: 'Single-Arm Dumbbell Row',
        sets: 3,
        reps: '12 per arm',
        imagePath: 'assets/images/fitness3.jpeg',
        description:
            'Place one knee and hand on a bench with the other foot on the floor. Hold a dumbbell in the free hand, pull it up to your hip, then lower it.',
        tips:
            'Keep your back parallel to the floor and pull the weight to your hip.',
        difficulty: DifficultyLevel.intermediate,
        targetMuscles: [
          'Latissimus Dorsi',
          'Rhomboids',
          'Trapezius',
          'Erector Spinae'
        ],
        equipment: ['Dumbbell', 'Bench'],
      ),
    ];
  }

  static List<Exercise> _getArmExercises() {
    return [
      Exercise(
        name: 'Barbell Curl',
        sets: 3,
        reps: '10-12',
        imagePath: 'assets/workouts/Arms workout image.jpeg',
        description:
            'Stand with feet shoulder-width apart, holding a barbell with an underhand grip. Keeping your elbows close to your sides, curl the weight toward your shoulders.',
        tips: 'Avoid swinging your body to lift the weight.',
        difficulty: DifficultyLevel.beginner,
        targetMuscles: [
          'Biceps Brachii',
          'Triceps Brachii',
          'Brachialis',
          'Forearms'
        ],
        equipment: ['Barbell'],
      ),
      Exercise(
        name: 'Tricep Dips',
        sets: 3,
        reps: '12-15',
        imagePath: 'assets/images/fitnessphoto1.jpeg',
        description:
            'Sit on the edge of a bench with hands gripping the edge. Slide your butt off the bench with legs extended. Lower your body by bending your elbows, then push back up.',
        tips: 'Keep your elbows pointing backward, not outward.',
        difficulty: DifficultyLevel.beginner,
        targetMuscles: ['Triceps Brachii', 'Forearms'],
        equipment: ['Bench'],
      ),
      Exercise(
        name: 'Hammer Curls',
        sets: 3,
        reps: '12 per arm',
        imagePath: 'assets/images/fitnessphoto1.jpeg',
        description:
            'Stand holding dumbbells with a neutral grip (palms facing each other). Curl the weights while maintaining the neutral grip.',
        tips:
            'This exercise targets the brachialis and brachioradialis muscles.',
        difficulty: DifficultyLevel.beginner,
        targetMuscles: [
          'Biceps Brachii',
          'Triceps Brachii',
          'Brachialis',
          'Forearms'
        ],
        equipment: ['Dumbbells'],
      ),
      Exercise(
        name: 'Tricep Pushdown',
        sets: 3,
        reps: '12-15',
        imagePath: 'assets/images/fitnessphoto1.jpeg',
        description:
            'Stand facing a cable machine with a rope attachment at head height. Grab the rope with both hands and push down until your arms are fully extended.',
        tips: 'Keep your elbows close to your body throughout the movement.',
        difficulty: DifficultyLevel.beginner,
        targetMuscles: ['Triceps Brachii', 'Forearms'],
        equipment: ['Cable Machine'],
      ),
    ];
  }

  static List<Exercise> _getLegExercises() {
    return [
      Exercise(
        name: 'Squats',
        sets: 4,
        reps: '8-12',
        imagePath: 'assets/workouts/leg workout pic.jpeg',
        description:
            'Stand with feet shoulder-width apart. Bend at the knees and hips as if sitting in a chair, keeping your chest up. Return to standing position.',
        tips:
            'Keep your knees in line with your toes and your weight in your heels.',
        difficulty: DifficultyLevel.intermediate,
        targetMuscles: ['Quadriceps', 'Hamstrings', 'Glutes', 'Calves'],
        equipment: ['None'],
      ),
      Exercise(
        name: 'Romanian Deadlift',
        sets: 3,
        reps: '10-12',
        imagePath: 'assets/images/fintessphoto2.jpeg',
        description:
            'Stand holding a barbell in front of your thighs. Hinge at the hips while keeping your back flat, lowering the bar along your legs. Return to standing position.',
        tips:
            'Focus on the hamstrings and maintain a slight bend in the knees.',
        difficulty: DifficultyLevel.intermediate,
        targetMuscles: ['Hamstrings', 'Glutes'],
        equipment: ['Barbell'],
      ),
      Exercise(
        name: 'Lunges',
        sets: 3,
        reps: '12 per leg',
        imagePath: 'assets/images/fintessphoto2.jpeg',
        description:
            'Stand with feet together. Step forward with one leg and lower your body until both knees are bent at 90 degrees. Push back to starting position.',
        tips: 'Keep your upper body straight and core engaged.',
        difficulty: DifficultyLevel.beginner,
        targetMuscles: ['Quadriceps', 'Hamstrings', 'Glutes', 'Calves'],
        equipment: ['None'],
      ),
      Exercise(
        name: 'Calf Raises',
        sets: 4,
        reps: '15-20',
        imagePath: 'assets/images/fintessphoto2.jpeg',
        description:
            'Stand on the edge of a step with heels hanging off. Rise up onto your toes as high as possible, then lower your heels below the step level.',
        tips:
            'For added resistance, hold dumbbells or use a calf raise machine.',
        difficulty: DifficultyLevel.beginner,
        targetMuscles: ['Calves'],
        equipment: ['None'],
      ),
    ];
  }

  static List<Exercise> _getShoulderExercises() {
    return [
      Exercise(
        name: 'Overhead Press',
        sets: 4,
        reps: '8-10',
        imagePath: 'assets/workouts/shoulder workouy.jpeg',
        description:
            'Stand holding dumbbells at shoulder height. Press the weights overhead until arms are fully extended, then lower back to starting position.',
        tips: 'Avoid arching your back; engage your core for stability.',
        difficulty: DifficultyLevel.intermediate,
        targetMuscles: [
          'Anterior Deltoid',
          'Lateral Deltoid',
          'Posterior Deltoid',
          'Trapezius'
        ],
        equipment: ['Dumbbells'],
      ),
      Exercise(
        name: 'Lateral Raises',
        sets: 3,
        reps: '12-15',
        imagePath: 'assets/images/fitness_default.jpeg',
        description:
            'Stand holding dumbbells at your sides. Raise the weights out to the sides until arms are parallel to the floor, then lower back down.',
        tips: 'Use lighter weights and focus on proper form.',
        difficulty: DifficultyLevel.beginner,
        targetMuscles: ['Lateral Deltoid'],
        equipment: ['Dumbbells'],
      ),
      Exercise(
        name: 'Front Raises',
        sets: 3,
        reps: '12-15',
        imagePath: 'assets/images/fitness_default.jpeg',
        description:
            'Stand holding dumbbells in front of your thighs. Raise the weights straight in front of you to shoulder height, then lower back down.',
        tips: 'Keep your core engaged and avoid using momentum.',
        difficulty: DifficultyLevel.beginner,
        targetMuscles: [
          'Anterior Deltoid',
          'Lateral Deltoid',
          'Posterior Deltoid',
          'Trapezius'
        ],
        equipment: ['Dumbbells'],
      ),
      Exercise(
        name: 'Reverse Fly',
        sets: 3,
        reps: '15',
        imagePath: 'assets/images/fitness_default.jpeg',
        description:
            'Bend at the hips with dumbbells hanging down. With a slight bend in the elbows, raise the weights out to the sides, squeezing your shoulder blades together.',
        tips: 'Focus on the rear deltoids and keep your back flat.',
        difficulty: DifficultyLevel.beginner,
        targetMuscles: ['Rear Deltoid'],
        equipment: ['Dumbbells'],
      ),
    ];
  }

  static List<Exercise> _getCoreExercises() {
    return [
      Exercise(
        name: 'Plank',
        sets: 3,
        reps: '30-60 sec',
        imagePath: 'assets/images/fitness3.jpeg',
        description:
            'Start in a push-up position but with your weight on your forearms. Keep your body in a straight line from head to heels.',
        tips: 'Engage your core and don\'t let your hips sag or pike up.',
        difficulty: DifficultyLevel.beginner,
        targetMuscles: [
          'Rectus Abdominis',
          'Obliques',
          'Transverse Abdominis',
          'Lower Back'
        ],
        equipment: ['None'],
      ),
      Exercise(
        name: 'Russian Twists',
        sets: 3,
        reps: '20 (10 each side)',
        imagePath: 'assets/images/fitness3.jpeg',
        description:
            'Sit on the floor with knees bent and feet lifted. Lean back slightly, keeping your back straight. Twist your torso to the right, then to the left.',
        tips: 'For added difficulty, hold a weight or medicine ball.',
        difficulty: DifficultyLevel.intermediate,
        targetMuscles: [
          'Rectus Abdominis',
          'Obliques',
          'Transverse Abdominis',
          'Lower Back'
        ],
        equipment: ['None'],
      ),
      Exercise(
        name: 'Bicycle Crunches',
        sets: 3,
        reps: '20 (10 each side)',
        imagePath: 'assets/images/fitness3.jpeg',
        description:
            'Lie on your back with hands behind your head. Lift shoulders and bring right elbow to left knee while extending right leg. Switch sides in a pedaling motion.',
        tips:
            'Focus on the rotation and keep your lower back pressed into the floor.',
        difficulty: DifficultyLevel.beginner,
        targetMuscles: [
          'Rectus Abdominis',
          'Obliques',
          'Transverse Abdominis',
          'Lower Back'
        ],
        equipment: ['None'],
      ),
      Exercise(
        name: 'Leg Raises',
        sets: 3,
        reps: '15',
        imagePath: 'assets/images/fitness3.jpeg',
        description:
            'Lie on your back with legs extended and hands at your sides or under your lower back. Lift your legs to a 90-degree angle, then lower them back down without touching the floor.',
        tips:
            'Keep your lower back pressed into the floor throughout the movement.',
        difficulty: DifficultyLevel.beginner,
        targetMuscles: [
          'Rectus Abdominis',
          'Obliques',
          'Transverse Abdominis',
          'Lower Back'
        ],
        equipment: ['None'],
      ),
    ];
  }

  static List<Exercise> _getCardioExercises() {
    return [
      Exercise(
        name: 'High Knees',
        sets: 3,
        reps: '45 seconds',
        imagePath: 'assets/images/fitnessphoto.jpeg',
        description:
            'Stand in place, running by bringing your knees up to hip level with each step. Pump your arms to increase intensity.',
        tips: 'Focus on quick movements and keeping your core engaged.',
        difficulty: DifficultyLevel.beginner,
        targetMuscles: ['Quadriceps', 'Glutes', 'Calves'],
        equipment: ['None'],
      ),
      Exercise(
        name: 'Jumping Jacks',
        sets: 3,
        reps: '60 seconds',
        imagePath: 'assets/images/fitnessphoto.jpeg',
        description:
            'Stand with feet together and arms at your sides. Jump while spreading legs and raising arms overhead, then return to starting position.',
        tips: 'Maintain a consistent rhythm and keep your core engaged.',
        difficulty: DifficultyLevel.beginner,
        targetMuscles: ['Quadriceps', 'Glutes', 'Calves'],
        equipment: ['None'],
      ),
      Exercise(
        name: 'Burpees',
        sets: 3,
        reps: '12-15',
        imagePath: 'assets/images/fitnessphoto.jpeg',
        description:
            'Start standing, then squat down and place hands on floor. Jump feet back to plank, perform a push-up, jump feet back to hands, then explosively jump up.',
        tips:
            'For an easier version, step back instead of jumping and omit the push-up.',
        difficulty: DifficultyLevel.beginner,
        targetMuscles: ['Quadriceps', 'Glutes', 'Calves'],
        equipment: ['None'],
      ),
      Exercise(
        name: 'Mountain Climbers',
        sets: 3,
        reps: '45 seconds',
        imagePath: 'assets/images/fitnessphoto.jpeg',
        description:
            'Start in a plank position. Alternately drive each knee toward your chest in a running motion.',
        tips: 'Keep your hips down and core tight throughout the movement.',
        difficulty: DifficultyLevel.beginner,
        targetMuscles: ['Quadriceps', 'Glutes', 'Calves'],
        equipment: ['None'],
      ),
    ];
  }

  static List<Exercise> _getYogaExercises() {
    return [
      Exercise(
        name: 'Downward Dog',
        sets: 1,
        reps: '30-60 seconds',
        imagePath: 'assets/images/fitnessphoto1.jpeg',
        description:
            'Start on hands and knees, then lift hips up and back to form an inverted V. Press heels toward the floor and relax your head between your arms.',
        tips: 'Bend your knees if needed to maintain a flat back.',
        difficulty: DifficultyLevel.beginner,
        targetMuscles: [
          'Anterior Deltoid',
          'Lateral Deltoid',
          'Posterior Deltoid',
          'Trapezius'
        ],
        equipment: ['None'],
      ),
      Exercise(
        name: 'Warrior II',
        sets: 1,
        reps: '30 seconds each side',
        imagePath: 'assets/images/fitnessphoto1.jpeg',
        description:
            'Step feet wide apart. Turn right foot out 90° and left foot in slightly. Bend right knee over ankle while extending arms parallel to floor.',
        tips: 'Keep your shoulders relaxed and gaze over your front hand.',
        difficulty: DifficultyLevel.beginner,
        targetMuscles: [
          'Anterior Deltoid',
          'Lateral Deltoid',
          'Posterior Deltoid',
          'Trapezius'
        ],
        equipment: ['None'],
      ),
      Exercise(
        name: 'Tree Pose',
        sets: 1,
        reps: '30 seconds each side',
        imagePath: 'assets/images/fitnessphoto1.jpeg',
        description:
            'Stand on one leg, place the sole of your other foot on your inner thigh or calf (not on knee). Bring hands to prayer position or extend overhead.',
        tips: 'Focus on a fixed point to help with balance.',
        difficulty: DifficultyLevel.beginner,
        targetMuscles: [
          'Anterior Deltoid',
          'Lateral Deltoid',
          'Posterior Deltoid',
          'Trapezius'
        ],
        equipment: ['None'],
      ),
      Exercise(
        name: 'Bridge Pose',
        sets: 1,
        reps: '45 seconds',
        imagePath: 'assets/images/fitnessphoto1.jpeg',
        description:
            'Lie on your back with knees bent and feet flat on floor. Press into feet to lift hips, clasping hands under your back if possible.',
        tips: 'Keep your thighs parallel and engage your glutes.',
        difficulty: DifficultyLevel.beginner,
        targetMuscles: [
          'Glutes',
          'Hamstrings',
          'Rectus Abdominis',
          'Lower Back'
        ],
        equipment: ['None'],
      ),
    ];
  }

  static List<Exercise> _getHiitExercises() {
    return [
      Exercise(
        name: 'Burpees',
        sets: 4,
        reps: '30 seconds',
        imagePath: 'assets/images/fitness3.jpeg',
        description:
            'Start standing, then squat down and place hands on floor. Jump feet back to plank, perform a push-up, jump feet back to hands, then explosively jump up.',
        tips:
            'Maintain a fast pace but keep proper form. Rest for 15 seconds between each set.',
        difficulty: DifficultyLevel.advanced,
        targetMuscles: ['Full Body', 'Core', 'Legs', 'Chest'],
        equipment: ['None'],
      ),
      Exercise(
        name: 'Mountain Climbers',
        sets: 4,
        reps: '45 seconds',
        imagePath: 'assets/images/fitness3.jpeg',
        description:
            'Start in a plank position. Alternately drive each knee toward your chest in a running motion.',
        tips: 'Move as quickly as possible while maintaining a stable core.',
        difficulty: DifficultyLevel.intermediate,
        targetMuscles: ['Core', 'Shoulders', 'Hip Flexors'],
        equipment: ['None'],
      ),
      Exercise(
        name: 'Kettlebell Swings',
        sets: 4,
        reps: '30 seconds',
        imagePath: 'assets/images/fitness3.jpeg',
        description:
            'Stand with feet shoulder-width apart holding a kettlebell with both hands. Hinge at the hips to swing the kettlebell between your legs, then thrust hips forward to swing it up to chest height.',
        tips:
            'The power should come from your hips, not your arms or shoulders.',
        difficulty: DifficultyLevel.intermediate,
        targetMuscles: ['Glutes', 'Hamstrings', 'Core', 'Shoulders'],
        equipment: ['Kettlebell'],
      ),
      Exercise(
        name: 'Box Jumps',
        sets: 4,
        reps: '30 seconds',
        imagePath: 'assets/images/fitness3.jpeg',
        description:
            'Stand in front of a sturdy box or platform. Bend your knees and jump onto the box, landing softly. Step back down and repeat.',
        tips: 'Land softly with bent knees to protect your joints.',
        difficulty: DifficultyLevel.advanced,
        targetMuscles: ['Quads', 'Glutes', 'Calves', 'Core'],
        equipment: ['Box or Platform'],
      ),
    ];
  }

  static List<Exercise> _getFunctionalExercises() {
    return [
      Exercise(
        name: 'Kettlebell Turkish Get-Up',
        sets: 3,
        reps: '5 per side',
        imagePath: 'assets/images/fitnessphoto.jpeg',
        description:
            'Lie on your back holding a kettlebell in one hand extended above your chest. Keep your eyes on the weight as you get up from the floor to a standing position, then reverse the movement back to the floor.',
        tips: 'Start with a light weight until you master the technique.',
        difficulty: DifficultyLevel.advanced,
        targetMuscles: ['Full Body', 'Core', 'Shoulders', 'Hips'],
        equipment: ['Kettlebell'],
      ),
      Exercise(
        name: 'Medicine Ball Slams',
        sets: 3,
        reps: '12-15',
        imagePath: 'assets/images/fitnessphoto.jpeg',
        description:
            'Stand with feet shoulder-width apart holding a medicine ball. Raise the ball overhead, then forcefully slam it to the ground, catching it on the bounce.',
        tips:
            'Use your entire body, engaging your core and using your arms as if throwing.',
        difficulty: DifficultyLevel.intermediate,
        targetMuscles: ['Core', 'Shoulders', 'Arms', 'Back'],
        equipment: ['Medicine Ball'],
      ),
      Exercise(
        name: 'TRX Rows',
        sets: 3,
        reps: '12-15',
        imagePath: 'assets/images/fitnessphoto.jpeg',
        description:
            'Hold TRX handles with arms extended and lean back. Pull your body up by bending your elbows and squeezing your shoulder blades together.',
        tips:
            'Adjust the angle of your body to increase or decrease difficulty.',
        difficulty: DifficultyLevel.intermediate,
        targetMuscles: ['Back', 'Biceps', 'Core'],
        equipment: ['TRX Suspension Trainer'],
      ),
      Exercise(
        name: 'Battle Ropes',
        sets: 3,
        reps: '30 seconds',
        imagePath: 'assets/images/fitnessphoto.jpeg',
        description:
            'Hold one end of a battle rope in each hand. Create waves, slams, or circles with the ropes while maintaining a squat position.',
        tips:
            'Keep your core engaged and knees slightly bent throughout the movement.',
        difficulty: DifficultyLevel.intermediate,
        targetMuscles: ['Shoulders', 'Arms', 'Core', 'Legs'],
        equipment: ['Battle Ropes'],
      ),
    ];
  }

  static String? getVideoPathFromCategory(String categoryName) {
    final category = getAllCategories().firstWhere(
        (c) => c.name.toLowerCase() == categoryName.toLowerCase(),
        orElse: () => getAllCategories()[0]);

    return category.videoPath;
  }

  static String? sanitizeVideoPath(String? path) {
    if (path == null) return null;
    return path;
  }

  static WorkoutCategory getCategoryByName(String name) {
    try {
      return getAllCategories().firstWhere(
        (category) => category.name.toLowerCase() == name.toLowerCase(),
      );
    } catch (e) {
      debugPrint('Category not found: $name, using default');
      return getAllCategories()[0];
    }
  }

  bool get hasVideo => videoPath != null && videoPath!.isNotEmpty;

  // Create a default category for fallback when none is found
  static WorkoutCategory createDefaultCategory(
      String categoryType, String title) {
    Color defaultColor = Colors.orangeAccent;
    String defaultDescription =
        'A workout designed to improve your fitness level.';
    IconData defaultIcon = Icons.fitness_center;

    // Attempt to standardize category type for matching
    final String normalizedType = categoryType.toLowerCase().trim();

    // Match common workout types to appropriate colors and icons
    if (normalizedType.contains('chest')) {
      defaultColor = Colors.redAccent;
      defaultIcon = Icons.fitness_center;
      defaultDescription =
          'Build a stronger, more defined chest with these effective exercises.';
    } else if (normalizedType.contains('back')) {
      defaultColor = Colors.purpleAccent;
      defaultIcon = Icons.accessibility_new;
      defaultDescription =
          'Develop a strong, muscular back with these powerful back exercises.';
    } else if (normalizedType.contains('arm')) {
      defaultColor = Colors.blueAccent;
      defaultIcon = Icons.sports_gymnastics;
      defaultDescription =
          'Sculpt impressive arms with these targeted bicep and tricep exercises.';
    } else if (normalizedType.contains('leg')) {
      defaultColor = Colors.orangeAccent;
      defaultIcon = Icons.directions_run;
      defaultDescription =
          'Build powerful legs with these effective lower body exercises.';
    } else if (normalizedType.contains('cardio')) {
      defaultColor = Colors.pinkAccent;
      defaultIcon = Icons.directions_run;
      defaultDescription =
          'Boost your heart rate and burn calories with these effective cardio workouts.';
    } else if (normalizedType.contains('full')) {
      defaultColor = Colors.tealAccent;
      defaultIcon = Icons.accessibility_new;
      defaultDescription =
          'A complete workout targeting all major muscle groups.';
    }

    return WorkoutCategory(
      name: title,
      icon: defaultIcon,
      color: defaultColor,
      videoPath: categoryType.toLowerCase(),
      imagePath: AssetResolver.resolveImagePath(categoryType.toLowerCase()),
      description: defaultDescription,
      exercises: [], // No exercises by default
      difficulty: DifficultyLevel.intermediate,
      estimatedDurationMinutes: 30,
      estimatedCaloriesBurn: 300,
      targetMuscleGroups: ['Full Body'],
    );
  }
}

class Exercise {
  final String name;
  final int sets;
  final String reps;
  final String? imagePath;
  final String description;
  final String tips;
  final DifficultyLevel difficulty;
  final List<String> targetMuscles;
  final List<String> equipment;

  Exercise({
    required this.name,
    required this.sets,
    required this.reps,
    this.imagePath,
    required this.description,
    required this.tips,
    this.difficulty = DifficultyLevel.intermediate,
    this.targetMuscles = const [],
    this.equipment = const [],
  });
}
