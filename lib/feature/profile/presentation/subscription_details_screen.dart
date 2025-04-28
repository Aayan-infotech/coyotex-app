import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shimmer/shimmer.dart';

import '../../../core/utills/app_colors.dart';
import '../../../core/utills/branded_primary_button.dart';
import '../../auth/data/model/plans.dart';
import '../../auth/data/subscription_provider.dart';
import '../../auth/data/view_model/user_view_model.dart';
import '../../auth/screens/subscription_screen.dart';

class SubscriptionDetailsScreen extends StatefulWidget {
  const SubscriptionDetailsScreen({super.key});

  @override
  State<SubscriptionDetailsScreen> createState() =>
      _SubscriptionDetailsScreenState();
}

class _SubscriptionDetailsScreenState extends State<SubscriptionDetailsScreen> {
  bool _initialized = false;

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => SubscriptionProvider(),
      builder: (context, child) {
        final subProvider =
            Provider.of<SubscriptionProvider>(context, listen: false);
        if (!_initialized) {
          _initialized = true;
          subProvider.fetchPlans();
        }

        return Consumer<SubscriptionProvider>(
          builder: (context, subProvider, _) {
            final plan = subProvider.selectedPlan;

            return Scaffold(
              appBar: AppBar(
                backgroundColor: Colors.transparent,
                iconTheme: const IconThemeData(color: Colors.white),
              ),
              backgroundColor: Colors.black,
              body: SafeArea(
                child: subProvider.isLoading
                    ? _buildShimmer()
                    : plan == null
                        ? const Center(
                            child: Text(
                              "No plan found.",
                              style: TextStyle(color: Colors.white),
                            ),
                          )
                        : _buildContent(plan, subProvider),
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildContent(Plan plan, SubscriptionProvider subProvider) {
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          const SizedBox(height: 16),
          Image.asset("assets/images/logo.png", height: 60),
          const SizedBox(height: 12),
          const Text(
            'PLANS AND PRICING',
            style: TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
              letterSpacing: 2,
            ),
          ),
          const SizedBox(height: 20),
          ToggleButtons(
            isSelected: [
              !subProvider.isAnnual,
              subProvider.isAnnual,
            ],
            onPressed: (index) {
              subProvider.togglePlan(index == 1);
            },
            borderRadius: BorderRadius.circular(10),
            selectedColor: Colors.white,
            fillColor: Pallete.primaryColor,
            color: Colors.white,
            children: const [
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 20),
                child: Text('Monthly',
                    style: TextStyle(fontWeight: FontWeight.w500)),
              ),
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 20),
                child: Text('Annually',
                    style: TextStyle(fontWeight: FontWeight.w500)),
              ),
            ],
          ),
          const SizedBox(height: 30),
          Container(
            margin: const EdgeInsets.symmetric(horizontal: 20),
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.black87,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: Colors.red.shade700, width: 1.5),
              boxShadow: [
                BoxShadow(
                  color: Colors.red.shade900.withAlpha(100),
                  blurRadius: 8,
                  spreadRadius: 2,
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Text(
                  '\$${plan.planAmount.toStringAsFixed(2)}',
                  style: const TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                    color: Pallete.primaryColor,
                  ),
                ),
                const SizedBox(height: 10),
                Text(
                  plan.planName,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 16),
                ...plan.description.map(
                  (desc) => Padding(
                    padding: const EdgeInsets.only(bottom: 8),
                    child: Row(
                      children: [
                        const Icon(Icons.check_circle,
                            color: Pallete.primaryColor),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(desc,
                              style: const TextStyle(color: Colors.white)),
                        ),
                      ],
                    ),
                  ),
                ),

                const SizedBox(height: 20),

                // 👇 Auto-renew disclaimer for Apple Review Guidelines
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 8.0),
                  child: Text(
                    "\$${plan.planAmount.toStringAsFixed(2)} per year. Subscription automatically renews unless canceled at least 24 hours before the end of the current period. "
                    "You can manage or cancel your subscription in your App Store account settings.",
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 12,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),

                const SizedBox(height: 20),

