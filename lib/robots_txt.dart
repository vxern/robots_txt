/// Lightweight, fully documented `robots.txt` file parser.
library robots_txt;

export 'src/robots.dart' show Robots, PrecedentRuleType, FieldType;
export 'src/rule.dart' show Rule, FindRule, Precedence, PrecedenceStrategy;
export 'src/ruleset.dart' show Ruleset, FindRuleInRuleset;
