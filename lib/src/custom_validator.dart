import 'package:qr_validation/src/validation_result.dart';

typedef ValidationRule = String? Function(Map<String, dynamic> data);

class CustomQRValidator {
  final List<ValidationRule> rules;

  CustomQRValidator(this.rules);

  QRValidationResult validate(QRValidationResult baseResult) {
    if (!baseResult.isValid) return baseResult;

    for (final rule in rules) {
      final error = rule(baseResult.data!);
      if (error != null) {
        return QRValidationResult.invalid(error);
      }
    }

    return baseResult;
  }
}