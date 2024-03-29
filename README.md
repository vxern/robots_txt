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
print(robots.verifyCanAccess('/government/robots_txt/', userAgent: userAgent)); // True
```

If you are only concerned about directives pertaining to your own user-agent,
you may instruct the parser to ignore other user-agents as follows:

```dart
// Parse the contents, disregarding user-agents other than 'government'.
final robots = Robots.parse(contents, onlyApplicableTo: const {'government'});
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
Crawl-delay: 10
Disallow: /
Allow: /file.txt

Host: https://hosting.example.com/
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
- Crawl-delay
- Host

If you want to accept files that feature any other fields, you will have to
specify them as so:

```dart
try {
  Robots.validate(
    '''
User-agent: *
Custom-field: value
''',
    allowedFieldNames: {'Custom-field'},
  );
} on FormatException {
  // Code to handle an invalid file.
}
```

By default, the `Allow` field is treated as having precedence by the parser.
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
