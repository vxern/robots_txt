/// Defines the method used to decide whether rules that explicitly allow a
/// user-agent to access a path take precedence over ones that disallow it to do
/// so, or the other way around.
enum PrecedentRuleType {
  /// The rule that explicitly allows a user-agent to access a path takes
  /// precedence over rules that explicitly disallow it.
  allow,

  /// The rule that explicitly disallows a user-agent to access a path takes
  /// precedence over rules that explicitly allow it.
  disallow;

  /// Defines the default precedent rule type.
  static const defaultPrecedentType = PrecedentRuleType.allow;
}
