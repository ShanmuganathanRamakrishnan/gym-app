// ignore_for_file: use_build_context_synchronously
import 'package:flutter/material.dart';
import '../../theme/gym_theme.dart';
import '../../services/subscription_service.dart';

/// Subscription management screen.
///
/// Refined UI to visually match Hevy's premium layout and hierarchy.
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
                const SizedBox(height: 12),
                _buildCurrentPlanCard(),

                const SizedBox(height: 32),

                // Subscription Offers
                _buildSectionHeader('Subscription Offers'),
                const SizedBox(height: 12),
                ...SubscriptionPlans.allProPlans.map(
                  (plan) => Padding(
                    padding: const EdgeInsets.only(bottom: 12),
                    child: _buildOfferCard(plan),
                  ),
                ),

                const SizedBox(height: 24),

                // More Information
                _buildSectionHeader('More Information'),
                const SizedBox(height: 12),
                _buildInfoLinks(),

                const SizedBox(height: 32),

                // Restore Purchases
                Center(
                  child: TextButton(
                    onPressed: _processing ? null : _restorePurchases,
                    child: Text(
                      'Restore Purchases',
                      style: TextStyle(
                        color: GymTheme.colors.accent,
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
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
        letterSpacing: 0.5,
      ),
    );
  }

  Widget _buildCurrentPlanCard() {
    final plan = _service.currentPlanDetails;
    final isFree = _service.currentPlan == SubscriptionPlan.free;

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: GymTheme.colors.surface,
        borderRadius: BorderRadius.circular(16),
        border: !isFree
            ? Border.all(color: GymTheme.colors.accent, width: 2)
            : null,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              if (isFree)
                Text(
                  'Free Subscription',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: GymTheme.colors.accent,
                  ),
                )
              else ...[
                Text(
                  plan.name,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
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
          const SizedBox(height: 8),
          Text(
            isFree
                ? 'You are currently on the free plan'
                : (plan.description ?? plan.period),
            style: TextStyle(
              fontSize: 14,
              color: GymTheme.colors.textSecondary,
              height: 1.4,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildOfferCard(PlanDetails plan) {
    // Note: Offer cards are NOT highlighted even if active,
    // to keep the "Current Subscription" section as the source of truth.
    // They act as buttons to switch/buy.
    final isCurrentPlan = _service.currentPlan == plan.plan;

    return Material(
      color: GymTheme.colors.surface,
      borderRadius: BorderRadius.circular(16),
      child: InkWell(
        onTap: isCurrentPlan || _processing
            ? null
            : () => _showPurchaseDialog(plan),
        borderRadius: BorderRadius.circular(16),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
          child: Row(
            children: [
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
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(
                      plan.period,
                      style: TextStyle(
                        fontSize: 13,
                        color: GymTheme.colors.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
              Text(
                plan.price,
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
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
      decoration: BoxDecoration(
        color: GymTheme.colors.surface,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        children: [
          _buildInfoRow('Privacy Policy', () {}),
          Divider(
            color: GymTheme.colors.divider,
            height: 1,
            thickness: 1,
            indent: 16,
            endIndent: 16,
          ),
          _buildInfoRow('Terms & Conditions', () {}),
        ],
      ),
    );
  }

  Widget _buildInfoRow(String title, VoidCallback onTap) {
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 16),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              title,
              style: TextStyle(
                fontSize: 14,
                color: GymTheme.colors.accent,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showPurchaseDialog(PlanDetails plan) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: GymTheme.colors.surface,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        title: const Text(
          'Confirm Purchase',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              plan.name,
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: Colors.white,
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
            const SizedBox(height: 20),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.amber.withAlpha(40),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.amber.withAlpha(80)),
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Icon(Icons.warning_amber_rounded,
                      color: Colors.amber, size: 20),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      'STUB MODE: This is a test. No real payment will occur.',
                      style: TextStyle(
                        fontSize: 13,
                        color: GymTheme.colors.textSecondary,
                        height: 1.3,
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
            style: TextButton.styleFrom(
              foregroundColor: GymTheme.colors.accent,
            ),
            child: const Text(
              'Confirm (Stub)',
              style: TextStyle(fontWeight: FontWeight.bold),
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
            behavior: SnackBarBehavior.floating,
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
            style: const TextStyle(color: Colors.white),
          ),
          backgroundColor: GymTheme.colors.surface,
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }
}
