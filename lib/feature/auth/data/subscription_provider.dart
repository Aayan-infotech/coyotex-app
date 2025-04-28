import 'package:flutter/cupertino.dart';

import '../../../core/services/server_calls/auth_apis.dart';
import 'model/plans.dart';

class SubscriptionProvider extends ChangeNotifier {
  final LoginAPIs _loginAPIs = LoginAPIs();
  bool _isAnnual = false;
  bool get isAnnual => _isAnnual;

  List<Plan> _lstPlan = [];
  List<Plan> get lstPlan => _lstPlan;

  bool _isLoading = true;
  bool get isLoading => _isLoading;

  Plan? get selectedPlan {
    if (_lstPlan.isEmpty) return null;
    return _lstPlan.firstWhere(
          (plan) => _isAnnual
          ? plan.planName.toLowerCase().contains("year")
          : plan.planName.toLowerCase().contains("month"),
      orElse: () => _lstPlan.first,
    );
  }

  void togglePlan(bool value) {
    _isAnnual = value;
    notifyListeners();
  }

  Future<void> fetchPlans() async {
    _isLoading = true;
    notifyListeners();
    final response = await _loginAPIs.getSubscription();
    debugPrint("RRESPONSE => ${response.success}");
    if (response.success) {
      _lstPlan = (response.data["subscriptions"] as List)
          .map((e) => Plan.fromJson(e))
          .toList();
    }
    _isLoading = false;
    notifyListeners();
  }
}
