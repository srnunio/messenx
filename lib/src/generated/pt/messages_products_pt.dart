// messages_products_pt.dart
import 'package:intl/message_lookup_by_library.dart';
import '../../messenx_base_message.dart';

class MessagesProductsPt extends MessenxLookupBase {
  @override
  String get localeName => "pt";

  @override
  Map<String, Function> get messages {
    return {
      "product_title": MessageLookupByLibrary.simpleMessage("Produtos"),
      "product_add": MessageLookupByLibrary.simpleMessage("Adicionar Produto"),
      "product_remove": MessageLookupByLibrary.simpleMessage("Remover Produto"),
    };
  }
}
