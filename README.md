## A simple yet complete, lightweight and sturdy `robots.txt` ruleset parser to ensure your application follows the standard protocol.

### Usage

The following code gets the `robots.txt` robot exclusion ruleset of a website.

`quietMode` determines whether or not the library should print warning messages in the case of the `robots.txt` not being valid or other errors.

```dart
// Create an instance of the `robots.txt` parser
final robots = Robots('host', quietMode: true);
// Read the ruleset of the website
robots.read().then(() {
  for (final ruleset in robots.rulesets) {
    // Print the user-agent the ruleset applies to 
    print(ruleset.appliesTo);
    print('Allows:');
    // Print the path expressions allowed by this ruleset
    for (final rule in ruleset.allows) {
      print('  - ${rule  expression}');
    }
    // Print the path expressions disallowed by this ruleset
    for (final rule in ruleset.disallows) {
      print('  - ${rule  expression}');
    }
  }
});
```