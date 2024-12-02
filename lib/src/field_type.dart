/// Defines a key-value field of a `robots.txt` file specifying a rule.
enum FieldType {
  /// A field specifying the user-agent the following fields apply to.
  userAgent(key: 'User-agent', example: '*'),

  /// A field explicitly disallowing a user-agent to visit a path.
  disallow(key: 'Disallow', example: '/'),

  /// A field explicitly allowing a user-agent to visit a path.
  allow(key: 'Allow', example: '/file.txt'),

  /// A field specifying the location of a sitemap of a website.
  sitemap(key: 'Sitemap', example: 'https://example.com/sitemap.xml'),

  /// A field specifying a delay that crawlers should take into account when
  /// crawling the website.
  crawlDelay(key: 'Crawl-delay', example: '10'),

  /// A field specifying the preferred domain for a website with multiple
  /// mirrors.
  host(key: 'Host', example: 'https://hosting.example.com');

  /// The name of the field key.
  final String key;

  /// An example of a field definition. Used for testing.
  final String example;

  /// Contains the field types that introduce rules.
  static const rules = [FieldType.allow, FieldType.disallow];

  /// A partial regular expression defining a union of the default field names.
  static final defaultFieldNameExpression =
      FieldType.values.map((value) => value.key).join('|');

  /// Constructs a `FieldType`.
  const FieldType({required this.key, required this.example});

  /// Converts a `FieldType` to a `robots.txt` field.
  String toField([String? value]) => '$key: ${value ?? example}';

  /// Attempts to resolve [key] to a `FieldKey` corresponding to that [key].
  /// Returns `null` if not found.
  static FieldType? byKey(String key) {
    for (final value in FieldType.values) {
      if (key == value.key) {
        return value;
      }
    }

    return null;
  }

  @override
  String toString() => toField();
}
