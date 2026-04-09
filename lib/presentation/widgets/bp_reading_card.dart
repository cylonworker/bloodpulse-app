import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../domain/entities/blood_pressure_reading.dart';
import '../../core/utils/health_status_calculator.dart';

class BpReadingCard extends StatelessWidget {
  final BloodPressureReading reading;
  final VoidCallback? onDelete;
  final VoidCallback? onTap;

  const BpReadingCard({
    super.key,
    required this.reading,
    this.onDelete,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final status = HealthStatusCalculator.categorize(reading.systolic, reading.diastolic);
    final dateFormat = DateFormat('MMM d, h:mm a');

    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              Container(
                width: 4,
                height: 48,
                decoration: BoxDecoration(
                  color: status.color,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Text(
                          '${reading.systolic}/${reading.diastolic}',
                          style: const TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(width: 8),
                        Text(
                          'mmHg',
                          style: TextStyle(
                            color: Colors.grey[600],
                            fontSize: 14,
                          ),
                        ),
                        if (reading.pulse != null) ...[
                          const SizedBox(width: 16),
                          Icon(Icons.favorite_border, size: 16, color: Colors.grey[600]),
                          const SizedBox(width: 4),
                          Text(
                            '${reading.pulse} bpm',
                            style: TextStyle(color: Colors.grey[600], fontSize: 14),
                          ),
                        ],
                      ],
                    ),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        Text(
                          dateFormat.format(reading.readingDate),
                          style: TextStyle(color: Colors.grey[600], fontSize: 12),
                        ),
                        const SizedBox(width: 8),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                          decoration: BoxDecoration(
                            color: status.color.withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Text(
                            status.label,
                            style: TextStyle(
                              color: status.color,
                              fontSize: 10,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                      ],
                    ),
                    if (reading.notes != null && reading.notes!.isNotEmpty) ...[
                      const SizedBox(height: 4),
                      Text(
                        reading.notes!,
                        style: TextStyle(
                          color: Colors.grey[600],
                          fontSize: 12,
                          fontStyle: FontStyle.italic,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ],
                ),
              ),
              if (onDelete != null)
                IconButton(
                  icon: const Icon(Icons.delete_outline, color: Colors.red),
                  onPressed: () {
                    showDialog(
                      context: context,
                      builder: (ctx) => AlertDialog(
                        title: const Text('Delete Reading'),
                        content: const Text('Are you sure you want to delete this reading?'),
                        actions: [
                          TextButton(
                            onPressed: () => Navigator.pop(ctx),
                            child: const Text('Cancel'),
                          ),
                          TextButton(
                            onPressed: () {
                              Navigator.pop(ctx);
                              onDelete?.call();
                            },
                            child: const Text('Delete', style: TextStyle(color: Colors.red)),
                          ),
                        ],
                      ),
                    );
                  },
                ),
            ],
          ),
        ),
      ),
    );
  }
}