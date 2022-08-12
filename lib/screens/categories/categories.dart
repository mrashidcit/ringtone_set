import 'package:deeze_app/widgets/app_image_assets.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_typeahead/flutter_typeahead.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';
import 'package:http/http.dart' as http;
import '../../bloc/deeze_bloc/Category_bloc/category_bloc.dart';
import '../../models/deeze_model.dart' as deeze;
import '../../models/categories.dart';
import '../../services/search_services.dart';
import '../../uitilities/end_points.dart';
import '../../widgets/ringtone_category_card.dart';
import '../../widgets/wallpaper_category_card.dart';
import '../../widgets/widgets.dart';
import '../dashboard/dashboard.dart';
import '../search/search_screen.dart';
import '../wallpapers/wallpapers.dart';

class Categories extends StatefulWidget {
  final bool isRingtone;
  const Categories({Key? key, required this.isRingtone}) : super(key: key);

  @override
  State<Categories> createState() => _CategoriesState();
}

class _CategoriesState extends State<Categories> {
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
  }

  final SearchServices _searchServices = SearchServices();
  final TextEditingController _typeAheadController = TextEditingController();
  bool ishow = false;
  int page = 1;
  late int totalPage;
  final RefreshController _refreshController =
      RefreshController(initialRefresh: true);

  List<HydraMember> hydraMember = [];
  Future<bool> fetchCategories({bool isRefresh = false}) async {
    if (isRefresh) {
      page = 1;
    } else {
      if (page >= totalPage) {
        _refreshController.loadNoData();
        return false;
      }
    }

    var url = getCategoriesUrl;

    Uri uri = Uri.parse(url).replace(queryParameters: {
      "page": "$page",
      "itemsPerPage": "20",
    });
    try {
      http.Response response = await http.get(
        uri,
        headers: {
          'Content-Type': 'application/json',
        },
      );
      print('${response.statusCode} : ${response.request}');

      if (response.statusCode == 200) {
        print(response.body);
        var rawResponse = categoriesFromJson(response.body);
        if (isRefresh) {
          hydraMember = rawResponse.hydraMember!;
        } else {
          hydraMember.addAll(rawResponse.hydraMember!);
        }

        page++;
        totalPage = rawResponse.hydraTotalItems!;
        setState(() {});
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
    return ishow
        ? Scaffold(
            appBar: PreferredSize(
              preferredSize: Size(0, 60),
              child: Padding(
                padding: const EdgeInsets.only(top: 8),
                child: AppBar(
                  automaticallyImplyLeading: false,
                  backgroundColor: const Color(0xFF4d047d),
                  elevation: 0,
                  centerTitle: true,
                  title: ishow
                      ? SizedBox(
                          height: 43,
                          width: MediaQuery.of(context).size.width,
                          child: TypeAheadFormField<deeze.HydraMember?>(
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
                                    onTap: () => setState(() => ishow = false),
                                    child: const AppImageAsset(
                                      image: 'assets/search.svg',
                                      color: Colors.black,
                                    ),
                                  ),
                                ),
                              ),
                              itemBuilder:
                                  (context, deeze.HydraMember? suggestion) {
                                final ringtone = suggestion!;
                                return GestureDetector(
                                  onTap: (() {
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (context) => SearchScreen(
                                          searchText: _typeAheadController.text,
                                        ),
                                      ),
                                    );
                                  }),
                                  child: Padding(
                                      padding: const EdgeInsets.only(
                                          left: 30, top: 10),
                                      child: Text(
                                        "${ringtone.name}",
                                        style: GoogleFonts.archivo(
                                          fontStyle: FontStyle.normal,
                                          color: Colors.black,
                                          fontSize: 18,
                                          fontWeight: FontWeight.w500,
                                        ),
                                      )),
                                );
                              },
                              onSuggestionSelected:
                                  (deeze.HydraMember? suggestion) {},
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
                          "Categories",
                          style: GoogleFonts.archivo(
                            fontStyle: FontStyle.normal,
                            color: Colors.white,
                            fontSize: 22,
                            fontWeight: FontWeight.w600,
                            wordSpacing: 0.34,
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
                padding: const EdgeInsets.only(left: 10, right: 10, top: 20),
                child: SmartRefresher(
                  enablePullUp: true,
                  controller: _refreshController,
                  onRefresh: () async {
                    final result = await fetchCategories(isRefresh: true);
                    if (result) {
                      _refreshController.refreshCompleted();
                    } else {
                      _refreshController.refreshFailed();
                    }
                  },
                  onLoading: () async {
                    final result = await fetchCategories();
                    if (result) {
                      _refreshController.loadComplete();
                    } else {
                      _refreshController.loadFailed();
                    }
                  },
                  child: GridView.builder(
                      itemCount: hydraMember.length,
                      gridDelegate:
                          const SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 2,
                        childAspectRatio: 3 / 1.5,
                        crossAxisSpacing: 10,
                        mainAxisSpacing: 14,
                      ),
                      itemBuilder: (context, index) {
                        return widget.isRingtone
                            ? RingtoneCategoryCard(
                                isAllCategory: true,
                                id: hydraMember[index].id!,
                                image: hydraMember[index].image!,
                                name: hydraMember[index].name,
                              )
                            : WallpaperCategoryCard(
                                isAllCategory: true,
                                id: hydraMember[index].id!,
                                image: hydraMember[index].image,
                                name: hydraMember[index].name,
                              );
                      }),
                ),
              ),
            ),
          )
        : Scaffold(
            appBar: PreferredSize(
              preferredSize: Size(0, 60),
              child: Padding(
                padding: const EdgeInsets.only(top: 8),
                child: AppBar(
                  backgroundColor: const Color(0xFF4d047d),
                  elevation: 0,
                  centerTitle: true,
                  leading: Builder(
                    builder: (ctx) {
                      return GestureDetector(
                        onTap: () => Scaffold.of(ctx).openDrawer(),
                        child: const AppImageAsset(image: 'assets/menu.svg'),
                      );
                    },
                  ),
                  title: ishow
                      ? SizedBox(
                          height: 43,
                          width: MediaQuery.of(context).size.width,
                          child: TypeAheadField<deeze.HydraMember?>(
                              suggestionsBoxDecoration:
                                  const SuggestionsBoxDecoration(
                                      color: Color(0xFF4d047d)),
                              suggestionsCallback:
                                  _searchServices.searchRingtone,
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
                                  fillColor: const Color(0xFF5d318c),
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
                                    onTap: (() {
                                      setState(() {
                                        ishow = false;
                                      });
                                    }),
                                    child: const Icon(
                                      Icons.search,
                                      color: Colors.white,
                                    ),
                                  ),
                                ),
                              ),
                              itemBuilder:
                                  (context, deeze.HydraMember? suggestion) {
                                final ringtone = suggestion!;
                                return Padding(
                                  padding: const EdgeInsets.only(bottom: 20),
                                  child: Container(
                                      height: 65,
                                      width: screenWidth,
                                      decoration: BoxDecoration(
                                        gradient: const LinearGradient(
                                            begin: Alignment.centerLeft,
                                            end: Alignment.centerRight,
                                            colors: [
                                              Color(0xFF279A88),
                                              Color(0xFF737B64),
                                              Color(0xFF4F4C7E),
                                              Color(0xFF4F4C7E),
                                            ]),
                                        borderRadius: BorderRadius.circular(10),
                                      ),
                                      child: Padding(
                                        padding: const EdgeInsets.symmetric(
                                            horizontal: 20),
                                        child: Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.spaceBetween,
                                          children: [
                                            Row(
                                              children: [
                                                Container(
                                                  height: 35,
                                                  width: 35,
                                                  alignment: Alignment.center,
                                                  decoration:
                                                      const BoxDecoration(
                                                          shape:
                                                              BoxShape.circle,
                                                          color: Color(
                                                              0xFF798975)),
                                                  child: const Icon(
                                                    Icons.play_arrow_sharp,
                                                    color: Colors.white,
                                                  ),
                                                ),
                                                const SizedBox(
                                                  width: 15,
                                                ),
                                                Text(
                                                  ringtone.name!,
                                                  style: GoogleFonts.archivo(
                                                    fontStyle: FontStyle.normal,
                                                    color: Colors.white,
                                                    fontSize: 18,
                                                  ),
                                                ),
                                              ],
                                            ),
                                            Column(
                                              children: [
                                                const AppImageAsset(image: 'assets/favourite_fill.svg', height: 30),
                                                Row(
                                                  children: const [
                                                    Icon(
                                                      Icons.arrow_downward,
                                                      color: Colors.white,
                                                      size: 15,
                                                    ),
                                                    Text(
                                                      "23k",
                                                      style: TextStyle(
                                                        fontSize: 15,
                                                        color: Colors.white,
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                              ],
                                            )
                                          ],
                                        ),
                                      )),
                                );
                              },
                              onSuggestionSelected:
                                  (deeze.HydraMember? suggestion) {},
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
                          "Categories",
                          style: GoogleFonts.archivo(
                            fontStyle: FontStyle.normal,
                            color: Colors.white,
                            fontSize: 22,
                            fontWeight: FontWeight.w600,
                            wordSpacing: 0.34,
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
                padding: const EdgeInsets.only(left: 10, right: 10, top: 20),
                child: SmartRefresher(
                  enablePullUp: true,
                  controller: _refreshController,
                  onRefresh: () async {
                    final result = await fetchCategories(isRefresh: true);
                    if (result) {
                      _refreshController.refreshCompleted();
                    } else {
                      _refreshController.refreshFailed();
                    }
                  },
                  onLoading: () async {
                    final result = await fetchCategories();
                    if (result) {
                      _refreshController.loadComplete();
                    } else {
                      _refreshController.loadFailed();
                    }
                  },
                  child: GridView.builder(
                      itemCount: hydraMember.length,
                      gridDelegate:
                          const SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 2,
                        childAspectRatio: 3 / 1.5,
                        crossAxisSpacing: 10,
                        mainAxisSpacing: 14,
                      ),
                      itemBuilder: (context, index) {
                        return widget.isRingtone
                            ? RingtoneCategoryCard(
                                isAllCategory: true,
                                id: hydraMember[index].id!,
                                image: hydraMember[index].image!,
                                name: hydraMember[index].name,
                              )
                            : WallpaperCategoryCard(
                                isAllCategory: true,
                                id: hydraMember[index].id!,
                                image: hydraMember[index].image,
                                name: hydraMember[index].name,
                              );
                      }),
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
                            const AppImageAsset(image: 'assets/notification.svg'),
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
          );
  }
}
