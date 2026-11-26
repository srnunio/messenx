import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:intl/message_lookup_by_library.dart';
import 'package:messenx/messenx.dart';
import 'package:messenx/src/generated/en/messages_clients_en.dart';
import 'package:messenx/src/generated/en/messages_products_en.dart';
import 'package:messenx/src/generated/pt/messages_clients_pt.dart';
import 'package:messenx/src/generated/pt/messages_products_pt.dart';

/// Counts how many times its map is built.
class _CountingPt extends MessenxLookupBase {
  static int builds = 0;

  @override
  String get localeName => 'pt';

  @override
  Map<String, Function> get messages {
    builds++;
    return {
      'step_of': MessageLookupByLibrary.simpleMessage('{current} de {total}'),
      'user_slot': MessageLookupByLibrary.simpleMessage('Utilizador {user_1}'),
      'minutes_ago_one':
          MessageLookupByLibrary.simpleMessage('há {count} minuto'),
      'minutes_ago_other':
          MessageLookupByLibrary.simpleMessage('há {count} minutos'),
      'records_zero': MessageLookupByLibrary.simpleMessage('Sem registos'),
      'records_one': MessageLookupByLibrary.simpleMessage('{count} registo'),
      'records_many':
          MessageLookupByLibrary.simpleMessage('{count} de registos'),
      'records_other': MessageLookupByLibrary.simpleMessage('{count} registos'),
      'account_records_zero':
          MessageLookupByLibrary.simpleMessage('Sem registos em {account}'),
      'account_records_one':
          MessageLookupByLibrary.simpleMessage('{count} registo em {account}'),
      'account_records_other':
          MessageLookupByLibrary.simpleMessage('{count} registos em {account}'),
      'greeting': MessageLookupByLibrary.simpleMessage('Olá'),
    };
  }
}

class _PtAo extends MessenxLookupBase {
  @override
  String get localeName => 'pt_AO';

  @override
  Map<String, Function> get messages => {
        'greeting': MessageLookupByLibrary.simpleMessage('Olá, mano'),
      };
}

class _En extends MessenxLookupBase {
  @override
  String get localeName => 'en';

  @override
  Map<String, Function> get messages => {
        'greeting': MessageLookupByLibrary.simpleMessage('Hello'),
        'step_of': MessageLookupByLibrary.simpleMessage('{current} of {total}'),
        'minutes_ago_one':
            MessageLookupByLibrary.simpleMessage('{count} minute ago'),
        'minutes_ago_other':
            MessageLookupByLibrary.simpleMessage('{count} minutes ago'),
        'account_records_zero':
            MessageLookupByLibrary.simpleMessage('No records in {account}'),
        'account_records_one':
            MessageLookupByLibrary.simpleMessage('{count} record in {account}'),
        'account_records_other': MessageLookupByLibrary.simpleMessage(
          '{count} records in {account}',
        ),
      };
}

class _LatePt extends MessenxLookupBase {
  @override
  String get localeName => 'pt';

  @override
  Map<String, Function> get messages => {
        'late_key': MessageLookupByLibrary.simpleMessage('Chegou depois'),
      };
}

class _OnceMorePt extends MessenxLookupBase {
  @override
  String get localeName => 'pt';

  @override
  Map<String, Function> get messages => {
        'once_more': MessageLookupByLibrary.simpleMessage('Mais uma'),
      };
}

class _EarlyOverrideEn extends MessenxLookupBase {
  @override
  String get localeName => 'en';

  @override
  Map<String, Function> get messages => {
        'shared_key': MessageLookupByLibrary.simpleMessage('From early'),
      };

  @override
  Map<String, Function> get overrides => {
        'product_title':
            MessageLookupByLibrary.simpleMessage('Products (Overridden Early)'),
      };
}

class _LaterMessageEn extends MessenxLookupBase {
  @override
  String get localeName => 'en';

  @override
  Map<String, Function> get messages => {
        'shared_key': MessageLookupByLibrary.simpleMessage('From later'),
      };
}

