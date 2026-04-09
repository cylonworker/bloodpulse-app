import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import '../../../domain/entities/user_settings.dart';

abstract class SettingsEvent extends Equatable {
  @override
  List<Object?> get props => [];
}

class SettingsLoadRequested extends SettingsEvent {
  final String userId;
  SettingsLoadRequested(this.userId);
  @override
  List<Object?> get props => [userId];
}

class SettingsUpdateRequested extends SettingsEvent {
  final UserSettings settings;
  SettingsUpdateRequested(this.settings);
  @override
  List<Object?> get props => [settings];
}

abstract class SettingsState extends Equatable {
  @override
  List<Object?> get props => [];
}

class SettingsInitial extends SettingsState {}
class SettingsLoading extends SettingsState {}

class SettingsLoaded extends SettingsState {
  final UserSettings settings;
  SettingsLoaded(this.settings);
  @override
  List<Object?> get props => [settings];
}

class SettingsError extends SettingsState {
  final String message;
  SettingsError(this.message);
  @override
  List<Object?> get props => [message];
}

class SettingsBloc extends Bloc<SettingsEvent, SettingsState> {
  SettingsBloc() : super(SettingsInitial()) {
    on<SettingsLoadRequested>(_onLoad);
    on<SettingsUpdateRequested>(_onUpdate);
  }

  Future<void> _onLoad(SettingsLoadRequested event, Emitter<SettingsState> emit) async {
    emit(SettingsLoading());
    // Default settings (would load from repository in full impl)
    final now = DateTime.now();
    emit(SettingsLoaded(UserSettings(
      id: '',
      userId: event.userId,
      notificationEnabled: true,
      highBpThresholdSystolic: 140,
      highBpThresholdDiastolic: 90,
      theme: AppThemeMode.system,
      unitPreference: UnitPreference.mmHg,
      createdAt: now,
      updatedAt: now,
    )));
  }

  Future<void> _onUpdate(SettingsUpdateRequested event, Emitter<SettingsState> emit) async {
    emit(SettingsLoaded(event.settings));
  }
}