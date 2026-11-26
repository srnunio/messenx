import 'package:intl/intl.dart';

/// Placeholders look like `{name}`: letters, digits and `_`.
final RegExp _placeholder = RegExp(r'\{(\w+)\}');

String _fill(String text, Map<String, Object?> args) {
  if (args.isEmpty) return text;
  return text.replaceAllMapped(_placeholder, (match) {
    final name = match.group(1)!;
    return args.containsKey(name) ? '${args[name]}' : match.group(0)!;
  });
}

/// Whether [key] has a translation in the current locale.
bool _exists(String key) => Intl.message('', name: key).isNotEmpty;

extension MessenxExtension on String {
  ///[translate] returns the message corresponding to the translation key
  ///
  /// Ex: ```dart "clients".translate``` This returns the value defined in the translation file, or ```'**$this** not found'``` if the key is not found in
  String get translate {
    return Intl.message('**$this** not found', name: this);
  }

  ///[tryTranslate] returns the message corresponding to the translation key
  ///
  /// Ex: ```dart "clients".translate``` This returns the value defined in the translation file, or ```'clients'``` if the key is not found in
  String get tryTranslate {
    return Intl.message(this, name: this);
  }

  ///[translateOrEmpty] returns the message corresponding to the translation key
  ///
  /// Ex: ```dart "clients".translate``` This returns the value defined in the translation file, or empty value if the key is not found in
  String get translateOrEmpty {
    return Intl.message('', name: this);
  }

  /// [translate] with `{name}` placeholders filled from [args].
  ///
  /// ```dart
  /// // "step_of": "{current} de {total}"
  /// 'step_of'.translateWith({'current': 1, 'total': 2}); // "1 de 2"
  /// ```
  ///
  /// Placeholders without a value in [args] are left as they are.
  String translateWith(Map<String, Object?> args) => _fill(translate, args);

  /// Plural form of this key for [count], with `{count}` (and any [args])
  /// filled in.
  ///
  /// Looks up `<key>_<category>` where the category comes from the CLDR
  /// plural rules of the current locale (`zero`, `one`, `two`, `few`,
  /// `many`, `other`) and falls back to `<key>_other`. A `<key>_zero` entry,
  /// when present, always wins for 0.
  ///
  /// ```dart
  /// // "minutes_ago_one": "há {count} minuto"
  /// // "minutes_ago_other": "há {count} minutos"
  /// 'minutes_ago'.plural(1); // "há 1 minuto"
  /// 'minutes_ago'.plural(5); // "há 5 minutos"
  /// ```
  ///
  /// Note: CLDR puts 0 in `one` for `pt` (and `pt_AO`, `pt_BR`), but not for
  /// `pt_PT`; add a `_zero` entry when 0 needs its own text.
  String plural(num count, {Map<String, Object?> args = const {}}) {
    final values = <String, Object?>{'count': count, ...args};
    if (count == 0 && _exists('${this}_zero')) {
      return _fill('${this}_zero'.translate, values);
    }
    final category = Intl.pluralLogic<String>(
      count,
      zero: 'zero',
      one: 'one',
      two: 'two',
      few: 'few',
      many: 'many',
      other: 'other',
      locale: Intl.getCurrentLocale(),
      useExplicitNumberCases: false,
    );
    final key =
        _exists('${this}_$category') ? '${this}_$category' : '${this}_other';
    return _fill(key.translate, values);
  }
}
