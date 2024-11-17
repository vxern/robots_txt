## 2.3.1

- Fixed empty `Disallow` entry not allowing access to everything.
- Bumped year in `LICENSE`.

## 2.3.0

- Bumped dependencies.
- Bumped the SDK version to `3.0.0`.
- Removed the `meta` package.
- Removed work-around for issue fixed by https://github.com/dart-lang/sdk/issues/49188.

## 2.2.0+3

- Updated licence bearer.

## 2.2.0+2

- Small phrasing change in README.md.

## 2.2.0+1

- Compiled the example files into a single file `example.dart`.

## 2.2.0

- Added support for the `Crawl-delay` and `Host` fields.

## 2.1.0+1

- Updated README.md.

## 2.1.0

- Added a method `.validate()` for validating files.
- Renamed `parser.dart` to `robots.dart`.

## 2.0.1

- Converted the `onlyApplicableTo` parameter in `Robots.parse()` from a `String`
  into a `Set` to allow multiple user-agents to be specified at once.
- Fixed the `onlyApplicableTo` parameter in `Robots.parse()` not being taken
  into account.

## 2.0.0

- Additions:
  - Added dependencies:
    - `meta` for static analysis.
  - Added developer dependencies:
    - `test` for testing.
  - Added support for the 'Sitemap' field.
  - Added support for specifying:
    - The precedent rule type for determining whether a certain user-agent can
      or cannot access a certain path. (`PrecedentRuleType`)
    - The comparison strategy to use for comparing rule precedence.
      (`PrecedenceStrategy`)
  - Added tests.
- Changes:
  - Bumped the minimum SDK version to `2.17.0` for enhanced enum support.
- Improvements:
  - Made all structs `const` and marked them as `@sealed` and `@immutable`.
- Deletions:
  - Removed dependencies:
    - `sprint`
    - `web_scraper`

## 1.1.1

- Updated project description.
- Adapted code to lint rules.

## 1.1.0+3

- Improved documentation.
- Bumped year in the license.

## 1.1.0+2

- Updated package description.
- Updated dependency versions.

## 1.1.0+1

- Formatted files in accordance with `dartfmt`.

## 1.1.0

- Fixed the reading of the contents of `robots.txt`.
- Fixed the parsing of rule fields to `Rule`s.
- Added `example.dart`.

## 1.0.0

- Initial release.
