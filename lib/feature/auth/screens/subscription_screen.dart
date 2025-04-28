import 'package:coyotex/core/utills/app_colors.dart';
import 'package:coyotex/core/utills/branded_primary_button.dart';
import 'package:coyotex/feature/auth/data/purchase_provider.dart';
import 'package:flutter/material.dart';
import 'package:in_app_purchase/in_app_purchase.dart';
import 'package:provider/provider.dart';

class SubscriptionScreen extends StatefulWidget {
  final String from;

  const SubscriptionScreen({super.key, required this.from});

  @override
  State<SubscriptionScreen> createState() => _SubscriptionScreenState();
}

class _SubscriptionScreenState extends State<SubscriptionScreen> {
  ProductDetails? _selectedProduct;

  final _products = [
    ProductDetails(
      id: 'coyotex_premium_monthly',
      title: 'Monthly Plan',
      description: 'Access all premium features monthly',
      price: '\$9.99',
      rawPrice: 9.99,
      currencyCode: 'USD',
    ),
    ProductDetails(
      id: 'coyotex_premium_yearly',
      title: 'Yearly Plan',
      description: 'Access all premium features yearly',
      price: '\$99.99',
      rawPrice: 99.99,
      currencyCode: 'USD',
    ),
  ];

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        children: [
          Consumer<PurchaseProvider>(
            builder: (context, iapProvider, child) {
              if (!iapProvider.isAvailable) {
                return const Center(
                  child: Text("Store unavailable",
                      style: TextStyle(color: Colors.white)),
                );
              }

              if (_products.isEmpty) {
                return const Center(
                  child: Text("No products available",
                      style: TextStyle(color: Colors.white)),
                );
              }

              return Center(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: SingleChildScrollView(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Image.asset(
                          "assets/images/logo.png",
                          width: MediaQuery.of(context).size.width * 0.3,
                        ),
                        const SizedBox(height: 30),
                        const Text(
                          "Coyotex",
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 24,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        const Text(
                          "Stay on top of your hunting adventures with our all-in-one tracking app!",
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 14,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        const SizedBox(height: 30),
                        const Text(
                          "Select Suitable Plan",
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 20,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        const SizedBox(height: 20),
                        // GridView to display subscription plans
                        GridView.builder(
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          gridDelegate:
                              const SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: 2,
                            crossAxisSpacing: 16,
                            mainAxisSpacing: 16,
                            childAspectRatio:
                                3 / 2, // Adjusted aspect ratio for plan cards
                          ),
                          itemCount: _products.length,
                          itemBuilder: (context, index) {
                            final product = _products[index];
                            return _buildPlanCard(product);
                          },
                        ),
                      ],
                    ),
                  ),
                ),
              );
            },
          ),
          Positioned(
            bottom: 40,
            left: 16,
            right: 16,
            child: BrandedPrimaryButton(
                isEnabled: _selectedProduct != null,
                // Disable button if no plan is selected
                suffixIcon: const Icon(
                  Icons.arrow_forward,
                  color: Colors.white,
                ),
                name: "Make Payment",
                onPressed: () async {
                  if (_selectedProduct != null) {
                    final provider =
                        Provider.of<PurchaseProvider>(context, listen: false);
                    provider.buyProduct(_selectedProduct!);
                  } else {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text("Please select a plan."),
                      ),
                    );
                  }
                }),
          )
        ],
      ),
    );
  }

  Widget _buildPlanCard(ProductDetails product) {
    final isSelected = _selectedProduct?.id == product.id;

    return GestureDetector(
      onTap: () {
        setState(() {
          _selectedProduct = product;
        });
      },
      child: Container(
        decoration: BoxDecoration(
          color: isSelected ? Pallete.primaryColor : Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSelected ? Pallete.primaryColor : Colors.transparent,
            width: 2,
          ),
        ),
        child: Stack(
          children: [
            if (isSelected)
              const Positioned(
                top: 8,
                right: 8,
                child: Icon(
                  Icons.check_circle,
                  color: Colors.white,
                  size: 24,
                ),
              ),
            Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    product.title,
                    style: TextStyle(
                      color: isSelected ? Colors.white : Colors.black,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 10),
                  Text(
                    product.price,
                    style: TextStyle(
                      color: isSelected ? Colors.white : Colors.black,
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
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
