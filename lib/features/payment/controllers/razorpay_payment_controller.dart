import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:stuwrite_user/common/basewidget/show_custom_snakbar_widget.dart';
import 'package:stuwrite_user/features/payment/domain/models/razorpay_checkout_config.dart';
import 'package:stuwrite_user/features/payment/domain/services/razorpay_payment_service.dart';
import 'package:stuwrite_user/features/payment/widgets/upi_app_picker_bottom_sheet.dart';
import 'package:stuwrite_user/helper/payment_redirect_helper.dart';
import 'package:stuwrite_user/localization/language_constrants.dart';
import 'package:stuwrite_user/main.dart';
import 'package:flutter_upi_india/flutter_upi_india.dart';
import 'package:razorpay_flutter/razorpay_flutter.dart';
import 'package:razorpay_flutter_customui/razorpay_flutter_customui.dart' as custom_ui;

class RazorpayPaymentController extends ChangeNotifier {
  Razorpay? _razorpay;
  custom_ui.Razorpay? _razorpayUpi;

  RazorpayCheckoutConfig? _config;
  PaymentFlowType _flowType = PaymentFlowType.checkout;
  String _orderId = '';
  bool _isProcessing = false;

  bool get isProcessing => _isProcessing;

  List<ApplicationMeta> installedUpiApps = [];

  Future<void> fetchInstalledUpiApps() async {
    try {
      installedUpiApps = await UpiPay.getInstalledUpiApplications(
        statusType: UpiApplicationDiscoveryAppStatusType.all,
      );
    } catch (e) {
      debugPrint('UPI app discovery failed: $e');
      installedUpiApps = [];
    }
    notifyListeners();
  }

  Future<bool> startPayment({
    required String redirectLink,
    required PaymentFlowType flowType,
    String orderId = '',
    bool preferUpiPicker = true,
  }) async {
    if (_isProcessing) {
      return false;
    }

    _flowType = flowType;
    _orderId = orderId;
    _isProcessing = true;
    notifyListeners();

    try {
      _config = await RazorpayPaymentService.fetchCheckoutConfig(redirectLink);

      if (preferUpiPicker && installedUpiApps.isEmpty) {
        await fetchInstalledUpiApps();
      }

      if (preferUpiPicker && installedUpiApps.isNotEmpty && Get.context != null) {
        _isProcessing = false;
        notifyListeners();
        await showUpiAppPicker(
          context: Get.context!,
          apps: installedUpiApps,
          onSelectApp: (app) => _openUpiCheckout(app.packageName),
          onSelectOtherMethods: _openStandardCheckout,
        );
        return true;
      }

      await _openStandardCheckout();
      return true;
    } catch (e) {
      _isProcessing = false;
      notifyListeners();
      if (Get.context != null) {
        showCustomSnackBarWidget(
          e.toString(),
          Get.context!,
          snackBarType: SnackBarType.error,
        );
      }
      return false;
    }
  }

  Future<void> _openStandardCheckout() async {
    if (_config == null) {
      return;
    }

    _isProcessing = true;
    notifyListeners();

    try {
      final order = await RazorpayPaymentService.createOrder(_config!);
      _razorpay?.clear();
      _razorpay = Razorpay()
        ..on(Razorpay.EVENT_PAYMENT_SUCCESS, _handleStandardSuccess)
        ..on(Razorpay.EVENT_PAYMENT_ERROR, _handleStandardError)
        ..on(Razorpay.EVENT_EXTERNAL_WALLET, _handleExternalWallet);

      final options = {
        'key': _config!.razorpayKey,
        'amount': order.amount,
        'currency': order.currency,
        'order_id': order.orderId,
        'name': _config!.businessName,
        'description': _config!.description,
        if (_config!.imageUrl != null) 'image': _config!.imageUrl,
        'prefill': {
          'name': _config!.customerName ?? '',
          'email': _config!.customerEmail ?? '',
          'contact': _config!.customerContact ?? '',
        },
        'theme': {'color': '#ff7529'},
      };

      _razorpay!.open(options);
    } catch (e) {
      _finishProcessing();
      if (Get.context != null) {
        showCustomSnackBarWidget(
          e.toString(),
          Get.context!,
          snackBarType: SnackBarType.error,
        );
      }
    }
  }

