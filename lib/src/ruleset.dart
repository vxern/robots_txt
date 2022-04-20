import 'package:robots_txt/src/rule.dart';

/// A collection of `Rule`s, and the `user-agent` they are relevant to inside
/// the `robots.txt` file.
class Ruleset {
  /// The `user-agent` which this ruleset applies to.
  final String appliesTo;

  /// List of `Rule`s which explicitly state that a path may be traversed.
  final List<Rule> allows = [];

  /// List of `Rule`s which explicitly state that a path may not be traversed.
  final List<Rule> disallows = [];

  /// Instantiates a ruleset with the `user-agent`.
  Ruleset(this.appliesTo);

  /// Checks whether this ruleset applies to [userAgent].
  bool doesConcern(String userAgent) =>
      appliesTo == '*' || appliesTo == userAgent;
}

/// Extends `List<Ruleset>` with a method for getting a single `Rule` from the
/// list of `Rulesets`
extension RulingOfRulesets on List<Ruleset> {
  /// Gets the rule which [appliesTo], [concernsPath] [andAllowsIt].
  Rule? getRule({
    required String appliesTo,
    required String concernsPath,
    required bool andAllowsIt,
  }) =>
      fold<Rule?>(null, (current, next) {
        if (!next.doesConcern(appliesTo)) {
          return current;
        }

        final currentPriority = current?.priority ?? -1;
        final relevantRules = andAllowsIt ? next.allows : next.disallows;
        final nextRule = relevantRules.getRulingOnPath(concernsPath);

        if (nextRule == null || nextRule.priority < currentPriority) {
          return current;
        }
        return nextRule;
      });
}
