import 'package:robots_txt/src/robots.dart';
import 'package:robots_txt/src/rule.dart';

/// A collection of `Rule`s applicable to a particular [userAgent].
class Ruleset {
  /// The user-agent which this ruleset applies to.
  final String userAgent;

  /// List of `Rule`s which state that a path may not be traversed.
  final List<Rule> disallows;

  /// List of `Rule`s which state that a path may be traversed.
  final List<Rule> allows;

  /// The number of seconds of delay that crawlers should add in-between
  /// accesses.
  final int? crawlDelaySeconds;

  /// Whether this ruleset applies to all user-agents.
  final bool appliesToAll;

  /// Instantiates a ruleset for the specified [userAgent].
  const Ruleset({
    required this.userAgent,
    required this.allows,
    required this.disallows,
    this.crawlDelaySeconds,
  }) : appliesToAll = userAgent == '*';

  /// Checks whether this ruleset applies to [userAgent].
  bool appliesTo(String userAgent) =>
      appliesToAll || this.userAgent == userAgent;
}

/// Extends `List<Ruleset>` with a  method used to find a rule that matches
/// the supplied filters.
extension FindRuleInRuleset on List<Ruleset> {
  /// Gets the rule that applies to [userAgent], pertains to [path] and is of
  /// type [type].
  Rule? findApplicableRule({
    required String userAgent,
    required String path,
    required RuleType type,
    PrecedenceStrategy comparisonMethod = PrecedenceStrategy.defaultStrategy,
  }) {
    for (final ruleset in this) {
      final rules = type == RuleType.allow ? ruleset.allows : ruleset.disallows;
      if (rules.isEmpty) {
        continue;
      }

      if (!ruleset.appliesTo(userAgent)) {
        continue;
      }

      final rule = rules.findMostApplicable(
        path: path,
        comparisonMethod: comparisonMethod,
      );
      if (rule != null) {
        return rule;
      }
    }

    return null;
  }
}
