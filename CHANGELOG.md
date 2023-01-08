## 2.0.0 (Work in progress)

- Additions:
  - Added the `meta` package for static analysis.
  - Added support for the 'Sitemap' field.
  - Added support for specifying:
    - The precedent rule type for determining whether a certain user-agent can
      or cannot access a certain path. (`PrecedentRuleType`)
    - The comparison strategy to use for comparing rule precedence.
      (`PrecedenceStrategy`)
- Changes:
  - Bumped the minimum SDK version to `2.17.0`.
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
