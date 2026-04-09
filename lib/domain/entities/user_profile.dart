import 'package:equatable/equatable.dart';

class UserProfile extends Equatable {
  final String id;
  final String email;
  final String name;
  final String? avatarUrl;
  final DateTime? dateOfBirth;
  final DateTime createdAt;
  final DateTime updatedAt;

  const UserProfile({
    required this.id,
    required this.email,
    required this.name,
    this.avatarUrl,
    this.dateOfBirth,
    required this.createdAt,
    required this.updatedAt,
  });

  factory UserProfile.fromMap(Map<String, dynamic> map) {
    return UserProfile(
      id: map['id'] as String,
      email: map['email'] as String,
      name: map['name'] as String,
      avatarUrl: map['avatar_url'] as String?,
      dateOfBirth: map['date_of_birth'] != null 
          ? DateTime.parse(map['date_of_birth'] as String) 
          : null,
      createdAt: DateTime.parse(map['created_at'] as String),
      updatedAt: DateTime.parse(map['updated_at'] as String),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'email': email,
      'name': name,
      'avatar_url': avatarUrl,
      'date_of_birth': dateOfBirth?.toIso8601String(),
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
    };
  }

  UserProfile copyWith({
    String? id,
    String? email,
    String? name,
    String? avatarUrl,
    DateTime? dateOfBirth,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return UserProfile(
      id: id ?? this.id,
      email: email ?? this.email,
      name: name ?? this.name,
      avatarUrl: avatarUrl ?? this.avatarUrl,
      dateOfBirth: dateOfBirth ?? this.dateOfBirth,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  @override
  List<Object?> get props => [id, email, name, avatarUrl, dateOfBirth, createdAt, updatedAt];
}