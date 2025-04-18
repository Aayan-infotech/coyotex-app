import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../auth/data/view_model/user_view_model.dart';

class SubscriptionDetailsScreen extends StatelessWidget {
  const SubscriptionDetailsScreen({super.key});



  @override
  Widget build(BuildContext context) {

    WidgetsBinding.instance.addPostFrameCallback((_) {
      final userViewModel = Provider.of<UserViewModel>(context, listen: false);
      if (userViewModel.subscriptionDetail == null) {
        userViewModel.getSubscriptionDetails();
      }
    });

    return Consumer<UserViewModel>(builder: (context, userViewModel, child) {
      return Scaffold(
        backgroundColor: Colors.black,
        appBar: AppBar(
          backgroundColor: Colors.black,
          elevation: 0,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back, color: Colors.white),
            onPressed: () => Navigator.of(context).pop(),
          ),
          actions: [
            // IconButton(
            //   icon: const Icon(Icons.file_upload, color: Colors.white),
            //   onPressed: () {
            //     // Handle upload action
            //   },
            // ),
          ],
        ),
        body: Stack(
          children: [
            // Content above the bottom sheet
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  // Logo
                  Image.asset(
                    'assets/images/logo.png',
                    // Replace with your logo asset
                    height: 100,
                  ),
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

                  // Description
                  const Text(
                    'Coyote is largest premium Hunt Track Planning platform with more than 25k users in 17 states, and coverage of every major region ...',
                    textAlign: TextAlign.center,
                    style: TextStyle(color: Colors.white70),
                  ),
                ],
              ),
            ),

            // Persistent Bottom Sheet
            Align(
              alignment: Alignment.bottomCenter,
              child: _buildPersistentBottomSheet(context, userViewModel),
            ),
          ],
        ),
      );
    });
  }

  Widget _buildPersistentBottomSheet(
      BuildContext context, UserViewModel userViewModel) {
    return Container(
      width: double.infinity,
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(16),
          topRight: Radius.circular(16),
        ),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Header
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

          // Subscription Details
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Column(
              children: [
                _buildSubscriptionRow('Month',
                    userViewModel.subscriptionDetail?.purchaseMonth ?? "N/A"),
                const Divider(color: Colors.grey),
                _buildSubscriptionRow('Amount',
                    '\$${userViewModel.subscriptionDetail?.amount ?? "0.0"}'),
                const Divider(color: Colors.grey),
                _buildSubscriptionRow('Begins',
                    userViewModel.subscriptionDetail?.formattedPurchaseDate ?? "N/A"),
                const Divider(color: Colors.grey),
                _buildSubscriptionRow('Ends',
                    userViewModel.subscriptionDetail?.formattedEndsDate ?? "N/A"),
                const Divider(color: Colors.grey),
                _buildSubscriptionRow('Type',
                    userViewModel.subscriptionDetail?.planName ?? "N/A"),
                const Divider(color: Colors.grey),
              ],
            ),
          ),

          const SizedBox(height: 16),

          // Buttons
          // Padding(
          //   padding: const EdgeInsets.only(bottom: 16, left: 16, right: 16),
          //   child: Row(
          //     mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          //     children: [
          //       Expanded(
          //           child: BrandedPrimaryButton(
          //               isEnabled: true,
          //               isUnfocus: true,
          //               name: "Renew",
          //               onPressed: () {})),
          //       const SizedBox(
          //         width: 5,
          //       ),
          //       Expanded(
          //           child: BrandedPrimaryButton(
          //               isEnabled: true, name: "Cancel", onPressed: () {}))
          //     ],
          //   ),
          // ),
        ],
      ),
    );
  }

  Widget _buildSubscriptionRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: const TextStyle(
              color: Colors.grey,
              fontWeight: FontWeight.bold,
            ),
          ),
          Text(
            value,
            style: const TextStyle(
              color: Colors.black,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}
