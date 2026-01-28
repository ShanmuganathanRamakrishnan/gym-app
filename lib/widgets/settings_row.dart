import 'package:flutter/material.dart';
import '../theme/gym_theme.dart';

/// Reusable settings row widget matching Hevy visual style.
///
/// Features:
/// - Leading icon (24px)
/// - Title (16px, medium weight)
/// - Optional subtitle (12px, textSecondary)
/// - Trailing widget (chevron or PRO badge)
/// - InkWell ripple with 48px min tap target
class SettingsRow extends StatelessWidget {
  final String title;
  final String? subtitle;
  final IconData leadingIcon;
  final Widget? trailingWidget;
  final VoidCallback? onTap;

  const SettingsRow({
    super.key,
    required this.title,
    this.subtitle,
    required this.leadingIcon,
    this.trailingWidget,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Semantics(
      label: '$title${subtitle != null ? ', $subtitle' : ''}',
      button: onTap != null,
      child: Material(
        color: GymTheme.colors.surface,
        borderRadius: BorderRadius.circular(GymTheme.radius.md),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(GymTheme.radius.md),
          child: Container(
            constraints: const BoxConstraints(minHeight: 48), // A11y hit target
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            child: Row(
              children: [
                // Leading icon
                Icon(
                  leadingIcon,
                  size: 24,
                  color: GymTheme.colors.textSecondary,
                ),
                const SizedBox(width: 16),

                // Title + subtitle
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        title,
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w500,
                          color: GymTheme.colors.textPrimary,
                        ),
                      ),
                      if (subtitle != null) ...[
                        const SizedBox(height: 2),
                        Text(
                          subtitle!,
                          style: TextStyle(
                            fontSize: 12,
                            color: GymTheme.colors.textSecondary,
                          ),
                        ),
                      ],
                    ],
                  ),
                ),

                // Trailing widget or default chevron
                trailingWidget ??
                    Icon(
                      Icons.chevron_right,
                      size: 24,
                      color: GymTheme.colors.textMuted,
                    ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/// PRO badge widget for subscription-gated rows.
class ProBadge extends StatelessWidget {
  const ProBadge({super.key});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          decoration: BoxDecoration(
            color: GymTheme.colors.accent,
            borderRadius: BorderRadius.circular(4),
          ),
          child: const Text(
            'PRO',
            style: TextStyle(
              fontSize: 10,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
        ),
        const SizedBox(width: 8),
        Icon(
          Icons.chevron_right,
          size: 24,
          color: GymTheme.colors.textMuted,
        ),
      ],
    );
  }
}
