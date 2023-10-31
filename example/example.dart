import 'dart:convert';
import 'dart:io';

import 'package:robots_txt/robots_txt.dart';

Future<void> main() async {
  // Get the contents of the `robots.txt` file.
  final contents = await fetchFileContents(host: 'github.com');
  // Parse the contents.
  final robots = Robots.parse(contents);

  // Print the rulesets.
  for (final ruleset in robots.rulesets) {
    // Print the user-agent this ruleset applies to.
    print('User-agent: ${ruleset.userAgent}');

    if (ruleset.allows.isNotEmpty) {
      print('Allowed:');
    }
    // Print the regular expressions that match to paths allowed by this
    // ruleset.
    for (final rule in ruleset.allows) {
      print('  - ${rule.pattern}');
    }

    if (ruleset.disallows.isNotEmpty) {
      print('Disallowed:');
    }
    // Print the regular expressions that match to paths disallowed by this
    // ruleset.
    for (final rule in ruleset.disallows) {
      print('  - ${rule.pattern}');
    }
  }

  const userAgent = 'government';

  // False: it cannot.
  print(
    "Can '$userAgent' access /gist/? ${robots.verifyCanAccess('/gist/', userAgent: userAgent)}",
  );
  // True: it can.
  print(
    "Can '$userAgent' access /government/robots_txt/? ${robots.verifyCanAccess('/government/robots_txt/', userAgent: userAgent)}",
  );

  // Validating an invalid file will throw a `FormatException`.
  try {
    Robots.validate('This is an obviously invalid robots.txt file.');
  } on FormatException {
    print('As expected, the first file is flagged as invalid.');
  }

  // Validating an already valid file will not throw anything.
  try {
    Robots.validate('''
User-agent: *
Crawl-delay: 10
Disallow: /
Allow: /file.txt

Host: https://hosting.example.com/
Sitemap: https://example.com/sitemap.xml
''');
    print('As expected also, the second file is not flagged as invalid.');
  } on FormatException {
    print('Welp, this was not supposed to happen.');
  }

  late final String contentsFromBefore;

  // Validating a file with unsupported fields.
  try {
    Robots.validate(
      contentsFromBefore = '''
User-agent: *
Some-field: abcd.txt
''',
    );
  } on FormatException {
    print(
      'This file is invalid on the grounds that it contains fields we did not '
      'expect it to have.',
    );
    print(
      "Let's fix that by including the custom field in the call to validate().",
    );
    try {
      Robots.validate(contentsFromBefore, allowedFieldNames: {'Some-field'});
      print('Aha! Now there are no issues.');
    } on FormatException {
      print('Welp, this also was not supposed to happen.');
    }
  }
}

Future<String> fetchFileContents({required String host}) async {
  final client = HttpClient();

  final contents = await client
      .get(host, 80, '/robots.txt')
      .then((request) => request.close())
      .then((response) => response.transform(utf8.decoder).join());

  client.close();

  return contents;
}
