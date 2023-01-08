## A complete, dependency-less and fully documented `robots.txt` ruleset parser.

### Usage

The following code gets the `robots.txt` robot exclusion ruleset of a website.

```dart
// Get the contents of the `robots.txt` file.
final contents = /* Your method of obtaining the contents of a `robots.txt` file. */;
// Parse the contents.
final robots = Robots.parse(contents);
```

Now that the `robots.txt` file has been read, we can verify whether we can visit
a certain path or not:

```dart
final userAgent = /* Your user agent. */;
// False: it cannot.
print(robots.verifyCanAccess('/gist/', userAgent: userAgent));
// True: it can.
print(robots.verifyCanAccess('/wordcollector/robots_txt', userAgent: userAgent));
```
