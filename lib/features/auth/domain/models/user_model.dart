class User {
  final String email;

  User({required this.email});

  factory User.fromJson(Map<String, dynamic> json) {
    return User(email: json['email']);
  }

  Map<String, dynamic> toJson() => {'email': email};
}