void _init() {
  Messenx.initialize(
    currentLocale: const Locale('pt'),
    supportedLocales: const [Locale('pt'), Locale('pt', 'AO'), Locale('en')],
    messages: [
      MessagesProductsPt(),
      MessagesClientsPt(),
      MessagesClientsEn(),
      _CountingPt(),
      _PtAo(),
      _En(),
    ],
  );
}

void main() {
  group('Before Messenx.initialize', () {
    test('uninitialized state getters and load assertion', () {
      expect(Messenx.instance.isInitialized, isFalse);
      expect(Messenx.instance.currentLocale, isNull);
      expect(Messenx.instance.supportedLocales, isEmpty);
      expect(Messenx.instance.languageCode, isNotEmpty);
      expect(Messenx.instance.localeName, isNotEmpty);
      expect(() => Messenx.load(), throwsA(isA<AssertionError>()));
    });

    test('initialize throws AssertionError on empty messages or locales', () {
      expect(
        () => Messenx.initialize(
          currentLocale: const Locale('pt'),
          messages: [],
        ),
        throwsA(isA<AssertionError>()),
      );
      expect(
        () => Messenx.initialize(
          currentLocale: const Locale('pt'),
          supportedLocales: [],
          messages: [MessagesProductsPt()],
        ),
        throwsA(isA<AssertionError>()),
      );
    });
  });

  group('Initialized Messenx', () {
    setUp(() async {
      _init();
      await Messenx.load(locale: const Locale('pt'));
    });

    test('initialize sets properties and default supportedLocales works', () {
      expect(Messenx.instance.isInitialized, isTrue);
      expect(Messenx.instance.currentLocale, const Locale('pt'));
      expect(
        Messenx.instance.supportedLocales,
        const [Locale('pt'), Locale('pt', 'AO'), Locale('en')],
      );

      // Calling initialize without supportedLocales uses default [Locale('en', 'EN')]
      Messenx.initialize(
        currentLocale: const Locale('pt', ''),
        messages: [MessagesProductsPt()],
      );
      expect(Messenx.instance.supportedLocales, const [Locale('en', 'EN')]);
      expect(Messenx.instance.localeName, 'pt');

      // Restore standard initialization
      _init();
    });

    test('load() without locale parameter loads currentLocale from initialize',
        () async {
      Messenx.initialize(
        currentLocale: const Locale('en'),
        supportedLocales: const [Locale('pt'), Locale('en')],
        messages: [MessagesClientsPt(), MessagesClientsEn()],
      );
      final instance = await Messenx.load();
      expect(instance, same(Messenx.instance));
      expect(Messenx.instance.languageCode, 'en');
      expect('client_title'.translate, 'Clients');
    });

    test('returns the message of the current language and changes with load',
        () async {
      expect(Messenx.instance.languageCode, 'pt');
      expect('client_title'.translate, 'Clientes');
      await Messenx.load(locale: const Locale('en'));
      expect('client_title'.translate, 'Clients');
      await Messenx.load(locale: const Locale('pt'));
      expect('client_title'.translate, 'Clientes');
    });

    test('Files of the same language get combined and overrides win', () {
      final ptLookup = Messenx.get(languageCode: 'pt');
      final pt = ptLookup.messages;
      expect(ptLookup.hasMessages, isTrue);
      expect(ptLookup.lengthKeys, pt.length);
      expect(
        pt.keys,
        containsAll(<String>['client_add', 'product_add', 'new_key']),
      );
      expect(
        (pt['product_title'] as String Function())(),
        'Produtos - Alterado',
      );
    });

    test(
        'earlier file overrides still win over later file messages, while later messages override earlier messages',
        () async {
      Messenx.initialize(
        currentLocale: const Locale('en'),
        supportedLocales: const [Locale('en')],
        messages: [
          _EarlyOverrideEn(),
          MessagesProductsEn(),
          _LaterMessageEn(),
        ],
      );
      await Messenx.load(locale: const Locale('en'));

      // _LaterMessageEn overrides _EarlyOverrideEn normal message
      expect('shared_key'.translate, 'From later');
      // _EarlyOverrideEn.overrides wins over MessagesProductsEn.messages even though registered earlier
      expect('product_title'.translate, 'Products (Overridden Early)');
    });

    test('MessenxLookupBase properties (hasMessages, hasExtra, lengthKeys)',
        () {
      final clientsPt = MessagesClientsPt();
      expect(clientsPt.hasMessages, isTrue);
      expect(clientsPt.hasExtra, isTrue);
      expect(clientsPt.lengthKeys, 3);

      final productsPt = MessagesProductsPt();
      expect(productsPt.hasMessages, isTrue);
      expect(productsPt.hasExtra, isFalse);
      expect(productsPt.lengthKeys, 3);

      final emptyFr = Messenx.get(languageCode: 'fr');
      expect(emptyFr.localeName, 'fr');
      expect(emptyFr.hasMessages, isFalse);
      expect(emptyFr.hasExtra, isFalse);
      expect(emptyFr.lengthKeys, 0);
    });

    test(
        'translate, tryTranslate, and translateOrEmpty for existing and missing keys',
        () {
      // Existing key
      expect('client_title'.translate, 'Clientes');
      expect('client_title'.tryTranslate, 'Clientes');
      expect('client_title'.translateOrEmpty, 'Clientes');

      // Missing key
      expect('missing_key'.translate, '**missing_key** not found');
      expect('missing_key'.tryTranslate, 'missing_key');
      expect('missing_key'.translateOrEmpty, '');
    });

    test('the attached map is built once, not at each translate', () {
      'greeting'.translate;
      final before = _CountingPt.builds;
      for (var i = 0; i < 50; i++) {
        'greeting'.translate;
        'client_title'.translate;
      }
      expect(_CountingPt.builds, before);
    });

    test('repeated initialize does not duplicate files', () {
      for (var i = 0; i < 5; i++) {
        _init();
      }
      Messenx.initialize(
        currentLocale: const Locale('pt'),
        messages: [_OnceMorePt()],
      );
      _CountingPt.builds = 0;
      Messenx.get(languageCode: 'pt').messages;
      expect(_CountingPt.builds, 1);
    });

    test('file registered after the load is also translated', () {
      expect('late_key'.translateOrEmpty, '');
      Messenx.initialize(
        currentLocale: const Locale('pt'),
        supportedLocales: const [Locale('pt')],
        messages: [_LatePt()],
      );
      expect('late_key'.translate, 'Chegou depois');
    });

    test('pt_AO joins on top of pt in both load and get', () async {
      await Messenx.load(locale: const Locale('pt', 'AO'));
      expect(Messenx.instance.localeName, 'pt_AO');
      expect('greeting'.translate, 'Olá, mano');
      expect('client_title'.translate, 'Clientes');

      // Messenx.get with regional code canonicalizes and merges base + regional
      final ptAoLookup = Messenx.get(languageCode: 'pt-AO');
      expect(ptAoLookup.localeName, 'pt_AO');
      expect(
        (ptAoLookup.messages['greeting'] as String Function())(),
        'Olá, mano',
      );
      expect(
        (ptAoLookup.messages['client_title'] as String Function())(),
        'Clientes',
      );

      await Messenx.load(locale: const Locale('pt'));
      expect('greeting'.translate, 'Olá');
    });

    test(
        'translateWith fills placeholders, handles empty/null/extra args, and leaves missing ones',
        () {
      expect('step_of'.translateWith({'current': 1, 'total': 2}), '1 de 2');
      expect('step_of'.translateWith({'current': 1}), '1 de {total}');
      expect('step_of'.translateWith({}), '{current} de {total}');
      expect(
        'step_of'
            .translateWith({'current': null, 'total': 5, 'extra': 'ignored'}),
        'null de 5',
      );
      expect('user_slot'.translateWith({'user_1': 'Edvaldo'}),
          'Utilizador Edvaldo');
    });

    test(
        "plural uses the language's CLDR rules, _zero, fallback to _other, and custom args",
        () async {
      // In pt, CLDR category for 0 is 'one', so without _zero ('minutes_ago') 0 uses _one
      expect('minutes_ago'.plural(0), 'há 0 minuto');
      expect('minutes_ago'.plural(1), 'há 1 minuto');
      expect('minutes_ago'.plural(5), 'há 5 minutos');
      // Fallback to _other when _many is not defined for 'minutes_ago'
      expect('minutes_ago'.plural(1000000), 'há 1000000 minutos');

      // With _zero and _many defined ('records')
      expect('records'.plural(0), 'Sem registos');
      expect('records'.plural(1), '1 registo');
      expect('records'.plural(2), '2 registos');
      expect('records'.plural(1000000), '1000000 de registos');

      // Plural with custom args
      expect(
        'account_records'.plural(0, args: {'account': 'Carteira'}),
        'Sem registos em Carteira',
      );
      expect(
        'account_records'.plural(1, args: {'account': 'Carteira'}),
        '1 registo em Carteira',
      );
      expect(
        'account_records'.plural(7, args: {'account': 'Carteira'}),
        '7 registos em Carteira',
      );

      // In en, CLDR category for 0 is 'other' when _zero is not defined
      await Messenx.load(locale: const Locale('en'));
      expect('minutes_ago'.plural(0), '0 minutes ago');
      expect('minutes_ago'.plural(1), '1 minute ago');
      expect('minutes_ago'.plural(2), '2 minutes ago');
      expect(
        'account_records'.plural(0, args: {'account': 'Wallet'}),
        'No records in Wallet',
      );
      expect(
        'account_records'.plural(3, args: {'account': 'Wallet'}),
        '3 records in Wallet',
      );
    });

    test('MessenxDelegate unit behavior', () async {
      const delegate = MessenxDelegate();
      expect(delegate.isSupported(const Locale('pt')), isTrue);
      expect(delegate.isSupported(const Locale('pt', 'AO')), isTrue);
      expect(delegate.isSupported(const Locale('en')), isTrue);
      expect(delegate.isSupported(const Locale('fr')), isFalse);
      expect(delegate.shouldReload(const MessenxDelegate()), isFalse);

      final loaded = await delegate.load(const Locale('en'));
      expect(loaded, same(Messenx.instance));
      expect(Messenx.instance.languageCode, 'en');
    });

    testWidgets('MaterialApp integration with MessenxDelegate and Messenx.of',
        (WidgetTester tester) async {
      final localeNotifier = ValueNotifier<Locale>(const Locale('pt', 'AO'));
      Messenx? capturedMessenx;

      await tester.pumpWidget(
        ValueListenableBuilder<Locale>(
          valueListenable: localeNotifier,
          builder: (context, locale, _) {
            return MaterialApp(
              locale: locale,
              supportedLocales: Messenx.instance.supportedLocales,
              localizationsDelegates: const [
                MessenxDelegate(),
                GlobalMaterialLocalizations.delegate,
                GlobalWidgetsLocalizations.delegate,
                GlobalCupertinoLocalizations.delegate,
              ],
              home: Builder(
                builder: (context) {
                  capturedMessenx = Messenx.of(context);
                  return Scaffold(
                    body: Column(
                      children: [
                        Text('greeting'.translate),
                        Text('step_of'
                            .translateWith({'current': 2, 'total': 4})),
                        Text(
                          'account_records'.plural(
                            3,
                            args: {'account': 'Standard'},
                          ),
                        ),
                      ],
                    ),
                  );
                },
              ),
            );
          },
        ),
      );
      await tester.pumpAndSettle();

      expect(capturedMessenx, same(Messenx.instance));
      expect(find.text('Olá, mano'), findsOneWidget);
      expect(find.text('2 de 4'), findsOneWidget);
      expect(find.text('3 registos em Standard'), findsOneWidget);

      // Switch locale dynamically to English
      localeNotifier.value = const Locale('en');
      await tester.pumpAndSettle();

      expect(find.text('Hello'), findsOneWidget);
      expect(find.text('2 of 4'), findsOneWidget);
      expect(find.text('3 records in Standard'), findsOneWidget);
    });
  });
}
