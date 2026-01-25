import 'package:flutter/material.dart';
import '../theme/gym_theme.dart';

class AdvancedStatRow extends StatelessWidget {
  final String title;
  final String? subtitle;
  final VoidCallback onTap;
  final Widget? trailing; // Badge or extra icon
  final bool isPro;

  const AdvancedStatRow({
    super.key,
    required this.title,
    this.subtitle,
    required this.onTap,
    this.trailing,
    this.isPro = false,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.symmetric(
            horizontal: GymTheme.spacing.md, vertical: GymTheme.spacing.md),
        decoration: BoxDecoration(
          border: Border(
            bottom: BorderSide(
                color: GymTheme.colors.divider.withValues(alpha: 0.5)),
          ),
        ),
        child: Row(
          children: [
            // Icon or leading could go here if needed, Hevy has icons sometimes
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Text(
                        title,
                        style: GymTheme.text.body.copyWith(
                          color: GymTheme.colors.textPrimary,
                          fontWeight: FontWeight.w500,
                          fontSize: 16,
                        ),
                      ),
                      if (isPro) ...[
                        SizedBox(width: GymTheme.spacing.sm),
                        _buildProBadge(),
                      ],
                    ],
                  ),
                  if (subtitle != null) ...[
                    const SizedBox(height: 4),
                    Text(
                      subtitle!,
                      style: GymTheme.text.secondary,
                    ),
                  ],
                ],
              ),
            ),
            if (trailing != null) ...[
              trailing!,
              SizedBox(width: GymTheme.spacing.sm),
            ],
            Icon(
              Icons.chevron_right,
              color: GymTheme.colors.textSecondary,
              size: 20,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildProBadge() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(
        color: const Color(0xFFFFD700), // Gold
        borderRadius: BorderRadius.circular(4),
      ),
      child: const Text(
        'PRO',
        style: TextStyle(
          color: Colors.black,
          fontSize: 10,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }
}
