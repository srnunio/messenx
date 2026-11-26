import 'package:flutter/widgets.dart';
import 'package:intl/intl.dart';
import 'package:messenx/src/composite_message_lookup.dart';

import 'messenx_base_message.dart';

/// [Messenx] It is a translation mechanism that combines multiple translation
/// files for a single language into a single message map.
///
/// [initialize] method called before everything
///
/// [load] loads the translation file and return [Messenx] instance
///
/// [get] returns the defined messages of a certain language
///
/// [supportedLocales] languages supported by the translation system
///
/// [currentLocale] and [languageCode] current language
class Messenx {
  static Messenx? _instance;

  static Messenx get instance => _instance ??= Messenx._();

  final MessenxLookupManager _manager = MessenxLookupManager.instance();

  /// [_locale] current language
  Locale? _locale;

  /// [_supportedLocales] languages supported by the translation system
  List<Locale> _supportedLocales = [];

  /// [currentLocale] current language
  Locale? get currentLocale => _locale;

  /// [isInitialized] check if is isInitialized
  bool get isInitialized => _locale != null && _manager.hasData;

  /// [supportedLocales] languages supported by the translation system
  List<Locale> get supportedLocales => _supportedLocales;

  /// [languageCode] current language code
  String get languageCode {
    if (_locale == null) return Intl.getCurrentLocale();
    return _locale!.languageCode;
  }

  /// Canonical name of the current locale, with the country when there is
  /// one (`pt_AO`, `en`). Files for `pt_AO` are merged on top of the `pt`
  /// files, so a regional file only needs the keys that differ.
  String get localeName {
    final locale = _locale;
    if (locale == null) {
      return Intl.canonicalizedLocale(Intl.getCurrentLocale());
    }
    final country = locale.countryCode;
    return Intl.canonicalizedLocale(
      country == null || country.isEmpty
          ? locale.languageCode
          : '${locale.languageCode}_$country',
    );
  }

  /// [_setSupportedLocales] set supported locales
  void _setSupportedLocales(List<Locale> values) =>
      _supportedLocales = values.toList();

  ///[_setLocale] set current locate
  void _setLocale(Locale value) => _locale = value;

  /// [_addMessages] register translate files
  void _addMessages(List<MessenxLookupBase> values) =>
      _manager.add(values.toList());

  Messenx._();

  /// [initialize] initializes the translation system,
  /// this method must be called before any functionality in Messenx
  /// [currentLocale] the current language
  /// [messages] the translation files
  factory Messenx.initialize({
    required Locale currentLocale,
    List<Locale> supportedLocales = const [Locale('en', 'EN')],
    required List<MessenxLookupBase> messages,
  }) {
    assert(messages.isNotEmpty, "The messages list can't be empty");
    assert(supportedLocales.isNotEmpty, "The supported locales can't be empty");
    var messenx = instance;
    messenx._setLocale(currentLocale);
    messenx._setSupportedLocales(supportedLocales);
    messenx._addMessages(messages);
    return messenx;
  }

  /// [load] loads the translation file and return [Messenx] instance
  /// call this method whenever you want to change the language or load a translation file
  ///
  /// Make sure to call this before invoking this method ``` Messenx.initialize() ```
  ///
  /// ```dart
  ///
  ///  Messenx.initialize(
  ///      currentLocale: Locale("en"),
  ///      supportedLocales: [Locale("pt"), Locale("en")],
  ///      messages: [
  ///        MessagesPt(),
  ///        MessagesEn(),
  ///      ],
  ///  )
  ///
  /// ```
  static Future<Messenx> load({Locale? locale}) {
    var messenx = instance;
    if (locale != null) messenx._setLocale(locale);
    assert(messenx.isInitialized,
        'Current language has not been defined, call the initialize() method before calling the load() method');
    final String localeName = messenx.localeName;
    return messenx._manager
        .initializeMessages(localeName: localeName)
        .then((_) {
      Intl.defaultLocale = localeName;
      return messenx;
    });
  }

  /// [get] returns the defined messages of a certain language [MessenxLookupBase]
  /// ```dart
  /// class MessagesEn extends MessenxLookupBase {
  ///  @override
  ///   String get localeName => "en";
  ///
  ///   @override
  ///   Map<String, Function> get messages {
  ///    return {
  ///      "client_title": MessageLookupByLibrary.simpleMessage("Clients"),
  ///      "client_add": MessageLookupByLibrary.simpleMessage("Add Client"),
  ///      "product_title": MessageLookupByLibrary.simpleMessage("Products"),
  ///      "product_add": MessageLookupByLibrary.simpleMessage("Add Product"),
  ///      "product_remove": MessageLookupByLibrary.simpleMessage("Remove Product"),
  ///     };
  ///   }
  /// }
  ///
  /// [languageCode] may also be a full locale name (`pt_AO`): the result is
  /// then the `pt` files merged with the `pt_AO` files.
  static MessenxLookupBase get({required String languageCode}) {
    final String localeName = Intl.canonicalizedLocale(languageCode);
    var messenx = instance;
    return messenx._manager.getMessage(localeName);
  }

  static Messenx? of(BuildContext context) {
    return Localizations.of<Messenx>(context, Messenx);
  }
}
