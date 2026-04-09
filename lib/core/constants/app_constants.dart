class AppConstants {
  AppConstants._();

  static const String appName = 'BloodPulse';
  static const String appVersion = '1.0.0';

  // Blood Pressure Thresholds (AHA Guidelines)
  static const int systolicNormal = 120;
  static const int systolicElevated = 130;
  static const int systolicHighNormal = 140;
  static const int systolicHypertension1 = 160;
  static const int systolicHypertension2 = 180;

  static const int diastolicNormal = 80;
  static const int diastolicElevated = 85;
  static const int diastolicHighNormal = 90;
  static const int diastolicHypertension1 = 100;
  static const int diastolicHypertension2 = 120;

  // Default Settings
  static const int defaultHighBpSystolic = 140;
  static const int defaultHighBpDiastolic = 90;

  // Database - Supabase Production
  static const String supabaseUrl = 'https://lnafpawzcgsiiffupzvr.supabase.co';
  static const String supabaseAnonKey = 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6ImxuYWZwYXd6Y2dzaWlmZnVwenZyIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NzQzMzg5NjIsImV4cCI6MjA4OTkxNDk2Mn0.q4QbTibFQdYSjLJhYQ3XvYCZxrKi0mffpDs6qE3RDts';

  // Backend API (Vercel)
  static const String apiBaseUrl = 'https://backend-theta-pied.vercel.app';

  // Platform Requirements
  static const int minAndroidSdk = 21;
  static const String minIosVersion = '12.0';
}