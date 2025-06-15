import 'package:flutter/material.dart';
import '../models/user_model.dart';

class UserProvider with ChangeNotifier {
  User? _user;
  Map<String, dynamic>? _userData;
  bool _isLoading = false;

  UserProvider() {
    // We won't set a default user at startup anymore
    // This way auth screens will appear first
  }

  void setDefaultUser() {
    _user = User(
      uid: 'default-user',
      email: 'ronald.adrian@example.com',
      name: 'Ronald Adrian',
    );
    _loadMockUserData();
  }

  User? get user => _user;
  Map<String, dynamic>? get userData => _userData;
  bool get isLoading => _isLoading;

  void setUser(User? user) {
    _user = user;
    if (user != null) {
      _loadMockUserData(); // Using mock data for now
    } else {
      _userData = null;
    }
    notifyListeners();
  }

  void _loadMockUserData() {
    _userData = {
      'name': _user?.name ?? 'Ronald Adrian',
      'email': _user?.email ?? 'ronald.adrian@example.com',
      'age': 28,
      'weight': 78.0,
      'height': 180.0,
      'fitnessGoal': 'Muscle Gain',
      'createdAt': DateTime.now().toString(),
      'lastLogin': DateTime.now().toString(),
    };
  }

  Future<void> updateUserData(Map<String, dynamic> data) async {
    _isLoading = true;
    notifyListeners();

    try {
      // In a real app, this would update Firebase
      _userData = {...?_userData, ...data};
    } catch (e) {
      debugPrint('Error updating user data: $e');
      rethrow;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  String get userGreeting {
    if (_userData != null && _userData!['name'] != null) {
      return 'Hello, ${_userData!['name'].split(' ')[0]}!';
    }
    return 'Hello, Fitness Enthusiast!';
  }

  String get fitnessGoal => _userData?['fitnessGoal'] ?? 'General Fitness';

  double get weight => _userData?['weight']?.toDouble() ?? 0.0;
  double get height => _userData?['height']?.toDouble() ?? 0.0;
  int get age => _userData?['age'] ?? 0;

  double get bmi {
    if (height <= 0 || weight <= 0) return 0;
    return weight / ((height / 100) * (height / 100));
  }

  String get bmiCategory {
    if (bmi < 18.5) return 'Underweight';
    if (bmi < 25) return 'Normal';
    if (bmi < 30) return 'Overweight';
    return 'Obese';
  }
}
