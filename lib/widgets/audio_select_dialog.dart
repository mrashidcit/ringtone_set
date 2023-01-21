import 'dart:async';
import 'dart:io';

import 'package:deeze_app/helpers/share_value_helper.dart';
import 'package:deeze_app/widgets/app_image_assets.dart';
import 'package:deeze_app/widgets/app_loader.dart';
import 'package:deeze_app/widgets/internet_checkor_dialog.dart';
import 'package:dio/dio.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_contacts/flutter_contacts.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:internet_connection_checker/internet_connection_checker.dart';
import 'package:ndialog/ndialog.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:platform_device_id/platform_device_id.dart';
import 'package:ringtone_set/ringtone_set.dart';
import 'package:android_intent_plus/android_intent.dart';
import 'package:android_intent_plus/flag.dart';

class AudioSelectDialog extends StatefulWidget {
  final String file;
  const AudioSelectDialog({Key? key, required this.file}) : super(key: key);

  @override
  State<AudioSelectDialog> createState() => _AudioSelectDialogState();
}

class _AudioSelectDialogState extends State<AudioSelectDialog> {
  @override
  void initState() {
    super.initState();
    initPlatformState();
  }

  // Platform messages are asynchronous, so we initialize in an async method.
  Future<void> initPlatformState() async {}
  // Future<bool> downloadFile(String url) async {
  //   final appStorage = await getApplicationDocumentsDirectory();
  //   final file = File("${appStorage.path}/video.mp3");
  //   try {
  //       await Dio().download(url, file);
  //
  //
  //     // final response = await Dio().get(url,
  //     //     options: Options(
  //     //         responseType: ResponseType.bytes,
  //     //         followRedirects: false,
  //     //         receiveTimeout: 0));
  //     // final raf = file.openSync(mode: FileMode.write);
  //     // raf.writeFromSync(response.data);
  //     // raf.close();
  //     return true;
  //   } catch (e) {
  //     return false;
  //   }
  // }

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Container(
        margin:
            EdgeInsets.only(bottom: MediaQuery.of(context).size.width * 0.26),
        alignment: Alignment.bottomCenter,
        child: Card(
          elevation: 10,
          margin: const EdgeInsets.all(20),
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
          child: Container(
            height: 400,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(10),
              color: Colors.white,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              mainAxisAlignment: MainAxisAlignment.center,
              mainAxisSize: MainAxisSize.min,
              children: [
                GestureDetector(
                  onTap: () => Navigator.of(context).pop(),
                  child: Container(
                    width: 180,
                    alignment: Alignment.centerLeft,
                    child: const AppImageAsset(
                      image: 'assets/bakward_arrow.svg',
                      height: 20,
                    ),
                  ),
                ),
                const SizedBox(height: 20),
                GestureDetector(
                  onTap: actionSetRingTone,
                  child: Container(
                    width: 180,
                    alignment: Alignment.center,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: [
                        const SizedBox(
                          width: 20,
                          child: AppImageAsset(
                            image: 'assets/call_drop.svg',
                            height: 20,
                          ),
                        ),
                        const SizedBox(width: 20),
                        Text(
                          'SET RINGTONE',
                          style: GoogleFonts.archivo(
                            fontStyle: FontStyle.normal,
                            color: Colors.black,
                            fontSize: 14,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 22),
                GestureDetector(
                  onTap: actionSetNotification,
                  child: Container(
                    width: 180,
                    alignment: Alignment.center,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: [
                        const SizedBox(
                          width: 20,
                          child: AppImageAsset(
                            image: 'assets/notification.svg',
                            height: 20,
                          ),
                        ),
                        const SizedBox(width: 20),
                        Text(
                          'SET NOTIFICATION',
                          style: GoogleFonts.archivo(
                            fontStyle: FontStyle.normal,
                            color: Colors.black,
                            fontSize: 14,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 22),
                GestureDetector(
                  onTap: actionSetAlarmSound,
                  child: Container(
                    width: 180,
                    alignment: Alignment.center,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: [
                        const SizedBox(
                          width: 20,
                          child: AppImageAsset(
                            image: 'assets/bell_clock.svg',
                            height: 20,
                          ),
                        ),
                        const SizedBox(width: 20),
                        Text(
                          'SET ALARM SOUND',
                          style: GoogleFonts.archivo(
                            fontStyle: FontStyle.normal,
                            color: Colors.black,
                            fontSize: 14,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 22),
                GestureDetector(
                  onTap: actionSetToContact,
                  child: Container(
                    width: 180,
                    alignment: Alignment.center,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: [
                        const SizedBox(
                          width: 20,
                          child: AppImageAsset(
                            image: 'assets/person.svg',
                            height: 20,
                          ),
                        ),
                        const SizedBox(width: 20),
                        Text(
                          'SET TO CONTACT',
                          style: GoogleFonts.archivo(
                            fontStyle: FontStyle.normal,
                            color: Colors.black,
                            fontSize: 14,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 30),
                InkWell(
                  onTap: actionSaveToMedia,
                  child: Stack(
                    clipBehavior: Clip.none,
                    children: [
                      Container(
                        height: 50,
                        width: 180,
                        alignment: Alignment.center,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(12),
                          gradient: const LinearGradient(
                            begin: Alignment.centerLeft,
                            end: Alignment.centerRight,
                            colors: <Color>[
                              Color(0xFF7209b7),
                              Color(0xFF5c3fcc),
                            ],
                          ),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const AppImageAsset(
                                image: 'assets/save_down.svg', height: 14),
                            const SizedBox(width: 20),
                            Text(
                              'SAVE TO MEDIA',
                              style: GoogleFonts.archivo(
                                fontStyle: FontStyle.normal,
                                color: Colors.white,
                                fontSize: 13,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const Positioned(
                        top: -6,
                        right: -10,
                        child: AppImageAsset(image: 'assets/premium_badge.svg'),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Future<void> actionSetRingTone() async {
    if (!await InternetConnectionChecker().hasConnection) {
      showCupertinoModalPopup(
        context: context,
        barrierDismissible: false,
        builder: (context) => InternetCheckerDialog(
          onRetryTap: () {
            Navigator.pop(context); // Hide Internet Message Dialog
            Timer(Duration(milliseconds: 500), () => actionSetRingTone());
          },
        ),
      );
      return;
    }

    bool storagePermissionStatus = false;

    if (Platform.isAndroid) {
      var androidInfo = await PlatformDeviceId.deviceInfoPlugin.androidInfo;
      var release = androidInfo.version.release;
      var sdkInt = androidInfo.version.sdkInt;

      if (sdkInt >= 30) {
        PermissionStatus managedExternalStorageStatus =
            await Permission.manageExternalStorage.status;
        print(
            '>> actionSetRingTone - sdkInt , Permission.manageExternalStorage.status.isGranted : $sdkInt , ${managedExternalStorageStatus.isGranted}');

        if (managedExternalStorageStatus.isGranted) {
          storagePermissionStatus = true;
        } else {
          print('>> actionSetRingTone : _requestStoragePermission');

          _requestStoragePermission();
          return;
        }
      } else {
        storagePermissionStatus = await _requestStoragePermission();
      }
    }

    if (!storagePermissionStatus) {
      showMessage(context, message: "Storage Permission is Required");
      return;
    }

    bool success = false;
    ProgressDialog pd = ProgressDialog(
      context,
      dismissable: false,
      message: Text(
        "Please Wait!",
        style: GoogleFonts.archivo(
          fontStyle: FontStyle.normal,
          color: Colors.black,
        ),
      ),
    );
    pd.show();
    try {
      print('>> widget.file = ${widget.file}');
      success = await RingtoneSet.setRingtoneFromNetwork(widget.file);
      pd.dismiss();
    } on PlatformException {
      success = false;
    } catch (ex) {
      print(ex);
      success = false;
    }
    if (success) {
      showMessage(context, message: "Ringtone set successfully!");
    } else {
      showMessage(context, message: "Unable to complete this action.");
    }
    Navigator.pop(context);
  }

  Future<void> actionSetNotification() async {
    if (!await InternetConnectionChecker().hasConnection) {
      showCupertinoModalPopup(
        context: context,
        barrierDismissible: false,
        builder: (context) => InternetCheckerDialog(
          onRetryTap: () {
            Navigator.pop(context); // Hide Internet Message Dialog
            Timer(Duration(milliseconds: 500), () => actionSetNotification());
          },
        ),
      );
      return;
    }

    bool storagePermissionStatus = false;

    if (Platform.isAndroid) {
      var androidInfo = await PlatformDeviceId.deviceInfoPlugin.androidInfo;
      var release = androidInfo.version.release;
      var sdkInt = androidInfo.version.sdkInt;

      if (sdkInt >= 30) {
        PermissionStatus managedExternalStorageStatus =
            await Permission.manageExternalStorage.status;
        print(
            '>> actionSetRingTone - sdkInt , Permission.manageExternalStorage.status.isGranted : $sdkInt , ${managedExternalStorageStatus.isGranted}');

        if (managedExternalStorageStatus.isGranted) {
          storagePermissionStatus = true;
        } else {
          print('>> actionSetRingTone : _requestStoragePermission');

          _requestStoragePermission();
          return;
        }
      } else {
        storagePermissionStatus = await _requestStoragePermission();
      }
    }

    if (!storagePermissionStatus) {
      showMessage(context, message: "Storage Permission is Required");
      return;
    }

    bool success = false;
    ProgressDialog pd = ProgressDialog(
      context,
      dismissable: false,
      message: Text(
        "Please Wait!",
        style: GoogleFonts.archivo(
          fontStyle: FontStyle.normal,
          color: Colors.black,
        ),
      ),
    );
    pd.show();
    try {
      success = await RingtoneSet.setNotificationFromNetwork(widget.file);
      pd.dismiss();
    } on PlatformException {
      success = false;
    }
    if (success) {
      showMessage(context, message: "Notifications sound set successfully!");
    } else {
      showMessage(context, message: "Error");
    }
    Navigator.pop(context);
  }

  Future<void> actionSetAlarmSound() async {
    if (!await InternetConnectionChecker().hasConnection) {
      showCupertinoModalPopup(
        context: context,
        barrierDismissible: false,
        builder: (context) => InternetCheckerDialog(
          onRetryTap: () {
            Navigator.pop(context); // Hide Internet Message Dialog
            Timer(Duration(milliseconds: 500), () => actionSetAlarmSound());
          },
        ),
      );
      return;
    }
    bool storagePermissionStatus = false;

    if (Platform.isAndroid) {
      var androidInfo = await PlatformDeviceId.deviceInfoPlugin.androidInfo;
      var release = androidInfo.version.release;
      var sdkInt = androidInfo.version.sdkInt;

      if (sdkInt >= 30) {
        PermissionStatus managedExternalStorageStatus =
            await Permission.manageExternalStorage.status;
        print(
            '>> actionSetRingTone - sdkInt , Permission.manageExternalStorage.status.isGranted : $sdkInt , ${managedExternalStorageStatus.isGranted}');

        if (managedExternalStorageStatus.isGranted) {
          storagePermissionStatus = true;
        } else {
          print('>> actionSetRingTone : _requestStoragePermission');

          _requestStoragePermission();
          return;
        }
      } else {
        storagePermissionStatus = await _requestStoragePermission();
      }
    }

    if (!storagePermissionStatus) {
      showMessage(context, message: "Storage Permission is Required");
      return;
    }

    bool success = false;
    ProgressDialog pd = ProgressDialog(
      context,
      dismissable: false,
      message: Text(
        "Please Wait!",
        style: GoogleFonts.archivo(
          fontStyle: FontStyle.normal,
          color: Colors.black,
        ),
      ),
    );
    pd.show();
    try {
      success = await RingtoneSet.setAlarmFromNetwork(widget.file);
      pd.dismiss();
    } on PlatformException {
      success = false;
    }

    if (success) {
      showMessage(context, message: "Set to Alarm successfully!");
    } else {
      showMessage(context, message: "Error");
    }
    Navigator.pop(context);
  }

  Future<void> actionSetToContact() async {
    if (!await InternetConnectionChecker().hasConnection) {
      showCupertinoModalPopup(
        context: context,
        barrierDismissible: false,
        builder: (context) => InternetCheckerDialog(
          onRetryTap: () {
            Navigator.pop(context); // Hide Internet Message Dialog
            Timer(Duration(milliseconds: 500), () => actionSetAlarmSound());
          },
        ),
      );
      return;
    }

    bool storagePermissionStatus = false;

    if (Platform.isAndroid) {
      var androidInfo = await PlatformDeviceId.deviceInfoPlugin.androidInfo;
      var release = androidInfo.version.release;
      var sdkInt = androidInfo.version.sdkInt;

      if (sdkInt >= 30) {
        PermissionStatus managedExternalStorageStatus =
            await Permission.manageExternalStorage.status;
        print(
            '>> actionSetRingTone - sdkInt , Permission.manageExternalStorage.status.isGranted : $sdkInt , ${managedExternalStorageStatus.isGranted}');

        if (managedExternalStorageStatus.isGranted) {
          storagePermissionStatus = true;
        } else {
          print('>> actionSetRingTone : _requestStoragePermission');

          _requestStoragePermission();
          return;
        }
      } else {
        storagePermissionStatus = await _requestStoragePermission();
      }
    }

    if (!storagePermissionStatus) {
      showMessage(context, message: "Storage Permission is Required");
      return;
    }

    // Request contact permission
    show_openAppAd.$ = false;
    if (await FlutterContacts.requestPermission()) {
      show_openAppAd.$ = false;
      Contact? contact = await FlutterContacts.openExternalPick();

      show_openAppAd.$ = true;

      if (contact == null || contact!.id.isEmpty) {
        return;
      }

      bool success = false;
      ProgressDialog pd = ProgressDialog(
        context,
        dismissable: false,
        message: Text(
          "Please Wait!",
          style: GoogleFonts.archivo(
            fontStyle: FontStyle.normal,
            color: Colors.black,
          ),
        ),
      );
      pd.show();
      try {
        print(
            '>> actionSetToContact - contact!.id , widget.file : ${contact!.id} , ${widget.file}');
        success = await RingtoneSet.setRingtoneToContactFromNetwork(
          widget.file,
          contact!.id,
        );
        pd.dismiss();
      } on PlatformException {
        success = false;
      }

      if (success) {
        showMessage(context, message: "Rintone Successfully Set to Contact!");
      } else {
        showMessage(context, message: "Error");
      }
      Navigator.pop(context);
    } else {
      showMessage(context,
          message: "Contact Permission is Required to Set the Ringtone.");
    }

    show_openAppAd.$ = true;
  }

  Future<void> actionSaveToMedia() async {
    if (!await InternetConnectionChecker().hasConnection) {
      showCupertinoModalPopup(
        context: context,
        barrierDismissible: false,
        builder: (context) => InternetCheckerDialog(
          onRetryTap: () {
            Navigator.pop(context); // Hide Internet Message Dialog
            Timer(Duration(milliseconds: 500), () => actionSaveToMedia());
          },
        ),
      );
      return;
    }

    bool storagePermissionStatus = false;

    if (Platform.isAndroid) {
      var androidInfo = await PlatformDeviceId.deviceInfoPlugin.androidInfo;
      var release = androidInfo.version.release;
      var sdkInt = androidInfo.version.sdkInt;

      if (sdkInt >= 30) {
        PermissionStatus managedExternalStorageStatus =
            await Permission.manageExternalStorage.status;
        print(
            '>> actionSetRingTone - sdkInt , Permission.manageExternalStorage.status.isGranted : $sdkInt , ${managedExternalStorageStatus.isGranted}');

        if (managedExternalStorageStatus.isGranted) {
          storagePermissionStatus = true;
        } else {
          print('>> actionSetRingTone : _requestStoragePermission');

          _requestStoragePermission();
          return;
        }
      } else {
        storagePermissionStatus = await _requestStoragePermission();
      }
    }

    if (!storagePermissionStatus) {
      showMessage(context, message: "Storage Permission is Required");
      return;
    }

    bool success = false;

    ProgressDialog pd = ProgressDialog(
      context,
      dismissable: false,
      message: Text(
        "Please Wait!",
        style: GoogleFonts.archivo(
          fontStyle: FontStyle.normal,
          color: Colors.black,
        ),
      ),
    );
    pd.show();

    try {
      success = await downloadFile(
          widget.file, '${DateTime.now().microsecondsSinceEpoch}.mp3');
      pd.dismiss();
    } on PlatformException {
      success = false;
    }

    if (success) {
      showMessage(context, message: "Your File  successfully Downloaded");
    } else {
      showMessage(context, message: "Try again!");
    }
    Navigator.pop(context);
  }

  Future<bool> _requestPermission() async {
    PermissionStatus storageStatus = await Permission.storage.status;

    PermissionStatus managedExternalStorageStatus =
        await Permission.manageExternalStorage.status;

    if ((storageStatus.isDenied ||
        storageStatus.isPermanentlyDenied ||
        managedExternalStorageStatus.isDenied ||
        managedExternalStorageStatus.isPermanentlyDenied)) {
      if (storageStatus.isDenied) {
        await Permission.storage.request();
      }
      if (managedExternalStorageStatus.isDenied) {
        await Permission.manageExternalStorage.request();
      }

      PermissionStatus permissionStorageStatus =
          await Permission.storage.status;
      PermissionStatus permissionExternalStatus =
          await Permission.manageExternalStorage.status;

      if (permissionStorageStatus.isDenied ||
          permissionExternalStatus.isDenied) {
        openAppSettings();
      }
      if (storageStatus.isGranted ||
          storageStatus.isLimited && managedExternalStorageStatus.isGranted ||
          managedExternalStorageStatus.isLimited) {
        return true;
      }
      return false;
    } else if (storageStatus.isGranted ||
        storageStatus.isLimited && managedExternalStorageStatus.isGranted ||
        managedExternalStorageStatus.isLimited) {
      return true;
    } else {
      return false;
    }
  }

  Future<bool> _requestStoragePermission() async {
    bool output = false;

    if (Platform.isAndroid) {
      var androidInfo = await PlatformDeviceId.deviceInfoPlugin.androidInfo;
      var release = androidInfo.version.release;
      var sdkInt = androidInfo.version.sdkInt;

      if (sdkInt >= 23 && sdkInt <= 29) {
        PermissionStatus storageStatus = await Permission.storage.status;
        if ((storageStatus.isDenied || storageStatus.isPermanentlyDenied)) {
          if (storageStatus.isDenied) {
            storageStatus = await Permission.storage.request();
          }

          output = storageStatus.isGranted;
        } else if (storageStatus.isGranted || storageStatus.isLimited) {
          output = true;
        } else {
          output = false;
        }
      } else {
        // for API level 29 & Above
        print('>> for API level 30 & Above ');
        show_openAppAd.$ = false;
        PermissionStatus managedExternalStorageStatus =
            await Permission.manageExternalStorage.status;

        print(
            '>> managedExternalStorageStatus.isGranted : ${managedExternalStorageStatus.isGranted}');
        print(
            '>> managedExternalStorageStatus.isDenied : ${managedExternalStorageStatus.isDenied}');
        print(
            '>> managedExternalStorageStatus.isPermanentlyDenied : ${managedExternalStorageStatus.isPermanentlyDenied}');
        print(
            '>> managedExternalStorageStatus.isRestricted : ${managedExternalStorageStatus.isRestricted}');
        if (!managedExternalStorageStatus.isGranted) {
          managedExternalStorageStatus =
              await Permission.manageExternalStorage.request();
          // managedExternalStorageStatus = await Permission.storage.request();

          output = managedExternalStorageStatus.isGranted;
          print(
              '>> after tigger setting - managedExternalStorageStatus.isGranted : ${managedExternalStorageStatus.isRestricted}');
        } else if (managedExternalStorageStatus.isGranted ||
            managedExternalStorageStatus.isLimited) {
          output = true;
        } else {
          output = false;
        }
      }
      show_openAppAd.$ = true;
      var manufacturer = androidInfo.manufacturer;
      var model = androidInfo.model;
      print('>> Android $release (SDK $sdkInt), $manufacturer $model');
      // Android 9 (SDK 28), Xiaomi Redmi Note 7
    }

    return output;
  }

  Future<bool> downloadFile(String url, String fileName) async {
    Directory directory;
    try {
      if (await _requestStoragePermission()) {
        directory = (await getExternalStorageDirectory())!;
        String newPath = "";

        print(directory);
        List<String> paths = directory.path.split("/");
        for (int x = 1; x < paths.length; x++) {
          String folder = paths[x];
          if (folder != "Android") {
            newPath += "/" + folder;
          } else {
            break;
          }
        }
        newPath = newPath + '/Ringtones' + "/DeezePlayer";
        directory = Directory(newPath);
      } else {
        return false;
      }

      if (!await directory.exists()) {
        await directory.create(recursive: true);
      }
      if (await directory.exists()) {
        File saveFile = File(directory.path + "/$fileName");
        print("saveFile => $saveFile");
        print("direc => $directory");
        await Dio().download(url, saveFile.path);
        return true;
      }
      if (await directory.exists()) {
        File saveFile = File(directory.path + "/$fileName");
        print("saveFile => $saveFile");
        await Dio().download(url, saveFile.path);
        return true;
      }
    } catch (ex, stackTrace) {
      Completer().completeError(ex, stackTrace);
    }
    return false;
  }
}
