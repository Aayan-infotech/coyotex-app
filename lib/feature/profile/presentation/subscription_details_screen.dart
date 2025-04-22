import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shimmer/shimmer.dart';

import '../../../core/utills/branded_primary_button.dart';
import '../../auth/data/view_model/user_view_model.dart';
import '../../auth/screens/subscription_screen.dart';

class SubscriptionDetailsScreen extends StatefulWidget {
  const SubscriptionDetailsScreen({super.key});

  @override
  State<SubscriptionDetailsScreen> createState() =>
      _SubscriptionDetailsScreenState();
}

class _SubscriptionDetailsScreenState extends State<SubscriptionDetailsScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final userViewModel = Provider.of<UserViewModel>(context, listen: false);
      if (userViewModel.subscriptionDetail == null) {
        userViewModel.getSubscriptionDetails();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final userViewModel = Provider.of<UserViewModel>(context);
    final detail = userViewModel.subscriptionDetail;

    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: detail == null
          ? userViewModel.isLoading
              ? const _ShimmerLayout()
              : const Center(
                  child: Text(
                    "No subscription found",
                    style: TextStyle(color: Colors.white, fontSize: 18),
                  ),
                )
          : _ActualLayout(userViewModel: userViewModel),
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
