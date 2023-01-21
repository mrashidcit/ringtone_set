import 'package:deeze_app/models/deeze_model.dart';

class RandomItemResponse {
  bool result;

  String message;
  List<DeezeItemModel> itemList;
  int statusCode = 0;

  RandomItemResponse({
    this.result = false,
    this.message = '',
    this.itemList = const [],
    statusCode = 0,
  }) : super();
}
