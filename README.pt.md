# messenx

🌐 **Ler em:** [English](README.md) | **Português**

---

Catálogos de tradução modulares para aplicações Flutter, construídos por cima do [`intl`](https://pub.dev/packages/intl). Cada idioma pode ser dividido em vários ficheiros (um por módulo ou funcionalidade); o **messenx** junta-os num único mapa em cache e traduz diretamente através de extensões em `String` como `'chave'.translate`.

## Índice

1. [Como Instalar](#1-como-instalar)
2. [Configuração dos Ficheiros de Idioma (`MessenxLookupBase`)](#2-configuração-dos-ficheiros-de-idioma-messenxlookupbase)
3. [Junção de Ficheiros de Idioma, Variantes Regionais e Overrides](#3-junção-de-ficheiros-de-idioma-variantes-regionais-e-overrides)
4. [Como Inicializar](#4-como-inicializar)
5. [Usar com `MaterialApp` vs. Modo Normal (Standalone)](#5-usar-com-materialapp-vs-modo-normal-standalone)
   - [Opção A: Com `MaterialApp` (`MessenxDelegate`)](#opção-a-com-materialapp-messenxdelegate)
   - [Opção B: Modo Normal / Standalone (Sem `BuildContext`)](#opção-b-modo-normal--standalone-sem-buildcontext)
6. [Como Usar: Tradução, Placeholders e Uso do Plural](#6-tradução-placeholders-e-uso-do-plural)
   - [Tradução Simples](#tradução-simples)
   - [Placeholders (`translateWith`)](#placeholders-translatewith)
   - [Uso do Plural (`plural`)](#uso-do-plural-plural)
7. [Ler um Catálogo Diretamente e Testes](#7-ler-um-catálogo-diretamente-e-testes)

## O que traz

- **Vários ficheiros por idioma**: Divide as traduções por módulo ou funcionalidade (ex.: Auth, Produtos, Clientes) e junta-as num só mapa (construído uma única vez e guardado em cache).
- **Variantes regionais**: Ficheiros como `pt_AO` ou `pt_BR` juntam-se por cima dos ficheiros base (`pt`), pelo que o ficheiro regional só precisa de declarar as chaves que mudam.
- **`overrides` explícitos**: Qualquer ficheiro pode substituir chaves de outro ficheiro do mesmo idioma.
- **Placeholders nomeados**: Preenche variáveis `{nome}` com `'chave'.translateWith({'nome': 'Ana'})`.
- **Plurais CLDR**: Suporte completo às regras de plural do `intl` (`_zero`, `_one`, `_two`, `_few`, `_many`, `_other`) com `'chave'.plural(count, args: ...)`.
- **Suporte para `MaterialApp` e Modo Normal**: Funciona com `LocalizationsDelegate` (`MessenxDelegate`) na árvore de widgets ou em modo normal/standalone sem `BuildContext`.

---

## 1. Como Instalar

### Via `pub.dev`

Adiciona `messenx` e `flutter_localizations` ao teu `pubspec.yaml`:

```yaml
dependencies:
  flutter:
    sdk: flutter
  flutter_localizations:
    sdk: flutter
  intl: ^0.20.2
  messenx: ^0.1.0
```

Ou executa no terminal:

```bash
flutter pub add messenx
```

### Via Git ou Caminho Local (`path`)

```yaml
dependencies:
  messenx:
    git:
      url: https://github.com/srnunio/messenx.git
      ref: main
  # Ou caminho local:
  # messenx:
  #   path: ./messenx
```

---

## 2. Configuração dos Ficheiros de Idioma (`MessenxLookupBase`)

Cada ficheiro de idioma é uma classe que estende `MessenxLookupBase`, definindo `localeName` e o mapa `messages` com `MessageLookupByLibrary.simpleMessage`:

```dart
import 'package:intl/message_lookup_by_library.dart';
import 'package:messenx/messenx.dart';

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
```

---

## 3. Junção de Ficheiros de Idioma, Variantes Regionais e Overrides

### Divisão por Módulo / Funcionalidade

Podes criar várias classes de catálogo para o mesmo `localeName` (por exemplo, um ficheiro por módulo). O `Messenx` junta automaticamente todos os ficheiros do mesmo idioma num único mapa:

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

### Variantes Regionais (`pt_AO` por cima de `pt`)

Um ficheiro regional (ex.: `pt_AO`) junta-se por cima do idioma base (`pt`). Só precisas de incluir as chaves que mudam nessa região:

```dart
class AppMessagesPtAo extends MessenxLookupBase {
  @override
  String get localeName => 'pt_AO';

  @override
  Map<String, Function> get messages => {
        'welcome_user': MessageLookupByLibrary.simpleMessage('Olá, mano {name}!'),
      };
}
// Com Locale('pt', 'AO'):
// 'welcome_user' vem de pt_AO, enquanto 'save', 'product_title', etc. vêm de pt.
```

### Substituição de Chaves (`overrides`)

Se precisares que um catálogo substitua chaves definidas noutro ficheiro do mesmo idioma, usa o getter `overrides`. As chaves em `overrides` são aplicadas sempre no fim e ganham independentemente da ordem de registo:

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

## 4. Como Inicializar

Chama `Messenx.initialize` no arranque da aplicação para registar os catálogos e os idiomas suportados, seguido de `await Messenx.load()`:

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

> **Nota:** Chamar `Messenx.initialize` várias vezes (ex.: em módulos carregados mais tarde, background isolates ou testes) não duplica ficheiros já registados e invalida automaticamente a cache quando novos ficheiros são adicionados.

---

## 5. Usar com `MaterialApp` vs. Modo Normal (Standalone)

### Opção A: Com `MaterialApp` (`MessenxDelegate`)

Adiciona `MessenxDelegate()` em `localizationsDelegates` e passa `Messenx.instance.supportedLocales`:

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

Também podes aceder à instância através de `Messenx.of(context)` dentro da árvore de widgets.

### Opção B: Modo Normal / Standalone (Sem `BuildContext`)

Como o `messenx` configura diretamente o `Intl`, podes traduzir chaves em qualquer lugar — dentro de ViewModels, BLoCs, serviços, repositórios ou testes — sem precisares de `BuildContext` nem de `MaterialApp`:

```dart
// Inicializar e carregar uma vez
Messenx.initialize(
  currentLocale: const Locale('pt'),
  supportedLocales: const [Locale('pt'), Locale('en')],
  messages: [AppMessagesPt(), AppMessagesEn()],
);
await Messenx.load();

// Usar diretamente em qualquer código Dart
final texto = 'save'.translate; // "Guardar"

// Mudar de idioma a qualquer momento
await Messenx.load(locale: const Locale('en'));
final textoEn = 'save'.translate; // "Save"
```

---

## 6. Tradução, Placeholders e Uso do Plural

### Tradução Simples

```dart
'save'.translate;               // "Guardar"
'nao_existe'.translate;         // "**nao_existe** not found" (fácil de detetar em desenvolvimento/testes)
'nao_existe'.tryTranslate;      // "nao_existe" (devolve a própria chave se não existir)
'nao_existe'.translateOrEmpty;  // "" (devolve string vazia se não existir)
```

### Placeholders (`translateWith`)

Os placeholders usam o formato `{nome}` (letras, dígitos e `_`). Qualquer placeholder que não seja passado no mapa mantém-se inalterado:

```dart
'step_of'.translateWith({'current': 1, 'total': 3}); // "Passo 1 de 3"
'step_of'.translateWith({'current': 1});             // "Passo 1 de {total}"
```

### Uso do Plural (`plural`)

`plural(count, args: ...)` escolhe `<chave>_<categoria>` segundo as regras CLDR do idioma atual (`zero`, `one`, `two`, `few`, `many`, `other`), cai em `<chave>_other` quando a categoria específica não está definida, e preenche automaticamente `{count}` (além de qualquer argumento extra passado em `args`):

```dart
// Chaves no catálogo:
// 'records_zero': 'Sem registos'
// 'records_one': '{count} registo'
// 'records_many': '{count} de registos'
// 'records_other': '{count} registos'

'records'.plural(0);         // "Sem registos" (_zero ganha sempre para 0 quando existe)
'records'.plural(1);         // "1 registo"
'records'.plural(7);         // "7 registos"
'records'.plural(1000000);   // "1000000 de registos" (usa _many em pt, ou cai em _other)

// Combinar o plural com placeholders adicionais em args:
// 'account_records_one': '{count} registo na conta {account}'
// 'account_records_other': '{count} registos na conta {account}'
'account_records'.plural(3, args: {'account': 'Corrente'}); // "3 registos na conta Corrente"
```

#### Categorias CLDR por Idioma

| Idioma | `0` | `1` | `2` | `1 000 000` | Resto |
|---|---|---|---|---|---|
| `pt`, `pt_AO`, `pt_BR` | `one` | `one` | `other` | `many` | `other` |
| `pt_PT` | `other` | `one` | `other` | `other` | `other` |
| `en` | `other` | `one` | `other` | `other` | `other` |

> **Dica:** Em `pt` (`pt_AO`, `pt_BR`), o CLDR coloca o `0` na categoria `one`. Define `<chave>_zero` sempre que o `0` precisar de texto próprio (ou plural) — quando `<chave>_zero` existe, tem sempre prioridade para `count == 0`.

---

## 7. Ler um Catálogo Diretamente e Testes

Podes inspecionar o catálogo combinado de qualquer idioma ou variante regional diretamente com `Messenx.get`:

```dart
final pt = Messenx.get(languageCode: 'pt');      // ou 'pt_AO' (pt + pt_AO juntos)
pt.hasMessages;   // false para um idioma sem ficheiros registados
pt.lengthKeys;    // total de chaves combinadas
pt.messages.keys; // todas as chaves do idioma
```

### Exemplo de Teste para Garantir Paridade de Chaves Entre Idiomas

```dart
test('Catálogos PT e EN têm as mesmas chaves', () {
  Messenx.initialize(
    currentLocale: const Locale('pt'),
    supportedLocales: const [Locale('pt'), Locale('en')],
    messages: [AppMessagesPt(), AppMessagesEn()],
  );

  final ptKeys = Messenx.get(languageCode: 'pt').messages.keys.toSet();
  final enKeys = Messenx.get(languageCode: 'en').messages.keys.toSet();

  expect(ptKeys.difference(enKeys), isEmpty, reason: 'Chaves em falta no EN');
  expect(enKeys.difference(ptKeys), isEmpty, reason: 'Chaves em falta no PT');
});
```
