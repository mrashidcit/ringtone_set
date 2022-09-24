import 'package:cached_network_image/cached_network_image.dart';
import 'package:deeze_app/bloc/deeze_bloc/wallpaper_bloc/wallpaper_bloc.dart';
import 'package:deeze_app/models/search_model.dart';
import 'package:deeze_app/screens/tags/tags.dart';
import 'package:deeze_app/screens/wallpapers/wallpapers.dart';
import 'package:deeze_app/widgets/app_image_assets.dart';
import 'package:deeze_app/widgets/app_loader.dart';
import 'package:deeze_app/widgets/single_wallpaper.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_typeahead/flutter_typeahead.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';

import '../../bloc/deeze_bloc/Category_bloc/category_bloc.dart';
import '../../models/deeze_model.dart';
import '../../services/search_services.dart';
import '../../uitilities/end_points.dart';
import '../../widgets/widgets.dart';
import '../categories/categories.dart';
import '../dashboard/dashboard.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

import '../search/search_screen.dart';

class WallpaperByCategory extends StatefulWidget {
  final String type;
  final int id;
  const WallpaperByCategory({Key? key, required this.type, required this.id})
      : super(key: key);

  @override
  State<WallpaperByCategory> createState() => _WallpaperByCategoryState();
}

class _WallpaperByCategoryState extends State<WallpaperByCategory> {
  void initState() {
    // TODO: implement initState
    super.initState();
    scrollController.addListener(() {
      if (scrollController.position.pixels == scrollController.position.maxScrollExtent) {
        setState(() {
          isDataLoad = true;
        });
      }
    });
    // context.read<WallpaperBloc>().add(LoadWallpaperByCategory());

    // WidgetsBinding.instance.addPostFrameCallback((timeStamp) => loadData());
  }

  // Future loadData() async {}

  @override
  void dispose() {
    // TODO: implement dispose
    super.dispose();
    // context.read<DeezeBloc>().close();
  }

  int page = 1;
  int? totalPage;
  bool isDataLoad = false;
  ScrollController scrollController = ScrollController();

  final RefreshController _refreshController =
      RefreshController(initialRefresh: true);

  List<DeezeItemModel> hydraMember = [];
  Future<bool> fetchWallpaperByCategory({bool isRefresh = false}) async {
    if (isRefresh) {
      page = 1;
    } else {
      if (totalPage == 0) {
        _refreshController.loadNoData();
        return false;
      }
    }

    var url = getDeezeAppUrlContent;

    Uri uri = Uri.parse(url).replace(queryParameters: {
      "page": "$page",
      "itemsPerPage": "10",
      "enabled": "true",
      "categories.id": "${widget.id}",
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
        var rawResponse = deezeItemModelFromJson(response.body);
        if (isRefresh) {
          hydraMember = rawResponse;
        } else {
          hydraMember.addAll(rawResponse);
        }

        page++;
        totalPage = rawResponse.length;
        setState(() {
          isLoading = false;
          if(isDataLoad && totalPage == 0){
            showMessage(context, message: 'No data available!');
          }
          isDataLoad = false;
        });
        return true;
      } else {
        return false;
      }
    } catch (e) {
      return false;
    }
  }

