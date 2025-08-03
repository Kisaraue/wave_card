class AppUser {
  final String uid;
  final String email;
  final String fullName;
  final String? profileImageUrl;
  final DateTime createdAt;
  final DateTime updatedAt;
  final bool emailVerified;
  final Map<String, dynamic> preferences;

  AppUser({
    required this.uid,
    required this.email,
    required this.fullName,
    this.profileImageUrl,
    required this.createdAt,
    required this.updatedAt,
    this.emailVerified = false,
    Map<String, dynamic>? preferences,
  }) : preferences = preferences ?? {};

  AppUser copyWith({
    String? uid,
    String? email,
    String? fullName,
    String? profileImageUrl,
    DateTime? createdAt,
    DateTime? updatedAt,
    bool? emailVerified,
    Map<String, dynamic>? preferences,
  }) {
    return AppUser(
      uid: uid ?? this.uid,
      email: email ?? this.email,
      fullName: fullName ?? this.fullName,
      profileImageUrl: profileImageUrl ?? this.profileImageUrl,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      emailVerified: emailVerified ?? this.emailVerified,
      preferences: preferences ?? this.preferences,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'uid': uid,
      'email': email,
      'fullName': fullName,
      'profileImageUrl': profileImageUrl,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
      'emailVerified': emailVerified,
      'preferences': preferences,
    };
  }

  factory AppUser.fromJson(Map<String, dynamic> json) {
    return AppUser(
      uid: json['uid'] as String,
      email: json['email'] as String,
      fullName: json['fullName'] as String,
      profileImageUrl: json['profileImageUrl'] as String?,
      createdAt: DateTime.parse(json['createdAt'] as String),
      updatedAt: DateTime.parse(json['updatedAt'] as String),
      emailVerified: json['emailVerified'] as bool? ?? false,
      preferences: Map<String, dynamic>.from(json['preferences'] ?? {}),
    );
  }

  String get initials {
    final names = fullName.trim().split(' ');
    if (names.isEmpty) return '?';
    if (names.length == 1) return names[0][0].toUpperCase();
    return '${names[0][0].toUpperCase()}${names[names.length - 1][0].toUpperCase()}';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is AppUser && other.uid == uid;
  }

  @override
  int get hashCode => uid.hashCode;

  @override
  String toString() {
    return 'AppUser(uid: $uid, email: $email, fullName: $fullName)';
  }
}