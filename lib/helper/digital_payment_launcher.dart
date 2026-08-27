import 'package:flutter/material.dart';
import 'package:stuwrite_user/features/payment/controllers/razorpay_payment_controller.dart';
import 'package:stuwrite_user/features/payment/domain/services/razorpay_payment_service.dart';
import 'package:stuwrite_user/helper/payment_redirect_helper.dart';
import 'package:stuwrite_user/helper/route_healper.dart';
import 'package:provider/provider.dart';

class DigitalPaymentLauncher {
  static Future<void> launch({
    required BuildContext context,
    required String redirectLink,
    required PaymentFlowType flowType,
    RouteAction action = RouteAction.pushReplacement,
    String orderId = '',
    bool fromWallet = false,
  }) async {
    if (redirectLink.isEmpty) {
      return;
    }

    if (RazorpayPaymentService.isRazorpayRedirect(redirectLink)) {
      final razorpayController = Provider.of<RazorpayPaymentController>(context, listen: false);
      await razorpayController.fetchInstalledUpiApps();
      final started = await razorpayController.startPayment(
        redirectLink: redirectLink,
        flowType: flowType,
        orderId: orderId,
      );
      if (started) {
        return;
      }
    }

    RouterHelper.getDigitalPaymentScreenRoute(
      url: redirectLink,
      fromWallet: fromWallet,
      orderId: orderId,
      action: action,
    );
  }
}
