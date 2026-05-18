import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/core.dart';

/// AI Planner screen — generates personalized itineraries.
///
/// This is the Phase 1 implementation with a clean UI scaffold.
/// AI integration (Gemini/GPT) will be added in a later phase.
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: CustomScrollView(
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
                                'Powered by AI',
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
        ),
      ),
    );
  }

  void _handleGenerate() {
    // Phase 1: Show coming soon dialog
    // Phase 2: Will integrate with Gemini AI API
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        icon: const Icon(
          Icons.rocket_launch_rounded,
          size: 48,
          color: AppColors.accent,
        ),
        title: const Text('Coming Soon!'),
        content: Text(
          'AI itinerary generation is under development.\n\n'
          'Your preferences:\n'
          '• Duration: $_selectedDays day${_selectedDays > 1 ? 's' : ''}\n'
          '• Budget: $_selectedBudget\n'
          '• Interests: ${_selectedInterests.isEmpty ? 'None selected' : _selectedInterests.join(', ')}\n'
          '${_promptController.text.isNotEmpty ? '• Note: "${_promptController.text}"' : ''}',
          style: AppTypography.bodyMedium,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Got it'),
          ),
        ],
      ),
    );
  }
}
