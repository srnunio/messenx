// messages_clients_pt.dart
import 'package:intl/message_lookup_by_library.dart';
import '../../messenx_base_message.dart';

class MessagesClientsPt extends MessenxLookupBase {
  @override
  String get localeName => "pt";

  final Map<String, Function> _messages = {
    "client_title": MessageLookupByLibrary.simpleMessage("Clientes"),
    "client_add": MessageLookupByLibrary.simpleMessage("Adicionar Cliente"),
    "product_title": MessageLookupByLibrary.simpleMessage("Produtos +"),
  };

  @override
  Map<String, Function> get overrides => {
        "product_title":
            MessageLookupByLibrary.simpleMessage("Produtos - Alterado"),
        "new_key": MessageLookupByLibrary.simpleMessage("Add new key")
      };

  @override
  Map<String, Function> get messages => _messages;
}
