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
    print(ruleset.userAgent);

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

  // False: it cannot.
  print(robots.verifyCanAccess('/gist/', userAgent: '*'));
  // True: it can.
  print(robots.verifyCanAccess('/wordcollector/robots_txt', userAgent: '*'));
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
