import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/core.dart';
import '../../../auth/providers/auth_provider.dart';

/// Profile screen — shows user info, stats, and settings menu.
class ProfileScreen extends ConsumerWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {

    return Scaffold(
      body: SafeArea(
        child: CustomScrollView(
          slivers: [
            // ── Header ──
            SliverToBoxAdapter(child: _buildProfileHeader(context, ref)),

            // ── Stats Row ──
            SliverToBoxAdapter(child: _buildStatsRow(context)),

            // ── Menu Sections ──
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.all(AppTheme.spacingMd),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // ── Account ──
                    _sectionTitle('Account'),
                    _menuTile(
                      context,
                      icon: Icons.person_outline_rounded,
                      title: 'Edit Profile',
                      onTap: () => context.push(RouteNames.editProfile),
                    ),
                    _menuTile(
                      context,
                      icon: Icons.bookmark_outline_rounded,
                      title: 'Saved Places',
                      onTap: () => context.push(RouteNames.savedPlaces),
                    ),
                    _menuTile(
                      context,
                      icon: Icons.emoji_events_outlined,
                      title: 'Rewards',
                      badge: 'NEW',
                      onTap: () => context.push(RouteNames.rewards),
                    ),

                    const SizedBox(height: AppTheme.spacingMd),

                    // ── Support ──
                    _sectionTitle('Support'),
                    _menuTile(
                      context,
                      icon: Icons.shield_outlined,
                      title: 'Safety Center',
                      onTap: () => context.push(RouteNames.safety),
                    ),
                    _menuTile(
                      context,
                      icon: Icons.help_outline_rounded,
                      title: 'Help & FAQ',
                      onTap: () => context.push(RouteNames.help),
                    ),
                    _menuTile(
                      context,
                      icon: Icons.chat_bubble_outline_rounded,
                      title: 'Chat Support',
                      onTap: () => context.push(RouteNames.chat),
                    ),

                    const SizedBox(height: AppTheme.spacingMd),

                    // ── Preferences ──
                    _sectionTitle('Preferences'),
                    _menuTile(
                      context,
                      icon: Icons.settings_outlined,
                      title: 'Settings',
                      onTap: () => context.push(RouteNames.settings),
                    ),
                    _menuTile(
                      context,
                      icon: Icons.notifications_outlined,
                      title: 'Notifications',
                      onTap: () => context.push(RouteNames.notifications),
                    ),

                    const SizedBox(height: AppTheme.spacingLg),

                    // ── Sign Out ──
                    SizedBox(
                      width: double.infinity,
                      child: OutlinedButton.icon(
                        onPressed: () => _showSignOutDialog(context, ref),
                        icon: const Icon(Icons.logout_rounded, size: 20),
                        label: const Text('Sign Out'),
                        style: OutlinedButton.styleFrom(
                          foregroundColor: AppColors.error,
                          side: const BorderSide(color: AppColors.error),
                          padding: const EdgeInsets.symmetric(vertical: 14),
                        ),
                      ),
                    ),

                    const SizedBox(height: AppTheme.spacingSm),

                    // App version
                    Center(
                      child: Text(
                        'Mahayatri v${AppConstants.appVersion}',
                        style: AppTypography.bodySmall.copyWith(
                          color: AppColors.grey400,
                        ),
                      ),
                    ),
                    const SizedBox(height: AppTheme.spacingLg),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildProfileHeader(BuildContext context, WidgetRef ref) {
    final profile = ref.watch(userProfileProvider);
    final initial = profile?.fullName?.isNotEmpty == true
        ? profile!.fullName![0].toUpperCase()
        : '?';

    return Container(
      padding: const EdgeInsets.all(AppTheme.spacingLg),
      decoration: const BoxDecoration(
        gradient: AppColors.primaryGradient,
      ),
      child: Column(
        children: [
          // Avatar
          CircleAvatar(
            radius: 48,
            backgroundColor: Colors.white.withValues(alpha: 0.2),
            backgroundImage: profile?.avatarUrl != null
                ? NetworkImage(profile!.avatarUrl!)
                : null,
            child: profile?.avatarUrl == null
                ? Text(
                    initial,
                    style: AppTypography.displaySmall.copyWith(
                      color: Colors.white,
                      fontWeight: FontWeight.w600,
                    ),
                  )
                : null,
          ),
          const SizedBox(height: AppTheme.spacingSm),

          // Name
          Text(
            profile?.fullName ?? 'Traveler',
            style: AppTypography.headlineMedium.copyWith(
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 4),

          // Email
          Text(
            profile?.email ?? '',
            style: AppTypography.bodyMedium.copyWith(
              color: Colors.white.withValues(alpha: 0.8),
            ),
          ),
          const SizedBox(height: 4),

          // Role badge
          if (profile?.role != null && profile!.role != 'traveler')
            Container(
              margin: const EdgeInsets.only(top: 4),
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.2),
                borderRadius: BorderRadius.circular(AppTheme.radiusPill),
              ),
              child: Text(
                profile.role.toUpperCase(),
                style: AppTypography.labelSmall.copyWith(
                  color: Colors.white,
                  fontWeight: FontWeight.w600,
                  letterSpacing: 1.2,
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildStatsRow(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(
        horizontal: AppTheme.spacingMd,
        vertical: AppTheme.spacingSm,
      ),
      padding: const EdgeInsets.symmetric(vertical: AppTheme.spacingMd),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(AppTheme.radiusMd),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.06),
            blurRadius: 10,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          _statItem('0', 'Trips'),
          _divider(),
          _statItem('0', 'Reviews'),
          _divider(),
          _statItem('0', 'Saved'),
        ],
      ),
    );
  }

  Widget _statItem(String value, String label) {
    return Column(
      children: [
        Text(
          value,
          style: AppTypography.headlineSmall.copyWith(
            fontWeight: FontWeight.w700,
            color: AppColors.primary,
          ),
        ),
        const SizedBox(height: 2),
        Text(
          label,
          style: AppTypography.bodySmall.copyWith(
            color: AppColors.textSecondaryLight,
          ),
        ),
      ],
    );
  }

  Widget _divider() {
    return Container(
      width: 1,
      height: 36,
      color: AppColors.grey200,
    );
  }

  Widget _sectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: AppTheme.spacingSm),
      child: Text(
        title,
        style: AppTypography.titleMedium.copyWith(
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }

  Widget _menuTile(
    BuildContext context, {
    required IconData icon,
    required String title,
    String? badge,
    required VoidCallback onTap,
  }) {
    return ListTile(
      contentPadding: EdgeInsets.zero,
      leading: Container(
        width: 40,
        height: 40,
        decoration: BoxDecoration(
          color: AppColors.primary.withValues(alpha: 0.08),
          borderRadius: BorderRadius.circular(AppTheme.radiusSm),
        ),
        child: Icon(icon, color: AppColors.primary, size: 22),
      ),
      title: Text(title, style: AppTypography.bodyLarge),
      trailing: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (badge != null)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
              margin: const EdgeInsets.only(right: 8),
              decoration: BoxDecoration(
                color: AppColors.accent,
                borderRadius: BorderRadius.circular(AppTheme.radiusPill),
              ),
              child: Text(
                badge,
                style: AppTypography.labelSmall.copyWith(
                  color: Colors.white,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          const Icon(Icons.chevron_right_rounded, color: AppColors.grey400),
        ],
      ),
      onTap: onTap,
    );
  }

  void _showSignOutDialog(BuildContext context, WidgetRef ref) {
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
}