                BrandedPrimaryButton(
                  isEnabled: true,
                  name: "SUBSCRIBE",
                  onPressed: () {},
                ),
                const SizedBox(height: 10),
                BrandedPrimaryButton(
                  isEnabled: true,
                  name: "RESTORE",
                  onPressed: () {},
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildShimmer() {
    return Padding(
      padding: const EdgeInsets.all(20.0),
      child: Shimmer.fromColors(
        baseColor: Colors.grey.shade800,
        highlightColor: Colors.grey.shade600,
        child: Column(
          children: [
            const SizedBox(height: 16),
            Container(
              height: 60,
              width: 60,
              decoration: const BoxDecoration(
                color: Colors.white,
                shape: BoxShape.circle,
              ),
            ),
            const SizedBox(height: 12),
            Container(
              height: 20,
              width: 200,
              color: Colors.white,
            ),
            const SizedBox(height: 30),
            Container(
              margin: const EdgeInsets.symmetric(horizontal: 20),
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.grey.shade900,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: Colors.red.shade700, width: 1.5),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Container(height: 32, width: 100, color: Colors.white),
                  const SizedBox(height: 10),
                  Container(height: 20, width: 140, color: Colors.white),
                  const SizedBox(height: 16),
                  ...List.generate(
                    3,
                    (index) => Padding(
                      padding: const EdgeInsets.only(bottom: 8),
                      child: Row(
                        children: [
                          const Icon(Icons.check_circle, color: Colors.white),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Container(
                              height: 16,
                              color: Colors.white,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),
                  Container(
                    height: 44,
                    width: double.infinity,
                    color: Colors.white,
                  ),
                  const SizedBox(height: 10),
                  Container(
                    height: 44,
                    width: double.infinity,
                    color: Colors.white,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ActualLayout extends StatelessWidget {
  final UserViewModel userViewModel;

  const _ActualLayout({required this.userViewModel});

  @override
  Widget build(BuildContext context) {
    final detail = userViewModel.subscriptionDetail;

    return Stack(
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Column(
            children: [
              const SizedBox(height: 32),
              Image.asset('assets/images/logo.png', height: 100),
              const SizedBox(height: 16),
              const Text(
                'CYOTE',
                style: TextStyle(
                  color: Colors.orange,
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 16),
              const Text(
                'Coyote is the largest premium Hunt Track Planning platform with more than 25k users in 17 states...',
                textAlign: TextAlign.center,
                style: TextStyle(color: Colors.white70),
              ),
            ],
          ),
        ),
        Align(
          alignment: Alignment.bottomCenter,
          child: Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(horizontal: 16),
            decoration: const BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Padding(
                  padding: EdgeInsets.symmetric(vertical: 16),
                  child: Text(
                    'Your Subscription',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.black,
                    ),
                  ),
                ),
                _buildRow('Month', detail?.purchaseMonth),
                _buildRow('Amount', '\$${detail?.amount ?? "0.0"}'),
                _buildRow('Begins', detail?.formattedPurchaseDate),
                _buildRow('Ends', detail?.formattedEndsDate),
                _buildRow('Type', detail?.planName),
                _buildRow('Status', detail?.status?.toUpperCase()),
                const SizedBox(height: 16),
                Visibility(
                  visible: detail?.status?.toLowerCase() == "expired",
                  child: BrandedPrimaryButton(
                      isEnabled: true,
                      isUnfocus: true,
                      name: "Renew",
                      onPressed: () {
                        Navigator.of(context)
                            .push(MaterialPageRoute(builder: (context) {
                          return const SubscriptionScreen(
                            from: "subDetail",
                          );
                        }));
                      }),
                ),
                const SizedBox(height: 16),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildRow(String label, String? value) {
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(label,
                style: const TextStyle(
                    color: Colors.grey, fontWeight: FontWeight.bold)),
            Text(value ?? 'N/A',
                style: const TextStyle(
                    color: Colors.black, fontWeight: FontWeight.w600)),
          ],
        ),
        const Divider(color: Colors.grey),
      ],
    );
  }
}

class _ShimmerLayout extends StatelessWidget {
  const _ShimmerLayout();

  @override
  Widget build(BuildContext context) {
    return Shimmer.fromColors(
      baseColor: Colors.grey.shade300,
      highlightColor: Colors.grey.shade100,
      child: Stack(
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Column(
              children: [
                const SizedBox(height: 32),
                Container(height: 100, width: 100, color: Colors.white),
                const SizedBox(height: 16),
                Container(height: 24, width: 80, color: Colors.white),
                const SizedBox(height: 16),
                Container(
                    height: 48, width: double.infinity, color: Colors.white),
              ],
            ),
          ),
          Align(
            alignment: Alignment.bottomCenter,
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              decoration: const BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: List.generate(5, (index) {
                  return Column(
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Container(height: 16, width: 80, color: Colors.grey),
                          Container(height: 16, width: 100, color: Colors.grey),
                        ],
                      ),
                      const Divider(color: Colors.grey),
                      const SizedBox(height: 8),
                    ],
                  );
                }),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
