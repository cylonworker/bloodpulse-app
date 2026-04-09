import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../blocs/auth/auth_bloc.dart';
import '../blocs/blood_pressure/blood_pressure_bloc.dart';
import '../../core/utils/health_status_calculator.dart';
import '../../domain/entities/blood_pressure_reading.dart';
import '../widgets/bp_input_dialog.dart';
import '../widgets/bp_reading_card.dart';
import '../widgets/bp_chart.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  @override
  void initState() {
    super.initState();
    _loadData();
  }

  void _loadData() {
    final authState = context.read<AuthBloc>().state;
    if (authState is AuthAuthenticated) {
      context.read<BloodPressureBloc>().add(
        BloodPressureLoadRequested(userId: authState.user.id),
      );
    }
  }

  void _showAddReadingDialog() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => const BpInputDialog(),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('BloodPulse'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _loadData,
          ),
        ],
      ),
      body: BlocBuilder<BloodPressureBloc, BloodPressureState>(
        builder: (context, state) {
          if (state is BloodPressureLoading) {
            return const Center(child: CircularProgressIndicator());
          }
          
          if (state is BloodPressureError) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.error_outline, size: 48, color: Colors.red),
                  const SizedBox(height: 16),
                  Text(state.message),
                  const SizedBox(height: 16),
                  ElevatedButton(onPressed: _loadData, child: const Text('Retry')),
                ],
              ),
            );
          }

          if (state is BloodPressureLoaded) {
            return RefreshIndicator(
              onRefresh: () async => _loadData(),
              child: SingleChildScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildCurrentReading(state.latestReading),
                    const SizedBox(height: 24),
                    _buildQuickAddButton(),
                    const SizedBox(height: 24),
                    if (state.readings.isNotEmpty) ...[
                      _buildWeeklyTrend(state.readings),
                      const SizedBox(height: 24),
                      _buildRecentReadings(state.readings),
                    ] else ...[
                      _buildEmptyState(),
                    ],
                  ],
                ),
              ),
            );
          }

          return const Center(child: Text('No data available'));
        },
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _showAddReadingDialog,
        icon: const Icon(Icons.add),
        label: const Text('Add Reading'),
      ),
    );
  }

  Widget _buildCurrentReading(BloodPressureReading? reading) {
    if (reading == null) {
      return Card(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            children: [
              Icon(Icons.monitor_heart, size: 48, color: Colors.grey[400]),
              const SizedBox(height: 16),
              Text(
                'No readings yet',
                style: Theme.of(context).textTheme.titleLarge,
              ),
              const SizedBox(height: 8),
              Text(
                'Add your first blood pressure reading',
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: Colors.grey[600],
                ),
              ),
            ],
          ),
        ),
      );
    }

    final status = HealthStatusCalculator.categorize(reading.systolic, reading.diastolic);

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(Icons.monitor_heart, size: 28),
                const SizedBox(width: 8),
                Text(
                  'Latest Reading',
                  style: Theme.of(context).textTheme.titleMedium,
                ),
                const Spacer(),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: status.color.withValues(alpha: 0.2),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    status.label,
                    style: TextStyle(
                      color: status.color,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                _buildBpValue('Systolic', reading.systolic),
                const SizedBox(width: 32),
                const Text('/', style: TextStyle(fontSize: 32, fontWeight: FontWeight.w300)),
                const SizedBox(width: 32),
                _buildBpValue('Diastolic', reading.diastolic),
              ],
            ),
            if (reading.pulse != null) ...[
              const SizedBox(height: 16),
              Center(
                child: Text(
                  'Pulse: ${reading.pulse} bpm',
                  style: Theme.of(context).textTheme.titleMedium,
                ),
              ),
            ],
            const SizedBox(height: 16),
            const Divider(),
            const SizedBox(height: 8),
            Text(
              status.explanation,
              style: Theme.of(context).textTheme.bodyMedium,
            ),
            if (reading.systolic >= 180 || reading.diastolic >= 120) ...[
              const SizedBox(height: 12),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.red[50],
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.red),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.warning, color: Colors.red),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        status.recommendation,
                        style: const TextStyle(color: Colors.red, fontWeight: FontWeight.w500),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildBpValue(String label, int value) {
    return Column(
      children: [
        Text(
          label,
          style: TextStyle(color: Colors.grey[600], fontSize: 14),
        ),
        const SizedBox(height: 4),
        Text(
          '$value',
          style: const TextStyle(fontSize: 48, fontWeight: FontWeight.bold),
        ),
        Text(
          'mmHg',
          style: TextStyle(color: Colors.grey[600], fontSize: 14),
        ),
      ],
    );
  }

  Widget _buildQuickAddButton() {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton.icon(
        onPressed: _showAddReadingDialog,
        icon: const Icon(Icons.add),
        label: const Text('Quick Add Reading'),
        style: ElevatedButton.styleFrom(
          padding: const EdgeInsets.symmetric(vertical: 16),
        ),
      ),
    );
  }

  Widget _buildWeeklyTrend(List<BloodPressureReading> readings) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Weekly Trend',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 16),
            SizedBox(
              height: 200,
              child: BpChart(readings: readings),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRecentReadings(List<BloodPressureReading> readings) {
    final recentReadings = readings.take(5).toList();
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Recent Readings',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 16),
            ...recentReadings.map((reading) => BpReadingCard(
              reading: reading,
              onDelete: () {
                context.read<BloodPressureBloc>().add(
                  BloodPressureDeleteRequested(reading.id),
                );
              },
            )),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.add_chart, size: 64, color: Colors.grey[400]),
          const SizedBox(height: 16),
          Text(
            'Start tracking your blood pressure',
            style: Theme.of(context).textTheme.titleMedium,
          ),
          const SizedBox(height: 8),
          Text(
            'Tap the button below to add your first reading',
            style: TextStyle(color: Colors.grey[600]),
          ),
        ],
      ),
    );
  }
}