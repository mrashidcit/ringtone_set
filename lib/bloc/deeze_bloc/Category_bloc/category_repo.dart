import 'package:http/http.dart' as http;
import 'dart:convert';

import '../../../models/categories.dart';
import '../../../uitilities/end_points.dart';
import 'category_bloc.dart';

class CategoryRepository {
  Future<CategoryState> getCategories() async {
    var url = getCategoriesUrl;

    Uri uri = Uri.parse(url).replace(queryParameters: {
      "page": "1",
      "itemsPerPage": "10",
    });
    try {
      http.Response response = await http.get(
        uri,
        headers: {
          'Content-Type': 'application/json',
        },
      );
      print(response.statusCode);

      if (response.statusCode == 200) {
        print(response.body);
        var rawResponse = categoriesFromJson(response.body);
        return LoadedCategory(categories: rawResponse);
      } else {
        return Error();
      }
    } catch (e) {
      return Error();
    }
  }
}
