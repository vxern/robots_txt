/// Lightweight, fully documented `robots.txt` file parser.
library robots_txt;

export 'src/robots.dart' show FieldType, PrecedentRuleType, Robots;
export 'src/rule.dart' show FindRule, Precedence, PrecedenceStrategy, Rule;
export 'src/ruleset.dart' show FindRuleInRuleset, Ruleset;
