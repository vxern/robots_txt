/// Defines the strategy to use to compare rules as per their `precedence`.
enum PrecedenceStrategy {
  /// The rule defined higher up in the `robots.txt` file takes precedence.
  higherTakesPrecedence,

  /// The rule defines lower down in the `robots.txt` file takes precedence.
  lowerTakesPrecedence;

  /// Defines the default strategy to use to compare rules.
  static const defaultStrategy = PrecedenceStrategy.higherTakesPrecedence;
}
