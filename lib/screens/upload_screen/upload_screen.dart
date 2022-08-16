import 'dart:io';

import 'package:deeze_app/widgets/app_image_assets.dart';
import 'package:dotted_border/dotted_border.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_picker/image_picker.dart';

class UploadScreen extends StatefulWidget {
  const UploadScreen({Key? key}) : super(key: key);

  @override
  State<UploadScreen> createState() => UploadScreenState();
}

class UploadScreenState extends State<UploadScreen> {
  File? profileImage;
  final ImagePicker imagePicker = ImagePicker();

  @override
  Widget build(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;
    return Scaffold(
      appBar: PreferredSize(
        preferredSize: const Size(0, 60),
        child: AppBar(
          backgroundColor: const Color(0xFF4d047d),
          elevation: 0,
          centerTitle: true,
          leading: Builder(
            builder: (ctx) {
              return GestureDetector(
                onTap: () => Scaffold.of(ctx).openDrawer(),
                child: const Padding(
                  padding: EdgeInsets.symmetric(horizontal: 15),
                  child: AppImageAsset(image: 'assets/menu.svg'),
                ),
              );
            },
          ),
          title: Text(
            'Upload',
            style: GoogleFonts.archivo(
              fontStyle: FontStyle.normal,
              color: Colors.white,
              fontSize: 22,
              fontWeight: FontWeight.w600,
              wordSpacing: 0.34,
            ),
          ),
          actions: const [
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 12),
              child: AppImageAsset(image: 'assets/search.svg'),
            ),
          ],
        ),
      ),
      body: Container(
        height: double.infinity,
        width: double.infinity,
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: <Color>[
              Color(0xFF4d047d),
              Color(0xFF17131F),
              Color(0xFF17131F),
              Color(0xFF17131F),
              Color(0xFF17131F),
              Color(0xFF17131F),
              Color(0xFF17131F),
            ],
          ),
        ),
        child: SingleChildScrollView(
          padding: const EdgeInsets.only(top: 50),
          child: Column(
            children: [
              GestureDetector(
                onTap: () {
                  showCupertinoModalPopup(
                    context: context,
                    builder: (context) => Material(
                      child: Wrap(
                        children: <Widget>[
                          ListTile(
                            leading: const Icon(Icons.photo_library),
                            title: Text(
                              Platform.isIOS ? 'Photo' : 'Gallery',
                              style: const TextStyle(
                                color: Colors.black,
                                fontSize: 16,
                                fontWeight: FontWeight.w200,
                              ),
                            ),
                            onTap: () {
                              imageFromGallery();
                              Navigator.of(context).pop();
                            },
                          ),
                          ListTile(
                            leading: const Icon(Icons.photo_camera),
                            title: const Text(
                              'Camera',
                              style: TextStyle(
                                color: Colors.black,
                                fontSize: 16,
                                fontWeight: FontWeight.w200,
                              ),
                            ),
                            onTap: () {
                              imageFromCamera();
                              Navigator.of(context).pop();
                            },
                          ),
                        ],
                      ),
                    ),
                  );
                },
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    if (profileImage == null)
                      DottedBorder(
                        color: const Color(0XFF979797),
                        strokeWidth: 3,
                        dashPattern: const [8, 8],
                        borderType: BorderType.RRect,
                        radius: const Radius.circular(12),
                        child: Container(
                          height: 250,
                          width: 150,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(12),
                            gradient: const LinearGradient(
                              begin: Alignment.topCenter,
                              end: Alignment.bottomCenter,
                              colors: <Color>[
                                Color(0xFF2F2841),
                                Color(0xFF1C1824),
                                Color(0xFF1B1723),
                              ],
                            ),
                          ),
                        ),
                      ),
                    profileImage == null
                        ? const AppImageAsset(image: 'assets/upload_add.svg')
                        : SizedBox(
                            height: 250,
                            width: 150,
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(12),
                              child: Image.file(
                                profileImage!,
                                height: 250,
                                width: 150,
                                fit: BoxFit.fill,
                              ),
                            ),
                          ),
                  ],
                ),
              ),
              const SizedBox(height: 30),
              if (profileImage != null)
                Container(
                  height: 50,
                  alignment: Alignment.center,
                  margin: const EdgeInsets.symmetric(horizontal: 20),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(16),
                    border:
                        Border.all(color: const Color(0XFF979797), width: 1),
                  ),
                  child: TextFormField(
                    style: const TextStyle(color: Colors.white),
                    decoration: const InputDecoration(
                      contentPadding: EdgeInsets.fromLTRB(10, 0, 0, 0),
                      hintText: 'Title',
                      hintStyle: TextStyle(
                        color: Colors.white,
                      ),
                      border: InputBorder.none,
                      focusedBorder: InputBorder.none,
                    ),
                  ),
                ),
              const SizedBox(height: 30),
              if (profileImage != null)
                Container(
                  height: 50,
                  alignment: Alignment.center,
                  margin: const EdgeInsets.symmetric(horizontal: 20),
                  decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: const Color(0XFF979797), width: 1),
                  ),
                  child: TextFormField(
                    style: const TextStyle(color: Colors.white),
                    decoration: const InputDecoration(
                      contentPadding: EdgeInsets.fromLTRB(10, 0, 0, 0),
                      hintText: 'Tags',
                      hintStyle: TextStyle(
                        color: Colors.white,
                      ),
                      border: InputBorder.none,
                      focusedBorder: InputBorder.none,
                    ),
                  ),
                ),
              const SizedBox(height: 40),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 22),
                child: Text(
                  'By selecting \'Upload\' you are representing that this item is not obscene and does not otherwise violate D’eeze’s Terms of Service, and that you own all copyrights to this item or have express permission from the copyright owner(s) to upload it.',
                  style: GoogleFonts.archivo(
                    fontStyle: FontStyle.normal,
                    color: const Color(0XFFA49FAD),
                    fontSize: 14,
                    wordSpacing: 0.22,
                  ),
                ),
              ),
              const SizedBox(height: 20),
              if (profileImage != null)
                Container(
                  height: 50,
                  width: double.infinity,
                  margin: const EdgeInsets.symmetric(horizontal: 22),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      primary: const Color(0xFF560CAD),
                    ),
                    child: Text(
                      'Finnish',
                      style: GoogleFonts.archivo(
                        fontStyle: FontStyle.normal,
                        color: Colors.white,
                        fontSize: 16,
                        wordSpacing: 0.22,
                      ),
                    ),
                    onPressed: () {},
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }

  void imageFromCamera() async {
    XFile? cameraImage = await imagePicker.pickImage(
      source: ImageSource.camera,
      imageQuality: 100,
    );
    if (cameraImage != null) {
      profileImage = File(cameraImage.path);
      print('Profile Image from Camera --> $profileImage');
      setState(() {});
    }
  }

  void imageFromGallery() async {
    XFile? galleryImage = await imagePicker.pickImage(
      source: ImageSource.gallery,
      imageQuality: 100,
    );
    if (galleryImage != null) {
      profileImage = File(galleryImage.path);
      print('Profile Image from Gallery --> $profileImage');
      setState(() {});
    }
  }
}