  final SearchServices _searchServices = SearchServices();
  final TextEditingController _typeAheadController = TextEditingController();
  bool ishow = false;
  bool isLoading = false;
  @override
  Widget build(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;
    return ishow
        ? WillPopScope(
           onWillPop: ()async{
           setState(() {
            ishow = false;
           });
           return ishow;
         },
          child: Scaffold(
              appBar: PreferredSize(
                preferredSize: Size(0, 60),
                child: AppBar(
                  automaticallyImplyLeading: false,
                  backgroundColor: const Color(0xFF4d047d),
                  elevation: 0,
                  centerTitle: true,
                  title: ishow
                      ? SizedBox(
                          height: 43,
                          width: MediaQuery.of(context).size.width,
                          child: TypeAheadFormField<SearchModel?>(
                              suggestionsBoxVerticalOffset: 0,
                              suggestionsBoxDecoration:
                                  const SuggestionsBoxDecoration(
                                      color: Colors.white),
                              suggestionsCallback: _searchServices.search,
                              debounceDuration:
                                  const Duration(milliseconds: 500),
                              // hideSuggestionsOnKeyboardHide: false,
                              textFieldConfiguration: TextFieldConfiguration(
                                controller: _typeAheadController,
                                onSubmitted: (val){
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
                                  ishow = false;
                                },
                                decoration: InputDecoration(
                                  hintText: "",
                                  hintStyle: const TextStyle(
                                    color: Color(0xFF5d318c),
                                    fontSize: 12,
                                  ),
                                  fillColor: Colors.white,
                                  filled: true,
                                  contentPadding: const EdgeInsets.symmetric(
                                    vertical: 5,
                                    horizontal: 20,
                                  ),
                                  focusedBorder: const OutlineInputBorder(
                                    borderRadius: BorderRadius.only(
                                        topLeft: Radius.circular(7),
                                        topRight: Radius.circular(7)),
                                    borderSide: BorderSide(
                                        color: Color(0xFF5d318c), width: 0),
                                  ),
                                  enabledBorder: const OutlineInputBorder(
                                    borderRadius:
                                        BorderRadius.all(Radius.circular(7)),
                                    borderSide: BorderSide(
                                        color: Color(0xFF5d318c), width: 0.0),
                                  ),
                                  suffixIcon: GestureDetector(
                                    onTap: () {
                                      FocusScope.of(context).unfocus();

                                      if(_typeAheadController.text.isEmpty){
                                        ishow = false;
                                      }
                                      else{
                                        Navigator.push(
                                          context,
                                          MaterialPageRoute(
                                              builder: (context) => SearchScreen(
                                                searchText:
                                                _typeAheadController.text,
                                              )),
                                        );
                                        ishow = false;
                                      }
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
                              itemBuilder: (context, SearchModel? suggestion) {
                                final ringtone = suggestion!;
                                return GestureDetector(
                                  onTap: (() {
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                          builder: (context) => SearchScreen(
                                                searchText:
                                                    _typeAheadController.text,
                                              )),
                                    );
                                    ishow = false;
                                    _typeAheadController.clear();
                                  }),
                                  child: Padding(
                                      padding: const EdgeInsets.only(
                                          left: 30, top: 10),
                                      child: Text(
                                        "${ringtone.name}",
                                        style: GoogleFonts.archivo(
                                          fontStyle: FontStyle.normal,
                                          color: Color(0xFF5d318c),
                                          fontSize: 18,
                                          fontWeight: FontWeight.w500,
                                        ),
                                      )),
                                );
                              },
                              onSuggestionSelected:
                                  (SearchModel? suggestion) {},
                              noItemsFoundBuilder: (context) => Center(
                                    child: Text(
                                      "No Found",
                                      style: GoogleFonts.archivo(
                                        fontStyle: FontStyle.normal,
                                        color: Color(0xFF5d318c),
                                        fontSize: 18,
                                        fontWeight: FontWeight.w500,
                                      ),
                                    ),
                                  ),
                              errorBuilder: (BuildContext context, error) {
                                return Center(
                                  child: Text(
                                    "Please enter ",
                                    style: GoogleFonts.archivo(
                                      fontStyle: FontStyle.normal,
                                      color: Color(0xFF5d318c),
                                      fontSize: 18,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                );
                              }),
                        )
                      : Text(
                          widget.type,
                          style: GoogleFonts.archivo(
                            fontStyle: FontStyle.normal,
                            color: Colors.white,
                            fontSize: 18,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                  actions: [
                    ishow
                        ? const SizedBox.shrink()
                        : GestureDetector(
                            onTap: () => setState(() => ishow = true),
                            child: const Padding(
                              padding: EdgeInsets.symmetric(horizontal: 15),
                              child: AppImageAsset(image: 'assets/search.svg'),
                            ),
                          ),
                  ],
                ),
              ),
              backgroundColor: const Color(0xFF4d047d),
              body: Container(
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
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 17),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const SizedBox(
                          height: 20,
                        ),
                        Expanded(
                          child: Padding(
                            padding: const EdgeInsets.only(bottom: 5),
                            child: SmartRefresher(
                              enablePullUp: true,
                              controller: _refreshController,
                              onRefresh: () async {
                                final result = await fetchWallpaperByCategory(
                                    isRefresh: true);
                                if (result) {
                                  _refreshController.refreshCompleted();
                                } else {
                                  _refreshController.refreshFailed();
                                }
                              },
                              onLoading: () async {
                                final result = await fetchWallpaperByCategory();
                                if (result) {
                                  _refreshController.loadComplete();
                                } else {
                                  _refreshController.loadFailed();
                                }
                              },
                              header: CustomHeader(builder: (context, mode) => Container()),
                              footer: CustomFooter(builder: (context, mode) => isDataLoad && totalPage != 0 ?  const LoadingPage() :  const SizedBox() ),
                              child: isLoading
                                  ? const LoadingPage()
                                  : GridView.builder(
                                  itemCount: hydraMember.length,
                                  controller: scrollController,
                                  gridDelegate:
                                  const SliverGridDelegateWithFixedCrossAxisCount(
                                      crossAxisCount: 3,
                                      childAspectRatio: 3 / 6,
                                      crossAxisSpacing: 5,
                                      mainAxisSpacing: 5),
                                  itemBuilder: (context, index) {
                                    return CategoryCard(
                                      index: index,
                                      listHydra: hydraMember,
                                      image: hydraMember[index].file!,
                                      name: hydraMember[index].name!,
                                    );
                                  }),
                            ),
                          ),
                        ),
                      ],
                    ),
                  )),
            ),
        )
        : WillPopScope(
          onWillPop: ()async{
            return true;
          },
          child: Scaffold(
              appBar: PreferredSize(
                preferredSize: Size(0, 60),
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
                  title: ishow
                      ? SizedBox(
                          height: 43,
                          width: MediaQuery.of(context).size.width,
                          child: TypeAheadField<SearchModel?>(
                              suggestionsBoxDecoration:
                                  const SuggestionsBoxDecoration(
                                      color: Color(0xFF4d047d)),
                              suggestionsCallback:
                                  _searchServices.searchWallpapers,
                              debounceDuration:
                                  const Duration(milliseconds: 500),
                              // hideSuggestionsOnKeyboardHide: false,
                              textFieldConfiguration: TextFieldConfiguration(
                                decoration: InputDecoration(
                                  hintText: "",
                                  hintStyle: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 12,
                                  ),
                                  fillColor: Color(0xFF5d318c),
                                  filled: true,
                                  contentPadding: const EdgeInsets.symmetric(
                                    vertical: 5,
                                    horizontal: 20,
                                  ),
                                  focusedBorder: const OutlineInputBorder(
                                    borderRadius:
                                        BorderRadius.all(Radius.circular(7)),
                                    borderSide: BorderSide(
                                        color: Color(0xFF5d318c), width: 0),
                                  ),
                                  enabledBorder: const OutlineInputBorder(
                                    borderRadius:
                                        BorderRadius.all(Radius.circular(7)),
                                    borderSide: BorderSide(
                                        color: Color(0xFF5d318c), width: 0.0),
                                  ),
                                  suffixIcon: GestureDetector(
                                    onTap: () => setState(() => ishow = false),
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
                              itemBuilder: (context, SearchModel? suggestion) {
                                final WallpaperByCategory = suggestion!;
                                return GestureDetector(
                                    onTap: (() {
                                      Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                          builder: (context) => SingleWallpaper(
                                            index: 0,
                                            urlImage: WallpaperByCategory.file!,
                                            userName: WallpaperByCategory
                                                .user!.firstName!,
                                            userProfileUrl:
                                                WallpaperByCategory.user!.image,
                                          ),
                                        ),
                                      );
                                    }),
                                    child: WallpaperByCategory.file == null
                                        ? Container(
                                            width: screenWidth * 0.4,
                                            decoration: BoxDecoration(
                                              image: const DecorationImage(
                                                  image: AssetImage(
                                                    "assets/no_image.jpg",
                                                  ),
                                                  fit: BoxFit.fill),
                                              borderRadius:
                                                  BorderRadius.circular(10),
                                            ),
                                            child: Align(
                                              alignment: Alignment.bottomLeft,
                                              child: Padding(
                                                padding:
                                                    const EdgeInsets.symmetric(
                                                        horizontal: 10,
                                                        vertical: 10),
                                                child: Text(
                                                  WallpaperByCategory.name!,
                                                  style: const TextStyle(
                                                    fontSize: 20,
                                                  ),
                                                ),
                                              ),
                                            ),
                                          )
                                        : SizedBox(
                                            width: screenWidth * 0.4,
                                            child: ClipRRect(
                                              borderRadius:
                                                  BorderRadius.circular(10),
                                              child: CachedNetworkImage(
                                                fit: BoxFit.cover,
                                                imageUrl:
                                                    WallpaperByCategory.file!,
                                                errorWidget:
                                                    (context, url, error) =>
                                                        const Icon(Icons.error),
                                              ),
                                            ),
                                          ));
                              },
                              onSuggestionSelected:
                                  (SearchModel? suggestion) {},
                              noItemsFoundBuilder: (context) => const Center(
                                    child: Text(
                                      "No Found",
                                      style: TextStyle(
                                        fontSize: 18,
                                        fontFamily: 'Poppins-Regular',
                                      ),
                                    ),
                                  ),
                              errorBuilder: (BuildContext context, error) {
                                return const Center(
                                  child: Text(
                                    "Please enter ",
                                    style: TextStyle(
                                      fontSize: 18,
                                      fontFamily: 'Poppins-Regular',
                                    ),
                                  ),
                                );
                              }),
                        )
                      : Text(
                          widget.type,
                          style: GoogleFonts.archivo(
                            fontStyle: FontStyle.normal,
                            color: Colors.white,
                            fontSize: 18,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                  actions: [
                    ishow
                        ? const SizedBox.shrink()
                        : GestureDetector(
                            onTap: () => setState(() => ishow = true),
                            child: const Padding(
                              padding: EdgeInsets.symmetric(horizontal: 15),
                              child: AppImageAsset(image: 'assets/search.svg'),
                            ),
                          ),
                  ],
                ),
              ),
              backgroundColor: const Color(0xFF4d047d),
              body: Container(
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
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 17),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const SizedBox(
                          height: 20,
                        ),
                        Expanded(
                          child: Padding(
                            padding: const EdgeInsets.only(bottom: 5),
                            child: SmartRefresher(
                              enablePullUp: true,
                              controller: _refreshController,
                              onRefresh: () async {
                                final result = await fetchWallpaperByCategory(
                                    isRefresh: true);
                                if (result) {
                                  _refreshController.refreshCompleted();
                                } else {
                                  _refreshController.refreshFailed();
                                }
                              },
                              onLoading: () async {
                                final result = await fetchWallpaperByCategory();
                                if (result) {
                                  _refreshController.loadComplete();
                                } else {
                                  _refreshController.loadFailed();
                                }
                              },
                              header: CustomHeader(builder: (context, mode) => Container()),
                              footer: CustomFooter(builder: (context, mode) => isDataLoad && totalPage != 0 ?  const LoadingPage() :  const SizedBox() ),
                              child: isLoading
                                  ? const LoadingPage()
                                  : GridView.builder(
                                  itemCount: hydraMember.length,
                                  controller: scrollController,
                                  gridDelegate:
                                      const SliverGridDelegateWithFixedCrossAxisCount(
                                          crossAxisCount: 3,
                                          childAspectRatio: 3 / 6,
                                          crossAxisSpacing: 5,
                                          mainAxisSpacing: 5),
                                  itemBuilder: (context, index) {
                                    return CategoryCard(
                                      index: index,
                                      listHydra: hydraMember,
                                      image: hydraMember[index].file!,
                                      name: hydraMember[index].name!,
                                    );
                                  }),
                            ),
                          ),
                        ),
                      ],
                    ),
                  )),
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
                        MyDrawerHeader(),
                        const SizedBox(
                          height: 40,
                        ),
                        InkWell(
                          onTap: () async {
                            Navigator.of(context).pop();
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => const Dashbaord(
                                  type: "RINGTONE",
                                ),
                              ),
                            );
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
                                    fontWeight: FontWeight.w700,
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
                                    fontWeight: FontWeight.w700,
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
                              const AppImageAsset(image: 'assets/bell.svg'),
                              const SizedBox(width: 20),
                              Padding(
                                padding: const EdgeInsets.all(8.0),
                                child: Text(
                                  "Notifications",
                                  style: GoogleFonts.archivo(
                                    fontStyle: FontStyle.normal,
                                    color: Colors.white,
                                    fontSize: 18,
                                    fontWeight: FontWeight.w700,
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
                        Padding(
                          padding: const EdgeInsets.only(left: 40),
                          child: Row(
                            children: [
                              const AppImageAsset(image: 'assets/favourite_fill.svg', color: Colors.white),
                              const SizedBox(
                                width: 29,
                              ),
                              Text(
                                "Saved",
                                style: GoogleFonts.archivo(
                                  fontStyle: FontStyle.normal,
                                  color: Colors.white,
                                  fontSize: 18,
                                  fontWeight: FontWeight.w700,
                                  wordSpacing: -0.09,
                                ),
                              ),
                            ],
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
                              Icon(
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
                              Icon(
                                Icons.settings,
                                color: Colors.white,
                                size: 20,
                              ),
                              const SizedBox(
                                width: 30,
                              ),
                              Text(
                                "Settings",
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
                              Icon(
                                Icons.privacy_tip,
                                color: Colors.white,
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
                                    color: Colors.white,
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
            ),
        );
  }
}
