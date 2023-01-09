## A complete, dependency-less and fully documented `robots.txt` ruleset parser.

### Usage

You can obtain the robot exclusion rulesets for a particular website as follows:

```dart
// Get the contents of the `robots.txt` file.
final contents = /* Your method of obtaining the contents of a `robots.txt` file. */;
// Parse the contents.
final robots = Robots.parse(contents);
```

Now that you have parsed the `robots.txt` file, you can perform checks to
establish whether or not a user-agent is allowed to visit a particular path:

```dart
final userAgent = /* Your user-agent. */;
print(robots.verifyCanAccess('/gist/', userAgent: userAgent)); // False
print(robots.verifyCanAccess('/wordcollector/robots_txt/', userAgent: userAgent)); // True
```

If you are not concerned about rules pertaining to any other user-agents, and we
only care about our own, you may instruct the parser to ignore them by
specifying only those that matter to us:

```dart
// Parse the contents, disregarding user-agents other than 'WordCollector'.
final robots = Robots.parse(contents, onlyApplicableTo: const {'WordCollector'});
```

The `Robots.parse()` function does not have any built-in structure validation.
It will not throw exceptions, and will fail silently wherever appropriate. If
the file contents passed into it were not a valid `robots.txt` file, there is no
guarantee that it will produce useful data, and disallow a bot wherever
possible.

If you wish to ensure before parsing that a particular file is valid, use the
`Robots.validate()` function. Unlike `Robots.parse()`, this one **will throw** a
`FormatException` if the file is not valid:

```dart
// Validating an invalid file will throw a `FormatException`.
try {
  Robots.validate('This is an obviously invalid robots.txt file.');
} on FormatException {
  print('As expected, this file is flagged as invalid.');
}

// Validating an already valid file will not throw anything.
try {
  Robots.validate('''
User-agent: *
Disallow: /
Allow: /file.txt

Sitemap: https://example.com/sitemap.xml
''');
  print('As expected also, this file is not flagged as invalid.');
} on FormatException {
  // Code to handle an invalid file.
}
```

By default, the validator will only accept the following fields:

- User-agent
- Allow
- Disallow
- Sitemap

If you want to accept files that feature any other fields, such as `Crawl-delay`
or `Host`, you will have to specify them as so:

```dart
try {
  Robots.validate(
    '''
User-agent: *
Crawl-delay: 5
''',
    allowedFieldNames: {'Crawl-delay'},
  );
} on FormatException {
  // Code to handle an invalid file.
}
```

By default, the `Allow` field is considered to have precedence by the parser.
This is the standard approach to both writing and reading `robots.txt` files,
however, you can instruct the parser to follow another approach by telling it to
do so:

```dart
robots.verifyCanAccess(
  '/path', 
  userAgent: userAgent, 
  typePrecedence: RuleTypePrecedence.disallow,
);
```

Similarly, fields defined **later** in the file are considered to have
precedence too. Similarly also, this is the standard approach. You can instruct
the parser to rule otherwise:

```dart
robots.verifyCanAccess(
  '/path',
  userAgent: userAgent,
  comparisonMethod: PrecedenceStrategy.lowerTakesPrecedence,
);
```
