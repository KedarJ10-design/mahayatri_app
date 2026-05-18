import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/core.dart';
import '../../../../services/gemini_service.dart';

/// AI Planner screen — generates personalized itineraries using Gemini.
class PlannerScreen extends ConsumerStatefulWidget {
  const PlannerScreen({super.key});

  @override
  ConsumerState<PlannerScreen> createState() => _PlannerScreenState();
}

class _PlannerScreenState extends ConsumerState<PlannerScreen> {
  final _promptController = TextEditingController();
  int _selectedDays = 3;
  String _selectedBudget = 'moderate';
  final List<String> _selectedInterests = [];

  static const _interests = [
    ('🏰', 'Forts'),
    ('🏖️', 'Beaches'),
    ('⛰️', 'Hill Stations'),
    ('🛕', 'Temples'),
    ('🍽️', 'Food'),
    ('🎨', 'Culture'),
    ('🌿', 'Nature'),
    ('📸', 'Photography'),
    ('🏄', 'Adventure'),
    ('🧘', 'Wellness'),
  ];

  static const _budgets = ['budget', 'moderate', 'luxury'];

  @override
  void dispose() {
    _promptController.dispose();
    super.dispose();
  }

  void _handleGenerate() {
    ref.read(itineraryProvider.notifier).generate(
          days: _selectedDays,
          budget: _selectedBudget,
          interests: _selectedInterests,
          prompt: _promptController.text.trim(),
        );
  }

  @override
  Widget build(BuildContext context) {
    final itineraryState = ref.watch(itineraryProvider);

    return Scaffold(
      body: SafeArea(
        child: itineraryState.when(
          data: (itinerary) {
            if (itinerary != null) {
              return _ItineraryResult(
                itinerary: itinerary,
                onReset: () => ref.read(itineraryProvider.notifier).reset(),
                onRegenerate: _handleGenerate,
              );
            }
            return _buildInputForm();
          },
          loading: () => _buildLoadingState(),
          error: (e, _) => _buildErrorState(e),
        ),
      ),
    );
  }

