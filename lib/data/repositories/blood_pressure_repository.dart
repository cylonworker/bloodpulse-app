import 'package:supabase_flutter/supabase_flutter.dart';
import '../../domain/entities/blood_pressure_reading.dart';

abstract class BloodPressureRepository {
  Future<List<BloodPressureReading>> getReadings(String userId, {DateTime? startDate, DateTime? endDate});
  Future<BloodPressureReading> addReading(BloodPressureReading reading);
  Future<BloodPressureReading> updateReading(String id, BloodPressureReading reading);
  Future<void> deleteReading(String id);
  Future<List<BloodPressureReading>> getWeeklyTrend(String userId);
}

class BloodPressureRepositoryImpl implements BloodPressureRepository {
  final SupabaseClient _supabase;
  
  BloodPressureRepositoryImpl(this._supabase);

  @override
  Future<List<BloodPressureReading>> getReadings(String userId, {DateTime? startDate, DateTime? endDate}) async {
    // Build filters list for the query
    final filters = <String>[];
    filters.add('user_id.eq.$userId');
    
    if (startDate != null) {
      filters.add('reading_date.gte.${startDate.toIso8601String()}');
    }
    if (endDate != null) {
      filters.add('reading_date.lte.${endDate.toIso8601String()}');
    }

    final data = await _supabase
        .from('blood_pressure_readings')
        .select()
        .eq('user_id', userId)
        .order('reading_date', ascending: false);

    return (data as List).map((json) => BloodPressureReading.fromMap(json)).toList();
  }

  @override
  Future<BloodPressureReading> addReading(BloodPressureReading reading) async {
    final data = await _supabase
        .from('blood_pressure_readings')
        .insert(reading.toMap())
        .select()
        .single();
    return BloodPressureReading.fromMap(data);
  }

  @override
  Future<BloodPressureReading> updateReading(String id, BloodPressureReading reading) async {
    final data = await _supabase
        .from('blood_pressure_readings')
        .update(reading.toMap())
        .eq('id', id)
        .select()
        .single();
    return BloodPressureReading.fromMap(data);
  }

  @override
  Future<void> deleteReading(String id) async {
    await _supabase.from('blood_pressure_readings').delete().eq('id', id);
  }

  @override
  Future<List<BloodPressureReading>> getWeeklyTrend(String userId) async {
    final now = DateTime.now();
    final weekAgo = now.subtract(const Duration(days: 7));
    
    return getReadings(userId, startDate: weekAgo, endDate: now);
  }
}