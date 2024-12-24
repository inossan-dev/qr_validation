import 'package:qr_validation/src/validation_result.dart';

extension QRValidationResultExtension on QRValidationResult {
  String get userMessage {
    if (isValid) {
      return 'Valid QR code';
    } else if (isExpired) {
      return 'QR code expired';
    } else {
      return error ?? 'Invalid QR code';
    }
  }

  bool hasData(String key) {
    return isValid && data?.containsKey(key) == true;
  }

  T? getData<T>(String key, {T? defaultValue}) {
    if (!isValid) return defaultValue;
    final value = data?[key];
    if (value is T) return value;
    return defaultValue;
  }
}
