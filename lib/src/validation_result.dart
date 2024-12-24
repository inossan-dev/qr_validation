class QRValidationResult {
  final bool isValid;
  final bool isExpired;
  final String? error;
  final Map<String, dynamic>? data;

  QRValidationResult._({
    required this.isValid,
    this.isExpired = false,
    this.error,
    this.data,
  });

  factory QRValidationResult.valid(Map<String, dynamic> data) {
    return QRValidationResult._(isValid: true, data: data);
  }

  factory QRValidationResult.invalid(String error) {
    return QRValidationResult._(isValid: false, error: error);
  }

  factory QRValidationResult.expired() {
    return QRValidationResult._(
      isValid: false,
      isExpired: true,
      error: "QR code expired",
    );
  }
}