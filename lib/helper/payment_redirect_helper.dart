import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_sixvalley_ecommerce/features/auth/controllers/auth_controller.dart';
import 'package:flutter_sixvalley_ecommerce/features/checkout/controllers/checkout_controller.dart';
import 'package:flutter_sixvalley_ecommerce/features/checkout/widgets/order_place_bottomsheet_widget.dart';
import 'package:flutter_sixvalley_ecommerce/features/checkout/widgets/order_place_dialog_widget.dart';
import 'package:flutter_sixvalley_ecommerce/features/wallet/controllers/wallet_controller.dart';
import 'package:flutter_sixvalley_ecommerce/common/basewidget/animated_custom_dialog_widget.dart';
import 'package:flutter_sixvalley_ecommerce/helper/route_healper.dart';
import 'package:flutter_sixvalley_ecommerce/localization/language_constrants.dart';
import 'package:flutter_sixvalley_ecommerce/main.dart';
import 'package:flutter_sixvalley_ecommerce/utill/app_constants.dart';
import 'package:provider/provider.dart';

enum PaymentFlowType { checkout, wallet, duePayment }

class PaymentRedirectHelper {
  static bool isAppRedirect(String url) {
    return url.contains(AppConstants.baseUrl) &&
        ((url.contains('success') && url.contains('token')) ||
            url.contains('fail') ||
            url.contains('cancel'));
  }

  static bool isSuccess(String url) => url.contains('success');
  static bool isFailed(String url) => url.contains('fail');
  static bool isCancel(String url) => url.contains('cancel');

  static bool isNewUser(String url) {
    try {
      return Uri.parse(url).queryParameters['new_user'] == '1';
    } catch (_) {
      return false;
    }
  }

  static String? extractOrderIds(BuildContext context, String url) {
    try {
      final encodedData = Uri.parse(url).queryParameters['order_ids'];
      if (encodedData != null && encodedData.isNotEmpty) {
        final decoded = utf8.decode(base64.decode(encodedData));
        return Provider.of<CheckoutController>(context, listen: false).extractId(decoded);
      }
    } catch (e) {
      debugPrint('Order ID extraction error: $e');
    }
    return '';
  }

  static void handleRedirect({
    required BuildContext context,
    required String url,
    required PaymentFlowType flowType,
    String orderId = '',
  }) {
    if (!isAppRedirect(url)) {
      return;
    }

    final success = isSuccess(url);
    final failed = isFailed(url);
    final cancel = isCancel(url);
    final isLoggedIn = Provider.of<AuthController>(context, listen: false).isLoggedIn();
    final isNewUserFlag = isNewUser(url);
    final orderIds = extractOrderIds(context, url);

    switch (flowType) {
      case PaymentFlowType.checkout:
        _handleCheckoutRedirect(
          context: context,
          success: success,
          failed: failed,
          cancel: cancel,
          isLoggedIn: isLoggedIn,
          isNewUser: isNewUserFlag,
          orderIds: orderIds,
          orderId: orderId,
        );
        break;
      case PaymentFlowType.wallet:
        _handleWalletRedirect(context: context, success: success, failed: failed, cancel: cancel);
        break;
      case PaymentFlowType.duePayment:
        _handleDuePaymentRedirect(
          context: context,
          success: success,
          failed: failed,
          cancel: cancel,
          orderId: orderId,
        );
        break;
    }
  }

  static void _handleCheckoutRedirect({
    required BuildContext context,
    required bool success,
    required bool failed,
    required bool cancel,
    required bool isLoggedIn,
    required bool isNewUser,
    required String? orderIds,
    required String orderId,
  }) {
    if (success) {
      if (orderId.trim().isNotEmpty && (orderIds == null || orderIds.isEmpty)) {
        RouterHelper.getOrderDetailsScreenRoute(
          orderId: int.parse(orderId),
          action: RouteAction.pushReplacement,
          isNotification: true,
        );
      } else if (isLoggedIn && orderIds != null && orderIds.isNotEmpty) {
        RouterHelper.getOrderScreenRoute(isBackButtonExist: true, action: RouteAction.push, fromPlaceOrder: true);
      } else {
        RouterHelper.getDashboardRoute(action: RouteAction.pushReplacement, page: 'home');
      }

      if (orderId.trim().isEmpty || orderId.trim() == 'null') {
        _showCheckoutBottomSheet(
          orderIds: orderIds,
          isNewUser: isNewUser,
          icon: Icons.check,
          titleKey: isNewUser ? 'order_placed_Account_Created' : 'order_placed',
          descKey: 'your_order_placed',
        );
      }
      return;
    }

    RouterHelper.getDashboardRoute(action: RouteAction.pushReplacement, page: 'home');
    _showCheckoutDialog(
      icon: Icons.clear,
      titleKey: failed ? 'payment_failed' : 'payment_cancelled',
      descKey: failed ? 'your_payment_failed' : 'your_payment_cancelled',
      isFailed: true,
    );
  }

