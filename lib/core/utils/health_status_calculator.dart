import 'package:flutter/material.dart';
import '../constants/app_constants.dart';
import '../theme/app_theme.dart';

enum HealthCategory {
  normal,
  elevated,
  highNormal,
  hypertensionStage1,
  hypertensionStage2,
  hypertensiveCrisis,
}

class HealthStatus {
  final HealthCategory category;
  final Color color;
  final String label;
  final String explanation;
  final String recommendation;

  const HealthStatus({
    required this.category,
    required this.color,
    required this.label,
    required this.explanation,
    required this.recommendation,
  });
}

class HealthStatusCalculator {
  HealthStatusCalculator._();

  static HealthStatus categorize(int systolic, int diastolic) {
    // Hypertensive Crisis - Emergency
    if (systolic > AppConstants.systolicHypertension2 || 
        diastolic > AppConstants.diastolicHypertension2) {
      return const HealthStatus(
        category: HealthCategory.hypertensiveCrisis,
        color: AppTheme.healthCrisis,
        label: 'Hypertensive Crisis',
        explanation: 'Your blood pressure is dangerously high (above 180/120 mmHg). This is a medical emergency.',
        recommendation: 'Seek immediate medical attention. Call emergency services now.',
      );
    }

    // Hypertension Stage 2
    if (systolic >= AppConstants.systolicHypertension1 || 
        diastolic >= AppConstants.diastolicHypertension1) {
      return const HealthStatus(
        category: HealthCategory.hypertensionStage2,
        color: AppTheme.healthHypertension2,
        label: 'Hypertension Stage 2',
        explanation: 'Your blood pressure is consistently high (140-179/90-119 mmHg).',
        recommendation: 'Consult your doctor about medication and lifestyle changes. Monitor daily.',
      );
    }

    // Hypertension Stage 1
    if (systolic >= AppConstants.systolicHighNormal || 
        diastolic >= AppConstants.diastolicHighNormal) {
      return const HealthStatus(
        category: HealthCategory.hypertensionStage1,
        color: AppTheme.healthHypertension1,
        label: 'Hypertension Stage 1',
        explanation: 'Your blood pressure is elevated (130-139/80-89 mmHg).',
        recommendation: 'Talk to your doctor about lifestyle modifications. Monitor more frequently.',
      );
    }

    // High Normal
    if (systolic >= AppConstants.systolicElevated || 
        diastolic >= AppConstants.diastolicElevated) {
      return const HealthStatus(
        category: HealthCategory.highNormal,
        color: AppTheme.healthHighNormal,
        label: 'High Normal',
        explanation: 'Your blood pressure is slightly above optimal (120-129/<80 mmHg).',
        recommendation: 'Maintain healthy habits. Check blood pressure regularly.',
      );
    }

    // Elevated
    if (systolic >= AppConstants.systolicNormal) {
      return const HealthStatus(
        category: HealthCategory.elevated,
        color: AppTheme.healthElevated,
        label: 'Elevated',
        explanation: 'Your systolic pressure is slightly elevated (120-129 mmHg with normal diastolic).',
        recommendation: 'Focus on diet and exercise. Recheck in a few months.',
      );
    }

    // Normal
    return const HealthStatus(
      category: HealthCategory.normal,
      color: AppTheme.healthNormal,
      label: 'Normal',
      explanation: 'Your blood pressure is in the healthy range (below 120/80 mmHg).',
      recommendation: 'Keep up the great work! Maintain your healthy lifestyle.',
    );
  }

  static String getCategoryLabel(HealthCategory category) {
    switch (category) {
      case HealthCategory.normal:
        return 'Normal';
      case HealthCategory.elevated:
        return 'Elevated';
      case HealthCategory.highNormal:
        return 'High Normal';
      case HealthCategory.hypertensionStage1:
        return 'Hypertension Stage 1';
      case HealthCategory.hypertensionStage2:
        return 'Hypertension Stage 2';
      case HealthCategory.hypertensiveCrisis:
        return 'Hypertensive Crisis';
    }
  }

  static Color getCategoryColor(HealthCategory category) {
    switch (category) {
      case HealthCategory.normal:
        return AppTheme.healthNormal;
      case HealthCategory.elevated:
        return AppTheme.healthElevated;
      case HealthCategory.highNormal:
        return AppTheme.healthHighNormal;
      case HealthCategory.hypertensionStage1:
        return AppTheme.healthHypertension1;
      case HealthCategory.hypertensionStage2:
        return AppTheme.healthHypertension2;
      case HealthCategory.hypertensiveCrisis:
        return AppTheme.healthCrisis;
    }
  }
}