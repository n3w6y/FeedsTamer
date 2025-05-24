import 'dart:async';
import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:in_app_purchase/in_app_purchase.dart';
import 'package:in_app_purchase_android/in_app_purchase_android.dart';
import 'package:in_app_purchase_storekit/in_app_purchase_storekit.dart';
import 'package:logger/logger.dart';
import 'package:feedstamer/models/user_profile.dart';
import 'package:feedstamer/services/auth_service.dart';

class SubscriptionService {
  // Singleton pattern
  static final SubscriptionService _instance = SubscriptionService._internal();
  factory SubscriptionService() => _instance;
  SubscriptionService._internal();

  // Product IDs
  static const String _kPremiumMonthlyId = 'premium_monthly';
  static const String _kPremiumYearlyId = 'premium_yearly';
  static const String _kBusinessMonthlyId = 'business_monthly';

  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final AuthService _authService = AuthService();
  final InAppPurchase _inAppPurchase = InAppPurchase.instance;
  final logger = Logger();

  late StreamSubscription<List<PurchaseDetails>> _subscription;
  List<ProductDetails> _products = [];
  bool _isAvailable = false;
  bool _isLoading = true;

  // Getters
  bool get isAvailable => _isAvailable;
  bool get isLoading => _isLoading;
  List<ProductDetails> get products => _products;

  // Get current subscription tier
  SubscriptionTier get currentTier {
    final profile = _authService.currentUserProfile;
    return profile?.subscriptionTier ?? SubscriptionTier.free;
  }

  // Check if user has an active premium subscription
  bool get isPremium {
    final profile = _authService.currentUserProfile;
    return profile?.isPremium ?? false;
  }

  // Check if subscription is active
  bool get hasActiveSubscription {
    final profile = _authService.currentUserProfile;
    return profile?.hasActiveSubscription ?? false;
  }

  // Initialize subscription service
  Future<void> initialize() async {
    try {
      // Set up the in-app purchase stream listener
      final purchaseUpdated = _inAppPurchase.purchaseStream;
      _subscription = purchaseUpdated.listen(
        _listenToPurchaseUpdated,
        onDone: () {
          _subscription.cancel();
        },
        onError: (error) {
          logger.e('Purchase stream error: $error');
        },
      );

      // Check if in-app purchases are available
      final isAvailable = await _inAppPurchase.isAvailable();
      _isAvailable = isAvailable;

      if (isAvailable) {
        // Load available products
        await _loadProducts();
      }

      _isLoading = false;
      
      logger.i('Subscription service initialized, IAP available: $_isAvailable');
    } catch (e) {
      _isLoading = false;
      logger.e('Error initializing subscription service: $e');
    }
  }

  // Load available products
  Future<void> _loadProducts() async {
    try {
      // Set up product IDs
      final Set<String> productIds = {
        _kPremiumMonthlyId,
        _kPremiumYearlyId,
        _kBusinessMonthlyId,
      };

      // Query product details
      final ProductDetailsResponse response = 
          await _inAppPurchase.queryProductDetails(productIds);

      if (response.error != null) {
        logger.e('Error loading products: ${response.error}');
        return;
      }

      _products = response.productDetails;
      
      logger.i('Loaded ${_products.length} products');
    } catch (e) {
      logger.e('Error loading products: $e');
    }
  }

  // Purchase a subscription
  Future<bool> purchaseSubscription(ProductDetails product) async {
    try {
      if (!_isAvailable) {
        logger.w('In-app purchases not available');
        return false;
      }

      if (_auth.currentUser == null) {
        logger.w('User not logged in');
        return false;
      }

      // Create purchase parameters
      final purchaseParam = PurchaseParam(
        productDetails: product,
        applicationUserName: _auth.currentUser!.uid,
      );

      // Start the purchase flow
      bool success;
      if (Platform.isAndroid) {
        success = await _inAppPurchase.buyNonConsumable(
          purchaseParam: purchaseParam,
        );
      } else {
        success = await _inAppPurchase.buyConsumable(
          purchaseParam: purchaseParam,
          autoConsume: true,
        );
      }

      logger.i('Purchase initiated: $success');
      
      return success;
    } catch (e) {
      logger.e('Error purchasing subscription: $e');
      return false;
    }
  }

