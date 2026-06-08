import 'package:collection/collection.dart';
import 'package:country_code_picker/country_code_picker.dart';
import 'package:flutter/material.dart';

class CountryCodeHelper{


  static String? getCountryCode(String? number) {
    String? countryCode = '';
    try{
      countryCode = codes.firstWhere((item) =>
          number!.contains('${item['dial_code']}'))['dial_code'];
    }catch(error){
      debugPrint('country error: $error');
    }
    return countryCode;
  }

  static String extractPhoneNumber(String countryCode, String phoneNumber) {
    return phoneNumber.replaceAll(countryCode, '');
  }

  static const Map<String, String> _englishCountryNameToIso = {
    'India': 'IN',
  };

  /// Resolves a country name (e.g. भारत, India) or ISO code (IN) to ISO alpha-2.
  static String? resolveCountryIso(String? value) {
    if (value == null || value.trim().isEmpty) return null;
    final trimmed = value.trim();
    if (_englishCountryNameToIso.containsKey(trimmed)) {
      return _englishCountryNameToIso[trimmed];
    }
    final upper = trimmed.toUpperCase();
    if (upper.length == 2) {
      try {
        CountryCode.fromCountryCode(upper);
        return upper;
      } catch (_) {}
    }
    final match = codes.firstWhereOrNull(
      (country) => country['name'] == trimmed || country['code']?.toUpperCase() == upper,
    );
    return match?['code'];
  }

}