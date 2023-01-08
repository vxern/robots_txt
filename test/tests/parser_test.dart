import 'package:test/test.dart';

import 'package:robots_txt/robots_txt.dart';

import '../samples.dart';

void main() {
  late Robots robots;

  group('The parser correctly parses', () {
    group('file contents', () {
      test('that are empty.', () {
        expect(() => robots = Robots.parse(emptyContents), returnsNormally);
        expect(robots.verifyCanAccess('/', userAgent: 'A'), equals(true));
      });

      test('that are not valid.', () {
        expect(() => robots = Robots.parse(invalidContents), returnsNormally);
        expect(robots.verifyCanAccess('/', userAgent: 'A'), equals(true));
      });

      test('that are valid, but have an invalid pattern.', () {
        expect(
          () => robots = Robots.parse(validContentsInvalidPattern),
          returnsNormally,
        );
      });

      test('that are valid.', () {
        expect(
          () => robots = Robots.parse(validContentsValidPattern),
          returnsNormally,
        );
        expect(robots.rulesets.length, equals(1));
        final ruleset = robots.rulesets.first;
        expect(ruleset.disallows.length, equals(1));
        expect(ruleset.allows.length, equals(1));
        expect(robots.sitemaps.length, equals(1));
        expect(robots.verifyCanAccess('/', userAgent: 'A'), equals(false));
        expect(
          robots.verifyCanAccess('/file.txt', userAgent: 'A'),
          equals(true),
        );
      });

      test('that define a sitemap.', () {
        expect(() => robots = Robots.parse(sitemap), returnsNormally);
        expect(robots.sitemaps, equals(<String>[FieldType.sitemap.example]));
      });
    });

    group('rules with logical applicability', () {
      test('defined without a user agent.', () {
        expect(
          () => robots = Robots.parse(rulesWithoutUserAgent),
          returnsNormally,
        );
        expect(robots.rulesets, equals(<Ruleset>[]));
        expect(robots.verifyCanAccess('/', userAgent: 'A'), equals(true));
      });

      test('defined before a user agent.', () {
        expect(
          () => robots = Robots.parse(rulesDefinedBeforeUserAgent),
          returnsNormally,
        );
        expect(robots.rulesets, equals(<Ruleset>[]));
        expect(robots.verifyCanAccess('/', userAgent: 'A'), equals(true));
      });

      test('that disallow a file for A.', () {
        expect(
          () => robots = Robots.parse(fileDisallowedForA),
          returnsNormally,
        );
        expect(robots.verifyCanAccess('/', userAgent: 'A'), equals(true));
        expect(
          robots.verifyCanAccess('/file.txt', userAgent: 'A'),
          equals(false),
        );
      });

      test('that disallow a file for both A and B.', () {
        expect(
          () => robots = Robots.parse(fileDisallowedForAAndB),
          returnsNormally,
        );
        expect(
          robots.verifyCanAccess('/file.txt', userAgent: 'A'),
          equals(false),
        );
        expect(
          robots.verifyCanAccess('/file.txt', userAgent: 'B'),
          equals(false),
        );
        expect(
          robots.verifyCanAccess('/file.txt', userAgent: 'C'),
          equals(true),
        );
      });

      test('that disallow a file for all user-agents.', () {
        expect(
          () => robots = Robots.parse(fileDisallowedForAll),
          returnsNormally,
        );
        expect(
          robots.verifyCanAccess('/', userAgent: 'A'),
          equals(true),
        );
        expect(
          robots.verifyCanAccess('/file.txt', userAgent: 'A'),
          equals(false),
        );
        expect(
          robots.verifyCanAccess('/file.txt', userAgent: 'B'),
          equals(false),
        );
      });

      test('that disallow a file for all user-agents except A.', () {
        expect(
          () => robots = Robots.parse(fileDisallowedForAllExceptA),
          returnsNormally,
        );
        expect(
          robots.verifyCanAccess('/file.txt', userAgent: 'A'),
          equals(true),
        );
        expect(
          robots.verifyCanAccess('/file.txt', userAgent: 'B'),
          equals(false),
        );
      });

      test(
        'that disallow a file for A, B and C, but the parser only reads '
        'rules applicable to A and C.',
        () {
          expect(
            () => robots = Robots.parse(
              fileDisallowedForAAndBAndC,
              onlyApplicableTo: const {'A', 'C'},
            ),
            returnsNormally,
          );
          expect(
            robots.rulesets.map((ruleset) => ruleset.userAgent).toSet(),
            equals(<String>{'A', 'C'}),
          );
          expect(
            robots.verifyCanAccess('/file.txt', userAgent: 'A'),
            equals(false),
          );
          expect(
            robots.verifyCanAccess('/file.txt', userAgent: 'B'),
            equals(true),
          );
          expect(
            robots.verifyCanAccess('/file.txt', userAgent: 'C'),
            equals(false),
          );
        },
      );
    });

    group('rules', () {
      test('that disallow a directory.', () {
        expect(
          () => robots = Robots.parse(directoryDisallowed),
          returnsNormally,
        );
        expect(
          robots.verifyCanAccess('/directory/', userAgent: 'A'),
          equals(false),
        );
      });

      test('that disallow a directory, but allow a file from within it.', () {
        expect(
          () => robots = Robots.parse(directoryDisallowedButNotFile),
          returnsNormally,
        );
        expect(
          robots.verifyCanAccess('/directory/', userAgent: 'A'),
          equals(false),
        );
        expect(
          robots.verifyCanAccess('/directory/file.txt', userAgent: 'A'),
          equals(true),
        );
      });

      test('that disallow a directory, but allow its subdirectory.', () {
        expect(
          () => robots = Robots.parse(directoryDisallowedButNotSubdirectory),
          returnsNormally,
        );
        expect(
          robots.verifyCanAccess('/directory/', userAgent: 'A'),
          equals(false),
        );
        expect(
          robots.verifyCanAccess('/directory/file.txt', userAgent: 'A'),
          equals(false),
        );
        expect(
          robots.verifyCanAccess('/directory/subdirectory/', userAgent: 'A'),
          equals(true),
        );
      });

      test('that disallow a nested directory.', () {
        expect(
          () => robots = Robots.parse(nestedDirectoryDisallowed),
          returnsNormally,
        );
        expect(
          robots.verifyCanAccess('/directory/', userAgent: 'A'),
          equals(true),
        );
        expect(
          robots.verifyCanAccess('/one/directory/', userAgent: 'A'),
          equals(false),
        );
        expect(
          robots.verifyCanAccess('/one/two/directory/', userAgent: 'A'),
          equals(false),
        );
        expect(
          robots.verifyCanAccess('/one/two/three/', userAgent: 'A'),
          equals(true),
        );
      });

      test('that disallow a nested directory, but allow its subdirectory.', () {
        expect(
          () => robots = Robots.parse(
            nestedDirectoryDisallowedButNotSubdirectory,
          ),
          returnsNormally,
        );
        expect(
          robots.verifyCanAccess('/nest/directory/', userAgent: 'A'),
          equals(false),
        );
        expect(
          robots.verifyCanAccess(
            '/nest/directory/subdirectory/',
            userAgent: 'A',
          ),
          equals(true),
        );
      });

      test('that disallow a nested file.', () {
        expect(
          () => robots = Robots.parse(nestedFileDisallowed),
          returnsNormally,
        );
        expect(
          robots.verifyCanAccess('/file.txt', userAgent: 'A'),
          equals(true),
        );
        expect(
          robots.verifyCanAccess('/directory/file.txt', userAgent: 'A'),
          equals(false),
        );
        expect(
          robots.verifyCanAccess(
            '/directory/subdirectory/file.txt',
            userAgent: 'A',
          ),
          equals(false),
        );
        expect(
          robots.verifyCanAccess(
            '/directory/subdirectory/file_2.txt',
            userAgent: 'A',
          ),
          equals(true),
        );
      });

      test('that disallow files.', () {
        expect(
          () => robots = Robots.parse(allFilesDisallowed),
          returnsNormally,
        );
        expect(
          robots.verifyCanAccess('/file.txt', userAgent: 'A'),
          equals(false),
        );
        expect(
          robots.verifyCanAccess('/path', userAgent: 'A'),
          equals(true),
        );
        expect(
          robots.verifyCanAccess('/directory/', userAgent: 'A'),
          equals(true),
        );
        expect(
          robots.verifyCanAccess('/directory/file.txt', userAgent: 'A'),
          equals(false),
        );
        expect(
          robots.verifyCanAccess(
            '/directory/subdirectory/file.txt',
            userAgent: 'A',
          ),
          equals(false),
        );
        expect(
          robots.verifyCanAccess(
            '/directory/subdirectory/',
            userAgent: 'A',
          ),
          equals(true),
        );
      });

      test('that disallow directories.', () {
        expect(
          () => robots = Robots.parse(directoriesDisallowed),
          returnsNormally,
        );
        expect(
          robots.verifyCanAccess('/file.txt', userAgent: 'A'),
          equals(true),
        );
        expect(
          robots.verifyCanAccess('/file', userAgent: 'A'),
          equals(true),
        );
        expect(
          robots.verifyCanAccess('/directory/', userAgent: 'A'),
          equals(false),
        );
        expect(
          robots.verifyCanAccess('/directory/file.txt', userAgent: 'A'),
          equals(false),
        );
        expect(
          robots.verifyCanAccess(
            '/directory/subdirectory/file.txt',
            userAgent: 'A',
          ),
          equals(false),
        );
        expect(
          robots.verifyCanAccess(
            '/directory/subdirectory/',
            userAgent: 'A',
          ),
          equals(false),
        );
      });

      test('that disallow only text files.', () {
        expect(
          () => robots = Robots.parse(textFilesDisallowed),
          returnsNormally,
        );
        expect(
          robots.verifyCanAccess('/file.txt', userAgent: 'A'),
          equals(false),
        );
        expect(
          robots.verifyCanAccess('/file.pdf', userAgent: 'A'),
          equals(true),
        );
      });

      test('that disallow files that contain a certain string.', () {
        expect(
          () => robots = Robots.parse(filesContainingStringDisallowed),
          returnsNormally,
        );
        expect(
          robots.verifyCanAccess('/file.txt', userAgent: 'A'),
          equals(true),
        );
        expect(
          robots.verifyCanAccess('/string.txt', userAgent: 'A'),
          equals(false),
        );
        expect(
          robots.verifyCanAccess('/abc|string.txt', userAgent: 'A'),
          equals(false),
        );
        expect(
          robots.verifyCanAccess('/string|abc.txt', userAgent: 'A'),
          equals(false),
        );
        expect(
          robots.verifyCanAccess('/string/file.txt', userAgent: 'A'),
          equals(true),
        );
      });

      test('that disallow directories that contain a certain string.', () {
        expect(
          () => robots = Robots.parse(directoriesContainingStringDisallowed),
          returnsNormally,
        );
        expect(
          robots.verifyCanAccess('/string.txt', userAgent: 'A'),
          equals(true),
        );
        expect(
          robots.verifyCanAccess('/directory/string.txt', userAgent: 'A'),
          equals(true),
        );
        expect(
          robots.verifyCanAccess('/string/', userAgent: 'A'),
          equals(false),
        );
        expect(
          robots.verifyCanAccess('/abc|string/', userAgent: 'A'),
          equals(false),
        );
        expect(
          robots.verifyCanAccess('/string|abc/', userAgent: 'A'),
          equals(false),
        );
        expect(
          robots.verifyCanAccess('/one/two/three/string/five/', userAgent: 'A'),
          equals(false),
        );
      });
    });
  });
}
