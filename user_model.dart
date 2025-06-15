class User {
  final String uid;
  final String email;
  final String? name;

  User({
    required this.uid,
    required this.email,
    this.name,
  });

  Map<String, dynamic> toMap() {
    return {
      'uid': uid,
      'email': email,
      'name': name,
    };
  }

  factory User.fromMap(Map<String, dynamic> map) {
    return User(
      uid: map['uid'] as String,
      email: map['email'] as String,
      name: map['name'] as String?,
    );
  }
}
