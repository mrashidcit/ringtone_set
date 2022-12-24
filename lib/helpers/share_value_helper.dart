import 'package:deeze_app/models/deeze_model.dart';
import 'package:shared_value/shared_value.dart';

final SharedValue<bool> is_logged_in = SharedValue(
  value: false, // initial value
  key: "is_logged_in", // disk storage key for shared_preferences
  autosave: true,
);

final SharedValue<int> user_id = SharedValue(
  value: 0, // initial value
  key: "user_id", // disk storage key for shared_preferences
  autosave: true,
);

final SharedValue<String> api_token = SharedValue(
  value: '', // initial value
  key: "api_token", // disk storage key for shared_preferences
  autosave: true,
);

final SharedValue<String> first_name = SharedValue(
  value: '', // initial value
  key: "first_name", // disk storage key for shared_preferences
  autosave: true,
);

final SharedValue<String> last_name = SharedValue(
  value: '', // initial value
  key: "last_name", // disk storage key for shared_preferences
  autosave: true,
);

final SharedValue<String> user_profile_image = SharedValue(
  value: '', // initial value
  key: "user_profile_image", // disk storage key for shared_preferences
  autosave: true,
);

final SharedValue<bool> show_openAppAd = SharedValue(
  value: true, // initial value
  key: "show_openAppAd", // disk storage key for shared_preferences
  autosave: true,
);

void saveUserInCache(User user) {
  user_id.$ = user.id!;
  first_name.$ = user.firstName!;
  last_name.$ = user.lastName!;
  user_profile_image.$ = user.image!;
}

User getUserFromCache() {
  return User(
    id: user_id.$,
    firstName: first_name.$,
    lastName: last_name.$,
    image: user_profile_image.$,
  );
}
