import 'dart:io';

import 'package:deeze_app/bloc/deeze_bloc/Category_bloc/category_bloc.dart';
import 'package:deeze_app/models/deeze_model.dart';
import 'package:deeze_app/models/search_model.dart';
import 'package:deeze_app/screens/favourite/favourite_screen.dart';
import 'package:deeze_app/screens/search/search_screen.dart';
import 'package:deeze_app/screens/upload_screen/upload_status_screen.dart';
import 'package:deeze_app/screens/wallpapers/wallpapers.dart';
import 'package:deeze_app/services/search_services.dart';
import 'package:deeze_app/uitilities/end_points.dart';
import 'package:deeze_app/widgets/app_image_assets.dart';
import 'package:deeze_app/widgets/app_loader.dart';
import 'package:deeze_app/widgets/category_card.dart';
import 'package:deeze_app/widgets/drawer_header.dart';
import 'package:deeze_app/widgets/wallpaper_category_card.dart';
import 'package:dotted_border/dotted_border.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_picker/image_picker.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';
import 'package:http/http.dart' as http;

import '../categories/categories.dart';
import '../tags/tags.dart';


class UploadScreen extends StatefulWidget {
  const UploadScreen({Key? key}) : super(key: key);

  @override
  State<UploadScreen> createState() => UploadScreenState();
}

class UploadScreenState extends State<UploadScreen> {
  File? profileImage;
  final ImagePicker imagePicker = ImagePicker();
  bool isShow = false;
  bool isLoading = false;
  int page = 1;
  late int totalPage;

  List<HydraMember> hydraMember = [];

  final TextEditingController _typeAheadController = TextEditingController();
  final SearchServices _searchServices = SearchServices();
  final RefreshController _refreshController = RefreshController(initialRefresh: true);

  Future<bool> fetchWallpapers({bool isRefresh = false}) async {
    if (isRefresh) {
      page = 1;
    } else {
      if (page >= totalPage) {
        _refreshController.loadNoData();
        return false;
      }
    }

    var url = getDeezeAppUrlContent;

    Uri uri = Uri.parse(url).replace(queryParameters: {
      "page": "$page",
      "itemsPerPage": "10",
      "enabled": "true",
      "type": "WALLPAPER"
    });
    try {
      if (isRefresh) setState(() => isLoading = true);
      http.Response response = await http.get(
        uri,
        headers: {
          'Content-Type': 'application/json',
        },
      );
      print('${response.statusCode} : ${response.request}');

      if (response.statusCode == 200) {
        print(response.body);
        var rawResponse = deezeFromJson(response.body);
        if (isRefresh) {
          hydraMember = rawResponse.hydraMember!;
        } else {
          hydraMember.addAll(rawResponse.hydraMember!);
        }

        page++;
        totalPage = rawResponse.hydraTotalItems!;
        setState(() => isLoading = false);
        return true;
      } else {
        return false;
      }
    } catch (e) {
      return false;
    }
  }


