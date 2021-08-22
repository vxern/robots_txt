/// A single rule (either `Allow` or `Disallow`) inside the `robots.txt` file
class Rule {
  /// An expression which a path may be matched against to determine whether
  /// this rule applies to the path
  final RegExp expression;

  /// The priority of this rule based on its position inside the `robots.txt`
  /// file. If the path is determined to be relevant to two rules, the rule
  /// with the higher priority *overrides* the ruling of the other.
  final int priority;

  /// Instantiates a rule with an [expression] and the [priority] it has over
  /// other rules
  const Rule(this.expression, this.priority);
}

/// Extends `List<Rule>` with a method for getting the `Rule` with the highest
/// [Rule.priority]
extension RulingOnPath on List<Rule> {
  /// Taking [path], checks which `Rule`s' expressions match [path], and
  /// returns the `Rule` with the highest priority
  Rule? getRulingOnPath(String path) {
    final relevantRules = where((rule) => rule.expression.hasMatch(path));
    if (relevantRules.isEmpty) {
      return null;
    }
    // Get the relevant rule with the highest priority
    return relevantRules.reduce((a, b) => a.priority > b.priority ? a : b);
  }
}
