import 'package:shared_preferences/shared_preferences.dart';

const String _kSubscriptionKey = 'gym_app_subscription_plan';

/// Subscription plan identifiers.
enum SubscriptionPlan {
  free,
  proMonthly,
  proYearly,
  proLifetime,
}

/// Subscription plan details for display.
class PlanDetails {
  final SubscriptionPlan plan;
  final String name;
  final String price;
  final String period;
  final String? description;

  const PlanDetails({
    required this.plan,
    required this.name,
    required this.price,
    required this.period,
    this.description,
  });
}

/// Available subscription plans with placeholder pricing.
/// NOTE: Prices are placeholders. Real prices should come from payment SDK.
class SubscriptionPlans {
  static const free = PlanDetails(
    plan: SubscriptionPlan.free,
    name: 'Free Subscription',
    price: '₹0',
    period: 'Forever',
    description: 'You will have free access forever',
  );

  static const proMonthly = PlanDetails(
    plan: SubscriptionPlan.proMonthly,
    name: 'PRO Monthly',
    price: '₹249',
    period: 'Billed Monthly',
    description: 'Cancel anytime',
  );

  static const proYearly = PlanDetails(
    plan: SubscriptionPlan.proYearly,
    name: 'PRO Yearly',
    price: '₹1,999',
    period: 'Billed Annually',
    description: 'Save 33% vs monthly',
  );

  static const proLifetime = PlanDetails(
    plan: SubscriptionPlan.proLifetime,
    name: 'PRO Lifetime',
    price: '₹6,500',
    period: 'Pay Once',
    description: 'One-time purchase, forever access',
  );

  static List<PlanDetails> get allProPlans =>
      [proMonthly, proYearly, proLifetime];
}

/// Subscription service for managing user subscription state.
///
/// NOTE: This is a STUB implementation for UI development.
/// TODO: Integrate with actual payment SDK (RevenueCat, Stripe, etc.)
class SubscriptionService {
  static final SubscriptionService _instance = SubscriptionService._internal();
  factory SubscriptionService() => _instance;
  SubscriptionService._internal();

  SubscriptionPlan _currentPlan = SubscriptionPlan.free;
  bool _initialized = false;

  /// Initialize and load stored subscription state.
  Future<void> init() async {
    if (_initialized) return;

    try {
      final prefs = await SharedPreferences.getInstance();
      final planIndex = prefs.getInt(_kSubscriptionKey) ?? 0;
      _currentPlan = SubscriptionPlan.values[planIndex];
    } catch (e) {
      _currentPlan = SubscriptionPlan.free;
    }

    _initialized = true;
  }

  /// Get current subscription plan.
  SubscriptionPlan get currentPlan => _currentPlan;

  /// Check if user has PRO access.
  bool get isPro => _currentPlan != SubscriptionPlan.free;

  /// Get details for current plan.
  PlanDetails get currentPlanDetails {
    switch (_currentPlan) {
      case SubscriptionPlan.free:
        return SubscriptionPlans.free;
      case SubscriptionPlan.proMonthly:
        return SubscriptionPlans.proMonthly;
      case SubscriptionPlan.proYearly:
        return SubscriptionPlans.proYearly;
      case SubscriptionPlan.proLifetime:
        return SubscriptionPlans.proLifetime;
    }
  }

  /// Purchase a subscription plan (STUB).
  ///
  /// TODO: Implement actual payment SDK integration.
  /// This stub simulates a 1-second processing delay before returning success.
  Future<bool> purchaseStub(SubscriptionPlan plan) async {
    // Simulate network/payment processing delay
    await Future.delayed(const Duration(seconds: 1));

    // TODO: Replace with actual payment verification
    // In production:
    // 1. Call payment SDK to initiate purchase
    // 2. Verify receipt with backend
    // 3. Update subscription state on success

    _currentPlan = plan;
    await _saveSubscription();
    return true;
  }

  /// Restore previous purchases (STUB).
  ///
  /// TODO: Implement actual restore flow with payment SDK.
  Future<bool> restorePurchases() async {
    // Simulate restore check
    await Future.delayed(const Duration(milliseconds: 500));

    // TODO: Replace with actual restore logic
    // In production:
    // 1. Call payment SDK restore function
    // 2. Verify any valid receipts
    // 3. Update subscription state accordingly

    // Stub always returns "no purchases found" for free users
    return _currentPlan != SubscriptionPlan.free;
  }

  Future<void> _saveSubscription() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setInt(_kSubscriptionKey, _currentPlan.index);
    } catch (e) {
      // Log error silently
    }
  }
}
