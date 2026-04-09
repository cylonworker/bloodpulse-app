import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:uuid/uuid.dart';
import '../../../domain/entities/blood_pressure_reading.dart';
import '../../../data/repositories/blood_pressure_repository.dart';

// Events
abstract class BloodPressureEvent extends Equatable {
  @override
  List<Object?> get props => [];
}

class BloodPressureLoadRequested extends BloodPressureEvent {
  final String userId;
  final DateTime? startDate;
  final DateTime? endDate;

  BloodPressureLoadRequested({required this.userId, this.startDate, this.endDate});

  @override
  List<Object?> get props => [userId, startDate, endDate];
}

class BloodPressureAddRequested extends BloodPressureEvent {
  final String userId;
  final int systolic;
  final int diastolic;
  final int? pulse;
  final String? notes;
  final DateTime? readingDate;

  BloodPressureAddRequested({
    required this.userId,
    required this.systolic,
    required this.diastolic,
    this.pulse,
    this.notes,
    this.readingDate,
  });

  @override
  List<Object?> get props => [userId, systolic, diastolic, pulse, notes, readingDate];
}

class BloodPressureUpdateRequested extends BloodPressureEvent {
  final String id;
  final int systolic;
  final int diastolic;
  final int? pulse;
  final String? notes;
  final DateTime? readingDate;

  BloodPressureUpdateRequested({
    required this.id,
    required this.systolic,
    required this.diastolic,
    this.pulse,
    this.notes,
    this.readingDate,
  });

  @override
  List<Object?> get props => [id, systolic, diastolic, pulse, notes, readingDate];
}

class BloodPressureDeleteRequested extends BloodPressureEvent {
  final String id;

  BloodPressureDeleteRequested(this.id);

  @override
  List<Object?> get props => [id];
}

class BloodPressureWeeklyTrendRequested extends BloodPressureEvent {
  final String userId;

  BloodPressureWeeklyTrendRequested(this.userId);

  @override
  List<Object?> get props => [userId];
}

// States
abstract class BloodPressureState extends Equatable {
  @override
  List<Object?> get props => [];
}

class BloodPressureInitial extends BloodPressureState {}

class BloodPressureLoading extends BloodPressureState {}

class BloodPressureLoaded extends BloodPressureState {
  final List<BloodPressureReading> readings;
  final BloodPressureReading? latestReading;

  BloodPressureLoaded(this.readings) : latestReading = readings.isNotEmpty ? readings.first : null;

  @override
  List<Object?> get props => [readings];
}

class BloodPressureError extends BloodPressureState {
  final String message;

  BloodPressureError(this.message);

  @override
  List<Object?> get props => [message];
}

class BloodPressureOperationSuccess extends BloodPressureState {
  final String message;

  BloodPressureOperationSuccess(this.message);

  @override
  List<Object?> get props => [message];
}

// BLoC
class BloodPressureBloc extends Bloc<BloodPressureEvent, BloodPressureState> {
  final BloodPressureRepository _repository;
  final Uuid _uuid = const Uuid();
  String? _currentUserId;

  BloodPressureBloc(this._repository) : super(BloodPressureInitial()) {
    on<BloodPressureLoadRequested>(_onLoadRequested);
    on<BloodPressureAddRequested>(_onAddRequested);
    on<BloodPressureUpdateRequested>(_onUpdateRequested);
    on<BloodPressureDeleteRequested>(_onDeleteRequested);
    on<BloodPressureWeeklyTrendRequested>(_onWeeklyTrendRequested);
  }

  Future<void> _onLoadRequested(
    BloodPressureLoadRequested event,
    Emitter<BloodPressureState> emit,
  ) async {
    emit(BloodPressureLoading());
    _currentUserId = event.userId;
    try {
      final readings = await _repository.getReadings(
        event.userId,
        startDate: event.startDate,
        endDate: event.endDate,
      );
      emit(BloodPressureLoaded(readings));
    } catch (e) {
      emit(BloodPressureError(e.toString()));
    }
  }

  Future<void> _onAddRequested(
    BloodPressureAddRequested event,
    Emitter<BloodPressureState> emit,
  ) async {
    emit(BloodPressureLoading());
    try {
      final now = DateTime.now();
      final reading = BloodPressureReading(
        id: _uuid.v4(),
        userId: event.userId,
        systolic: event.systolic,
        diastolic: event.diastolic,
        pulse: event.pulse,
        notes: event.notes,
        readingDate: event.readingDate ?? now,
        createdAt: now,
        updatedAt: now,
      );
      await _repository.addReading(reading);
      emit(BloodPressureOperationSuccess('Reading added successfully'));
      if (_currentUserId != null) {
        add(BloodPressureLoadRequested(userId: _currentUserId!));
      }
    } catch (e) {
      emit(BloodPressureError(e.toString()));
    }
  }

  Future<void> _onUpdateRequested(
    BloodPressureUpdateRequested event,
    Emitter<BloodPressureState> emit,
  ) async {
    emit(BloodPressureLoading());
    try {
      final now = DateTime.now();
      final existingReadings = state is BloodPressureLoaded 
          ? (state as BloodPressureLoaded).readings 
          : <BloodPressureReading>[];
      final existing = existingReadings.firstWhere((r) => r.id == event.id);
      
      final updatedReading = existing.copyWith(
        systolic: event.systolic,
        diastolic: event.diastolic,
        pulse: event.pulse,
        notes: event.notes,
        readingDate: event.readingDate,
        updatedAt: now,
      );
      
      await _repository.updateReading(event.id, updatedReading);
      emit(BloodPressureOperationSuccess('Reading updated successfully'));
      if (_currentUserId != null) {
        add(BloodPressureLoadRequested(userId: _currentUserId!));
      }
    } catch (e) {
      emit(BloodPressureError(e.toString()));
    }
  }

  Future<void> _onDeleteRequested(
    BloodPressureDeleteRequested event,
    Emitter<BloodPressureState> emit,
  ) async {
    emit(BloodPressureLoading());
    try {
      await _repository.deleteReading(event.id);
      emit(BloodPressureOperationSuccess('Reading deleted successfully'));
      if (_currentUserId != null) {
        add(BloodPressureLoadRequested(userId: _currentUserId!));
      }
    } catch (e) {
      emit(BloodPressureError(e.toString()));
    }
  }

  Future<void> _onWeeklyTrendRequested(
    BloodPressureWeeklyTrendRequested event,
    Emitter<BloodPressureState> emit,
  ) async {
    emit(BloodPressureLoading());
    try {
      final readings = await _repository.getWeeklyTrend(event.userId);
      emit(BloodPressureLoaded(readings));
    } catch (e) {
      emit(BloodPressureError(e.toString()));
    }
  }
}