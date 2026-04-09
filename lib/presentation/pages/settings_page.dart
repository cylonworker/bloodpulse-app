import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../blocs/auth/auth_bloc.dart';
import '../blocs/settings/settings_bloc.dart';

class SettingsPage extends StatelessWidget {
  const SettingsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Settings'),
      ),
      body: BlocBuilder<SettingsBloc, SettingsState>(
        builder: (context, state) {
          if (state is SettingsLoading) {
            return const Center(child: CircularProgressIndicator());
          }
          
          if (state is SettingsLoaded) {
            return ListView(
              padding: const EdgeInsets.all(16),
              children: [
                _buildProfileSection(context),
                const SizedBox(height: 24),
                _buildPreferencesSection(context, state),
                const SizedBox(height: 24),
                _buildNotificationsSection(context, state),
                const SizedBox(height: 24),
                _buildAccountSection(context),
              ],
            );
          }
          
          return const Center(child: Text('Failed to load settings'));
        },
      ),
    );
  }

  Widget _buildProfileSection(BuildContext context) {
    return BlocBuilder<AuthBloc, AuthState>(
      builder: (context, state) {
        final name = state is AuthAuthenticated ? state.user.name : 'User';
        final email = state is AuthAuthenticated ? state.user.email : '';
        
        return Card(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                CircleAvatar(
                  radius: 32,
                  backgroundColor: Theme.of(context).colorScheme.primary,
                  child: Text(
                    name.isNotEmpty ? name[0].toUpperCase() : 'U',
                    style: const TextStyle(fontSize: 24, color: Colors.white),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(name, style: Theme.of(context).textTheme.titleLarge),
                      Text(email, style: TextStyle(color: Colors.grey[600])),
                    ],
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.edit),
                  onPressed: () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Profile editing coming soon')),
                    );
                  },
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildPreferencesSection(BuildContext context, SettingsLoaded state) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Preferences', style: Theme.of(context).textTheme.titleMedium),
            const SizedBox(height: 16),
            ListTile(
              leading: const Icon(Icons.palette),
              title: const Text('Theme'),
              subtitle: Text(_getThemeLabel(state.settings.theme.name)),
              trailing: const Icon(Icons.chevron_right),
              onTap: () => _showThemeDialog(context, state),
            ),
            const Divider(),
            ListTile(
              leading: const Icon(Icons.straighten),
              title: const Text('Unit'),
              subtitle: Text(state.settings.unitPreference.name),
              trailing: const Icon(Icons.chevron_right),
              onTap: () => _showUnitDialog(context, state),
            ),
            const Divider(),
            ListTile(
              leading: const Icon(Icons.favorite),
              title: const Text('High BP Threshold'),
              subtitle: Text('${state.settings.highBpThresholdSystolic}/${state.settings.highBpThresholdDiastolic} mmHg'),
              trailing: const Icon(Icons.chevron_right),
              onTap: () => _showThresholdDialog(context, state),
            ),
          ],
        ),
      ),
    );
  }

  String _getThemeLabel(String theme) {
    switch (theme) {
      case 'light': return 'Light';
      case 'dark': return 'Dark';
      case 'oled': return 'OLED Black';
      default: return 'System Default';
    }
  }

  Widget _buildNotificationsSection(BuildContext context, SettingsLoaded state) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Notifications', style: Theme.of(context).textTheme.titleMedium),
            const SizedBox(height: 16),
            SwitchListTile(
              secondary: const Icon(Icons.notifications),
              title: const Text('Push Notifications'),
              subtitle: const Text('Get alerts for high readings'),
              value: state.settings.notificationEnabled,
              onChanged: (value) {
                // Would update settings
              },
            ),
            const Divider(),
            ListTile(
              leading: const Icon(Icons.access_time),
              title: const Text('Reminder Time'),
              subtitle: Text(state.settings.reminderTime ?? 'Not set'),
              trailing: const Icon(Icons.chevron_right),
              enabled: state.settings.notificationEnabled,
              onTap: state.settings.notificationEnabled
                  ? () => _showReminderTimeDialog(context, state)
                  : null,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAccountSection(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Account', style: Theme.of(context).textTheme.titleMedium),
            const SizedBox(height: 16),
            ListTile(
              leading: const Icon(Icons.cloud_sync),
              title: const Text('Cloud Sync'),
              subtitle: const Text('Synced'),
              trailing: Switch(
                value: true,
                onChanged: (value) {},
              ),
            ),
            const Divider(),
            ListTile(
              leading: const Icon(Icons.logout, color: Colors.red),
              title: const Text('Sign Out', style: TextStyle(color: Colors.red)),
              onTap: () => _showSignOutDialog(context),
            ),
          ],
        ),
      ),
    );
  }

  void _showThemeDialog(BuildContext context, SettingsLoaded state) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Select Theme'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            RadioListTile(title: const Text('System Default'), value: 'system', groupValue: state.settings.theme.name, onChanged: (_) {}),
            RadioListTile(title: const Text('Light'), value: 'light', groupValue: state.settings.theme.name, onChanged: (_) {}),
            RadioListTile(title: const Text('Dark'), value: 'dark', groupValue: state.settings.theme.name, onChanged: (_) {}),
            RadioListTile(title: const Text('OLED Black'), value: 'oled', groupValue: state.settings.theme.name, onChanged: (_) {}),
          ],
        ),
      ),
    );
  }

  void _showUnitDialog(BuildContext context, SettingsLoaded state) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Select Unit'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            RadioListTile(title: const Text('mmHg'), value: 'mmHg', groupValue: state.settings.unitPreference.name, onChanged: (_) {}),
            RadioListTile(title: const Text('kPa'), value: 'kPa', groupValue: state.settings.unitPreference.name, onChanged: (_) {}),
          ],
        ),
      ),
    );
  }

  void _showThresholdDialog(BuildContext context, SettingsLoaded state) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Threshold customization coming soon')),
    );
  }

  void _showReminderTimeDialog(BuildContext context, SettingsLoaded state) async {
    final time = await showTimePicker(
      context: context,
      initialTime: const TimeOfDay(hour: 9, minute: 0),
    );
    if (time != null) {
      // Would update settings
    }
  }

  void _showSignOutDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Sign Out'),
        content: const Text('Are you sure you want to sign out?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(ctx);
              context.read<AuthBloc>().add(AuthSignOutRequested());
            },
            child: const Text('Sign Out', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }
}