class RazorpayCheckoutConfig {
  final String paymentRequestId;
  final String paymentAmount;
  final String currencyCode;
  final String razorpayKey;
  final String businessName;
  final String description;
  final String? imageUrl;
  final String? customerName;
  final String? customerEmail;
  final String? customerContact;
  final String callbackUrl;
  final String verifyPaymentBaseUrl;

  const RazorpayCheckoutConfig({
    required this.paymentRequestId,
    required this.paymentAmount,
    required this.currencyCode,
    required this.razorpayKey,
    required this.businessName,
    required this.description,
    this.imageUrl,
    this.customerName,
    this.customerEmail,
    this.customerContact,
    required this.callbackUrl,
    required this.verifyPaymentBaseUrl,
  });
}

class RazorpayCreateOrderResponse {
  final String orderId;
  final int amount;
  final String currency;

  const RazorpayCreateOrderResponse({
    required this.orderId,
    required this.amount,
    required this.currency,
  });

  factory RazorpayCreateOrderResponse.fromJson(Map<String, dynamic> json) {
    return RazorpayCreateOrderResponse(
      orderId: json['order_id'].toString(),
      amount: int.parse(json['amount'].toString()),
      currency: json['currency'].toString(),
    );
  }
}
