import 'package:test/test.dart';

import 'package:robots_txt/robots_txt.dart';

import '../samples.dart';

void main() {
  late Robots robots;

  group('The parser correctly parses', () {
    group('file contents', () {
      test('that are empty.', () {
        expect(() => robots = Robots.parse(emptyContents), returnsNormally);
        expect(robots.verifyCanAccess('/', userAgent: 'A'), isTrue);
      });

      test('that are not valid.', () {
        expect(() => robots = Robots.parse(invalidContents), returnsNormally);
        expect(robots.verifyCanAccess('/', userAgent: 'A'), isTrue);
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
        expect(robots.hosts, equals([FieldType.host.example]));

        expect(robots.verifyCanAccess('/', userAgent: 'A'), isFalse);
        expect(
          robots.verifyCanAccess('/file.txt', userAgent: 'A'),
          isTrue,
        );
      });

      test('that define a sitemap.', () {
        expect(() => robots = Robots.parse(sitemap), returnsNormally);
        expect(robots.sitemaps, equals([FieldType.sitemap.example]));
      });

      test('that define a host.', () {
        expect(() => robots = Robots.parse(host), returnsNormally);
        expect(robots.hosts, equals([FieldType.host.example]));
      });
    });

    group('rules with logic-based applicability', () {
      test('defined without a User-Agent.', () {
        expect(
          () => robots = Robots.parse(rulesWithoutUserAgent),
          returnsNormally,
        );
        expect(robots.rulesets, equals(<Ruleset>[]));
        expect(robots.verifyCanAccess('/', userAgent: 'A'), isTrue);
      });

      test('defined before a User-Agent.', () {
        expect(
          () => robots = Robots.parse(rulesDefinedBeforeUserAgent),
          returnsNormally,
        );
        expect(robots.rulesets, equals(<Ruleset>[]));
        expect(robots.verifyCanAccess('/', userAgent: 'A'), isTrue);
      });

      test('that disallow a file for A.', () {
        expect(
          () => robots = Robots.parse(fileDisallowedForA),
          returnsNormally,
        );
        expect(robots.verifyCanAccess('/', userAgent: 'A'), isTrue);
        expect(
          robots.verifyCanAccess('/file.txt', userAgent: 'A'),
          isFalse,
        );
      });

      test('that disallow a file for both A and B.', () {
        expect(
          () => robots = Robots.parse(fileDisallowedForAAndB),
          returnsNormally,
        );
        expect(
          robots.verifyCanAccess('/file.txt', userAgent: 'A'),
          isFalse,
        );
        expect(
          robots.verifyCanAccess('/file.txt', userAgent: 'B'),
          isFalse,
        );
        expect(
          robots.verifyCanAccess('/file.txt', userAgent: 'C'),
          isTrue,
        );
      });

      test('that disallow a file for all user-agents.', () {
        expect(
          () => robots = Robots.parse(fileDisallowedForAll),
          returnsNormally,
        );
        expect(
          robots.verifyCanAccess('/', userAgent: 'A'),
          isTrue,
        );
        expect(
          robots.verifyCanAccess('/file.txt', userAgent: 'A'),
          isFalse,
        );
        expect(
          robots.verifyCanAccess('/file.txt', userAgent: 'B'),
          isFalse,
        );
      });

      test('that disallow a file for all user-agents except A.', () {
        expect(
          () => robots = Robots.parse(fileDisallowedForAllExceptA),
          returnsNormally,
        );
        expect(
          robots.verifyCanAccess('/file.txt', userAgent: 'A'),
          isTrue,
        );
        expect(
          robots.verifyCanAccess('/file.txt', userAgent: 'B'),
          isFalse,
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
            isFalse,
          );
          expect(
            robots.verifyCanAccess('/file.txt', userAgent: 'B'),
            isTrue,
          );
          expect(
            robots.verifyCanAccess('/file.txt', userAgent: 'C'),
            isFalse,
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
          isFalse,
        );
      });

      test('that disallow a directory, but allow a file from within it.', () {
        expect(
          () => robots = Robots.parse(directoryDisallowedButNotFile),
          returnsNormally,
        );
        expect(
          robots.verifyCanAccess('/directory/', userAgent: 'A'),
          isFalse,
        );
        expect(
          robots.verifyCanAccess('/directory/file.txt', userAgent: 'A'),
          isTrue,
        );
      });

      test('that disallow a directory, but allow its subdirectory.', () {
        expect(
          () => robots = Robots.parse(directoryDisallowedButNotSubdirectory),
          returnsNormally,
        );
        expect(
          robots.verifyCanAccess('/directory/', userAgent: 'A'),
          isFalse,
        );
        expect(
          robots.verifyCanAccess('/directory/file.txt', userAgent: 'A'),
          isFalse,
        );
        expect(
          robots.verifyCanAccess('/directory/subdirectory/', userAgent: 'A'),
          isTrue,
        );
      });

      test('that disallow a nested directory.', () {
        expect(
          () => robots = Robots.parse(nestedDirectoryDisallowed),
          returnsNormally,
        );
        expect(
          robots.verifyCanAccess('/directory/', userAgent: 'A'),
          isTrue,
        );
        expect(
          robots.verifyCanAccess('/one/directory/', userAgent: 'A'),
          isFalse,
        );
        expect(
          robots.verifyCanAccess('/one/two/directory/', userAgent: 'A'),
          isFalse,
        );
        expect(
          robots.verifyCanAccess('/one/two/three/', userAgent: 'A'),
          isTrue,
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
          isFalse,
        );
        expect(
          robots.verifyCanAccess(
            '/nest/directory/subdirectory/',
            userAgent: 'A',
          ),
          isTrue,
        );
      });

      test('that disallow a nested file.', () {
        expect(
          () => robots = Robots.parse(nestedFileDisallowed),
          returnsNormally,
        );
        expect(
          robots.verifyCanAccess('/file.txt', userAgent: 'A'),
          isTrue,
        );
        expect(
          robots.verifyCanAccess('/directory/file.txt', userAgent: 'A'),
          isFalse,
        );
        expect(
          robots.verifyCanAccess(
            '/directory/subdirectory/file.txt',
            userAgent: 'A',
          ),
          isFalse,
        );
        expect(
          robots.verifyCanAccess(
            '/directory/subdirectory/file_2.txt',
            userAgent: 'A',
          ),
          isTrue,
        );
      });

      test('that disallow files.', () {
        expect(
          () => robots = Robots.parse(allFilesDisallowed),
          returnsNormally,
        );
        expect(
          robots.verifyCanAccess('/file.txt', userAgent: 'A'),
          isFalse,
        );
        expect(
          robots.verifyCanAccess('/path', userAgent: 'A'),
          isTrue,
        );
        expect(
          robots.verifyCanAccess('/directory/', userAgent: 'A'),
          isTrue,
        );
        expect(
          robots.verifyCanAccess('/directory/file.txt', userAgent: 'A'),
          isFalse,
        );
        expect(
          robots.verifyCanAccess(
            '/directory/subdirectory/file.txt',
            userAgent: 'A',
          ),
          isFalse,
        );
        expect(
          robots.verifyCanAccess(
            '/directory/subdirectory/',
            userAgent: 'A',
          ),
          isTrue,
        );
      });

      test('that disallow directories.', () {
        expect(
          () => robots = Robots.parse(directoriesDisallowed),
          returnsNormally,
        );
        expect(
          robots.verifyCanAccess('/file.txt', userAgent: 'A'),
          isTrue,
        );
        expect(
          robots.verifyCanAccess('/file', userAgent: 'A'),
          isTrue,
        );
        expect(
          robots.verifyCanAccess('/directory/', userAgent: 'A'),
          isFalse,
        );
        expect(
          robots.verifyCanAccess('/directory/file.txt', userAgent: 'A'),
          isFalse,
        );
        expect(
          robots.verifyCanAccess(
            '/directory/subdirectory/file.txt',
            userAgent: 'A',
          ),
          isFalse,
        );
        expect(
          robots.verifyCanAccess(
            '/directory/subdirectory/',
            userAgent: 'A',
          ),
          isFalse,
        );
      });

      test('that disallow only text files.', () {
        expect(
          () => robots = Robots.parse(textFilesDisallowed),
          returnsNormally,
        );
        expect(
          robots.verifyCanAccess('/file.txt', userAgent: 'A'),
          isFalse,
        );
        expect(
          robots.verifyCanAccess('/file.pdf', userAgent: 'A'),
          isTrue,
        );
      });

      test('that disallow files that contain a certain string.', () {
        expect(
          () => robots = Robots.parse(filesContainingStringDisallowed),
          returnsNormally,
        );
        expect(
          robots.verifyCanAccess('/file.txt', userAgent: 'A'),
          isTrue,
        );
        expect(
          robots.verifyCanAccess('/string.txt', userAgent: 'A'),
          isFalse,
        );
        expect(
          robots.verifyCanAccess('/abc|string.txt', userAgent: 'A'),
          isFalse,
        );
        expect(
          robots.verifyCanAccess('/string|abc.txt', userAgent: 'A'),
          isFalse,
        );
        expect(
          robots.verifyCanAccess('/string/file.txt', userAgent: 'A'),
          isTrue,
        );
      });

      test('that disallow directories that contain a certain string.', () {
        expect(
          () => robots = Robots.parse(directoriesContainingStringDisallowed),
          returnsNormally,
        );
        expect(
          robots.verifyCanAccess('/string.txt', userAgent: 'A'),
          isTrue,
        );
        expect(
          robots.verifyCanAccess('/directory/string.txt', userAgent: 'A'),
          isTrue,
        );
        expect(
          robots.verifyCanAccess('/string/', userAgent: 'A'),
          isFalse,
        );
        expect(
          robots.verifyCanAccess('/abc|string/', userAgent: 'A'),
          isFalse,
        );
        expect(
          robots.verifyCanAccess('/string|abc/', userAgent: 'A'),
          isFalse,
        );
        expect(
          robots.verifyCanAccess('/one/two/three/string/five/', userAgent: 'A'),
          isFalse,
        );
      });

      test(
        "that disallow everything for all User-Agents except for 'A'.",
        () {
          expect(
            () => robots = Robots.parse(everythingDisallowedForAllExceptA),
            returnsNormally,
          );
          expect(
            robots.verifyCanAccess('/file.txt', userAgent: 'B'),
            isFalse,
          );
          expect(
            robots.verifyCanAccess('/file.txt', userAgent: 'C'),
            isFalse,
          );
          expect(
            robots.verifyCanAccess('/file.txt', userAgent: 'A'),
            isTrue,
          );
        },
      );
    });
  });
}
