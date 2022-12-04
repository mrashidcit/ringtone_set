import 'package:cached_network_image/cached_network_image.dart';
import 'package:deeze_app/models/search_model.dart';
import 'package:deeze_app/screens/tags/tags.dart';
import 'package:deeze_app/uitilities/constants.dart';
import 'package:deeze_app/widgets/app_image_assets.dart';
import 'package:deeze_app/widgets/app_loader.dart';
import 'package:deeze_app/widgets/single_wallpaper.dart';
import 'package:deeze_app/widgets/wallpaper_category_card.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
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

import '../favourite/favourite_screen.dart';
import '../search/search_screen.dart';

class WallPapers extends StatefulWidget {
  final String type;
  const WallPapers({Key? key, required this.type}) : super(key: key);

  @override
  State<WallPapers> createState() => _WallPapersState();
}

class _WallPapersState extends State<WallPapers> {
  void initState() {
    // TODO: implement initState
    super.initState();
    // context.read<WallpaperBloc>().add(LoadWallpapers());
    context.read<CategoryBloc>().add(LoadCategory());
    scrollController.addListener(() {
      if (scrollController.position.pixels ==
          scrollController.position.maxScrollExtent) {
        setState(() {
          isDataLoad = true;
        });
      }
    });
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
  final RefreshController _refreshController =
      RefreshController(initialRefresh: true);
  ScrollController scrollController = ScrollController();
  bool isDataLoad = false;

  List<DeezeItemModel> hydraMember = [];
  Future<bool> fetchWallpapers({bool isRefresh = false}) async {
    if (isRefresh) {
      page = 1;
    } else {
      if (totalPage == 0) {
        _refreshController.loadNoData();
        return false;
      }
    }

    var url = getDeezeAppHpUrlContent;

    Uri uri = Uri.parse(url).replace(queryParameters: {
      "page": "$page",
      "itemsPerPage": "10",
      // "enabled": "true",
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
          if (isDataLoad && totalPage == 0) {
            showMessage(context, message: 'No data available!');
          }
          isDataLoad = false;
        });
        return true;
      } else {
        return false;
      }
    } catch (ex, stack) {
      print('>> $ex , $stack');
      return false;
    }
  }

  Future<bool> _onWillPop() async {
    ishow
        ? setState(() => ishow = false)
        : await showDialog(
            context: context,
            builder: (context) => AlertDialog(
              title: const Text('Are you sure?'),
              content: const Text('Do you want to exit an App'),
              actions: <Widget>[
                TextButton(
                  onPressed: () => Navigator.of(context).pop(false),
                  child: const Text('No'),
                ),
                TextButton(
                  onPressed: () => SystemNavigator.pop(),
                  child: const Text('Yes'),
                ),
              ],
            ),
          );
    return false;
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
            onWillPop: _onWillPop,
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
                  footer: CustomFooter(
                      builder: (context, mode) => isDataLoad && totalPage != 0
                          ? const LoadingPage()
                          : const SizedBox()),
                  child: SafeArea(
                    child: Stack(
                      children: [
                        CustomScrollView(
                          controller: scrollController,
                          slivers: [
                            const SliverToBoxAdapter(
                              child: SizedBox(height: 70),
                            ),
                            SliverPadding(
                              padding:
                                  const EdgeInsets.symmetric(horizontal: 17),
                              sliver: SliverToBoxAdapter(
                                child: Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
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
                                child:
                                    BlocConsumer<CategoryBloc, CategoryState>(
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
                                        padding:
                                            const EdgeInsets.only(left: 17),
                                        child: ListView.builder(
                                          scrollDirection: Axis.horizontal,
                                          itemCount: 4,
                                          itemBuilder: (context, index) {
                                            return Padding(
                                              padding: const EdgeInsets.only(
                                                  right: 12),
                                              child: WallpaperCategoryCard(
                                                id: state
                                                    .categories![index].id!,
                                                image: state
                                                    .categories![index].image,
                                                name: state
                                                    .categories![index].name,
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
                              padding:
                                  const EdgeInsets.symmetric(horizontal: 17),
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
                            const SliverToBoxAdapter(
                                child: SizedBox(height: 15)),
                            SliverPadding(
                              padding:
                                  const EdgeInsets.symmetric(horizontal: 8.0),
                              sliver: SliverGrid(
                                gridDelegate:
                                    const SliverGridDelegateWithFixedCrossAxisCount(
                                  crossAxisCount: 3,
                                  mainAxisSpacing: 5.0,
                                  crossAxisSpacing: 5.0,
                                  childAspectRatio: 3 / 6,
                                ),
                                delegate: SliverChildBuilderDelegate(
                                  (BuildContext context, int index) {
                                    return CategoryCard(
                                      id: hydraMember[index].id.toString(),
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
                                margin:
                                    const EdgeInsets.symmetric(horizontal: 16),
                                height: 46,
                                width: MediaQuery.of(context).size.width,
                                child: TextFormField(
                                  controller: _typeAheadController,
                                  onChanged: (data) => setState(() {}),
                                  onFieldSubmitted: (val) {
                                    FocusScope.of(context).unfocus();
                                    if (_typeAheadController.text.isNotEmpty) {
                                      Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                            builder: (context) => SearchScreen(
                                                  searchText:
                                                      _typeAheadController.text,
                                                  itemType: Constants
                                                      .ItemType_Ringtones,
                                                )),
                                      );
                                    }
                                    _typeAheadController.clear();
                                    ishow = false;
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
                                      borderRadius: BorderRadius.only(
                                          topRight: Radius.circular(7),
                                          topLeft: Radius.circular(7)),
                                      borderSide: BorderSide(
                                          color: Color(0xFF5d318c), width: 0),
                                    ),
                                    enabledBorder: const OutlineInputBorder(
                                      borderRadius: BorderRadius.only(
                                          topRight: Radius.circular(7),
                                          topLeft: Radius.circular(7)),
                                      borderSide: BorderSide(
                                          color: Color(0xFF5d318c), width: 0.0),
                                    ),
                                    suffixIcon: GestureDetector(
                                      onTap: () {
                                        FocusScope.of(context).unfocus();
                                        if (_typeAheadController.text.isEmpty) {
                                          ishow = false;
                                        } else {
                                          _typeAheadController.clear();
                                          Navigator.push(
                                            context,
                                            MaterialPageRoute(
                                                builder: (context) =>
                                                    SearchScreen(
                                                      searchText:
                                                          _typeAheadController
                                                              .text,
                                                      itemType: Constants
                                                          .ItemType_Ringtones,
                                                    )),
                                          );
                                          ishow = false;
                                        }
                                        _typeAheadController.clear();
                                        setState(() {});
                                      },
                                      child: const Padding(
                                        padding: EdgeInsets.symmetric(
                                            horizontal: 12),
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
                                  future: _searchServices
                                      .search(_typeAheadController.text.trim()),
                                  builder: (BuildContext context,
                                      AsyncSnapshot<List<SearchModel>>
                                          snapshot) {
                                    if (snapshot.hasError) {
                                      return Container(
                                          color: Colors.white,
                                          alignment: Alignment.centerLeft,
                                          margin: const EdgeInsets.symmetric(
                                              horizontal: 16),
                                          padding: const EdgeInsets.symmetric(
                                                  vertical: 10)
                                              .copyWith(left: 30),
                                          child: const Text(
                                            "Something went wrong",
                                            style: TextStyle(
                                                color: Color(0xFF5d318c)),
                                          ));
                                    }
                                    if (snapshot.connectionState ==
                                        ConnectionState.done) {
                                      return Container(
                                        color: Colors.white,
                                        margin: const EdgeInsets.symmetric(
                                            horizontal: 16),
                                        child: ListView.builder(
                                          shrinkWrap: true,
                                          itemCount: snapshot.data!.length > 4
                                              ? 4
                                              : snapshot.data!.length,
                                          itemBuilder: (context, index) =>
                                              GestureDetector(
                                            onTap: (() {
                                              FocusScope.of(context).unfocus();
                                              _typeAheadController.clear();
                                              Navigator.push(
                                                context,
                                                MaterialPageRoute(
                                                    builder: (context) =>
                                                        SearchScreen(
                                                          searchText: snapshot
                                                              .data![index]
                                                              .name!,
                                                          itemType: Constants
                                                              .ItemType_Ringtones,
                                                        )),
                                              );
                                              ishow = false;
                                            }),
                                            child: Padding(
                                                padding: const EdgeInsets.only(
                                                    left: 30,
                                                    top: 10,
                                                    bottom: 10),
                                                child: Text(
                                                  "${snapshot.data![index].name}",
                                                  style: GoogleFonts.archivo(
                                                    fontStyle: FontStyle.normal,
                                                    color:
                                                        const Color(0xFF5d318c),
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
                                margin:
                                    const EdgeInsets.symmetric(horizontal: 16),
                                padding:
                                    const EdgeInsets.all(30).copyWith(top: 10),
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
          )
        : WillPopScope(
            onWillPop: _onWillPop,
            child: Scaffold(
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
                                    onTap: () => setState(() => ishow = false),
                                    child: const Padding(
                                      padding: const EdgeInsets.symmetric(
                                          horizontal: 12),
                                      child: AppImageAsset(
                                        image: 'assets/search.svg',
                                        color: Colors.black,
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                              itemBuilder: (context, SearchModel? suggestion) {
                                final wallpapers = suggestion!;
                                return GestureDetector(
                                    onTap: (() {
                                      Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                          builder: (context) => SingleWallpaper(
                                            index: 0,
                                            urlImage: wallpapers.file!,
                                            userName:
                                                wallpapers.user!.firstName!,
                                            userProfileUrl:
                                                wallpapers.user!.image,
                                          ),
                                        ),
                                      );
                                    }),
                                    child: wallpapers.file == null
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
                                                  wallpapers.name!,
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
                                                imageUrl: wallpapers.file!,
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
                          "Wallpapers",
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
                  footer: CustomFooter(
                      builder: (context, mode) => isDataLoad && totalPage != 0
                          ? const LoadingPage()
                          : const SizedBox()),
                  child: isLoading
                      ? const LoadingPage()
                      : CustomScrollView(
                          controller: scrollController,
                          slivers: [
                            const SliverToBoxAdapter(
                              child: SizedBox(
                                height: 20,
                              ),
                            ),
                            SliverPadding(
                              padding:
                                  const EdgeInsets.symmetric(horizontal: 17),
                              sliver: SliverToBoxAdapter(
                                child: Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
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
                                          const SizedBox(width: 10),
                                          const AppImageAsset(
                                              image: 'assets/backward.svg',
                                              height: 10)
                                        ],
                                      ),
                                    )
                                  ],
                                ),
                              ),
                            ),
                            const SliverToBoxAdapter(
                                child: SizedBox(height: 20)),
                            SliverToBoxAdapter(
                              child: SizedBox(
                                height: 60,
                                width: screenWidth,
                                child:
                                    BlocConsumer<CategoryBloc, CategoryState>(
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
                                        padding:
                                            const EdgeInsets.only(left: 17),
                                        child: ListView.builder(
                                          scrollDirection: Axis.horizontal,
                                          itemCount: 4,
                                          itemBuilder: (context, index) {
                                            return Padding(
                                              padding: const EdgeInsets.only(
                                                  right: 12),
                                              child: WallpaperCategoryCard(
                                                id: state
                                                    .categories![index].id!,
                                                image: state
                                                    .categories![index].image,
                                                name: state
                                                    .categories![index].name,
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
                                child: SizedBox(height: 20)),
                            SliverPadding(
                              padding:
                                  const EdgeInsets.symmetric(horizontal: 17),
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
                                child: SizedBox(height: 15)),
                            SliverToBoxAdapter(
                              child: SizedBox(
                                height: 33,
                                width: screenWidth,
                                child: const Tags(),
                              ),
                            ),
                            const SliverToBoxAdapter(
                                child: SizedBox(height: 15)),
                            SliverPadding(
                              padding:
                                  const EdgeInsets.symmetric(horizontal: 8.0),
                              sliver: SliverGrid(
                                gridDelegate:
                                    const SliverGridDelegateWithFixedCrossAxisCount(
                                  crossAxisCount: 3,
                                  mainAxisSpacing: 5.0,
                                  crossAxisSpacing: 5.0,
                                  childAspectRatio: 3 / 6,
                                ),
                                delegate: SliverChildBuilderDelegate(
                                  (BuildContext context, int index) {
                                    return CategoryCard(
                                      id: hydraMember[index].id.toString(),
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
                        const MyDrawerHeader(),
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
                                const AppImageAsset(
                                    image: 'assets/ringtone.svg'),
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
                            // Navigator.push(
                            //   context,
                            //   MaterialPageRoute(
                            //     builder: (context) => const WallPapers(
                            //       type: "WALLPAPER",
                            //     ),
                            //   ),
                            // );
                          },
                          child: Padding(
                            padding: const EdgeInsets.only(left: 40),
                            child: Row(
                              children: [
                                const AppImageAsset(
                                    image: "assets/wallpaper.svg"),
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
                                const AppImageAsset(
                                    image: 'assets/favourite_fill.svg',
                                    color: Colors.grey),
                                const SizedBox(
                                  width: 29,
                                ),
                                Text(
                                  "Favourite",
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
                                color: Colors.grey,
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
                                color: Colors.grey,
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
                              const Icon(
                                Icons.privacy_tip,
                                color: Colors.grey,
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
                              const AppImageAsset(
                                image: "assets/facebook.svg",
                                color: Colors.grey,
                              ),
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
