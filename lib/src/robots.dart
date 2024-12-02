import 'package:robots_txt/src/field_type.dart';
import 'package:robots_txt/src/precedence_rule_type.dart';
import 'package:robots_txt/src/precedence_strategy.dart';
import 'package:robots_txt/src/rule.dart';
import 'package:robots_txt/src/rule_type.dart';
import 'package:robots_txt/src/ruleset.dart';

/// Taking a set of [allowedFieldNames], builds a regular expression matching
/// only to valid `robots.txt` files.
RegExp buildValidFilePattern({Set<String> allowedFieldNames = const {}}) {
  final fieldNameExpression =
      [FieldType.defaultFieldNameExpression, ...allowedFieldNames].join('|');

  return RegExp(
    '^(?:(?:(?:$fieldNameExpression):(?:.+))(?:\\s*(?:#.*)?)\n?){0,}\$',
  );
}

/// Defines a Regex pattern that matches to comments.
final commentPattern = RegExp('#.*');

/// Stores information about a `robots.txt` file, exposing a simple and concise
/// API for working with the file and validating if a certain path can be
/// accessed by a given user-agent.
class Robots {
  /// Stores information about the rules specified for given user-agents.
  final List<Ruleset> rulesets;

  /// Stores links to the website's sitemaps.
  final List<String> sitemaps;

  /// Stores the preferred domains for a website with multiple mirrors.
  final List<String> hosts;

  /// Defines an instance of `Robots` with no rulesets.
  static const _empty = Robots._construct(
    rulesets: [],
    sitemaps: [],
    hosts: [],
  );

  /// Creates an instance of `Robots`.
  const Robots._construct({
    required this.rulesets,
    required this.sitemaps,
    required this.hosts,
  });

  /// Parses the contents of a `robots.txt` file, creating an instance of
  /// `Robots`.
  ///
  /// If [onlyApplicableTo] is specified, the parser will ignore user-agents
  /// that are not included within it.
  ///
  /// This function will never throw an exception. If you wish to validate a
  /// file
  factory Robots.parse(
    String contents, {
    Set<String>? onlyApplicableTo,
  }) =>
      Robots._parse(contents, onlyApplicableTo: onlyApplicableTo);

  /// Taking the contents of `robots.txt` file, ensures that the file is valid,
  /// and throws a `FormatException` if not.
  ///
  /// By default, this function will only accept the following fields:
  /// - User-agent
  /// - Allow
  /// - Disallow
  /// - Sitemap
  /// - Crawl-delay
  /// - Host
  ///
  /// To accept any other fields, simply specify them in the [allowedFieldNames]
  /// parameter.
  static void validate(
    String contents, {
    Set<String> allowedFieldNames = const {},
  }) {
    final validFilePattern =
        buildValidFilePattern(allowedFieldNames: allowedFieldNames);
    if (!validFilePattern.hasMatch(contents)) {
      throw const FormatException(
        'The file is not a valid `robots.txt` file.',
      );
    }

    Robots._parse(contents, throwOnError: true);
  }

