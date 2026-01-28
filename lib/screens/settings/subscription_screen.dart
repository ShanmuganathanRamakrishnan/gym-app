// ignore_for_file: use_build_context_synchronously
import 'package:flutter/material.dart';
import '../../theme/gym_theme.dart';
import '../../services/subscription_service.dart';

/// Subscription management screen.
///
/// Shows current plan and available upgrade options with stub payment flow.
class SubscriptionScreen extends StatefulWidget {
  const SubscriptionScreen({super.key});

  @override
  State<SubscriptionScreen> createState() => _SubscriptionScreenState();
}

class _SubscriptionScreenState extends State<SubscriptionScreen> {
  final _service = SubscriptionService();
  bool _loading = true;
  bool _processing = false;

  @override
  void initState() {
    super.initState();
    _loadSubscription();
  }

  Future<void> _loadSubscription() async {
    await _service.init();
    if (mounted) {
      setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: GymTheme.colors.background,
      appBar: AppBar(
        backgroundColor: GymTheme.colors.background,
        elevation: 0,
        scrolledUnderElevation: 0,
        leading: const BackButton(),
        title: Text('Manage Subscription', style: GymTheme.text.screenTitle),
      ),
      body: _loading
          ? Center(
              child: CircularProgressIndicator(color: GymTheme.colors.accent),
            )
          : ListView(
              padding: EdgeInsets.all(GymTheme.spacing.md),
              children: [
                // Current Subscription
                _buildSectionHeader('Current Subscription'),
                const SizedBox(height: 8),
                _buildCurrentPlanCard(),

                const SizedBox(height: 24),

                // Subscription Offers
                _buildSectionHeader('Subscription Offers'),
                const SizedBox(height: 8),
                ...SubscriptionPlans.allProPlans.map(
                  (plan) => Padding(
                    padding: const EdgeInsets.only(bottom: 12),
                    child: _buildOfferCard(plan),
                  ),
                ),

                const SizedBox(height: 16),

                // More Information
                _buildSectionHeader('More Information'),
                const SizedBox(height: 8),
                _buildInfoLinks(),

                const SizedBox(height: 24),

                // Restore Purchases
                Center(
                  child: TextButton(
                    onPressed: _processing ? null : _restorePurchases,
                    child: Text(
                      'Restore Purchases',
                      style: TextStyle(
                        color: GymTheme.colors.accent,
                        fontSize: 14,
                      ),
                    ),
                  ),
                ),

                // Bottom padding
                SizedBox(
                  height: MediaQuery.of(context).padding.bottom +
                      kBottomNavigationBarHeight +
                      24,
                ),
              ],
            ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Text(
      title,
      style: TextStyle(
        fontSize: 12,
        fontWeight: FontWeight.w600,
        color: GymTheme.colors.textMuted,
      ),
    );
  }

  Widget _buildCurrentPlanCard() {
    final plan = _service.currentPlanDetails;
    final isFree = _service.currentPlan == SubscriptionPlan.free;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: GymTheme.colors.surface,
        borderRadius: BorderRadius.circular(GymTheme.radius.md),
        border: !isFree
            ? Border.all(color: GymTheme.colors.accent, width: 2)
            : null,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(
                isFree ? 'Free Subscription' : plan.name,
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: isFree
                      ? GymTheme.colors.accent
                      : GymTheme.colors.textPrimary,
                ),
              ),
              if (!isFree) ...[
                const SizedBox(width: 8),
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                  decoration: BoxDecoration(
                    color: GymTheme.colors.accent,
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: const Text(
                    'ACTIVE',
                    style: TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                ),
              ],
            ],
          ),
          const SizedBox(height: 4),
          Text(
            plan.description ?? plan.period,
            style: TextStyle(
              fontSize: 14,
              color: GymTheme.colors.textSecondary,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildOfferCard(PlanDetails plan) {
    final isCurrentPlan = _service.currentPlan == plan.plan;

    return Material(
      color: GymTheme.colors.surface,
      borderRadius: BorderRadius.circular(GymTheme.radius.md),
      child: InkWell(
        onTap: isCurrentPlan || _processing
            ? null
            : () => _showPurchaseDialog(plan),
        borderRadius: BorderRadius.circular(GymTheme.radius.md),
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(GymTheme.radius.md),
            border: isCurrentPlan
                ? Border.all(color: GymTheme.colors.accent, width: 2)
                : null,
          ),
          child: Row(
            children: [
              // Plan info
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 6, vertical: 2),
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
                        Text(
                          plan.name.replaceFirst('PRO ', ''),
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                            color: GymTheme.colors.textPrimary,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(
                      plan.period,
                      style: TextStyle(
                        fontSize: 12,
                        color: GymTheme.colors.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
              // Price
              Text(
                plan.price,
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: GymTheme.colors.textPrimary,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildInfoLinks() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: GymTheme.colors.surface,
        borderRadius: BorderRadius.circular(GymTheme.radius.md),
      ),
      child: Column(
        children: [
          _buildInfoRow('Privacy Policy', () {}),
          Divider(color: GymTheme.colors.divider, height: 16),
          _buildInfoRow('Terms & Conditions', () {}),
        ],
      ),
    );
  }

  Widget _buildInfoRow(String title, VoidCallback onTap) {
    return InkWell(
      onTap: onTap,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            title,
            style: TextStyle(
              fontSize: 14,
              color: GymTheme.colors.accent,
            ),
          ),
        ],
      ),
    );
  }

  void _showPurchaseDialog(PlanDetails plan) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: GymTheme.colors.surface,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(GymTheme.radius.md),
        ),
        title: Text(
          'Confirm Purchase',
          style: TextStyle(color: GymTheme.colors.textPrimary),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              plan.name,
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: GymTheme.colors.textPrimary,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              '${plan.price} - ${plan.period}',
              style: TextStyle(
                fontSize: 14,
                color: GymTheme.colors.textSecondary,
              ),
            ),
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.amber.withAlpha(51),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                children: [
                  const Icon(Icons.warning, color: Colors.amber, size: 20),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'STUB: This is a test purchase. No payment will be processed.',
                      style: TextStyle(
                        fontSize: 12,
                        color: GymTheme.colors.textSecondary,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: Text(
              'Cancel',
              style: TextStyle(color: GymTheme.colors.textSecondary),
            ),
          ),
          TextButton(
            onPressed: () async {
              Navigator.pop(ctx);
              await _processPurchase(plan);
            },
            child: Text(
              'Confirm Purchase (STUB)',
              style: TextStyle(color: GymTheme.colors.accent),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _processPurchase(PlanDetails plan) async {
    setState(() => _processing = true);

    final success = await _service.purchaseStub(plan.plan);

    if (mounted) {
      setState(() => _processing = false);

      if (success) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text('Subscription active!'),
            backgroundColor: GymTheme.colors.accent,
          ),
        );
      }
    }
  }

  Future<void> _restorePurchases() async {
    setState(() => _processing = true);

    final restored = await _service.restorePurchases();

    if (mounted) {
      setState(() => _processing = false);

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            restored ? 'Purchases restored!' : 'No previous purchases found.',
          ),
          backgroundColor: GymTheme.colors.surface,
        ),
      );
    }
  }
}
