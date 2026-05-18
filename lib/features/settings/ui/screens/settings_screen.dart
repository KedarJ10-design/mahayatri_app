import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/core.dart';
import '../../../auth/providers/auth_provider.dart';

/// Full settings screen with theme, notifications, account, and support.
class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Settings'),
        centerTitle: true,
      ),
      body: ListView(
        padding: const EdgeInsets.symmetric(vertical: AppTheme.spacingSm),
        children: [
          // ── Account ──
          _SectionHeader(title: 'Account'),
          _SettingsTile(
            icon: Icons.person_outline_rounded,
            title: 'Edit Profile',
            subtitle: 'Name, photo, phone, bio',
            onTap: () => context.push(RouteNames.editProfile),
          ),
          _SettingsTile(
            icon: Icons.lock_outline_rounded,
            title: 'Privacy',
            subtitle: 'Profile visibility, data sharing',
            onTap: () {},
          ),
          _SettingsTile(
            icon: Icons.security_rounded,
            title: 'Security',
            subtitle: 'Password, 2FA, login activity',
            onTap: () {},
          ),

          const Divider(height: 32),

          // ── Preferences ──
          _SectionHeader(title: 'Preferences'),
          _SettingsSwitch(
            icon: Icons.dark_mode_rounded,
            title: 'Dark Mode',
            subtitle: 'Use dark theme',
            value: false,
            onChanged: (v) {
              // TODO: Implement theme switching
            },
          ),
          _SettingsSwitch(
            icon: Icons.notifications_outlined,
            title: 'Push Notifications',
            subtitle: 'Booking updates, promotions',
            value: true,
            onChanged: (v) {
              // TODO: Implement notification toggle
            },
          ),
          _SettingsSwitch(
            icon: Icons.email_outlined,
            title: 'Email Notifications',
            subtitle: 'Booking confirmations, newsletters',
            value: true,
            onChanged: (v) {},
          ),
          _SettingsTile(
            icon: Icons.language_rounded,
            title: 'Language',
            subtitle: 'English',
            trailing: const Icon(Icons.chevron_right_rounded),
            onTap: () {},
          ),
          _SettingsTile(
            icon: Icons.currency_rupee_rounded,
            title: 'Currency',
            subtitle: 'INR (₹)',
            trailing: const Icon(Icons.chevron_right_rounded),
            onTap: () {},
          ),

          const Divider(height: 32),

          // ── Support ──
          _SectionHeader(title: 'Support'),
          _SettingsTile(
            icon: Icons.help_outline_rounded,
            title: 'Help Center',
            subtitle: 'FAQs, guides, troubleshooting',
            onTap: () {},
          ),
          _SettingsTile(
            icon: Icons.bug_report_outlined,
            title: 'Report a Problem',
            subtitle: 'Send feedback or report bugs',
            onTap: () {},
          ),
          _SettingsTile(
            icon: Icons.star_outline_rounded,
            title: 'Rate Mahayatri',
            subtitle: 'Love us? Leave a review!',
            onTap: () {},
          ),

          const Divider(height: 32),

          // ── Legal ──
          _SectionHeader(title: 'Legal'),
          _SettingsTile(
            icon: Icons.description_outlined,
            title: 'Terms of Service',
            onTap: () {},
          ),
          _SettingsTile(
            icon: Icons.privacy_tip_outlined,
            title: 'Privacy Policy',
            onTap: () {},
          ),
          _SettingsTile(
            icon: Icons.gavel_rounded,
            title: 'Licenses',
            onTap: () => showLicensePage(
              context: context,
              applicationName: 'Mahayatri',
              applicationVersion: '1.0.0',
            ),
          ),

          const Divider(height: 32),

          // ── Danger Zone ──
          _SettingsTile(
            icon: Icons.logout_rounded,
            title: 'Sign Out',
            titleColor: AppColors.error,
            iconColor: AppColors.error,
            onTap: () => _confirmSignOut(context, ref),
          ),
          _SettingsTile(
            icon: Icons.delete_forever_rounded,
            title: 'Delete Account',
            titleColor: AppColors.error,
            iconColor: AppColors.error,
            onTap: () => _confirmDelete(context),
          ),

          const SizedBox(height: AppTheme.spacingMd),

          // ── App Info ──
          Center(
            child: Column(
              children: [
                Text(
                  'Mahayatri v1.0.0',
                  style: AppTypography.bodySmall.copyWith(
                    color: AppColors.grey400,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Made with ❤️ in Maharashtra',
                  style: AppTypography.labelSmall.copyWith(
                    color: AppColors.grey400,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: AppTheme.spacingLg),
        ],
      ),
    );
  }

  void _confirmSignOut(BuildContext context, WidgetRef ref) {
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
          ElevatedButton(
            onPressed: () {
              Navigator.pop(ctx);
              ref.read(authNotifierProvider.notifier).signOut();
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.error,
            ),
            child: const Text('Sign Out'),
          ),
        ],
      ),
    );
  }

  void _confirmDelete(BuildContext context) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        icon: const Icon(Icons.warning_rounded,
            size: 48, color: AppColors.error),
        title: const Text('Delete Account'),
        content: const Text(
          'This action is permanent and cannot be undone.\n\n'
          'All your data, bookings, and preferences will be permanently deleted.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(ctx);
              // TODO: Implement account deletion
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.error,
            ),
            child: const Text('Delete Forever'),
          ),
        ],
      ),
    );
  }
}

// ── Reusable Components ──

class _SectionHeader extends StatelessWidget {
  final String title;
  const _SectionHeader({required this.title});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: AppTheme.spacingMd,
        vertical: AppTheme.spacingSm,
      ),
      child: Text(
        title,
        style: AppTypography.titleSmall.copyWith(
          fontWeight: FontWeight.w600,
          color: AppColors.primary,
        ),
      ),
    );
  }
}

class _SettingsTile extends StatelessWidget {
  final IconData icon;
  final String title;
  final String? subtitle;
  final Color? titleColor;
  final Color? iconColor;
  final Widget? trailing;
  final VoidCallback? onTap;

  const _SettingsTile({
    required this.icon,
    required this.title,
    this.subtitle,
    this.titleColor,
    this.iconColor,
    this.trailing,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: Icon(icon,
          color: iconColor ?? AppColors.textSecondaryLight, size: 24),
      title: Text(
        title,
        style: AppTypography.bodyLarge.copyWith(
          color: titleColor,
          fontWeight: FontWeight.w500,
        ),
      ),
      subtitle: subtitle != null
          ? Text(
              subtitle!,
              style: AppTypography.bodySmall.copyWith(
                color: AppColors.grey500,
              ),
            )
          : null,
      trailing: trailing ??
          const Icon(Icons.chevron_right_rounded, color: AppColors.grey400),
      onTap: onTap,
    );
  }
}

class _SettingsSwitch extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final bool value;
  final ValueChanged<bool> onChanged;

  const _SettingsSwitch({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.value,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading:
          Icon(icon, color: AppColors.textSecondaryLight, size: 24),
      title: Text(
        title,
        style: AppTypography.bodyLarge.copyWith(
          fontWeight: FontWeight.w500,
        ),
      ),
      subtitle: Text(
        subtitle,
        style: AppTypography.bodySmall.copyWith(
          color: AppColors.grey500,
        ),
      ),
      trailing: Switch.adaptive(
        value: value,
        onChanged: onChanged,
        activeTrackColor: AppColors.primary,
      ),
    );
  }
}
