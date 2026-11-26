// messages_products_pt.dart
import 'package:intl/message_lookup_by_library.dart';
import '../../messenx_base_message.dart';

class MessagesProductsEn extends MessenxLookupBase {
  @override
  String get localeName => "en";

  @override
  Map<String, Function> get messages {
    return {
      "product_title": MessageLookupByLibrary.simpleMessage("Produts"),
      "product_add": MessageLookupByLibrary.simpleMessage("Add Product"),
      "product_remove": MessageLookupByLibrary.simpleMessage("Remove Product"),
    };
  }
}