  /// Splits [contents] into lines and iterates over them, sequentially parsing
  /// each field, optionally ignoring those user-agents that are not found in
  /// [onlyApplicableTo].
  ///
  /// If [throwOnError] is `true`, this function will re-throw errors caught
  /// during parsing.
  factory Robots._parse(
    String contents, {
    Set<String>? onlyApplicableTo,
    bool throwOnError = false,
  }) {
    final List<String> lines;
    {
      contents = contents.replaceAll(commentPattern, '');

      if (contents.trim().isEmpty) {
        return Robots._empty;
      }

      lines = contents.split('\n').where((line) => line.isNotEmpty).toList();
    }

    final rulesets = <Ruleset>[];
    final sitemaps = <String>[];
    final hosts = <String>[];

    // Temporary data used for parsing rulesets.
    final userAgents = <String>[];
    final allows = <Rule>[];
    final disallows = <Rule>[];
    int? crawlDelay;

    bool isReadingRuleset() => userAgents.isNotEmpty;

    void saveRulesets() {
      for (final userAgent in userAgents) {
        rulesets.add(
          Ruleset(
            userAgent: userAgent,
            allows: List.from(allows),
            disallows: List.from(disallows),
          ),
        );
      }
    }

    void reset() {
      userAgents.clear();
      allows.clear();
      disallows.clear();
      crawlDelay = null;
    }

    late FieldType previousType;
    for (var index = 0; index < lines.length; index++) {
      final field = _getFieldFromLine(lines[index]);
      if (field == null) {
        continue;
      }

      final type = FieldType.byKey(field.key);
      if (type == null) {
        continue;
      }

      switch (type) {
        case FieldType.userAgent:
          if (userAgents.isNotEmpty && previousType != FieldType.userAgent) {
            saveRulesets();
            reset();
          }

          if (onlyApplicableTo != null &&
              !onlyApplicableTo.contains(field.value)) {
            break;
          }

          userAgents.add(field.value);
        case FieldType.disallow:
          if (!isReadingRuleset()) {
            break;
          }

          final RegExp pattern;
          try {
            pattern = _convertPathToRegExp(field.value);
          } on FormatException catch (exception) {
            if (throwOnError) {
              throw wrapFormatException(exception, field.value, index);
            } else {
              break;
            }
          }

          if (field.value.trim().isEmpty) {
            allows.add(Rule(pattern: pattern, precedence: 0));
            break;
          }

          disallows.add(
            Rule(
              pattern: pattern,
              precedence: lines.length - (index + 1),
            ),
          );
        case FieldType.allow:
          if (!isReadingRuleset()) {
            break;
          }

          final RegExp pattern;
          try {
            pattern = _convertPathToRegExp(field.value);
          } on FormatException catch (exception) {
            if (throwOnError) {
              throw wrapFormatException(exception, field.value, index);
            } else {
              break;
            }
          }
          allows.add(
            Rule(
              pattern: pattern,
              precedence: lines.length - (index + 1),
            ),
          );
        case FieldType.sitemap:
          sitemaps.add(field.value);
        case FieldType.crawlDelay:
          final value = int.tryParse(field.value);
          if (value == null || (crawlDelay != null && value < crawlDelay!)) {
            break;
          }

          crawlDelay = value;
        case FieldType.host:
          hosts.add(field.value);
      }

      previousType = type;
    }

    if (isReadingRuleset()) {
      saveRulesets();
      reset();
    }

    return Robots._construct(
      rulesets: rulesets,
      sitemaps: sitemaps,
      hosts: hosts,
    );
  }

  /// Reads a path declaration from within `robots.txt` and converts it to a
  /// regular expression for later matching.
  static RegExp _convertPathToRegExp(String pathDeclaration) {
    // Collapse duplicate slashes and wildcards into single ones.
    final collapsed =
        pathDeclaration.replaceAll('/+', '/').replaceAll('*+', '*');
    final normalised = collapsed.endsWith('*')
        ? collapsed.substring(0, collapsed.length - 1)
        : collapsed;
    final withWildcardsReplaced =
        normalised.replaceAll('.', r'\.').replaceAll('*', '.*');
    final withTrailingText = withWildcardsReplaced.contains(r'$')
        ? withWildcardsReplaced.split(r'$').first
        : '$withWildcardsReplaced.*';
    return RegExp(withTrailingText, caseSensitive: false, dotAll: true);
  }

  /// Extracts the key and value from [target] and puts it into a `MapEntry`.
  static MapEntry<String, String>? _getFieldFromLine(String target) {
    final keyValuePair = target.split(':');
    if (keyValuePair.length < 2) {
      return null;
    }

    final key = keyValuePair.first.trim();
    final value = keyValuePair.sublist(1).join(':').trim();
    return MapEntry(key, value);
  }

  /// Checks if the `robots.txt` file allows [userAgent] to access [path].
  bool verifyCanAccess(
    String path, {
    required String userAgent,
    PrecedentRuleType typePrecedence = PrecedentRuleType.defaultPrecedentType,
    PrecedenceStrategy comparisonMethod = PrecedenceStrategy.defaultStrategy,
  }) {
    final allowedBy = rulesets.findApplicableRule(
      userAgent: userAgent,
      path: path,
      type: RuleType.allow,
      comparisonMethod: comparisonMethod,
    );
    final disallowedBy = rulesets.findApplicableRule(
      userAgent: userAgent,
      path: path,
      type: RuleType.disallow,
      comparisonMethod: comparisonMethod,
    );

    switch (typePrecedence) {
      // ignore: no_duplicate_case_values
      case PrecedentRuleType.allow:
        return allowedBy != null || disallowedBy == null;
      case PrecedentRuleType.disallow:
        return disallowedBy != null || allowedBy == null;
    }
  }
}

/// Taking an [exception], a [line] and the [index] of that line, creates a more
/// informational `FormatException`.
FormatException wrapFormatException(
  Exception exception,
  String line,
  int index,
) =>
    FormatException('''
Line $index of the file, defined as
  $line
is invalid:
  $exception
''');
