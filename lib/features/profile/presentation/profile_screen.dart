import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../core/constants/app_constants.dart';
import '../../../core/services/notification_service.dart';
import '../../../core/themes/app_spacing.dart';
import '../../auth/data/auth_repository.dart';
import '../../settings/data/notification_repository.dart';
import '../../settings/data/settings_controller.dart';

class ProfileScreen extends ConsumerWidget {
  const ProfileScreen({super.key});

  Widget _sectionTitle(BuildContext context, String title) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.fromLTRB(
        AppSpacing.md,
        AppSpacing.lg,
        AppSpacing.md,
        AppSpacing.sm,
      ),
      child: Text(
        title,
        style: theme.textTheme.labelLarge
            ?.copyWith(color: theme.colorScheme.onSurfaceVariant),
      ),
    );
  }

  Future<void> _openRepo(BuildContext context) async {
    final ok = await launchUrl(
      Uri.parse(AppConstants.projectRepoUrl),
      mode: LaunchMode.externalApplication,
    );
    if (!ok && context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Could not open the project page.')),
      );
    }
  }

  Future<void> _confirmLogout(BuildContext context, WidgetRef ref) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Log out?'),
        content: const Text('You can sign back in at any time.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(false),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () => Navigator.of(dialogContext).pop(true),
            child: const Text('Log out'),
          ),
        ],
      ),
    );
    if (confirmed != true || !context.mounted) return;

    // Unregister FCM token before clearing auth state.
    final fcmToken = await ref.read(notificationServiceProvider).getToken();
    if (fcmToken != null) {
      await ref.read(notificationRepositoryProvider).unregisterDevice(fcmToken);
    }

    await ref.read(authRepositoryProvider).logout();
    if (!context.mounted) return;
    // Router redirects to the welcome flow when the session clears.
    ref.read(sessionProvider.notifier).set(null);
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final session = ref.watch(sessionProvider);
    final themeMode = ref.watch(themeModeProvider);
    final prefs = ref.watch(notificationPrefsProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Profile & Settings')),
      body: ListView(
        padding: const EdgeInsets.only(bottom: AppSpacing.xl),
        children: [
          // Header
          Padding(
            padding: const EdgeInsets.all(AppSpacing.lg),
            child: Column(
              children: [
                CircleAvatar(
                  radius: 40,
                  backgroundColor: theme.colorScheme.primaryContainer,
                  child: Icon(
                    Icons.person,
                    size: 40,
                    color: theme.colorScheme.onPrimaryContainer,
                  ),
                ),
                const SizedBox(height: AppSpacing.md),
                Text(
                  session?.displayName ?? 'Guest',
                  style: theme.textTheme.titleLarge
                      ?.copyWith(fontWeight: FontWeight.w700),
                  textAlign: TextAlign.center,
                ),
                if (session != null) ...[
                  const SizedBox(height: AppSpacing.xs),
                  Text(
                    '@${session.username}',
                    style: theme.textTheme.bodySmall
                        ?.copyWith(color: theme.colorScheme.onSurfaceVariant),
                  ),
                ],
              ],
            ),
          ),
          _sectionTitle(context, 'Appearance'),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
            child: SegmentedButton<ThemeMode>(
              segments: const [
                ButtonSegment(
                  value: ThemeMode.system,
                  label: Text('System'),
                  icon: Icon(Icons.brightness_auto),
                ),
                ButtonSegment(
                  value: ThemeMode.light,
                  label: Text('Light'),
                  icon: Icon(Icons.light_mode_outlined),
                ),
                ButtonSegment(
                  value: ThemeMode.dark,
                  label: Text('Dark'),
                  icon: Icon(Icons.dark_mode_outlined),
                ),
              ],
              selected: {themeMode},
              onSelectionChanged: (selection) =>
                  ref.read(themeModeProvider.notifier).set(selection.first),
            ),
          ),
          _sectionTitle(context, 'Notifications'),
          SwitchListTile(
            title: const Text('Meal reminders'),
            subtitle: const Text('Get notified when it\'s time to log a meal.'),
            value: prefs.mealReminders,
            onChanged: (value) => ref
                .read(notificationPrefsProvider.notifier)
                .setMealReminders(value),
          ),
          SwitchListTile(
            title: const Text('Hydration reminders'),
            subtitle:
                const Text('Get reminded to drink water throughout the day.'),
            value: prefs.hydrationReminders,
            onChanged: (value) => ref
                .read(notificationPrefsProvider.notifier)
                .setHydrationReminders(value),
          ),
          _sectionTitle(context, 'About'),
          const ListTile(
            leading: Icon(Icons.info_outline),
            title: Text('App version'),
            subtitle: Text('${AppConstants.appName} 2.0.0'),
          ),
          ListTile(
            leading: const Icon(Icons.code),
            title: const Text('About this project'),
            trailing: const Icon(Icons.open_in_new, size: 18),
            onTap: () => _openRepo(context),
          ),
          const ListTile(
            leading: Icon(Icons.health_and_safety_outlined),
            title: Text('Disclaimer'),
            subtitle: Text(
              'NutriSalud provides educational content, not medical advice.',
            ),
          ),
          const Divider(height: AppSpacing.xl),
          ListTile(
            leading: Icon(Icons.logout, color: theme.colorScheme.error),
            title: Text(
              'Log out',
              style: TextStyle(color: theme.colorScheme.error),
            ),
            onTap: () => _confirmLogout(context, ref),
          ),
        ],
      ),
    );
  }
}
