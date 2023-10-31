/// A single rule (either `Allow` or `Disallow`) inside a `robots.txt` file.
class Rule {
  /// A regular expression matching to a particular path.
  final RegExp pattern;

  /// The precedence of this rule based on its position inside the `robots.txt`
  /// file. The rule with the higher precedence is used to decide whether or not
  /// a path may be visited.
  final int _precedence;

  /// Instantiates a rule with an [pattern] and the [precedence] it has over
  /// other rules.
  const Rule({required this.pattern, required int precedence})
      : _precedence = precedence;
}

/// Extends `List<Rule>` with methods used to find rule that pertain to a
/// certain path.
extension FindRule on List<Rule> {
  /// Taking a [path], returns the `Rule`s that pertain to it.
  List<Rule> findApplicable({required String path}) =>
      where((rule) => rule.pattern.hasMatch(path)).toList();

  /// Taking a [path], gets the `Rule`s that pertain to it, and returns the
  /// `Rule` that has precedence over the other rules.
  Rule? findMostApplicable({
    required String path,
    PrecedenceStrategy comparisonMethod = PrecedenceStrategy.defaultStrategy,
  }) {
    final comparisonFunction = _ruleComparisonFunctions[comparisonMethod]!;

    final applicableRules = findApplicable(path: path);
    if (applicableRules.isEmpty) {
      return null;
    }

    return applicableRules.reduce(comparisonFunction);
  }
}

/// Extends `Rule?` with a getter `precedence` to avoid having to explicitly
/// default to `-1` whenever attempting to access the hidden property
/// `_precedence` on a nullish value.
extension Precedence on Rule? {
  /// Gets the precedence of this rule. Defaults to `-1` if `null`.
  int get precedence => this?._precedence ?? -1;
}

/// The signature of a method that compares two variables of type `T` and
/// returns the one supposed 'greater'.
typedef ComparisonFunction<T> = T Function(T a, T b);

/// `ComparisonFunction`s matched to `PrecedenceStrategy`s.
final _ruleComparisonFunctions =
    Map<PrecedenceStrategy, ComparisonFunction<Rule>>.unmodifiable(
  <PrecedenceStrategy, ComparisonFunction<Rule>>{
    PrecedenceStrategy.higherTakesPrecedence: (a, b) =>
        a.precedence > b.precedence ? a : b,
    PrecedenceStrategy.lowerTakesPrecedence: (a, b) =>
        a.precedence < b.precedence ? a : b,
  },
);

/// Defines the strategy to use to compare rules as per their `precedence`.
enum PrecedenceStrategy {
  /// The rule defined higher up in the `robots.txt` file takes precedence.
  higherTakesPrecedence,

  /// The rule defines lower down in the `robots.txt` file takes precedence.
  lowerTakesPrecedence;

  /// Defines the default strategy to use to compare rules.
  static const defaultStrategy = PrecedenceStrategy.higherTakesPrecedence;
}
