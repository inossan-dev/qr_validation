import 'package:qr_validation/src/custom_validator.dart';

class CommonValidationRules {
  static ValidationRule requiredField(String fieldName) {
    return (data) {
      if (!data.containsKey(fieldName) || data[fieldName] == null) {
        return 'The field $fieldName is required';
      }
      return null;
    };
  }

  static ValidationRule numberInRange(String fieldName, num min, num max) {
    return (data) {
      final value = data[fieldName];
      if (value is! num) return 'The field $fieldName must be a number';
      if (value < min || value > max) {
        return 'The field $fieldName must be between $min and $max';
      }
      return null;
    };
  }
}