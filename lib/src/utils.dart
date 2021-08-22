/// Taking the singular form of [word], morph it according to [count]
String pluralise(String word, int count) => '${count == 0 ? 'no' : count} '
    '${count == 0 || count > 1 ? '${word}s' : word}';
