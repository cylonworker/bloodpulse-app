import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../blocs/auth/auth_bloc.dart';
import '../blocs/blood_pressure/blood_pressure_bloc.dart';

class BpInputDialog extends StatefulWidget {
  const BpInputDialog({super.key});

  @override
  State<BpInputDialog> createState() => _BpInputDialogState();
}

class _BpInputDialogState extends State<BpInputDialog> {
  final _formKey = GlobalKey<FormState>();
  final _systolicController = TextEditingController();
  final _diastolicController = TextEditingController();
  final _pulseController = TextEditingController();
  final _notesController = TextEditingController();
  DateTime _selectedDate = DateTime.now();
  TimeOfDay _selectedTime = TimeOfDay.now();

  @override
  void dispose() {
    _systolicController.dispose();
    _diastolicController.dispose();
    _pulseController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  void _submit() {
    if (_formKey.currentState?.validate() ?? false) {
      final authState = context.read<AuthBloc>().state;
      if (authState is AuthAuthenticated) {
        final readingDate = DateTime(
          _selectedDate.year,
          _selectedDate.month,
          _selectedDate.day,
          _selectedTime.hour,
          _selectedTime.minute,
        );
        
        context.read<BloodPressureBloc>().add(
          BloodPressureAddRequested(
            userId: authState.user.id,
            systolic: int.parse(_systolicController.text),
            diastolic: int.parse(_diastolicController.text),
            pulse: _pulseController.text.isNotEmpty 
                ? int.parse(_pulseController.text) 
                : null,
            notes: _notesController.text.isNotEmpty 
                ? _notesController.text 
                : null,
            readingDate: readingDate,
          ),
        );
        
        Navigator.of(context).pop();
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Reading added successfully')),
        );
      }
    }
  }

  Future<void> _selectDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime(2020),
      lastDate: DateTime.now(),
    );
    if (picked != null) {
      setState(() => _selectedDate = picked);
    }
  }

  Future<void> _selectTime() async {
    final picked = await showTimePicker(
      context: context,
      initialTime: _selectedTime,
    );
    if (picked != null) {
      setState(() => _selectedTime = picked);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Theme.of(context).scaffoldBackgroundColor,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
      ),
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom,
      ),
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Center(
                child: Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: Colors.grey[300],
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              Text(
                'Add Reading',
                style: Theme.of(context).textTheme.titleLarge,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 24),
              Row(
                children: [
                  Expanded(
                    child: TextFormField(
                      controller: _systolicController,
                      decoration: const InputDecoration(
                        labelText: 'Systolic',
                        suffixText: 'mmHg',
                      ),
                      keyboardType: TextInputType.number,
                      inputFormatters: [
                        FilteringTextInputFormatter.digitsOnly,
                        LengthLimitingTextInputFormatter(3),
                      ],
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Required';
                        }
                        final num = int.tryParse(value);
                        if (num == null || num < 60 || num > 300) {
                          return '60-300';
                        }
                        return null;
                      },
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: TextFormField(
                      controller: _diastolicController,
                      decoration: const InputDecoration(
                        labelText: 'Diastolic',
                        suffixText: 'mmHg',
                      ),
                      keyboardType: TextInputType.number,
                      inputFormatters: [
                        FilteringTextInputFormatter.digitsOnly,
                        LengthLimitingTextInputFormatter(3),
                      ],
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Required';
                        }
                        final num = int.tryParse(value);
                        if (num == null || num < 40 || num > 200) {
                          return '40-200';
                        }
                        return null;
                      },
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _pulseController,
                decoration: const InputDecoration(
                  labelText: 'Pulse (optional)',
                  suffixText: 'bpm',
                ),
                keyboardType: TextInputType.number,
                inputFormatters: [
                  FilteringTextInputFormatter.digitsOnly,
                  LengthLimitingTextInputFormatter(3),
                ],
                validator: (value) {
                  if (value != null && value.isNotEmpty) {
                    final num = int.tryParse(value);
                    if (num == null || num < 30 || num > 220) {
                      return '30-220';
                    }
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: _selectDate,
                      icon: const Icon(Icons.calendar_today, size: 18),
                      label: Text(
                        '${_selectedDate.day}/${_selectedDate.month}/${_selectedDate.year}',
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: _selectTime,
                      icon: const Icon(Icons.access_time, size: 18),
                      label: Text(_selectedTime.format(context)),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _notesController,
                decoration: const InputDecoration(
                  labelText: 'Notes (optional)',
                  hintText: 'e.g., After exercise, feeling stressed',
                ),
                maxLines: 2,
                textCapitalization: TextCapitalization.sentences,
              ),
              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: _submit,
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                ),
                child: const Text('Save Reading'),
              ),
              const SizedBox(height: 8),
            ],
          ),
        ),
      ),
    );
  }
}