  Widget _buildInputForm() {
    return CustomScrollView(
      slivers: [
        // ── Header ──
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.all(AppTheme.spacingMd),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        gradient: AppColors.accentGradient,
                        borderRadius:
                            BorderRadius.circular(AppTheme.radiusMd),
                      ),
                      child: const Icon(
                        Icons.auto_awesome_rounded,
                        color: Colors.white,
                        size: 28,
                      ),
                    ),
                    const SizedBox(width: AppTheme.spacingSm),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'AI Trip Planner',
                            style: AppTypography.headlineMedium,
                          ),
                          Text(
                            'Powered by Gemini AI',
                            style: AppTypography.bodySmall.copyWith(
                              color: AppColors.accent,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: AppTheme.spacingMd),
                Text(
                  'Tell me about your dream Maharashtra trip and I\'ll create a personalized itinerary for you.',
                  style: AppTypography.bodyMedium.copyWith(
                    color: AppColors.textSecondaryLight,
                  ),
                ),
              ],
            ),
          ),
        ),

        // ── Prompt Input ──
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: AppTheme.spacingMd,
            ),
            child: TextField(
              controller: _promptController,
              maxLines: 3,
              decoration: InputDecoration(
                hintText:
                    'E.g., "Family trip to Konkan coast with kids, love seafood and beach sunsets..."',
                hintStyle: AppTypography.bodyMedium.copyWith(
                  color: AppColors.grey400,
                ),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(AppTheme.radiusMd),
                ),
              ),
            ),
          ),
        ),

        const SliverToBoxAdapter(
          child: SizedBox(height: AppTheme.spacingMd),
        ),

        // ── Duration Selector ──
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: AppTheme.spacingMd,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Trip Duration',
                    style: AppTypography.titleSmall.copyWith(
                      fontWeight: FontWeight.w600,
                    )),
                const SizedBox(height: AppTheme.spacingSm),
                Row(
                  children: [
                    for (final days in [1, 2, 3, 5, 7])
                      Padding(
                        padding: const EdgeInsets.only(right: 8),
                        child: ChoiceChip(
                          label: Text('$days day${days > 1 ? 's' : ''}'),
                          selected: _selectedDays == days,
                          onSelected: (_) =>
                              setState(() => _selectedDays = days),
                          selectedColor:
                              AppColors.primary.withValues(alpha: 0.15),
                          labelStyle: AppTypography.labelMedium.copyWith(
                            color: _selectedDays == days
                                ? AppColors.primary
                                : AppColors.textPrimaryLight,
                          ),
                        ),
                      ),
                  ],
                ),
              ],
            ),
          ),
        ),

        const SliverToBoxAdapter(
          child: SizedBox(height: AppTheme.spacingMd),
        ),

        // ── Budget Selector ──
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: AppTheme.spacingMd,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Budget',
                    style: AppTypography.titleSmall.copyWith(
                      fontWeight: FontWeight.w600,
                    )),
                const SizedBox(height: AppTheme.spacingSm),
                Row(
                  children: _budgets.map((budget) {
                    final isSelected = _selectedBudget == budget;
                    final icon = switch (budget) {
                      'budget' => '💰',
                      'moderate' => '💵',
                      'luxury' => '💎',
                      _ => '💰',
                    };
                    return Padding(
                      padding: const EdgeInsets.only(right: 8),
                      child: ChoiceChip(
                        label: Text(
                            '$icon ${budget[0].toUpperCase()}${budget.substring(1)}'),
                        selected: isSelected,
                        onSelected: (_) =>
                            setState(() => _selectedBudget = budget),
                        selectedColor:
                            AppColors.primary.withValues(alpha: 0.15),
                        labelStyle: AppTypography.labelMedium.copyWith(
                          color: isSelected
                              ? AppColors.primary
                              : AppColors.textPrimaryLight,
                        ),
                      ),
                    );
                  }).toList(),
                ),
              ],
            ),
          ),
        ),

        const SliverToBoxAdapter(
          child: SizedBox(height: AppTheme.spacingMd),
        ),

        // ── Interests ──
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: AppTheme.spacingMd,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Interests',
                    style: AppTypography.titleSmall.copyWith(
                      fontWeight: FontWeight.w600,
                    )),
                const SizedBox(height: AppTheme.spacingSm),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: _interests.map((interest) {
                    final (emoji, label) = interest;
                    final isSelected =
                        _selectedInterests.contains(label.toLowerCase());
                    return FilterChip(
                      label: Text('$emoji $label'),
                      selected: isSelected,
                      onSelected: (selected) {
                        setState(() {
                          if (selected) {
                            _selectedInterests.add(label.toLowerCase());
                          } else {
                            _selectedInterests.remove(label.toLowerCase());
                          }
                        });
                      },
                      selectedColor:
                          AppColors.accent.withValues(alpha: 0.15),
                      checkmarkColor: AppColors.accent,
                      labelStyle: AppTypography.labelMedium.copyWith(
                        color: isSelected
                            ? AppColors.accent
                            : AppColors.textPrimaryLight,
                      ),
                    );
                  }).toList(),
                ),
              ],
            ),
          ),
        ),

        const SliverToBoxAdapter(
          child: SizedBox(height: AppTheme.spacingXl),
        ),

        // ── Generate Button ──
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: AppTheme.spacingMd,
            ),
            child: SizedBox(
              width: double.infinity,
              height: 56,
              child: ElevatedButton.icon(
                onPressed: _handleGenerate,
                icon: const Icon(Icons.auto_awesome_rounded),
                label: const Text('Generate Itinerary'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.accent,
                  shape: RoundedRectangleBorder(
                    borderRadius:
                        BorderRadius.circular(AppTheme.radiusMd),
                  ),
                  textStyle: AppTypography.button.copyWith(
                    fontSize: 16,
                  ),
                ),
              ),
            ),
          ),
        ),

        const SliverPadding(padding: EdgeInsets.only(bottom: 48)),
      ],
    );
  }

  Widget _buildLoadingState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // Animated AI indicator
          TweenAnimationBuilder<double>(
            tween: Tween(begin: 0, end: 1),
            duration: const Duration(seconds: 2),
            builder: (context, value, child) {
              return Transform.rotate(
                angle: value * 6.28,
                child: child,
              );
            },
            child: Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                gradient: AppColors.accentGradient,
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: AppColors.accent.withValues(alpha: 0.3),
                    blurRadius: 24,
                    spreadRadius: 4,
                  ),
                ],
              ),
              child: const Icon(
                Icons.auto_awesome_rounded,
                color: Colors.white,
                size: 40,
              ),
            ),
          ),
          const SizedBox(height: AppTheme.spacingLg),
          Text(
            'Crafting your perfect trip...',
            style: AppTypography.headlineSmall,
          ),
          const SizedBox(height: AppTheme.spacingSm),
          Text(
            'Our AI is exploring the best of Maharashtra\nfor your $_selectedDays-day adventure',
            textAlign: TextAlign.center,
            style: AppTypography.bodyMedium.copyWith(
              color: AppColors.textSecondaryLight,
            ),
          ),
          const SizedBox(height: AppTheme.spacingLg),
          const SizedBox(
            width: 200,
            child: LinearProgressIndicator(
              backgroundColor: Color(0xFFE0E0E0),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildErrorState(Object error) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(AppTheme.spacingLg),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.error_outline_rounded,
                size: 56, color: AppColors.error),
            const SizedBox(height: AppTheme.spacingMd),
            Text('Generation Failed',
                style: AppTypography.headlineSmall),
            const SizedBox(height: AppTheme.spacingSm),
            Text(
              'Something went wrong while generating your itinerary. Please try again.',
              textAlign: TextAlign.center,
              style: AppTypography.bodyMedium.copyWith(
                color: AppColors.textSecondaryLight,
              ),
            ),
            const SizedBox(height: AppTheme.spacingLg),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                OutlinedButton.icon(
                  onPressed: () =>
                      ref.read(itineraryProvider.notifier).reset(),
                  icon: const Icon(Icons.arrow_back_rounded),
                  label: const Text('Go Back'),
                ),
                const SizedBox(width: AppTheme.spacingSm),
                ElevatedButton.icon(
                  onPressed: _handleGenerate,
                  icon: const Icon(Icons.refresh_rounded),
                  label: const Text('Try Again'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

// ════════════════════════════════════════════
// Itinerary Result Display
// ════════════════════════════════════════════

class _ItineraryResult extends StatelessWidget {
  final TripItinerary itinerary;
  final VoidCallback onReset;
  final VoidCallback onRegenerate;

  const _ItineraryResult({
    required this.itinerary,
    required this.onReset,
    required this.onRegenerate,
  });

  @override
  Widget build(BuildContext context) {
    return CustomScrollView(
      slivers: [
        // ── App Bar ──
        SliverAppBar(
          expandedHeight: 140,
          pinned: true,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back_rounded),
            onPressed: onReset,
          ),
          actions: [
            IconButton(
              icon: const Icon(Icons.refresh_rounded),
              onPressed: onRegenerate,
              tooltip: 'Regenerate',
            ),
            IconButton(
              icon: const Icon(Icons.share_rounded),
              onPressed: () {},
              tooltip: 'Share',
            ),
          ],
          flexibleSpace: FlexibleSpaceBar(
            background: Container(
              decoration: const BoxDecoration(gradient: AppColors.accentGradient),
              child: Center(
                child: Padding(
                  padding: const EdgeInsets.only(top: 50),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.auto_awesome_rounded,
                          color: Colors.white, size: 28),
                      const SizedBox(height: 4),
                      Text(
                        itinerary.title,
                        style: AppTypography.titleLarge.copyWith(
                          color: Colors.white,
                          fontWeight: FontWeight.w600,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),

        // ── Summary ──
        SliverToBoxAdapter(
          child: Container(
            margin: const EdgeInsets.all(AppTheme.spacingMd),
            padding: const EdgeInsets.all(AppTheme.spacingMd),
            decoration: BoxDecoration(
              color: AppColors.accent.withValues(alpha: 0.06),
              borderRadius: BorderRadius.circular(AppTheme.radiusMd),
              border:
                  Border.all(color: AppColors.accent.withValues(alpha: 0.15)),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    const Icon(Icons.info_outline_rounded,
                        size: 18, color: AppColors.accent),
                    const SizedBox(width: 6),
                    Text('Overview',
                        style: AppTypography.titleSmall.copyWith(
                          fontWeight: FontWeight.w600,
                          color: AppColors.accent,
                        )),
                  ],
                ),
                const SizedBox(height: 8),
                Text(
                  itinerary.summary,
                  style: AppTypography.bodyMedium.copyWith(
                    color: AppColors.textSecondaryLight,
                    height: 1.5,
                  ),
                ),
                const SizedBox(height: AppTheme.spacingSm),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: AppColors.primary.withValues(alpha: 0.08),
                    borderRadius: BorderRadius.circular(AppTheme.radiusPill),
                  ),
                  child: Text(
                    '💰 Estimated: ${itinerary.estimatedBudget}',
                    style: AppTypography.labelMedium.copyWith(
                      color: AppColors.primary,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),

        // ── Day-by-Day ──
        for (final dayPlan in itinerary.days) ...[
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: AppTheme.spacingMd,
                vertical: AppTheme.spacingSm,
              ),
              child: Row(
                children: [
                  Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      gradient: AppColors.primaryGradient,
                      borderRadius: BorderRadius.circular(AppTheme.radiusSm),
                    ),
                    child: Center(
                      child: Text(
                        '${dayPlan.day}',
                        style: AppTypography.titleMedium.copyWith(
                          color: Colors.white,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: AppTheme.spacingSm),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Day ${dayPlan.day}',
                            style: AppTypography.labelSmall.copyWith(
                              color: AppColors.grey500,
                            )),
                        Text(dayPlan.title,
                            style: AppTypography.titleSmall.copyWith(
                              fontWeight: FontWeight.w600,
                            )),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
          SliverList(
            delegate: SliverChildBuilderDelegate(
              (context, index) {
                final activity = dayPlan.activities[index];
                return _ActivityCard(
                  activity: activity,
                  isLast: index == dayPlan.activities.length - 1,
                );
              },
              childCount: dayPlan.activities.length,
            ),
          ),
        ],

        // ── Tips ──
        if (itinerary.tips.isNotEmpty)
          SliverToBoxAdapter(
            child: Container(
              margin: const EdgeInsets.all(AppTheme.spacingMd),
              padding: const EdgeInsets.all(AppTheme.spacingMd),
              decoration: BoxDecoration(
                color: AppColors.warning.withValues(alpha: 0.06),
                borderRadius: BorderRadius.circular(AppTheme.radiusMd),
                border: Border.all(
                    color: AppColors.warning.withValues(alpha: 0.2)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      const Icon(Icons.lightbulb_outline_rounded,
                          size: 20, color: AppColors.warning),
                      const SizedBox(width: 6),
                      Text('Travel Tips',
                          style: AppTypography.titleSmall.copyWith(
                            fontWeight: FontWeight.w600,
                          )),
                    ],
                  ),
                  const SizedBox(height: AppTheme.spacingSm),
                  ...itinerary.tips.map(
                    (tip) => Padding(
                      padding: const EdgeInsets.only(bottom: 6),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('• ',
                              style: AppTypography.bodyMedium.copyWith(
                                color: AppColors.warning,
                                fontWeight: FontWeight.w700,
                              )),
                          Expanded(
                            child: Text(
                              tip,
                              style: AppTypography.bodySmall.copyWith(
                                color: AppColors.textSecondaryLight,
                                height: 1.5,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),

        const SliverPadding(padding: EdgeInsets.only(bottom: 48)),
      ],
    );
  }
}

/// Individual activity card in the itinerary timeline.
class _ActivityCard extends StatelessWidget {
  final Activity activity;
  final bool isLast;

  const _ActivityCard({required this.activity, this.isLast = false});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: AppTheme.spacingMd),
      child: IntrinsicHeight(
        child: Row(
          children: [
            // Timeline line
            SizedBox(
              width: 40,
              child: Column(
                children: [
                  Container(
                    width: 12,
                    height: 12,
                    decoration: BoxDecoration(
                      color: _categoryColor,
                      shape: BoxShape.circle,
                    ),
                  ),
                  if (!isLast)
                    Expanded(
                      child: Container(
                        width: 2,
                        color: AppColors.grey200,
                      ),
                    ),
                ],
              ),
            ),
            const SizedBox(width: AppTheme.spacingSm),
            // Content
            Expanded(
              child: Container(
                margin: const EdgeInsets.only(bottom: AppTheme.spacingSm),
                padding: const EdgeInsets.all(AppTheme.spacingSm),
                decoration: BoxDecoration(
                  color: Theme.of(context).cardColor,
                  borderRadius: BorderRadius.circular(AppTheme.radiusSm),
                  border: Border.all(color: AppColors.grey200),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(_categoryIcon, size: 16, color: _categoryColor),
                        const SizedBox(width: 6),
                        Text(
                          activity.time,
                          style: AppTypography.labelSmall.copyWith(
                            color: _categoryColor,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        const Spacer(),
                        if (activity.estimatedCost != null)
                          Text(
                            activity.estimatedCost!,
                            style: AppTypography.labelSmall.copyWith(
                              color: AppColors.primary,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(
                      activity.name,
                      style: AppTypography.titleSmall.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    Text(
                      activity.description,
                      style: AppTypography.bodySmall.copyWith(
                        color: AppColors.textSecondaryLight,
                        height: 1.4,
                      ),
                    ),
                    if (activity.location != null) ...[
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          Icon(Icons.location_on_outlined,
                              size: 14, color: AppColors.grey500),
                          const SizedBox(width: 4),
                          Expanded(
                            child: Text(
                              activity.location!,
                              style: AppTypography.labelSmall.copyWith(
                                color: AppColors.grey500,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Color get _categoryColor {
    return switch (activity.category) {
      'transport' => const Color(0xFF5C6BC0),
      'food' => const Color(0xFFEF6C00),
      'sightseeing' => AppColors.primary,
      'stay' => const Color(0xFF00897B),
      'activity' => AppColors.accent,
      'shopping' => const Color(0xFFAB47BC),
      _ => AppColors.primary,
    };
  }

  IconData get _categoryIcon {
    return switch (activity.category) {
      'transport' => Icons.directions_car_rounded,
      'food' => Icons.restaurant_rounded,
      'sightseeing' => Icons.photo_camera_rounded,
      'stay' => Icons.hotel_rounded,
      'activity' => Icons.hiking_rounded,
      'shopping' => Icons.shopping_bag_rounded,
      _ => Icons.place_rounded,
    };
  }
}
