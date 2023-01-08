import 'package:robots_txt/robots_txt.dart';

Future<void> main() async {
  // Validating an invalid file will throw a `FormatException`.
  try {
    Robots.validate('This is obviously an invalid robots.txt file.');
  } on FormatException {
    print('As expected, the first file is flagged as invalid.');
  }

  // Validating an already valid file.
  try {
    Robots.validate('''
User-agent: *
Disallow: /
Allow: /file.txt

Sitemap: https://example.com/sitemap.xml
''');
    print('As expected also, the second file is not flagged as invalid.');
  } on FormatException {
    print('Welp, this was not supposed to happen.');
  }

  late final String contentsFromBefore;

  // Validating a file with unsupported fields.
  try {
    Robots.validate(
      contentsFromBefore = '''
User-agent: *
Some-field: abcd.txt
''',
    );
  } on FormatException {
    print(
      'This file is invalid on the grounds that it contains fields we did not '
      'expect it to have.',
    );
    print(
      "Let's fix that by including the custom field in the call to validate().",
    );
    try {
      Robots.validate(contentsFromBefore, allowedFieldNames: {'Some-field'});
      print('Aha! Now there are no issues.');
    } on FormatException {
      print('Welp, this also was not supposed to happen.');
    }
  }
}
