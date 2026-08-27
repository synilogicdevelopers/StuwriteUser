import 'dart:convert';

import 'package:stuwrite_user/features/payment/domain/models/razorpay_checkout_config.dart';
import 'package:stuwrite_user/utill/app_constants.dart';
import 'package:http/http.dart' as http;

class RazorpayPaymentService {
  static bool isRazorpayRedirect(String url) {
    return url.contains('/payment/razor-pay/');
  }

  static String? extractPaymentRequestId(String redirectLink) {
    final uri = Uri.tryParse(redirectLink);
    return uri?.queryParameters['payment_id'];
  }

  static Future<RazorpayCheckoutConfig> fetchCheckoutConfig(String redirectLink) async {
    final response = await http.get(
      Uri.parse(redirectLink),
      headers: const {
        'Accept': 'text/html,application/xhtml+xml',
        'User-Agent': 'Mozilla/5.0 (Linux; Android 13) AppleWebKit/537.36 Chrome/120.0.0.0 Mobile Safari/537.36',
      },
    );

    if (response.statusCode != 200) {
      throw Exception('Unable to load Razorpay payment session (${response.statusCode})');
    }

    final html = response.body;
    final paymentRequestId = _firstMatch(html, RegExp(r'payment_request_id:\s*"([^"]+)"')) ??
        extractPaymentRequestId(redirectLink);
    final paymentAmount = _firstMatch(html, RegExp(r'payment_amount:\s*"([^"]+)"'));
    final currencyCode = _firstMatch(html, RegExp(r'currency_code:\s*"([^"]+)"')) ?? 'INR';
    final razorpayKey = _firstMatch(html, RegExp(r'"key":\s*"([^"]+)"'));
    final businessName = _firstMatch(html, RegExp(r'"name":\s*"([^"]+)"')) ?? AppConstants.appName;
    final description = _firstMatch(html, RegExp(r'"description":\s*"([^"]+)"')) ?? paymentAmount ?? '';
    final imageUrl = _firstMatch(html, RegExp(r'"image":\s*"([^"]+)"'));
    final prefill = _parsePrefill(html);
    final customerName = prefill['name'];
    final customerEmail = prefill['email'];
    final customerContact = prefill['contact'];
    final callbackUrl = _firstMatch(html, RegExp(r'"callback_url":\s*"([^"]+)"')) ??
        '${AppConstants.baseUrl}/payment/razor-pay/callback';

    if (paymentRequestId == null || paymentAmount == null || razorpayKey == null) {
      throw Exception('Invalid Razorpay payment configuration received from server');
    }

    return RazorpayCheckoutConfig(
      paymentRequestId: paymentRequestId,
      paymentAmount: paymentAmount,
      currencyCode: currencyCode,
      razorpayKey: razorpayKey,
      businessName: businessName,
      description: description,
      imageUrl: imageUrl,
      customerName: customerName,
      customerEmail: customerEmail,
      customerContact: customerContact,
      callbackUrl: callbackUrl,
      verifyPaymentBaseUrl: '${AppConstants.baseUrl}/payment/razor-pay/verify-payment',
    );
  }

  static Future<RazorpayCreateOrderResponse> createOrder(RazorpayCheckoutConfig config) async {
    final response = await http.post(
      Uri.parse('${AppConstants.baseUrl}/payment/razor-pay/create-order'),
      headers: const {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
      },
      body: jsonEncode({
        'payment_request_id': config.paymentRequestId,
        'payment_amount': config.paymentAmount,
        'currency_code': config.currencyCode,
      }),
    );

    if (response.statusCode != 200) {
      throw Exception('Unable to create Razorpay order (${response.statusCode})');
    }

    final decoded = jsonDecode(response.body) as Map<String, dynamic>;
    if (decoded['status'] != true && decoded['status'] != 1) {
      throw Exception(decoded['message']?.toString() ?? 'Unable to create Razorpay order');
    }

    return RazorpayCreateOrderResponse.fromJson(decoded);
  }

  static Future<String> verifyPayment({
    required String paymentRequestId,
    required String paymentId,
    required String orderId,
    required String signature,
  }) async {
    final uri = Uri.parse('${AppConstants.baseUrl}/payment/razor-pay/verify-payment').replace(
      queryParameters: {
        'payment_request_id': paymentRequestId,
        'payment_id': paymentId,
        'order_id': orderId,
        'signature': signature,
      },
    );

    return _followRedirects(uri);
  }

  static Future<String> followCancelUrl(String paymentRequestId) async {
    final uri = Uri.parse('${AppConstants.baseUrl}/payment/razor-pay/cancel').replace(
      queryParameters: {'payment_id': paymentRequestId},
    );
    return _followRedirects(uri);
  }

  static Future<String> _followRedirects(Uri uri) async {
    final client = http.Client();
    try {
      var nextUri = uri;
      for (var i = 0; i < 10; i++) {
        final request = http.Request('GET', nextUri)
          ..headers['Accept'] = 'text/html,application/xhtml+xml'
          ..followRedirects = false;
        final streamed = await client.send(request);
        final response = await http.Response.fromStream(streamed);

        if (response.statusCode >= 300 && response.statusCode < 400) {
          final location = response.headers['location'];
          if (location == null || location.isEmpty) {
            break;
          }
          nextUri = Uri.parse(location.startsWith('http') ? location : '${nextUri.origin}$location');
          continue;
        }

        if (response.request?.url != null) {
          return response.request!.url.toString();
        }
        return nextUri.toString();
      }
    } finally {
      client.close();
    }

    return uri.toString();
  }

  static String? _firstMatch(String input, RegExp pattern, {int group = 1, int occurrence = 1}) {
    final matches = pattern.allMatches(input);
    var index = 0;
    for (final match in matches) {
      index++;
      if (index == occurrence) {
        return match.group(group);
      }
    }
    return null;
  }

  static Map<String, String> _parsePrefill(String html) {
    final prefillBlock = RegExp(r'"prefill"\s*:\s*\{([^}]+)\}').firstMatch(html)?.group(1) ?? '';
    return {
      'name': _firstMatch(prefillBlock, RegExp(r'"name":\s*"([^"]+)"')) ?? '',
      'email': _firstMatch(prefillBlock, RegExp(r'"email":\s*"([^"]+)"')) ?? '',
      'contact': _firstMatch(prefillBlock, RegExp(r'"contact":\s*"([^"]+)"')) ?? '',
    };
  }
}
