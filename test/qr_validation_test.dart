import 'package:flutter_test/flutter_test.dart';
import 'package:qr_validation/qr_validation.dart';

void main() {
  group('QRValidationResult Tests', () {
    // Tests pour les constructeurs factory
    test('QRValidationResult.valid() crée un résultat valide', () {
      final data = {'test': 'value'};
      final result = QRValidationResult.valid(data);

      expect(result.isValid, isTrue);
      expect(result.isExpired, isFalse);
      expect(result.error, isNull);
      expect(result.data, equals(data));
    });

    test('QRValidationResult.invalid() crée un résultat invalide', () {
      final result = QRValidationResult.invalid('Test error');

      expect(result.isValid, isFalse);
      expect(result.isExpired, isFalse);
      expect(result.error, equals('Test error'));
      expect(result.data, isNull);
    });

    test('QRValidationResult.expired() crée un résultat expiré', () {
      final result = QRValidationResult.expired();

      expect(result.isValid, isFalse);
      expect(result.isExpired, isTrue);
      expect(result.error, equals('QR code expired'));
      expect(result.data, isNull);
    });
  });

  group('QRValidationResultExtension Tests', () {
    test('userMessage retourne le bon message pour un résultat valide', () {
      final result = QRValidationResult.valid({'test': 'value'});
      expect(result.userMessage, equals('Valid QR code'));
    });

    test('userMessage retourne le bon message pour un résultat expiré', () {
      final result = QRValidationResult.expired();
      expect(result.userMessage, equals('QR code expired'));
    });

    test('userMessage retourne le message d\'erreur pour un résultat invalide', () {
      final result = QRValidationResult.invalid('Custom error');
      expect(result.userMessage, equals('Custom error'));
    });

    group('hasData Tests', () {
      final validData = {'key1': 'value1', 'key2': null};
      final validResult = QRValidationResult.valid(validData);
      final invalidResult = QRValidationResult.invalid('error');

      test('hasData retourne true pour une clé existante', () {
        expect(validResult.hasData('key1'), isTrue);
      });

      test('hasData retourne false pour une clé inexistante', () {
        expect(validResult.hasData('key3'), isFalse);
      });

      test('hasData retourne false pour une clé avec valeur null', () {
        expect(validResult.hasData('key2'), isTrue);
      });

      test('hasData retourne false pour un résultat invalide', () {
        expect(invalidResult.hasData('key1'), isFalse);
      });
    });

    group('getData Tests', () {
      final data = {
        'string': 'test',
        'int': 42,
        'double': 3.14,
        'bool': true,
        'null': null,
      };
      final validResult = QRValidationResult.valid(data);
      final invalidResult = QRValidationResult.invalid('error');

      test('getData retourne la valeur correcte pour le bon type', () {
        expect(validResult.getData<String>('string'), equals('test'));
        expect(validResult.getData<int>('int'), equals(42));
        expect(validResult.getData<double>('double'), equals(3.14));
        expect(validResult.getData<bool>('bool'), equals(true));
      });

      test('getData retourne null pour une clé inexistante', () {
        expect(validResult.getData<String>('nonexistent'), isNull);
      });

      test('getData retourne la valeur par défaut pour une clé inexistante', () {
        expect(
            validResult.getData<String>('nonexistent', defaultValue: 'default'),
            equals('default')
        );
      });

      test('getData retourne null pour une valeur null', () {
        expect(validResult.getData<String>('null'), isNull);
      });

      test('getData retourne la valeur par défaut pour un type incorrect', () {
        expect(
            validResult.getData<int>('string', defaultValue: 0),
            equals(0)
        );
      });

      test('getData retourne la valeur par défaut pour un résultat invalide', () {
        expect(
            invalidResult.getData<String>('string', defaultValue: 'default'),
            equals('default')
        );
      });
    });
  });

  group('CustomQRValidator Tests', () {
    test('validate retourne le résultat original si déjà invalide', () {
      final validator = CustomQRValidator([(_) => null]);
      final invalidResult = QRValidationResult.invalid('Original error');

      final result = validator.validate(invalidResult);
      expect(result, equals(invalidResult));
    });

    test('validate applique toutes les règles avec succès', () {
      final rules = [
            (data) => null,
            (data) => null,
      ];
      final validator = CustomQRValidator(rules);
      final validResult = QRValidationResult.valid({'test': 'value'});

      final result = validator.validate(validResult);
      expect(result.isValid, isTrue);
    });

    test('validate s\'arrête à la première règle échouée', () {
      final rules = [
            (data) => 'Error 1',
            (data) => 'Error 2',
      ];
      final validator = CustomQRValidator(rules);
      final validResult = QRValidationResult.valid({'test': 'value'});

      final result = validator.validate(validResult);
      expect(result.isValid, isFalse);
      expect(result.error, equals('Error 1'));
    });

    test('validate gère une liste de règles vide', () {
      final validator = CustomQRValidator([]);
      final validResult = QRValidationResult.valid({'test': 'value'});

      final result = validator.validate(validResult);
      expect(result.isValid, isTrue);
    });
  });

  group('CommonValidationRules Tests', () {
    group('requiredField Tests', () {
      final rule = CommonValidationRules.requiredField('testField');

      test('accepte une valeur non-null', () {
        final result = rule({'testField': 'value'});
        expect(result, isNull);
      });

      test('rejette une clé manquante', () {
        final result = rule({});
        expect(result, contains('testField is required'));
      });

      test('rejette une valeur null', () {
        final result = rule({'testField': null});
        expect(result, contains('testField is required'));
      });
    });

    group('numberInRange Tests', () {
      final rule = CommonValidationRules.numberInRange('age', 0, 120);

      test('accepte une valeur dans la plage', () {
        final result = rule({'age': 25});
        expect(result, isNull);
      });

      test('accepte les valeurs limites', () {
        expect(rule({'age': 0}), isNull);
        expect(rule({'age': 120}), isNull);
      });

      test('rejette une valeur hors plage inférieure', () {
        final result = rule({'age': -1});
        expect(result, contains('must be between'));
      });

      test('rejette une valeur hors plage supérieure', () {
        final result = rule({'age': 121});
        expect(result, contains('must be between'));
      });

      test('rejette une valeur non numérique', () {
        final result = rule({'age': 'invalid'});
        expect(result, contains('must be a number'));
      });

      test('gère les valeurs décimales', () {
        final decimalRule = CommonValidationRules.numberInRange('score', 0, 100);
        expect(decimalRule({'score': 99.9}), isNull);
      });
    });
  });
}