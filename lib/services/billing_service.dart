import 'dart:async';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:in_app_purchase/in_app_purchase.dart';

class BillingService {
  static final InAppPurchase _iap = InAppPurchase.instance;
  static StreamSubscription<List<PurchaseDetails>>? _subscription;
  static Function(PurchaseDetails)? _onSuccess;
  static Function(String)? _onError;
  static VoidCallback? _onCancel;

  // Guards to avoid duplicate callbacks when the purchase stream re-emits
  // historical events (common on Android) or when init() is called repeatedly.
  static bool _purchaseFlowActive = false;
  static String? _lastEmittedEventKey;

  static void init({
    required Function(PurchaseDetails) onSuccess,
    Function(String)? onError,
    VoidCallback? onCancel,
  }) {
    _onSuccess = onSuccess;
    _onError = onError;
    _onCancel = onCancel;

    // If init is called multiple times (e.g., from dialogs), avoid stacking
    // multiple listeners that would emit callbacks repeatedly.
    _subscription?.cancel();
    _subscription = _iap.purchaseStream.listen((purchases) {
      for (final purchase in purchases) {
        final eventKey = _eventKey(purchase);
        if (_lastEmittedEventKey == eventKey) {
          continue;
        }
        _lastEmittedEventKey = eventKey;

        if (purchase.status == PurchaseStatus.purchased) {
          _purchaseFlowActive = false;
          _onSuccess?.call(purchase);
          _iap.completePurchase(purchase);
        } else if (purchase.status == PurchaseStatus.error) {
          _purchaseFlowActive = false;
          final error = purchase.error?.message ?? 'Unknown purchase error';
          _onError?.call(error);
          _iap.completePurchase(purchase);
        } else if (purchase.status == PurchaseStatus.canceled) {
          // User closed the Play/App Store sheet (back button / cancel).
          // Only notify cancel if we actually initiated a purchase flow.
          if (_purchaseFlowActive) {
            _purchaseFlowActive = false;
            _onCancel?.call();
          }
        } else if (purchase.status == PurchaseStatus.pending) {
          // Purchase is pending, wait for it to complete
          print('Purchase pending: ${purchase.productID}');
        } else if (purchase.status == PurchaseStatus.restored) {
          // Handle restored purchases if needed
          _iap.completePurchase(purchase);
        }
      }
    });
  }

  static Future<void> buy(String productId) async {
    try {
      _purchaseFlowActive = true;
      // Check platform support
      if (!Platform.isAndroid && !Platform.isIOS) {
        _purchaseFlowActive = false;
        _onError?.call('In-app purchases are only supported on Android and iOS devices.');
        return;
      }
      
      final platformName = Platform.isAndroid ? 'Google Play' : 'App Store';
      print('Querying product details from $platformName for product ID: $productId');
      
      final response = await _iap.queryProductDetails({productId});

      if (response.error != null) {
        _purchaseFlowActive = false;
        final errorMsg = response.error!.message;
        print('Error querying product: $errorMsg');
        _onError?.call('Failed to load product from $platformName: $errorMsg');
        return;
      }

      if (response.productDetails.isEmpty) {
        _purchaseFlowActive = false;
        print('Product not found: $productId on $platformName');
        _onError?.call('Product "$productId" not found in $platformName. Please ensure the product is configured correctly.');
        return;
      }

      final productDetails = response.productDetails.first;
      print('Product found: ${productDetails.title} - ${productDetails.price}');
      
      final purchaseParam = PurchaseParam(productDetails: productDetails);

      print('Initiating purchase...');
      await _iap.buyConsumable(purchaseParam: purchaseParam);
    } catch (e) {
      _purchaseFlowActive = false;
      final platformName = Platform.isAndroid ? 'Google Play' : 'App Store';
      print('Exception during purchase: $e');
      _onError?.call('Failed to initiate purchase on $platformName: $e');
    }
  }

  static void dispose() {
    _subscription?.cancel();
    _subscription = null;
    _onSuccess = null;
    _onError = null;
    _onCancel = null;
    _purchaseFlowActive = false;
    _lastEmittedEventKey = null;
  }

  static String _eventKey(PurchaseDetails p) {
    final purchaseId = (p.purchaseID ?? '').trim();
    final txnDate = (p.transactionDate ?? '').trim();
    // purchaseID can be null/empty on some platforms; include multiple fields.
    return '${p.productID}|${p.status.name}|$purchaseId|$txnDate';
  }
}
