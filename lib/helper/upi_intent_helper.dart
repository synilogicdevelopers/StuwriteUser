import 'package:flutter/foundation.dart';
import 'package:url_launcher/url_launcher.dart';

class UpiIntentHelper {
  static const String _mobileUserAgent =
      'Mozilla/5.0 (Linux; Android 10; SM-G973F) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/88.0.4324.93 Mobile Safari/537.36';

  static String get mobileUserAgent => _mobileUserAgent;

  static bool isUpiIntentUrl(String url) {
    final lowerUrl = url.toLowerCase();
    return lowerUrl.contains('phonepe://pay?') ||
        lowerUrl.contains('tez://upi/pay?') ||
        lowerUrl.contains('paytmmp://pay?') ||
        lowerUrl.contains('bhim://pay?') ||
        lowerUrl.contains('cred://pay?') ||
        lowerUrl.contains('upi://pay?') ||
        lowerUrl.contains('gpay://') ||
        lowerUrl.startsWith('intent://');
  }

  static Future<bool> launchUpiIntent(String url) async {
    try {
      final uri = Uri.parse(url);
      if (await canLaunchUrl(uri)) {
        await launchUrl(uri, mode: LaunchMode.externalApplication);
        return true;
      }

      if (url.toLowerCase().startsWith('intent://')) {
        await launchUrl(uri, mode: LaunchMode.externalApplication);
        return true;
      }
    } catch (e) {
      debugPrint('UPI intent launch error: $e');
    }
    return false;
  }
}
