// Unit tests for NanheNest validators.
// Firebase-dependent widget tests require a test Firebase environment.

import 'package:flutter_test/flutter_test.dart';
import 'package:nanhenest/utils/validators.dart';

void main() {
  group('Validators.email', () {
    test('valid address passes', () {
      expect(Validators.email('user@example.com'), isNull);
    });
    test('empty returns error', () {
      expect(Validators.email(''), isNotNull);
    });
    test('missing @ returns error', () {
      expect(Validators.email('notanemail'), isNotNull);
    });
  });

  group('Validators.password', () {
    test('strong password passes', () {
      expect(Validators.password('Secure1'), isNull);
    });
    test('too short returns error', () {
      expect(Validators.password('Ab1'), isNotNull);
    });
    test('no uppercase returns error', () {
      expect(Validators.password('secure1'), isNotNull);
    });
    test('no digit returns error', () {
      expect(Validators.password('SecurePass'), isNotNull);
    });
  });

  group('Validators.name', () {
    test('valid name passes', () {
      expect(Validators.name('Asha'), isNull);
    });
    test('empty returns error', () {
      expect(Validators.name(''), isNotNull);
    });
    test('single char returns error', () {
      expect(Validators.name('A'), isNotNull);
    });
  });
}
