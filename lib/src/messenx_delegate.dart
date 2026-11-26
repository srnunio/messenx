import 'package:flutter/widgets.dart';
import 'messenx.dart';

/// [MessenxDelegate]
class MessenxDelegate extends LocalizationsDelegate<Messenx> {
  const MessenxDelegate();

  @override
  bool isSupported(Locale locale) {
    return Messenx.instance.supportedLocales
        .any((l) => l.languageCode == locale.languageCode);
  }

  @override
  Future<Messenx> load(Locale locale) async {
    await Messenx.load(locale: locale);
    return Messenx.instance;
  }

  @override
  bool shouldReload(LocalizationsDelegate<Messenx> old) => false;
}
