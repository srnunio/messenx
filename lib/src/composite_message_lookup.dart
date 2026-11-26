import 'package:intl/intl.dart';
import 'package:intl/message_lookup_by_library.dart';
// `initializeInternalMessageLookup` só existe em intl_helpers; o intl não o exporta.
// ignore: implementation_imports
import 'package:intl/src/intl_helpers.dart';

import 'messenx_base_message.dart';

/// [MessenxLookupManager] manages the registered translation files.
///
/// - **`add(List<MessenxLookupBase> data)`**: registers translation files
///   (a file already registered is ignored, so calling it twice is safe).
/// - **`getMessage(String localeName)`**: the merged lookup for [localeName].
/// - **`initializeMessages({required String localeName})`**: makes the lookup
///   for [localeName] the one `Intl.message` reads.
class MessenxLookupManager {
  MessenxLookupManager._();

  factory MessenxLookupManager.instance() => MessenxLookupManager._();

  /// Registered translation files, in registration order.
  final List<MessenxLookupBase> _translates = [];

  /// One stable lookup per locale name. `Intl` keeps the first object it is
  /// given for a locale, so the same object is reused and only its cache is
  /// cleared when files are added later.
  final Map<String, _CombinedMessageLookup> _lookups = {};

  /// Whether any translation file is registered.
  bool get hasData => _translates.isNotEmpty;

  /// Registers translation files. A file whose type and locale are already
  /// registered is skipped, so repeated `Messenx.initialize` calls (tests,
  /// background isolates) do not pile up duplicates.
  void add(List<MessenxLookupBase> data) {
    var changed = false;
    for (final file in data) {
      final duplicate = _translates.any(
        (t) =>
            t.runtimeType == file.runtimeType &&
            t.localeName == file.localeName,
      );
      if (duplicate) continue;
      _translates.add(file);
      changed = true;
    }
    if (changed) {
      for (final lookup in _lookups.values) {
        lookup.invalidate();
      }
    }
  }

  /// Files that apply to [localeName], language-level first: for `pt_AO`,
  /// the `pt` files and then the `pt_AO` files (whose keys win).
  List<MessenxLookupBase> _filesFor(String localeName) {
    final language = localeName.split(RegExp('[_-]')).first;
    return [
      if (language != localeName)
        ..._translates.where((t) => t.localeName == language),
      ..._translates.where((t) => t.localeName == localeName),
    ];
  }

  /// The merged lookup for [localeName] (empty when no file applies).
  MessenxLookupBase getMessage(String localeName) {
    if (_filesFor(localeName).isEmpty) return _EmptyMessages(localeName);
    return _lookupFor(localeName);
  }

  _CombinedMessageLookup _lookupFor(String localeName) => _lookups.putIfAbsent(
        localeName,
        () => _CombinedMessageLookup(localeName, () => _filesFor(localeName)),
      );

  /// Makes the lookup for [localeName] the one `Intl.message` reads. The
  /// stable lookup is registered even when no file applies yet, so files
  /// added later still reach `Intl` (it never replaces a known locale).
  Future<bool> initializeMessages({required String localeName}) async {
    initializeInternalMessageLookup(() => CompositeMessageLookup());
    final lookup = _lookupFor(localeName);
    messageLookup.addLocale(localeName, (_) => lookup);
    Intl.defaultLocale = localeName;
    return true;
  }
}

/// [_EmptyMessages] predefined translation file
class _EmptyMessages extends MessenxLookupBase {
  final String locale;

  _EmptyMessages(this.locale);

  @override
  String get localeName => locale;

  @override
  Map<String, Function> get messages => {};
}

/// Several translation files for the same language merged into one map.
///
/// ```dart
/// class MessagesProductsEn extends MessenxLookupBase {
///   @override
///   String get localeName => "en";
///
///   @override
///   Map<String, Function> get messages => {
///         "product_title": MessageLookupByLibrary.simpleMessage("Products"),
///       };
/// }
///
/// class MessagesClientsEn extends MessenxLookupBase {
///   @override
///   String get localeName => "en";
///
///   @override
///   Map<String, Function> get messages => {
///         "client_title": MessageLookupByLibrary.simpleMessage("Clients"),
///       };
/// }
///
/// Messenx.initialize(currentLocale: const Locale('en'), messages: [
///   MessagesProductsEn(),
///   MessagesClientsEn(),
/// ]);
/// // "product_title" and "client_title" both resolve in English.
/// ```
///
/// The merged map is built once and cached: every `.translate` reads it, so
/// rebuilding it per lookup (thousands of entries) would cost on every build.
/// Later files override earlier ones; `overrides` of any file win last.
class _CombinedMessageLookup extends MessenxLookupBase {
  final String _localeName;

  final List<MessenxLookupBase> Function() _files;

  Map<String, Function>? _merged;

  _CombinedMessageLookup(this._localeName, this._files);

  @override
  String get localeName => _localeName;

  /// Drops the cached map (new files were registered).
  void invalidate() => _merged = null;

  @override
  Map<String, Function> get messages => _merged ??= _merge();

  Map<String, Function> _merge() {
    final Map<String, Function> merged = {};
    final Map<String, Function> overrides = {};

    for (final lookup in _files()) {
      merged.addAll(lookup.messages.cast<String, Function>());
      if (lookup.hasExtra) overrides.addAll(lookup.overrides);
    }
    merged.addAll(overrides);
    return merged;
  }
}
