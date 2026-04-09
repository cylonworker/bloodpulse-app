import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import '../blocs/auth/auth_bloc.dart';
import '../blocs/blood_pressure/blood_pressure_bloc.dart';
import '../../domain/entities/blood_pressure_reading.dart';
import '../../core/utils/health_status_calculator.dart';

class HistoryPage extends StatefulWidget {
  const HistoryPage({super.key});

  @override
  State<HistoryPage> createState() => _HistoryPageState();
}

class _HistoryPageState extends State<HistoryPage> {
  String _selectedFilter = 'All';
  final List<String> _filters = ['All', 'Today', 'Week', 'Month', 'Year'];

  @override
  void initState() {
    super.initState();
    _loadReadings();
  }

  void _loadReadings() {
    final authState = context.read<AuthBloc>().state;
    if (authState is AuthAuthenticated) {
      context.read<BloodPressureBloc>().add(
        BloodPressureLoadRequested(userId: authState.user.id),
      );
    }
  }

  List<BloodPressureReading> _filterReadings(List<BloodPressureReading> readings) {
    final now = DateTime.now();
    switch (_selectedFilter) {
      case 'Today':
        return readings.where((r) {
          final readingDate = r.readingDate;
          return readingDate.year == now.year && 
                 readingDate.month == now.month && 
                 readingDate.day == now.day;
        }).toList();
      case 'Week':
        final weekAgo = now.subtract(const Duration(days: 7));
        return readings.where((r) => r.readingDate.isAfter(weekAgo)).toList();
      case 'Month':
        final monthAgo = DateTime(now.year, now.month - 1, now.day);
        return readings.where((r) => r.readingDate.isAfter(monthAgo)).toList();
      case 'Year':
        final yearAgo = DateTime(now.year - 1, now.month, now.day);
        return readings.where((r) => r.readingDate.isAfter(yearAgo)).toList();
      default:
        return readings;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('History'),
      ),
      body: Column(
        children: [
          _buildFilterChips(),
          Expanded(
            child: BlocBuilder<BloodPressureBloc, BloodPressureState>(
              builder: (context, state) {
                if (state is BloodPressureLoading) {
                  return const Center(child: CircularProgressIndicator());
                }
                if (state is BloodPressureLoaded) {
                  final filteredReadings = _filterReadings(state.readings);
                  if (filteredReadings.isEmpty) {
                    return _buildEmptyState();
                  }
                  return _buildReadingsList(filteredReadings);
                }
                return const Center(child: Text('No data'));
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFilterChips() {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      padding: const EdgeInsets.all(16),
      child: Row(
        children: _filters.map((filter) {
          final isSelected = _selectedFilter == filter;
          return Padding(
            padding: const EdgeInsets.only(right: 8),
            child: ChoiceChip(
              label: Text(filter),
              selected: isSelected,
              onSelected: (_) => setState(() => _selectedFilter = filter),
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildReadingsList(List<BloodPressureReading> readings) {
    // Group by date
    final grouped = <String, List<BloodPressureReading>>{};
    for (final reading in readings) {
      final dateKey = DateFormat('MMMM d, yyyy').format(reading.readingDate);
      grouped.putIfAbsent(dateKey, () => []).add(reading);
    }

    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      itemCount: grouped.length,
      itemBuilder: (context, index) {
        final date = grouped.keys.elementAt(index);
        final dayReadings = grouped[date]!;

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 8),
              child: Text(
                date,
                style: Theme.of(context).textTheme.titleSmall?.copyWith(
                  color: Colors.grey[600],
                ),
              ),
            ),
            ...dayReadings.map((reading) => _buildReadingItem(reading)),
          ],
        );
      },
    );
  }

  Widget _buildReadingItem(BloodPressureReading reading) {
    final status = HealthStatusCalculator.categorize(reading.systolic, reading.diastolic);
    final timeFormat = DateFormat('h:mm a');

    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: ListTile(
        leading: Container(
          width: 4,
          height: 48,
          decoration: BoxDecoration(
            color: status.color,
            borderRadius: BorderRadius.circular(2),
          ),
        ),
        title: Text(
          '${reading.systolic}/${reading.diastolic} mmHg',
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (reading.pulse != null) Text('Pulse: ${reading.pulse} bpm'),
            Text(timeFormat.format(reading.readingDate)),
            if (reading.notes != null && reading.notes!.isNotEmpty)
              Text(reading.notes!, style: TextStyle(color: Colors.grey[600], fontSize: 12)),
          ],
        ),
        trailing: IconButton(
          icon: const Icon(Icons.delete_outline),
          onPressed: () {
            context.read<BloodPressureBloc>().add(
              BloodPressureDeleteRequested(reading.id),
            );
          },
        ),
        isThreeLine: true,
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.history, size: 64, color: Colors.grey[400]),
          const SizedBox(height: 16),
          const Text('No readings found'),
          const SizedBox(height: 8),
          Text(
            'Try adjusting your filter',
            style: TextStyle(color: Colors.grey[600]),
          ),
        ],
      ),
    );
  }
}