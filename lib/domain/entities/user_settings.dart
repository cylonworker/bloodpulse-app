import 'package:equatable/equatable.dart';

enum AppThemeMode { light, dark, oled, system }

enum UnitPreference { mmHg, kPa }

class UserSettings extends Equatable {
  final String id;
  final String userId;
  final bool notificationEnabled;
  final int highBpThresholdSystolic;
  final int highBpThresholdDiastolic;
  final AppThemeMode theme;
  final UnitPreference unitPreference;
  final String? reminderTime;
  final DateTime createdAt;
  final DateTime updatedAt;

  const UserSettings({
    required this.id,
    required this.userId,
    required this.notificationEnabled,
    required this.highBpThresholdSystolic,
    required this.highBpThresholdDiastolic,
    required this.theme,
    required this.unitPreference,
    this.reminderTime,
    required this.createdAt,
    required this.updatedAt,
  });

  factory UserSettings.fromMap(Map<String, dynamic> map) {
    return UserSettings(
      id: map['id'] as String,
      userId: map['user_id'] as String,
      notificationEnabled: map['notification_enabled'] as bool,
      highBpThresholdSystolic: map['high_bp_threshold_systolic'] as int,
      highBpThresholdDiastolic: map['high_bp_threshold_diastolic'] as int,
      theme: AppThemeMode.values.firstWhere(
        (e) => e.name == map['theme'],
        orElse: () => AppThemeMode.system,
      ),
      unitPreference: UnitPreference.values.firstWhere(
        (e) => e.name == map['unit_preference'],
        orElse: () => UnitPreference.mmHg,
      ),
      reminderTime: map['reminder_time'] as String?,
      createdAt: DateTime.parse(map['created_at'] as String),
      updatedAt: DateTime.parse(map['updated_at'] as String),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'user_id': userId,
      'notification_enabled': notificationEnabled,
      'high_bp_threshold_systolic': highBpThresholdSystolic,
      'high_bp_threshold_diastolic': highBpThresholdDiastolic,
      'theme': theme.name,
      'unit_preference': unitPreference.name,
      'reminder_time': reminderTime,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
    };
  }

  UserSettings copyWith({
    String? id,
    String? userId,
    bool? notificationEnabled,
    int? highBpThresholdSystolic,
    int? highBpThresholdDiastolic,
    AppThemeMode? theme,
    UnitPreference? unitPreference,
    String? reminderTime,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return UserSettings(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      notificationEnabled: notificationEnabled ?? this.notificationEnabled,
      highBpThresholdSystolic: highBpThresholdSystolic ?? this.highBpThresholdSystolic,
      highBpThresholdDiastolic: highBpThresholdDiastolic ?? this.highBpThresholdDiastolic,
      theme: theme ?? this.theme,
      unitPreference: unitPreference ?? this.unitPreference,
      reminderTime: reminderTime ?? this.reminderTime,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  @override
  List<Object?> get props => [
    id, userId, notificationEnabled, highBpThresholdSystolic, 
    highBpThresholdDiastolic, theme, unitPreference, reminderTime, 
    createdAt, updatedAt
  ];
}