  static void _handleWalletRedirect({
    required BuildContext context,
    required bool success,
    required bool failed,
    required bool cancel,
  }) {
    if (success) {
      Provider.of<WalletController>(context, listen: false).getTransactionList(1, isUpdate: false);
      RouterHelper.getDashboardRoute(action: RouteAction.pushReplacement, page: 'wallet');
      showAnimatedDialog(
        Get.context!,
        OrderPlaceDialogWidget(
          icon: Icons.done,
          title: getTranslated('fund_added_into_wallet', Get.context!),
          description: getTranslated('your_fund_successfully_added_to_your_wallet', Get.context!),
        ),
        dismissible: false,
        willFlip: true,
      );
      return;
    }

    RouterHelper.getDashboardRoute(action: RouteAction.pushReplacement, page: 'wallet');
    showAnimatedDialog(
      Get.context!,
      OrderPlaceDialogWidget(
        icon: Icons.clear,
        title: getTranslated(failed ? 'payment_failed' : 'payment_cancelled', Get.context!),
        description: getTranslated(failed ? 'your_payment_failed' : 'your_payment_cancelled', Get.context!),
        isFailed: true,
      ),
      dismissible: false,
      willFlip: true,
    );
  }

  static void _handleDuePaymentRedirect({
    required BuildContext context,
    required bool success,
    required bool failed,
    required bool cancel,
    required String orderId,
  }) {
    if (success && orderId.isNotEmpty) {
      RouterHelper.getOrderDetailsScreenRoute(
        orderId: int.parse(orderId),
        action: RouteAction.pushReplacement,
        isNotification: true,
      );
      return;
    }

    RouterHelper.getDashboardRoute(action: RouteAction.pushReplacement, page: 'home');
    _showCheckoutDialog(
      icon: Icons.clear,
      titleKey: failed ? 'payment_failed' : 'payment_cancelled',
      descKey: failed ? 'your_payment_failed' : 'your_payment_cancelled',
      isFailed: true,
    );
  }

  static void _showCheckoutBottomSheet({
    String? orderIds,
    bool isNewUser = false,
    required IconData icon,
    required String titleKey,
    required String descKey,
    bool isFailed = false,
  }) {
    Future.delayed(const Duration(milliseconds: 500), () {
      showModalBottomSheet(
        context: Get.context!,
        isScrollControlled: true,
        useSafeArea: true,
        backgroundColor: Colors.transparent,
        builder: (context) => SafeArea(
          child: Container(
            decoration: BoxDecoration(
              color: Theme.of(context).cardColor,
              borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
            ),
            child: OrderPlaceBottomSheetWidget(
              orderID: orderIds,
              icon: icon,
              title: getTranslated(titleKey, Get.context!),
              description: getTranslated(descKey, Get.context!),
              isFailed: isFailed,
            ),
          ),
        ),
      );
    });
  }

  static void _showCheckoutDialog({
    required IconData icon,
    required String titleKey,
    required String descKey,
    bool isFailed = false,
  }) {
    Future.delayed(const Duration(milliseconds: 500), () {
      showAnimatedDialog(
        Get.context!,
        OrderPlaceDialogWidget(
          icon: icon,
          title: getTranslated(titleKey, Get.context!),
          description: getTranslated(descKey, Get.context!),
          isFailed: isFailed,
        ),
        dismissible: false,
        willFlip: true,
      );
    });
  }
}