  @override
  Widget build(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;
    return isShow ? WillPopScope(
      onWillPop: ()async{
        isShow = false;
        setState(() {});
        return false;
      },
      child: Scaffold(
        backgroundColor: const Color(0xFF4d047d),
        body: Container(
          height: MediaQuery.of(context).size.height,
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
                ]),
          ),
          child: SmartRefresher(
            enablePullUp: true,
            controller: _refreshController,
            onRefresh: () async {
              final result = await fetchWallpapers(isRefresh: true);
              if (result) {
                _refreshController.refreshCompleted();
              } else {
                _refreshController.refreshFailed();
              }
            },
            onLoading: () async {
              final result = await fetchWallpapers();
              if (result) {
                _refreshController.loadComplete();
              } else {
                _refreshController.loadFailed();
              }
            },
            header: CustomHeader(builder: (context, mode) => Container()),
            footer: CustomFooter(builder: (context, mode) => const LoadingPage()),
            child: SafeArea(
              child: Stack(
                children: [
                  CustomScrollView(
                    slivers: [
                      const SliverToBoxAdapter(
                        child: SizedBox(height: 70),
                      ),
                      SliverPadding(
                        padding: const EdgeInsets.symmetric(horizontal: 17),
                        sliver: SliverToBoxAdapter(
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                "Categories",
                                style: GoogleFonts.archivo(
                                  fontStyle: FontStyle.normal,
                                  color: Colors.white,
                                  fontSize: 12,
                                  wordSpacing: 0.19,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                              GestureDetector(
                                onTap: () {
                                  Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                          builder: (context) =>
                                          const Categories(
                                            isRingtone: false,
                                          )));
                                },
                                child: Row(
                                  children: [
                                    Text(
                                      "View All",
                                      style: GoogleFonts.archivo(
                                        fontStyle: FontStyle.normal,
                                        color: Colors.white,
                                        fontSize: 10,
                                        wordSpacing: 0.16,
                                        fontWeight: FontWeight.w400,
                                      ),
                                    ),
                                    const SizedBox(
                                      width: 10,
                                    ),
                                    const Icon(
                                      Icons.arrow_forward,
                                      color: Colors.white,
                                      size: 15,
                                    ),
                                  ],
                                ),
                              )
                            ],
                          ),
                        ),
                      ),
                      const SliverToBoxAdapter(
                        child: SizedBox(
                          height: 20,
                        ),
                      ),
                      SliverToBoxAdapter(
                        child: SizedBox(
                          height: 60,
                          width: screenWidth,
                          child: BlocConsumer<CategoryBloc, CategoryState>(
                            listener: (context, state) {
                              // TODO: implement listener
                            },
                            builder: (context, state) {
                              if (state is CategoryInitial) {
                                return const Center(
                                    child: CircularProgressIndicator());
                              }
                              if (state is LoadedCategory) {
                                return Padding(
                                  padding: const EdgeInsets.only(left: 17),
                                  child: ListView.builder(
                                    scrollDirection: Axis.horizontal,
                                    itemCount: 4,
                                    itemBuilder: (context, index) {
                                      return Padding(
                                        padding:
                                        const EdgeInsets.only(right: 12),
                                        child: WallpaperCategoryCard(
                                          id: state.categories!
                                              .hydraMember![index].id!,
                                          image: state.categories
                                              ?.hydraMember?[index].image,
                                          name: state.categories
                                              ?.hydraMember?[index].name,
                                        ),
                                      );
                                    },
                                  ),
                                );
                              }
                              return const Center(
                                  child: CircularProgressIndicator());
                            },
                          ),
                        ),
                      ),
                      const SliverToBoxAdapter(
                        child: SizedBox(
                          height: 20,
                        ),
                      ),
                      SliverPadding(
                        padding: const EdgeInsets.symmetric(horizontal: 17),
                        sliver: SliverToBoxAdapter(
                          child: Text(
                            "Popular",
                            style: GoogleFonts.archivo(
                              fontStyle: FontStyle.normal,
                              color: Colors.white,
                              fontSize: 15,
                            ),
                          ),
                        ),
                      ),
                      const SliverToBoxAdapter(
                        child: SizedBox(
                          height: 15,
                        ),
                      ),
                      SliverToBoxAdapter(
                        child: SizedBox(
                          height: 33,
                          width: screenWidth,
                          child: const Tags(),
                        ),
                      ),
                      const SliverToBoxAdapter(child: SizedBox(height: 15)),
                      SliverPadding(
                        padding: const EdgeInsets.symmetric(horizontal: 8.0),
                        sliver: SliverGrid(
                          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: 3,
                            mainAxisSpacing: 5.0,
                            crossAxisSpacing: 5.0,
                            childAspectRatio: 3 / 6,
                          ),
                          delegate: SliverChildBuilderDelegate(
                                (BuildContext context, int index) {
                              return CategoryCard(
                                index: index,
                                listHydra: hydraMember,
                                image: hydraMember[index].file!,
                                name: hydraMember[index].name!,
                              );
                            },
                            childCount: hydraMember.length,
                          ),
                        ),
                      ),
                    ],
                  ),
                  SingleChildScrollView(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Container(
                          margin: const EdgeInsets.symmetric(horizontal: 16),
                          height: 46,
                          width: MediaQuery.of(context).size.width,
                          child: TextFormField(
                            controller: _typeAheadController,
                            onChanged: (data) => setState(() {}),
                            onFieldSubmitted: (val){
                              FocusScope.of(context).unfocus();
                              if(_typeAheadController.text.isNotEmpty){
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                      builder: (context) => SearchScreen(
                                        searchText:
                                        _typeAheadController.text,
                                      )),
                                );
                              }
                              _typeAheadController.clear();
                            },
                            decoration: InputDecoration(
                              hintText: "",
                              hintStyle: const TextStyle(
                                color: Colors.white,
                                fontSize: 12,
                              ),
                              fillColor: Colors.white,
                              filled: true,
                              contentPadding: const EdgeInsets.symmetric(
                                vertical: 5,
                                horizontal: 20,
                              ),
                              focusedBorder: const OutlineInputBorder(
                                borderRadius: BorderRadius.only(topRight: Radius.circular(7),topLeft: Radius.circular(7)),
                                borderSide:
                                BorderSide(color: Color(0xFF5d318c), width: 0),
                              ),
                              enabledBorder: const OutlineInputBorder(
                                borderRadius: BorderRadius.only(topRight: Radius.circular(7),topLeft: Radius.circular(7)),
                                borderSide:
                                BorderSide(color: Color(0xFF5d318c), width: 0.0),
                              ),
                              suffixIcon: GestureDetector(
                                onTap: () {
                                  FocusScope.of(context).unfocus();
                                  _typeAheadController.text.isEmpty ?
                                  isShow = false
                                      : Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                        builder: (context) => SearchScreen(
                                          searchText:
                                          _typeAheadController.text,
                                        )),
                                  );
                                  _typeAheadController.clear();
                                  setState(() {});
                                },
                                child: const Padding(
                                  padding: EdgeInsets.symmetric(horizontal: 12),
                                  child: AppImageAsset(
                                    image: 'assets/search.svg',
                                    color: Colors.black,
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ),
                        FutureBuilder<List<SearchModel>>(
                            future: _searchServices.search(_typeAheadController.text.trim()),
                            builder: (BuildContext context,
                                AsyncSnapshot<List<SearchModel>> snapshot) {
                              if (snapshot.hasError) {
                                return Container(
                                    color: Colors.white,
                                    alignment: Alignment.centerLeft,
                                    margin: const EdgeInsets.symmetric(horizontal: 16),
                                    padding: const EdgeInsets.symmetric(vertical: 10).copyWith(left: 30),
                                    child: const Text("Something went wrong",style: TextStyle(color: Color(0xFF5d318c)),)
                                );
                              }
                              if (snapshot.connectionState == ConnectionState.done) {
                                return Container(
                                  color: Colors.white,
                                  margin: const EdgeInsets.symmetric(horizontal: 16),
                                  child: ListView.builder(
                                    shrinkWrap: true,
                                    itemCount: snapshot.data!.length > 4
                                        ? 4
                                        : snapshot.data!.length,
                                    itemBuilder: (context, index) => GestureDetector(
                                      onTap: (() {
                                        Navigator.push(
                                          context,
                                          MaterialPageRoute(
                                              builder: (context) => SearchScreen(
                                                searchText:
                                                snapshot.data![index].name!,
                                              )),
                                        );
                                      }),
                                      child: Padding(
                                          padding: const EdgeInsets.only(
                                              left: 30, top: 10, bottom: 10),
                                          child: Text(
                                            "${snapshot.data![index].name}",
                                            style: GoogleFonts.archivo(
                                              fontStyle: FontStyle.normal,
                                              color: const Color(0xFF5d318c),
                                              fontSize: 18,
                                              fontWeight: FontWeight.w500,
                                            ),
                                          )),
                                    ),
                                  ),
                                );
                              } else {
                                return Container();
                              }
                            }),
                        Container(
                          width: MediaQuery.of(context).size.width,
                          margin: const EdgeInsets.symmetric(horizontal: 16),
                          padding: const EdgeInsets.all(30).copyWith(top: 10),
                          decoration: const BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.only(
                              bottomLeft: Radius.circular(10),
                              bottomRight: Radius.circular(10),
                            ),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text(
                                'Trending search',
                                style: TextStyle(
                                    color: Colors.black,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 16),
                              ),
                              const SizedBox(height: 10),
                              Wrap(
                                spacing: 8,
                                runSpacing: 10,
                                children: List.generate(
                                  _searchServices
                                      .trendingSearchItems.length,
                                      (index) => Container(
                                    padding: const EdgeInsets.symmetric(
                                        vertical: 8, horizontal: 10),
                                    decoration: BoxDecoration(
                                      border: Border.all(
                                          color: const Color(0XFFE1E1E1)),
                                      borderRadius:
                                      BorderRadius.circular(10),
                                    ),
                                    child: Text(
                                      _searchServices
                                          .trendingSearchItems[index],
                                      style: const TextStyle(
                                          color: Colors.black),
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    ) :
    Scaffold(
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
          actions:  [
            GestureDetector(
              onTap: () => setState(() => isShow = true),
              child: const Padding(
                padding: EdgeInsets.symmetric(horizontal: 12),
                child: const AppImageAsset(image: 'assets/search.svg'),
              ),
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
                    onPressed: () {
                      if (profileImage!.lengthSync() < ((1024*1024) * 2)) {
                        showCupertinoModalPopup(context: context, builder: (context) => const UploadSuccess());
                      } else {
                        showCupertinoModalPopup(context: context, builder: (context) => const UploadFail());
                      }
                    },
                  ),
                ),
            ],
          ),
        ),
      ),
      drawer: Drawer(
        child: Container(
          decoration: const BoxDecoration(
            color: Color(0xFF252030),
            // gradient: const LinearGradient(colors: [
            //   Color(0xFF252030),
            // ]),
            // borderRadius: BorderRadius.circular(10),
          ),
          child: SingleChildScrollView(
            child: Column(
              children: [
                const MyDrawerHeader(showUpload: false),
                const SizedBox(
                  height: 40,
                ),
                InkWell(
                  onTap: () async {
                    Navigator.of(context).pop();
                    // Navigator.push(
                    //   context,
                    //   MaterialPageRoute(
                    //     builder: (context) => const Dashbaord(
                    //       type: "RINGTONE",
                    //     ),
                    //   ),
                    // );
                  },
                  child: Padding(
                    padding: const EdgeInsets.only(left: 40),
                    child: Row(
                      children: [
                        const AppImageAsset(image: 'assets/ringtone.svg'),
                        const SizedBox(
                          width: 26,
                        ),
                        Text(
                          "Ringtones",
                          style: GoogleFonts.archivo(
                            fontStyle: FontStyle.normal,
                            color: Colors.white,
                            fontSize: 18,
                            // fontWeight: FontWeight.w700,
                            wordSpacing: -0.09,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(
                  height: 30,
                ),
                GestureDetector(
                  onTap: () async {
                    Navigator.of(context).pop();
                    // ignore: use_build_context_synchronously
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const WallPapers(
                          type: "WALLPAPER",
                        ),
                      ),
                    );
                  },
                  child: Padding(
                    padding: const EdgeInsets.only(left: 40),
                    child: Row(
                      children: [
                        const AppImageAsset(image: "assets/wallpaper.svg"),
                        const SizedBox(
                          width: 26,
                        ),
                        Text(
                          "Wallpapers",
                          style: GoogleFonts.archivo(
                            fontStyle: FontStyle.normal,
                            color: Colors.white,
                            fontSize: 18,
                            // fontWeight: FontWeight.w700,
                            wordSpacing: -0.09,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(
                  height: 30,
                ),
                Padding(
                  padding: const EdgeInsets.only(left: 40),
                  child: Row(
                    children: [
                      SvgPicture.asset("assets/bell.svg"),
                      const SizedBox(
                        width: 20,
                      ),
                      Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Text(
                          "Notifications",
                          style: GoogleFonts.archivo(
                            fontStyle: FontStyle.normal,
                            color: Colors.white,
                            fontSize: 18,
                            // fontWeight: FontWeight.w700,
                            wordSpacing: -0.09,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(
                  height: 30,
                ),
                GestureDetector(
                  onTap: () {
                    Navigator.pop(context);
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) => const FavouriteScreen(
                            id: 9,
                            type: 'Favourites',
                          )),
                    );
                  },
                  child: Padding(
                    padding: const EdgeInsets.only(left: 40),
                    child: Row(
                      children: [
                        const AppImageAsset(image: 'assets/favourite_fill.svg'),
                        const SizedBox(
                          width: 29,
                        ),
                        Text(
                          "Favourite",
                          style: GoogleFonts.archivo(
                            fontStyle: FontStyle.normal,
                            color: Colors.white,
                            fontSize: 18,
                            // fontWeight: FontWeight.w700,
                            wordSpacing: -0.09,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(
                  height: 30,
                ),
                Divider(
                  height: 1,
                  thickness: 1,
                  color: Colors.grey.shade600,
                ),
                const SizedBox(
                  height: 25,
                ),
                Padding(
                  padding: const EdgeInsets.only(left: 37),
                  child: Row(
                    children: [
                      const Icon(
                        Icons.info,
                        color: Colors.white,
                        size: 20,
                      ),
                      const SizedBox(
                        width: 30,
                      ),
                      Text(
                        "Help",
                        style: GoogleFonts.archivo(
                          fontStyle: FontStyle.normal,
                          color: Colors.white,
                          fontSize: 13,
                          fontWeight: FontWeight.w400,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(
                  height: 25,
                ),
                Padding(
                  padding: const EdgeInsets.only(left: 37),
                  child: Row(
                    children: [
                      const Icon(
                        Icons.settings,
                        color: Color(0xffA49FAD),
                        size: 20,
                      ),
                      const SizedBox(
                        width: 30,
                      ),
                      Text(
                        "Settings",
                        style: GoogleFonts.archivo(
                          fontStyle: FontStyle.normal,
                          color: const Color(0xffA49FAD),
                          fontSize: 13,
                          fontWeight: FontWeight.w400,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(
                  height: 25,
                ),
                Padding(
                  padding: const EdgeInsets.only(left: 37),
                  child: Row(
                    children: [
                      const Icon(
                        Icons.privacy_tip,
                        color: Color(0xffA49FAD),
                        size: 20,
                      ),
                      const SizedBox(
                        width: 25,
                      ),
                      Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Text(
                          "Privacy Policy",
                          style: GoogleFonts.archivo(
                            fontStyle: FontStyle.normal,
                            color: const Color(0xffA49FAD),
                            fontSize: 13,
                            fontWeight: FontWeight.w400,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(
                  height: 25,
                ),
                Divider(
                  height: 1,
                  thickness: 1,
                  color: Colors.grey.shade600,
                ),
                const SizedBox(
                  height: 25,
                ),
                Padding(
                  padding: const EdgeInsets.only(left: 40),
                  child: Row(
                    children: [
                      const AppImageAsset(image: "assets/facebook.svg"),
                      const SizedBox(width: 30),
                      Text(
                        "Join us on Facebook",
                        style: GoogleFonts.archivo(
                          fontStyle: FontStyle.normal,
                          color: Colors.white,
                          fontSize: 13,
                          fontWeight: FontWeight.w400,
                        ),
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
