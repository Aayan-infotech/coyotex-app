import 'package:flutter/foundation.dart';
import 'package:in_app_purchase/in_app_purchase.dart';

class PurchaseProvider with ChangeNotifier {
  static const List<String> _kProductIds = <String>[
    'coyotex_premium_monthly',
    'coyotex_premium_yearly',
  ];

  final InAppPurchase _iap = InAppPurchase.instance;
  bool _isAvailable = false;
  List<ProductDetails> _products = [];
  final List<PurchaseDetails> _purchases = [
    PurchaseDetails(
      productID: 'coyotex_premium_monthly',
      verificationData: PurchaseVerificationData(
        localVerificationData: 'dummy_local_data_monthly',
        serverVerificationData: 'dummy_server_data_monthly',
        source: 'app_store',
      ),
      transactionDate: DateTime.now()
          .subtract(const Duration(days: 3))
          .millisecondsSinceEpoch
          .toString(),
      status: PurchaseStatus.purchased,
    ),
    PurchaseDetails(
      productID: 'coyotex_premium_yearly',
      verificationData: PurchaseVerificationData(
        localVerificationData: 'dummy_local_data_yearly',
        serverVerificationData: 'dummy_server_data_yearly',
        source: 'app_store',
      ),
      transactionDate: DateTime.now()
          .subtract(const Duration(days: 30))
          .millisecondsSinceEpoch
          .toString(),
      status: PurchaseStatus.purchased,
    ),
  ];

  bool get isAvailable => _isAvailable;

  List<ProductDetails> get products => _products;

  List<PurchaseDetails> get purchases => _purchases;

  PurchaseProvider() {
    _initialize();
    _iap.purchaseStream.listen(_onPurchaseUpdate, onDone: () {
      print("Purchase stream closed");
    }, onError: (error) {
      print("Purchase stream error: $error");
    });
  }

  Future<void> _initialize() async {
    try {
      final bool available = await _iap.isAvailable();
      _isAvailable = available;

      if (_isAvailable) {
        print("⚠️ K Products: ${_kProductIds.toSet()}");
        final ProductDetailsResponse response =
            await _iap.queryProductDetails(_kProductIds.toSet());
        print("⚠️ Product response: ${response.error}");
        if (response.notFoundIDs.isNotEmpty) {
          print("⚠️ Not Found Product IDs: ${response.notFoundIDs}");
        }else{
          _products = response.productDetails;
        }


        print("✅ Found products: ${_products.map((e) => e.id).toList()}");
      } else {
        print("❌ Store not available");
      }
    } catch (e) {
      print("❌ Error during initialization: $e");
    }

    notifyListeners();
  }

  void _onPurchaseUpdate(List<PurchaseDetails> purchaseDetailsList) {
    for (final purchase in purchaseDetailsList) {
      print("🔄 Purchase Update: ${purchase.productID} - ${purchase.status}");

      if (purchase.status == PurchaseStatus.purchased ||
          purchase.status == PurchaseStatus.restored) {
        _verifyAndDeliver(purchase);
      }

      if (purchase.pendingCompletePurchase) {
        _iap.completePurchase(purchase);
      }
    }
  }

  void _verifyAndDeliver(PurchaseDetails purchase) {
    // NOTE: You should ideally verify purchase with backend here.
    _purchases.add(purchase);
    notifyListeners();
  }

  Future<void> buyProduct(ProductDetails product) async {
    final PurchaseParam purchaseParam = PurchaseParam(productDetails: product);

    try {
      // Subscriptions are also non-consumables
      await _iap.buyNonConsumable(purchaseParam: purchaseParam);
    } catch (e) {
      print("❌ Error while buying product: $e");
    }
  }

  Future<void> restorePurchases() async {
    try {
      await _iap.restorePurchases();
    } catch (e) {
      print("❌ Error restoring purchases: $e");
    }
  }
}
