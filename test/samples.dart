import 'package:robots_txt/robots_txt.dart';

/// Empty file contents.
const emptyContents = '';

/// Invalid `robots.txt` contents.
const invalidContents = 'This is an invalid robots.txt file.';

/// Valid `robots.txt` file with all supported fields with example values and an
/// extra field named 'Field'.
final validContentsWithCustomFieldName = [
  ...FieldType.values.map((value) => value.toField()),
  'Field: unknown',
].join('\n');

/// Valid `robots.txt` file with an invalid disallow field.
final validContentsInvalidPattern = '''
${FieldType.userAgent.toField('A')}
${FieldType.disallow.toField(r'/\$')}
''';

/// Valid `robots.txt` file with all supported fields with example values.
final validContentsValidPattern =
    FieldType.values.map((value) => value.toField()).join('\n');

/// Example rule fields without a user-agent.
final rulesWithoutUserAgent =
    FieldType.rules.map((value) => value.toField()).join('\n');

/// Example rule fields defined before a user-agent.
final rulesDefinedBeforeUserAgent = [...FieldType.rules, FieldType.userAgent]
    .map((value) => value.toField())
    .join();

/// Example sitemap field.
final sitemap = FieldType.sitemap.toField();

/// File disallowed for user-agent 'A'.
final fileDisallowedForA = '''
${FieldType.userAgent.toField('A')}
${FieldType.disallow.toField('/file.txt')}
''';

/// File disallowed for user-agents 'A' and 'B'.
final fileDisallowedForAAndB = '''
${FieldType.userAgent.toField('A')}
${FieldType.userAgent.toField('B')}
${FieldType.disallow.toField('/file.txt')}
''';

/// File disallowed for all user-agents.
final fileDisallowedForAll = '''
${FieldType.userAgent.toField('*')}
${FieldType.disallow.toField('/file.txt')}
''';

/// File disallowed for all user-agents except 'A'.
final fileDisallowedForAllExceptA = '''
${FieldType.userAgent.toField('*')}
${FieldType.disallow.toField('/file.txt')}
${FieldType.userAgent.toField('A')}
${FieldType.allow.toField('/file.txt')}
''';

/// File disallowed for 'A', 'B' and 'C'.
final fileDisallowedForAAndBAndC = '''
${FieldType.userAgent.toField('A')}
${FieldType.userAgent.toField('B')}
${FieldType.userAgent.toField('C')}
${FieldType.disallow.toField('/file.txt')}
''';

/// Directory disallowed.
final directoryDisallowed = '''
${FieldType.userAgent.toField('*')}
${FieldType.disallow.toField('/directory/')}
''';

/// Directory disallowed, but not a certain file.
final directoryDisallowedButNotFile = '''
${FieldType.userAgent.toField('*')}
${FieldType.disallow.toField('/directory/')}
${FieldType.allow.toField('/directory/file.txt')}
''';

/// Directory disallowed, but not its subdirectory.
final directoryDisallowedButNotSubdirectory = '''
${FieldType.userAgent.toField('*')}
${FieldType.disallow.toField('/directory/')}
${FieldType.allow.toField('/directory/subdirectory/')}
''';

/// Nested directory disallowed.
final nestedDirectoryDisallowed = '''
${FieldType.userAgent.toField('*')}
${FieldType.disallow.toField('/*/directory/')}
''';

/// Nested directory disallowed, but not its subdirectory.
final nestedDirectoryDisallowedButNotSubdirectory = '''
${FieldType.userAgent.toField('*')}
${FieldType.disallow.toField('/*/directory/')}
${FieldType.allow.toField('/*/directory/subdirectory/')}
''';

/// Nested file disallowed.
final nestedFileDisallowed = '''
${FieldType.userAgent.toField('*')}
${FieldType.disallow.toField('/*/file.txt')}
''';

/// All files disallowed.
final allFilesDisallowed = '''
${FieldType.userAgent.toField('*')}
${FieldType.disallow.toField('/*.*')}
''';

/// All directories disallowed.
final directoriesDisallowed = '''
${FieldType.userAgent.toField('*')}
${FieldType.disallow.toField('/*/')}
''';

/// All text files disallowed, but not other files.
final textFilesDisallowed = '''
${FieldType.userAgent.toField('*')}
${FieldType.disallow.toField('/*.txt')}
''';

/// Files containing a certain string disallowed.
final filesContainingStringDisallowed = '''
${FieldType.userAgent.toField('*')}
${FieldType.disallow.toField('*/*string*.*')}
${FieldType.allow.toField('/*string*/')}
''';

/// Directories containing a certain string disallowed.
final directoriesContainingStringDisallowed = '''
${FieldType.userAgent.toField('*')}
${FieldType.disallow.toField('/*string*/')}
''';
