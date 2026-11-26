import 'package:intl/message_lookup_by_library.dart';

/// [MessenxLookupBase] abstract base message class,
/// Example:
/// ```dart
/// class MessagesEn extends MessenxLookupBase {
///   @override
///   String get localeName => "en";
///
///   @override
///   Map<String, Function> get messages {
///     return {
///       "client_title": MessageLookupByLibrary.simpleMessage("Clients"),
///       "client_add": MessageLookupByLibrary.simpleMessage("Add Client"),
///     };
///   }
/// }
abstract class MessenxLookupBase extends MessageLookupByLibrary {
  /// [overrides] helps replace some messages
  /// ```dart
  /// class MessagesOverrideEn extends MessagesEn {
  ///   @override
  ///   Map<String, Function> get overrides {
  ///     return {
  ///       "client_title": MessageLookupByLibrary.simpleMessage("List all clients"),
  ///     };
  ///   }
  /// }
  /// ```
  Map<String, Function> get overrides => {};

  /// [hasExtra] checks if there are messages to be replaced
  bool get hasExtra => overrides.isNotEmpty;

  /// [hasMessages] checks if there are defined messages
  bool get hasMessages => messages.isNotEmpty;

  /// [lengthKeys] messages count keys
  int get lengthKeys => messages.keys.length;
}
