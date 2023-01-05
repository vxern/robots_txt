import 'package:robots_txt/src/rule.dart';
import 'package:robots_txt/src/ruleset.dart';
import 'package:web_scraper/web_scraper.dart';

/// Abstracts away the rather convoluted declaration for an element with two
/// fields; 'title' and 'attributes'.  'attributes' is a map containing the
/// attributes of the element.
typedef Element = Map<String, Map<String, dynamic>>;

/// Allows for parsing of a host's `robots.txt` to get information about which
/// of its resources may or may not be accessed, as well as which of its pages
/// cannot be traversed.
class Robots {
  /// The host of this `robots.txt` file.
  final String host;

  /// Stores an instance of the scraper for a given URL.
  final WebScraper scraper;

  /// Stores expressions for both paths which may or may not be traversed.
  final List<Ruleset> rulesets = [];

  /// Creates an instance of a `robots.txt` parser for the provided [host].
  Robots({required this.host}) : scraper = WebScraper(host);

  /// Reads and parses the `robots.txt` file of the [host].
  Future<void> read({String? onlyRelevantTo}) async {
    await scraper.loadWebPage('/robots.txt');
    final body = scraper.getElement('body', [])[0];

    if (body.isEmpty) {
      throw Exception('The robots.txt contents of $host is invalid.');
    }

    final content = body['title'] as String;
    final lines = content.split('\n').where((line) => line.isNotEmpty);
    parseRulesets(lines, onlyRelevantTo: onlyRelevantTo);
  }

  /// Iterates over [lines] and parses each ruleset, additionally ignoring
  /// those rulesets which are not relevant to [onlyRelevantTo].
  void parseRulesets(Iterable<String> lines, {String? onlyRelevantTo}) {
    Ruleset? ruleset;
    for (var index = 0; index < lines.length; index++) {
      final field = getRobotsFieldFromLine(lines.elementAt(index));

      switch (field.key) {
        case 'user-agent':
          if (ruleset != null) {
            rulesets.add(ruleset);
          }
          if (onlyRelevantTo != null && field.key != onlyRelevantTo) {
            ruleset = null;
            break;
          }
          ruleset = Ruleset(field.value);
          break;

        case 'allow':
          if (ruleset != null) {
            final expression = convertFieldPathToExpression(field.value);
            ruleset.allows.add(Rule(expression, index));
          }
          break;
        case 'disallow':
          if (ruleset != null) {
            final expression = convertFieldPathToExpression(field.value);
            ruleset.disallows.add(Rule(expression, index));
          }
          break;
      }
    }

    if (ruleset != null) {
      rulesets.add(ruleset);
    }
  }

  /// Reads a path declaration from within `robots.txt` and converts it to a
  /// regular expression for later matching.
  RegExp convertFieldPathToExpression(String pathDeclaration) {
    // Collapse duplicate slashes and wildcards into singles.
    final collapsed =
        pathDeclaration.replaceAll('/+', '/').replaceAll('*+', '*');
    final normalised = collapsed.endsWith('*')
        ? collapsed.substring(0, collapsed.length - 1)
        : collapsed;
    final withWildcardsReplaced =
        normalised.replaceAll('.', r'\.').replaceAll('*', '.*');
    final withTrailingText = withWildcardsReplaced.contains(r'$')
        ? withWildcardsReplaced.split(r'$')[0]
        : '$withWildcardsReplaced.*';
    return RegExp(withTrailingText, caseSensitive: false, dotAll: true);
  }

  /// Extracts the key and value from [target] and puts it into a `MapEntry`.
  MapEntry<String, String> getRobotsFieldFromLine(String target) {
    final keyValuePair = target.split(':');
    final key = keyValuePair[0].toLowerCase();
    final value = keyValuePair.sublist(1).join(':').trim();
    return MapEntry(key, value);
  }

  /// Determines whether or not [path] may be traversed.
  bool canVisitPath(String path, {required String userAgent}) {
    final explicitAllowance = rulesets.getRule(
      appliesTo: userAgent,
      concernsPath: path,
      andAllowsIt: true,
    );
    final explicitDisallowance = rulesets.getRule(
      appliesTo: userAgent,
      concernsPath: path,
      andAllowsIt: false,
    );

    final allowancePriority = explicitAllowance?.priority ?? -1;
    final disallowancePriority = explicitDisallowance?.priority ?? -1;

    return allowancePriority >= disallowancePriority;
  }
}
