// messages_clients_en.dart
import 'package:intl/message_lookup_by_library.dart';

import '../../messenx_base_message.dart';

class MessagesClientsEn extends MessenxLookupBase {
  @override
  String get localeName => "en";

  @override
  Map<String, Function> get messages {
    return {
      "client_title": MessageLookupByLibrary.simpleMessage("Clients"),
      "client_add": MessageLookupByLibrary.simpleMessage("Add Client"),
    };
  }
}
