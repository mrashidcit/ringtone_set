import 'package:deeze_app/models/deeze_model.dart';

class RandomItemResponse {
  bool result;
  String message;
  List<DeezeItemModel> itemList;

  RandomItemResponse({
    this.result = false,
    this.message = '',
    this.itemList = const [],
  }) : super();
}
