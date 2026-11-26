# messenx

🌐 **Read in:** **English** | [Português](README.pt.md)

---

Modular translation catalogs for Flutter apps built on top of [`intl`](https://pub.dev/packages/intl). Each language can be split across multiple files (one per module or feature); **messenx** merges them into a single cached map and translates keys directly via String extensions like `'key'.translate`.

## Table of Contents

1. [Installation](#1-installation)
2. [Configuring Language Files (`MessenxLookupBase`)](#2-configuring-language-files-messenxlookupbase)
3. [Merging Multiple Language Files, Regional Variants & Overrides](#3-merging-multiple-language-files-regional-variants--overrides)
4. [Initialization](#4-initialization)
5. [Usage with `MaterialApp` vs. Normal (Standalone) Mode](#5-usage-with-materialapp-vs-normal-standalone-mode)
   - [Option A: With `MaterialApp` (`MessenxDelegate`)](#option-a-with-materialapp-messenxdelegate)
   - [Option B: Normal / Standalone Mode (Without `BuildContext`)](#option-b-normal--standalone-mode-without-buildcontext)
6. [How to Use: Translating, Placeholders & Plurals](#6-translating-placeholders--plurals)
   - [Basic Translation](#basic-translation)
   - [Named Placeholders (`translateWith`)](#named-placeholders-translatewith)
   - [Plurals (`plural`)](#plurals-plural)
7. [Inspecting Catalogs Directly & Testing](#7-inspecting-catalogs-directly--testing)

## Features

- **Multiple files per language**: Split translations by module or feature (e.g., Auth, Products, Clients) and merge them into a single lookup map (built once and cached).
- **Regional variants**: Regional files such as `pt_AO` or `pt_BR` are layered on top of base language files (`pt`), so a regional catalog only needs to define the keys that differ.
- **Explicit `overrides`**: Any catalog can override keys defined in other files of the same language.
- **Named placeholders**: Interpolate `{name}` variables cleanly with `'key'.translateWith({'name': 'Ana'})`.
- **CLDR Plurals**: Full pluralization using `intl`'s CLDR rules (`_zero`, `_one`, `_two`, `_few`, `_many`, `_other`) via `'key'.plural(count, args: ...)`.
- **`MaterialApp` & Standalone support**: Works seamlessly with Flutter's `LocalizationsDelegate` (`MessenxDelegate`) or in standalone/normal mode without a `BuildContext`.

---

## 1. Installation

### From `pub.dev`

Add `messenx` and `flutter_localizations` to your `pubspec.yaml`:

```yaml
dependencies:
  flutter:
    sdk: flutter
  flutter_localizations:
    sdk: flutter
  intl: ^0.20.2
  messenx: ^0.1.0
```

Or run:

```bash
flutter pub add messenx
```

### From Git or Local Path

```yaml
dependencies:
  messenx:
    git:
      url: https://github.com/srnunio/messenx.git
      ref: main
  # Or local path:
  # messenx:
  #   path: ./messenx
```

---

## 2. Configuring Language Files (`MessenxLookupBase`)

Each translation file is a class that extends `MessenxLookupBase`, specifying `localeName` and a `messages` map using `MessageLookupByLibrary.simpleMessage`:

```dart
import 'package:intl/message_lookup_by_library.dart';
import 'package:messenx/messenx.dart';

class AppMessagesEn extends MessenxLookupBase {
  @override
  String get localeName => 'en';

  @override
  Map<String, Function> get messages => {
        'save': MessageLookupByLibrary.simpleMessage('Save'),
        'welcome_user': MessageLookupByLibrary.simpleMessage('Hello, {name}!'),
        'step_of': MessageLookupByLibrary.simpleMessage('Step {current} of {total}'),
        'records_zero': MessageLookupByLibrary.simpleMessage('No records found'),
        'records_one': MessageLookupByLibrary.simpleMessage('{count} record'),
        'records_other': MessageLookupByLibrary.simpleMessage('{count} records'),
      };
}

class AppMessagesPt extends MessenxLookupBase {
  @override
  String get localeName => 'pt';

  @override
  Map<String, Function> get messages => {
        'save': MessageLookupByLibrary.simpleMessage('Guardar'),
        'welcome_user': MessageLookupByLibrary.simpleMessage('Olá, {name}!'),
        'step_of': MessageLookupByLibrary.simpleMessage('Passo {current} de {total}'),
        'records_zero': MessageLookupByLibrary.simpleMessage('Sem registos'),
        'records_one': MessageLookupByLibrary.simpleMessage('{count} registo'),
        'records_many': MessageLookupByLibrary.simpleMessage('{count} de registos'),
        'records_other': MessageLookupByLibrary.simpleMessage('{count} registos'),
      };
}
```

---

## 3. Merging Multiple Language Files, Regional Variants & Overrides

### Splitting by Feature / Module

You can create separate catalog classes for the same `localeName` (for example, one per feature or package). `Messenx` automatically merges all files of the same language into a single map:

```dart
class ProductsMessagesPt extends MessenxLookupBase {
  @override
  String get localeName => 'pt';

  @override
  Map<String, Function> get messages => {
        'product_title': MessageLookupByLibrary.simpleMessage('Produtos'),
        'product_add': MessageLookupByLibrary.simpleMessage('Adicionar Produto'),
      };
}

class ClientsMessagesPt extends MessenxLookupBase {
  @override
  String get localeName => 'pt';

  @override
  Map<String, Function> get messages => {
        'client_title': MessageLookupByLibrary.simpleMessage('Clientes'),
        'client_add': MessageLookupByLibrary.simpleMessage('Adicionar Cliente'),
      };
}
```

### Regional Variants (`pt_AO` on top of `pt`)

A regional catalog (e.g., `pt_AO`) is merged on top of its base language (`pt`). You only need to declare the keys that change for that region:

```dart
class AppMessagesPtAo extends MessenxLookupBase {
  @override
  String get localeName => 'pt_AO';

  @override
  Map<String, Function> get messages => {
        'welcome_user': MessageLookupByLibrary.simpleMessage('Olá, mano {name}!'),
      };
}
// When current locale is Locale('pt', 'AO'):
// 'welcome_user' comes from pt_AO, while 'save', 'product_title', etc. come from pt.
```

### Overriding Keys (`overrides`)

If a module or white-label app needs to replace keys defined in another catalog of the same language, override the `overrides` getter. Entries in `overrides` are applied last and always win regardless of registration order:

```dart
class CustomClientsMessagesPt extends MessenxLookupBase {
  @override
  String get localeName => 'pt';

  @override
  Map<String, Function> get messages => {
        'custom_label': MessageLookupByLibrary.simpleMessage('Etiqueta'),
      };

  @override
  Map<String, Function> get overrides => {
        'product_title': MessageLookupByLibrary.simpleMessage('Catálogo de Produtos'),
      };
}
```

---

## 4. Initialization

Call `Messenx.initialize` once at startup to register all catalogs and supported locales, followed by `await Messenx.load()`:

```dart
import 'package:flutter/material.dart';
import 'package:messenx/messenx.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  Messenx.initialize(
    currentLocale: const Locale('pt', 'AO'),
    supportedLocales: const [
      Locale('pt', 'AO'),
      Locale('pt'),
      Locale('en'),
    ],
    messages: [
      AppMessagesPt(),
      ProductsMessagesPt(),
      ClientsMessagesPt(),
      AppMessagesPtAo(),
      AppMessagesEn(),
    ],
  );

  await Messenx.load();
  runApp(const MyApp());
}
```

> **Note:** Calling `Messenx.initialize` multiple times (e.g. from lazy modules, background isolates, or tests) will not duplicate already-registered catalogs, and newly registered catalogs automatically invalidate the cached lookup map.

---

## 5. Usage with `MaterialApp` vs. Normal (Standalone) Mode

### Option A: With `MaterialApp` (`MessenxDelegate`)

Add `MessenxDelegate()` to `localizationsDelegates` and pass `Messenx.instance.supportedLocales`:

```dart
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:messenx/messenx.dart';

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  Locale _locale = Messenx.instance.currentLocale ?? const Locale('pt');

  Future<void> _changeLanguage(Locale newLocale) async {
    await Messenx.load(locale: newLocale);
    setState(() => _locale = newLocale);
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      locale: _locale,
      supportedLocales: Messenx.instance.supportedLocales,
      localizationsDelegates: const [
        MessenxDelegate(),
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      home: Scaffold(
        appBar: AppBar(title: Text('product_title'.translate)),
        body: Center(
          child: Text('welcome_user'.translateWith({'name': 'Edvaldo'})),
        ),
        floatingActionButton: FloatingActionButton(
          onPressed: () => _changeLanguage(const Locale('en')),
          child: const Icon(Icons.language),
        ),
      ),
    );
  }
}
```

You can also access the instance via `Messenx.of(context)` inside widgets when needed.

### Option B: Normal / Standalone Mode (Without `BuildContext`)

Because `messenx` wires into `Intl`, you can translate strings anywhere—inside ViewModels, BLoCs, repositories, CLI scripts, or unit tests—without needing a `BuildContext` or `MaterialApp`:

```dart
// Initialize & load once
Messenx.initialize(
  currentLocale: const Locale('pt'),
  supportedLocales: const [Locale('pt'), Locale('en')],
  messages: [AppMessagesPt(), AppMessagesEn()],
);
await Messenx.load();

// Use anywhere in Dart code
final label = 'save'.translate; // "Guardar"

// Switch language at any time
await Messenx.load(locale: const Locale('en'));
final labelEn = 'save'.translate; // "Save"
```

---

## 6. Translating, Placeholders & Plurals

### Basic Translation

```dart
'save'.translate;             // "Guardar"
'unknown_key'.translate;      // "**unknown_key** not found" (easy to spot during development/tests)
'unknown_key'.tryTranslate;   // "unknown_key" (falls back to the key itself)
'unknown_key'.translateOrEmpty; // "" (returns empty string if missing)
```

### Named Placeholders (`translateWith`)

Placeholders use `{variable_name}` syntax (letters, digits, and `_`). Any placeholder not provided in the map remains untouched:

```dart
'step_of'.translateWith({'current': 1, 'total': 3}); // "Passo 1 de 3"
'step_of'.translateWith({'current': 1});             // "Passo 1 de {total}"
```

### Plurals (`plural`)

`plural(count, args: ...)` selects `<key>_<category>` according to the current locale's CLDR plural rules (`zero`, `one`, `two`, `few`, `many`, `other`), falls back to `<key>_other` if the specific category key is not defined, and interpolates `{count}` along with any additional `args`:

```dart
// Catalog keys:
// 'records_zero': 'Sem registos'
// 'records_one': '{count} registo'
// 'records_many': '{count} de registos'
// 'records_other': '{count} registos'

'records'.plural(0);         // "Sem registos" (_zero always wins for 0 when defined)
'records'.plural(1);         // "1 registo"
'records'.plural(7);         // "7 registos"
'records'.plural(1000000);   // "1000000 de registos" (uses _many in pt, or falls back to _other)

// Combining count with additional placeholders:
// 'account_records_one': '{count} registo na conta {account}'
// 'account_records_other': '{count} registos na conta {account}'
'account_records'.plural(3, args: {'account': 'Corrente'}); // "3 registos na conta Corrente"
```

#### CLDR Plural Categories by Locale

| Locale | `0` | `1` | `2` | `1,000,000` | Other |
|---|---|---|---|---|---|
| `pt`, `pt_AO`, `pt_BR` | `one` | `one` | `other` | `many` | `other` |
| `pt_PT` | `other` | `one` | `other` | `other` | `other` |
| `en` | `other` | `one` | `other` | `other` | `other` |

> **Tip:** In `pt` (`pt_AO`, `pt_BR`), CLDR classifies `0` under `one`. If `0` should display a dedicated message (or plural form), define `<key>_zero`—when present, `_zero` always takes priority for `count == 0`.

---

## 7. Inspecting Catalogs Directly & Testing

You can inspect the merged catalog for any language or regional locale directly with `Messenx.get`:

```dart
final ptCatalog = Messenx.get(languageCode: 'pt');       // or 'pt_AO' (pt + pt_AO merged)
ptCatalog.hasMessages;   // true if at least one file is registered for this locale
ptCatalog.lengthKeys;    // total number of merged keys
ptCatalog.messages.keys; // all translation keys
```

### Example Unit Test Ensuring Catalog Parity Between Languages

```dart
test('PT and EN catalogs have identical keys', () {
  Messenx.initialize(
    currentLocale: const Locale('pt'),
    supportedLocales: const [Locale('pt'), Locale('en')],
    messages: [AppMessagesPt(), AppMessagesEn()],
  );

  final ptKeys = Messenx.get(languageCode: 'pt').messages.keys.toSet();
  final enKeys = Messenx.get(languageCode: 'en').messages.keys.toSet();

  expect(ptKeys.difference(enKeys), isEmpty, reason: 'Keys missing in EN');
  expect(enKeys.difference(ptKeys), isEmpty, reason: 'Keys missing in PT');
});
```
