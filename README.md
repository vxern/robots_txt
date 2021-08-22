## A simple yet complete, lightweight and sturdy `robots.txt` ruleset parser to ensure your application follows the standard protocol.

### Usage

The following code gets the `robots.txt` robot exclusion ruleset of a website.

`quietMode` determines whether or not the library should print warning messages in the case of the `robots.txt` not being valid or other errors.

```dart
// Create an instance of the `robots.txt` parser
final robots = Robots(host: 'https://github.com/');
// Read the ruleset of the website
await robots.read();
```

Now that the `robots.txt` file has been read, we can verify whether we can visit a certain path or not:

```dart
final userAgent = '*';
print("Can '$userAgent' visit '/gist/'?");
print(robots.canVisitPath('/gist/', userAgent: '*')); // It cannot
print("Can '$userAgent' visit '/wordcollector/robots_txt'?");
print(robots.canVisitPath('/wordcollector/robots_txt', userAgent: '*')); // It can
```