import 'package:test/test.dart';

import 'package:robots_txt/robots_txt.dart';

import '../samples.dart';

void main() {
  group('The validator correctly deals with', () {
    test('an empty file.', () {
      expect(() => Robots.validate(emptyContents), returnsNormally);
    });

    test('an invalid file.', () {
      expect(() => Robots.validate(invalidContents), throwsFormatException);
    });

    test('a valid file with a custom field name not accounted for.', () {
      expect(
        () => Robots.validate(validContentsWithCustomFieldName),
        throwsFormatException,
      );
    });

    test('a valid file with a custom field name.', () {
      expect(
        () => Robots.validate(
          validContentsWithCustomFieldName,
          allowedFieldNames: {'Field'},
        ),
        returnsNormally,
      );
    });

    test('a valid file with an invalid path definition.', () {
      expect(
        () => Robots.validate(validContentsInvalidPattern),
        throwsFormatException,
      );
    });

    test('a valid file.', () {
      expect(
        () => Robots.validate(validContentsValidPattern),
        returnsNormally,
      );
    });
  });
}
