import 'package:deeze_app/ads_util/app_open_ad_manager.dart';
import 'package:deeze_app/helpers/share_value_helper.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';

/// Listens for app foreground events and shows app open ads.
class AppLifecycleReactor {
  final AppOpenAdManager appOpenAdManager;

  AppLifecycleReactor({required this.appOpenAdManager});

  void listenToAppStateChanges() {
    AppStateEventNotifier.startListening();
    AppStateEventNotifier.appStateStream
        .forEach((state) => _onAppStateChanged(state));
  }

  void _onAppStateChanged(AppState appState) {
    // Try to show an app open ad if the app is being resumed and
    // we're not already showing an app open ad.
    print(
        '>> AppLifecycleReactor - _onAppStateChanged : ${appState.name} , ${show_openAppAd_counter_check.$}');
    if (appState == AppState.foreground &&
        show_openAppAd.$ &&
        show_openAppAd_counter_check.$ >= 9) {
      appOpenAdManager.showAdIfAvailable();
      show_openAppAd_counter_check.$ = 0; // reseting it
    } else {
      show_openAppAd_counter_check.$ = show_openAppAd_counter_check.$ + 1;
    }
  }
}
