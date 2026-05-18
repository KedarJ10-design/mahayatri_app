import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:shimmer/shimmer.dart';

import '../../core/core.dart';

/// A reusable card for displaying destinations, stays, or guides.
///
/// Supports two layouts: `horizontal` (for carousels) and `vertical` (for lists).
class ContentCard extends StatelessWidget {
  final String? imageUrl;
  final String title;
  final String? subtitle;
  final double? rating;
  final int? reviewCount;
  final String? tag;
  final String? price;
  final VoidCallback? onTap;
  final double width;
  final double height;

  const ContentCard({
    super.key,
    this.imageUrl,
    required this.title,
    this.subtitle,
    this.rating,
    this.reviewCount,
    this.tag,
    this.price,
    this.onTap,
    this.width = 200,
    this.height = 240,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: width,
        height: height,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(AppTheme.radiusMd),
          color: Theme.of(context).cardColor,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.08),
              blurRadius: 12,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        clipBehavior: Clip.antiAlias,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Image
            Expanded(
              flex: 3,
              child: Stack(
                fit: StackFit.expand,
                children: [
                  _buildImage(),
                  // Tag badge
                  if (tag != null)
                    Positioned(
                      top: AppTheme.spacingSm,
                      left: AppTheme.spacingSm,
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: AppTheme.spacingSm,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: AppColors.accent,
                          borderRadius:
                              BorderRadius.circular(AppTheme.radiusSm),
                        ),
                        child: Text(
                          tag!,
                          style: AppTypography.labelSmall.copyWith(
                            color: Colors.white,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ),
                ],
              ),
            ),

            // Info
            Expanded(
              flex: 2,
              child: Padding(
                padding: const EdgeInsets.all(AppTheme.spacingSm),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Title
                    Text(
                      title,
                      style: AppTypography.titleSmall,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 2),

                    // Subtitle
                    if (subtitle != null)
                      Text(
                        subtitle!,
                        style: AppTypography.bodySmall.copyWith(
                          color: AppColors.textSecondaryLight,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),

                    const Spacer(),

                    // Bottom row: Rating + Price
                    Row(
                      children: [
                        if (rating != null && rating! > 0) ...[
                          const Icon(
                            Icons.star_rounded,
                            size: 14,
                            color: AppColors.warning,
                          ),
                          const SizedBox(width: 2),
                          Text(
                            rating!.toStringAsFixed(1),
                            style: AppTypography.labelSmall.copyWith(
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          if (reviewCount != null) ...[
                            const SizedBox(width: 2),
                            Text(
                              '($reviewCount)',
                              style: AppTypography.labelSmall.copyWith(
                                color: AppColors.grey400,
                              ),
                            ),
                          ],
                        ],
                        const Spacer(),
                        if (price != null)
                          Text(
                            price!,
                            style: AppTypography.titleSmall.copyWith(
                              color: AppColors.primary,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildImage() {
    if (imageUrl != null && imageUrl!.isNotEmpty) {
      return CachedNetworkImage(
        imageUrl: imageUrl!,
        fit: BoxFit.cover,
        placeholder: (_, __) => _shimmerPlaceholder(),
        errorWidget: (_, __, ___) => _fallbackImage(),
      );
    }
    return _fallbackImage();
  }

  Widget _shimmerPlaceholder() {
    return Shimmer.fromColors(
      baseColor: AppColors.grey200,
      highlightColor: AppColors.grey100,
      child: Container(color: AppColors.grey200),
    );
  }

  Widget _fallbackImage() {
    return Container(
      color: AppColors.grey100,
      child: const Center(
        child: Icon(Icons.image_outlined, size: 32, color: AppColors.grey400),
      ),
    );
  }
}
