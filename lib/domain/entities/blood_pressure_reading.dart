import 'package:equatable/equatable.dart';

class BloodPressureReading extends Equatable {
  final String id;
  final String userId;
  final int systolic;
  final int diastolic;
  final int? pulse;
  final String? notes;
  final DateTime readingDate;
  final DateTime createdAt;
  final DateTime updatedAt;
  final DateTime? syncedAt;

  const BloodPressureReading({
    required this.id,
    required this.userId,
    required this.systolic,
    required this.diastolic,
    this.pulse,
    this.notes,
    required this.readingDate,
    required this.createdAt,
    required this.updatedAt,
    this.syncedAt,
  });

  factory BloodPressureReading.fromMap(Map<String, dynamic> map) {
    return BloodPressureReading(
      id: map['id'] as String,
      userId: map['user_id'] as String,
      systolic: map['systolic'] as int,
      diastolic: map['diastolic'] as int,
      pulse: map['pulse'] as int?,
      notes: map['notes'] as String?,
      readingDate: DateTime.parse(map['reading_date'] as String),
      createdAt: DateTime.parse(map['created_at'] as String),
      updatedAt: DateTime.parse(map['updated_at'] as String),
      syncedAt: map['synced_at'] != null 
          ? DateTime.parse(map['synced_at'] as String) 
          : null,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'user_id': userId,
      'systolic': systolic,
      'diastolic': diastolic,
      'pulse': pulse,
      'notes': notes,
      'reading_date': readingDate.toIso8601String(),
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
      'synced_at': syncedAt?.toIso8601String(),
    };
  }

  BloodPressureReading copyWith({
    String? id,
    String? userId,
    int? systolic,
    int? diastolic,
    int? pulse,
    String? notes,
    DateTime? readingDate,
    DateTime? createdAt,
    DateTime? updatedAt,
    DateTime? syncedAt,
  }) {
    return BloodPressureReading(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      systolic: systolic ?? this.systolic,
      diastolic: diastolic ?? this.diastolic,
      pulse: pulse ?? this.pulse,
      notes: notes ?? this.notes,
      readingDate: readingDate ?? this.readingDate,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      syncedAt: syncedAt ?? this.syncedAt,
    );
  }

  @override
  List<Object?> get props => [id, userId, systolic, diastolic, pulse, notes, readingDate, createdAt, updatedAt, syncedAt];
}