  // Restore purchases
  Future<bool> restorePurchases() async {
    try {
      if (!_isAvailable) {
        logger.w('In-app purchases not available');
        return false;
      }

      if (_auth.currentUser == null) {
        logger.w('User not logged in');
        return false;
      }

      // Restore purchases
      await _inAppPurchase.restorePurchases();
      
      logger.i('Restore purchases initiated');
      
      return true;
    } catch (e) {
      logger.e('Error restoring purchases: $e');
      return false;
    }
  }

  // Listen to purchase updated events
  Future<void> _listenToPurchaseUpdated(List<PurchaseDetails> purchaseDetailsList) async {
    for (final purchaseDetails in purchaseDetailsList) {
      if (purchaseDetails.status == PurchaseStatus.pending) {
        logger.i('Purchase pending: ${purchaseDetails.productID}');
      } else {
        if (purchaseDetails.status == PurchaseStatus.error) {
          logger.e('Purchase error: ${purchaseDetails.error}');
        } else if (purchaseDetails.status == PurchaseStatus.purchased ||
                 purchaseDetails.status == PurchaseStatus.restored) {
          // Handle successful purchase
          await _handleSuccessfulPurchase(purchaseDetails);
        } else if (purchaseDetails.status == PurchaseStatus.canceled) {
          logger.i('Purchase canceled: ${purchaseDetails.productID}');
        }

        // Complete the purchase
        if (purchaseDetails.pendingCompletePurchase) {
          await _inAppPurchase.completePurchase(purchaseDetails);
        }
      }
    }
  }

  // Handle successful purchase
  Future<void> _handleSuccessfulPurchase(PurchaseDetails purchaseDetails) async {
    try {
      if (_auth.currentUser == null) {
        logger.w('User not logged in');
        return;
      }

      // Determine subscription tier and duration from product ID
      SubscriptionTier tier = SubscriptionTier.free;
      int months = 0;

      switch (purchaseDetails.productID) {
        case _kPremiumMonthlyId:
          tier = SubscriptionTier.premium;
          months = 1;
          break;
        case _kPremiumYearlyId:
          tier = SubscriptionTier.premium;
          months = 12;
          break;
        case _kBusinessMonthlyId:
          tier = SubscriptionTier.business;
          months = 1;
          break;
      }

      // Calculate expiry date
      final now = DateTime.now();
      final expiryDate = DateTime(
        now.year,
        now.month + months,
        now.day,
        now.hour,
        now.minute,
        now.second,
      );

      // Update user profile with subscription info
      await _authService.updateSubscriptionTier(tier, expiryDate);

      // Store purchase details in Firestore
      await _firestore.collection('subscriptions').add({
        'userId': _auth.currentUser!.uid,
        'productId': purchaseDetails.productID,
        'purchaseId': purchaseDetails.purchaseID,
        'purchaseTime': now,
        'expiryDate': expiryDate,
        'tier': tier.toString().split('.').last,
        'status': 'active',
        'platform': Platform.isAndroid ? 'android' : 'ios',
        'verificationData': purchaseDetails.verificationData.serverVerificationData,
      });

      logger.i('Successful purchase processed: ${purchaseDetails.productID}');
    } catch (e) {
      logger.e('Error handling successful purchase: $e');
    }
  }

  // Get product details by ID
  ProductDetails? getProductById(String productId) {
    try {
      return _products.firstWhere((product) => product.id == productId);
    } catch (e) {
      return null;
    }
  }

  // Format price for display
  String formatPrice(ProductDetails product) {
    return product.price;
  }

  // Calculate discount between monthly and yearly
  double calculateYearlyDiscount() {
    try {
      final monthlyProduct = getProductById(_kPremiumMonthlyId);
      final yearlyProduct = getProductById(_kPremiumYearlyId);

      if (monthlyProduct == null || yearlyProduct == null) {
        return 0;
      }

      // Extract numeric price values (this is a simplified approach)
      final monthlyPrice = double.tryParse(
          monthlyProduct.price.replaceAll(RegExp(r'[^0-9.]'), '')) ?? 0;
      final yearlyPrice = double.tryParse(
          yearlyProduct.price.replaceAll(RegExp(r'[^0-9.]'), '')) ?? 0;

      if (monthlyPrice <= 0) {
        return 0;
      }

      // Calculate discount
      final annualMonthlyTotal = monthlyPrice * 12;
      final discount = (annualMonthlyTotal - yearlyPrice) / annualMonthlyTotal;

      return discount * 100; // Return as percentage
    } catch (e) {
      logger.e('Error calculating yearly discount: $e');
      return 0;
    }
  }

  // Dispose resources
  void dispose() {
    _subscription.cancel();
  }
}