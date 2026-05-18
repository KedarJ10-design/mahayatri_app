import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../../core/core.dart';

/// Safety Center — SOS, emergency contacts, safety tips.
class SafetyScreen extends StatelessWidget {
  const SafetyScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Safety Center'),
        centerTitle: true,
      ),
      body: ListView(
        padding: const EdgeInsets.all(AppTheme.spacingMd),
        children: [
          // ── SOS Button ──
          Container(
            padding: const EdgeInsets.all(AppTheme.spacingLg),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [Color(0xFFD32F2F), Color(0xFFFF5252)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(AppTheme.radiusLg),
              boxShadow: [
                BoxShadow(
                  color: const Color(0xFFD32F2F).withValues(alpha: 0.3),
                  blurRadius: 16,
                  offset: const Offset(0, 6),
                ),
              ],
            ),
            child: Column(
              children: [
                const Icon(Icons.sos_rounded,
                    size: 56, color: Colors.white),
                const SizedBox(height: AppTheme.spacingSm),
                Text(
                  'Emergency SOS',
                  style: AppTypography.headlineMedium.copyWith(
                    color: Colors.white,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: AppTheme.spacingSm),
                Text(
                  'Press the button below to call emergency services immediately.',
                  textAlign: TextAlign.center,
                  style: AppTypography.bodyMedium.copyWith(
                    color: Colors.white.withValues(alpha: 0.9),
                  ),
                ),
                const SizedBox(height: AppTheme.spacingMd),
                SizedBox(
                  width: double.infinity,
                  height: 56,
                  child: ElevatedButton.icon(
                    onPressed: () => _callEmergency(context),
                    icon: const Icon(Icons.phone_rounded,
                        color: Color(0xFFD32F2F)),
                    label: const Text(
                      'Call 112 (Emergency)',
                      style: TextStyle(
                        color: Color(0xFFD32F2F),
                        fontWeight: FontWeight.w700,
                        fontSize: 16,
                      ),
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius:
                            BorderRadius.circular(AppTheme.radiusMd),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: AppTheme.spacingLg),

          // ── Quick Emergency Numbers ──
          Text('Emergency Contacts',
              style: AppTypography.titleMedium.copyWith(
                fontWeight: FontWeight.w600,
              )),
          const SizedBox(height: AppTheme.spacingSm),
          _EmergencyContact(
            icon: Icons.local_police_rounded,
            name: 'Police',
            number: '100',
            color: const Color(0xFF1565C0),
          ),
          _EmergencyContact(
            icon: Icons.local_hospital_rounded,
            name: 'Ambulance',
            number: '108',
            color: const Color(0xFFD32F2F),
          ),
          _EmergencyContact(
            icon: Icons.fire_truck_rounded,
            name: 'Fire Brigade',
            number: '101',
            color: const Color(0xFFEF6C00),
          ),
          _EmergencyContact(
            icon: Icons.woman_rounded,
            name: 'Women Helpline',
            number: '1091',
            color: const Color(0xFF7B1FA2),
          ),
          _EmergencyContact(
            icon: Icons.travel_explore_rounded,
            name: 'Tourist Helpline',
            number: '1363',
            color: AppColors.primary,
          ),
          const SizedBox(height: AppTheme.spacingLg),

          // ── Safety Tips ──
          Text('Safety Tips',
              style: AppTypography.titleMedium.copyWith(
                fontWeight: FontWeight.w600,
              )),
          const SizedBox(height: AppTheme.spacingSm),
          _SafetyTip(
            icon: Icons.share_location_rounded,
            title: 'Share Your Location',
            description:
                'Always share your live location with a trusted contact when traveling to remote areas.',
          ),
          _SafetyTip(
            icon: Icons.attach_money_rounded,
            title: 'Keep Cash Handy',
            description:
                'Rural areas may not have UPI/card payment. Keep ₹2,000-5,000 cash as backup.',
          ),
          _SafetyTip(
            icon: Icons.water_drop_rounded,
            title: 'Stay Hydrated',
            description:
                'Carry bottled water especially during treks and summer travel in Maharashtra.',
          ),
          _SafetyTip(
            icon: Icons.verified_user_rounded,
            title: 'Verify Guides',
            description:
                'Only book verified guides through the app. Check reviews and ratings before booking.',
          ),
          _SafetyTip(
            icon: Icons.phone_android_rounded,
            title: 'Keep Phone Charged',
            description:
                'Carry a power bank. Some remote fort treks and beach areas have no charging points.',
          ),
          const SizedBox(height: AppTheme.spacingMd),
        ],
      ),
    );
  }

  void _callEmergency(BuildContext context) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        icon: const Icon(Icons.phone_rounded,
            size: 48, color: Color(0xFFD32F2F)),
        title: const Text('Call Emergency?'),
        content: const Text(
            'This will call 112 (India Emergency Services). Only use in real emergencies.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(ctx);
              launchUrl(Uri.parse('tel:112'));
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFD32F2F),
            ),
            child: const Text('Call 112'),
          ),
        ],
      ),
    );
  }
}

class _EmergencyContact extends StatelessWidget {
  final IconData icon;
  final String name;
  final String number;
  final Color color;

  const _EmergencyContact({
    required this.icon,
    required this.name,
    required this.number,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: ListTile(
        leading: Container(
          width: 44,
          height: 44,
          decoration: BoxDecoration(
            color: color.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(AppTheme.radiusSm),
          ),
          child: Icon(icon, color: color, size: 24),
        ),
        title: Text(name,
            style: AppTypography.bodyLarge.copyWith(
              fontWeight: FontWeight.w500,
            )),
        subtitle: Text(number,
            style: AppTypography.bodySmall.copyWith(
              color: AppColors.grey500,
            )),
        trailing: IconButton(
          icon: Icon(Icons.phone_rounded, color: color),
          onPressed: () => launchUrl(Uri.parse('tel:$number')),
        ),
      ),
    );
  }
}

class _SafetyTip extends StatelessWidget {
  final IconData icon;
  final String title;
  final String description;

  const _SafetyTip({
    required this.icon,
    required this.title,
    required this.description,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(AppTheme.spacingSm),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(AppTheme.radiusMd),
        border: Border.all(color: AppColors.grey200),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: AppColors.primary.withValues(alpha: 0.08),
              borderRadius: BorderRadius.circular(AppTheme.radiusSm),
            ),
            child: Icon(icon, color: AppColors.primary, size: 22),
          ),
          const SizedBox(width: AppTheme.spacingSm),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title,
                    style: AppTypography.titleSmall.copyWith(
                      fontWeight: FontWeight.w600,
                    )),
                const SizedBox(height: 4),
                Text(
                  description,
                  style: AppTypography.bodySmall.copyWith(
                    color: AppColors.textSecondaryLight,
                    height: 1.5,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
