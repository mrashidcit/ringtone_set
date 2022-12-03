import 'package:deeze_app/helpers/share_value_helper.dart';
import 'package:flutter/cupertino.dart';

class Utils {
  static Future<void> getSharedValueHelperData() async {
    await is_logged_in.load();
    await user_id.load();
    await first_name.load();
    await last_name.load();
    await user_profile_image.load();
  }

  static void hideKeyboard() {
    FocusManager.instance.primaryFocus?.unfocus();
  }
}