  Future<void> _openUpiCheckout(String packageName) async {
    if (_config == null) {
      return;
    }

    _isProcessing = true;
    notifyListeners();

    try {
      final order = await RazorpayPaymentService.createOrder(_config!);
      _razorpayUpi?.clear();
      _razorpayUpi = custom_ui.Razorpay()
        ..on(custom_ui.Razorpay.EVENT_PAYMENT_SUCCESS, _handleUpiSuccess)
        ..on(custom_ui.Razorpay.EVENT_PAYMENT_ERROR, _handleUpiError);

      final options = {
        'key': _config!.razorpayKey,
        'amount': order.amount,
        'currency': order.currency,
        'email': _config!.customerEmail ?? '',
        'contact': _config!.customerContact ?? '',
        'method': 'upi',
        '_[flow]': 'intent',
        'upi_app_package_name': packageName,
        'order_id': order.orderId,
      };

      _razorpayUpi!.submit(options);
    } catch (e) {
      _finishProcessing();
      if (Get.context != null) {
        showCustomSnackBarWidget(
          e.toString(),
          Get.context!,
          snackBarType: SnackBarType.error,
        );
      }
    }
  }

  Future<void> _handleStandardSuccess(PaymentSuccessResponse response) async {
    await _completePayment(
      paymentId: response.paymentId ?? '',
      orderId: response.orderId ?? '',
      signature: response.signature ?? '',
    );
  }

  Future<void> _handleStandardError(PaymentFailureResponse response) async {
    _finishProcessing();
    if (Get.context == null) {
      return;
    }

    if (_config != null) {
      final cancelUrl = await RazorpayPaymentService.followCancelUrl(_config!.paymentRequestId);
      PaymentRedirectHelper.handleRedirect(
        context: Get.context!,
        url: cancelUrl,
        flowType: _flowType,
        orderId: _orderId,
      );
      return;
    }

    showCustomSnackBarWidget(
      response.message ?? getTranslated('payment_failed', Get.context!) ?? 'Payment failed',
      Get.context!,
      snackBarType: SnackBarType.error,
    );
  }

  void _handleExternalWallet(ExternalWalletResponse response) {
    debugPrint('External wallet selected: ${response.walletName}');
  }

  Future<void> _handleUpiSuccess(dynamic response) async {
    final data = response['data'] as Map<String, dynamic>? ?? {};
    await _completePayment(
      paymentId: data['razorpay_payment_id']?.toString() ?? '',
      orderId: data['razorpay_order_id']?.toString() ?? '',
      signature: data['razorpay_signature']?.toString() ?? '',
    );
  }

  Future<void> _handleUpiError(dynamic response) async {
    _finishProcessing();
    if (Get.context == null) {
      return;
    }

    showCustomSnackBarWidget(
      getTranslated('payment_failed', Get.context!) ?? 'Payment failed',
      Get.context!,
      snackBarType: SnackBarType.error,
    );
  }

  Future<void> _completePayment({
    required String paymentId,
    required String orderId,
    required String signature,
  }) async {
    if (_config == null || Get.context == null) {
      _finishProcessing();
      return;
    }

    try {
      final finalUrl = await RazorpayPaymentService.verifyPayment(
        paymentRequestId: _config!.paymentRequestId,
        paymentId: paymentId,
        orderId: orderId,
        signature: signature,
      );

      PaymentRedirectHelper.handleRedirect(
        context: Get.context!,
        url: finalUrl,
        flowType: _flowType,
        orderId: _orderId,
      );
    } catch (e) {
      if (Get.context != null) {
        showCustomSnackBarWidget(
          e.toString(),
          Get.context!,
          snackBarType: SnackBarType.error,
        );
      }
    } finally {
      _finishProcessing();
    }
  }

  void _finishProcessing() {
    _isProcessing = false;
    notifyListeners();
  }

  @override
  void dispose() {
    _razorpay?.clear();
    _razorpayUpi?.clear();
    super.dispose();
  }
}
