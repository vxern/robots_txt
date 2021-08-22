import 'package:robots_txt/robots_txt.dart';

Future main() async {
  // Create an instance of the `robots.txt` parser
  final robots = Robots(host: 'https://github.com/');
  // Read the ruleset of the website
  await robots.read();
  // Print the ruleset
  for (final ruleset in robots.rulesets) {
    // Print the user-agent the ruleset applies to 
    print(ruleset.appliesTo);
    if (ruleset.allows.isNotEmpty) {
      print('Allows:');
    }
    // Print the path expressions allowed by this ruleset
    for (final rule in ruleset.allows) {
      print('  - ${rule.expression}');
    }
    if (ruleset.disallows.isNotEmpty) {
      print('Disallows:');
    }
    // Print the path expressions disallowed by this ruleset
    for (final rule in ruleset.disallows) {
      print('  - ${rule.expression}');
    }
  }
  // False, it cannot
  print(robots.canVisitPath('/gist/', userAgent: '*'));
  // True, it can
  print(robots.canVisitPath('/wordcollector/robots_txt', userAgent: '*'));
  return;
}