import 'dart:async';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:modal_bottom_sheet/modal_bottom_sheet.dart';
import 'package:works_app/components/colors.dart';
import 'package:works_app/components/size_config.dart';
import 'package:works_app/global_helper/ImagePickerComponent.dart';
import 'package:works_app/global_helper/reuse_widget.dart';
import 'package:works_app/models/chat/chart_search_list.dart';
import 'package:works_app/ui/chat/search_chat_list/chart_filter.dart';
import 'package:works_app/ui/chat/search_chat_list/chat_search_list.dart';
import 'package:works_app/ui/chat/search_chat_list/groups_search_list.dart';
import 'package:works_app/ui/friends/component.dart';
import 'package:works_app/ui/friends/friends_details.dart';

import '../../bloc/chart/chart_bloc.dart';
import '../../bloc/friends/friends_bloc.dart';
import '../../bloc/register_account/initial_register_bloc.dart';
import '../../bloc/report_post_bloc.dart';
import '../../bloc/show_interested/show_interested_bloc.dart';
import '../../global_helper/loading_placeholder/home_layout.dart';
import '../../models/friends/global_search_list_modal.dart';
import 'chat_view.dart';
import 'modal/filter_search_modal.dart';
import 'package:buttons_tabbar/buttons_tabbar.dart';

class AddFriendsScreen extends StatefulWidget {
  final String header;
  final VoidCallback refreshPageCallback;

  const AddFriendsScreen(
      {super.key, required this.header, required this.refreshPageCallback});

  @override
  State<AddFriendsScreen> createState() => _AddFriendsScreenState();
}

class _AddFriendsScreenState extends State<AddFriendsScreen> {
  late FriendsBloc friendsBloc;
  late ShowInterestedBloc showInterestedBloc;
  late ChartBloc chartBloc;
  final ScrollController _scrollController = ScrollController();
  final TextEditingController _searchController = TextEditingController();
  late List<SearchFriendLists> searchFriendLists;
  late List<ChartSearchList> chartSearchList = [];
  Timer? _debounce;
  String searchKeyword = "";
  bool isFetchingMore = false;
  int currentPage = 1;
  int pageSize = 10;
  int maxPageNumber = 1;
  int currentChartPage = 1;
  bool isFetchingChartMore = false;
  int maxChartPageNumber = 1;
  int chartPageSize = 10;
  bool filterVisible = true;
  String? selectedCity = '';
  String selectedGender = '';

  @override
  void initState() {
    super.initState();
    friendsBloc = BlocProvider.of<FriendsBloc>(context);
    showInterestedBloc = BlocProvider.of<ShowInterestedBloc>(context);
    chartBloc = BlocProvider.of<ChartBloc>(context);
    searchFriendLists = [];
    _scrollController.addListener(() {
      if (_scrollController.position.pixels ==
              _scrollController.position.maxScrollExtent &&
          !isFetchingMore &&
          currentPage < maxPageNumber) {
        _loadMoreData();
      }
    });
    _fetchData();
    _fetchChartData();
  }

  void _onSearchChanged(String keyword) {
    if (_debounce?.isActive ?? false) _debounce?.cancel();
    _debounce = Timer(const Duration(milliseconds: 500), () {
      setState(() {
        searchKeyword = keyword;
        currentPage = 1;
      });
      _fetchData();
      _fetchChartData();
    });
  }

  void _fetchData({bool isNewFetch = false}) {
    if (isNewFetch) {
      searchFriendLists.clear();
      currentPage = 1;
    }

    friendsBloc.add(FetchFriendsAddListEvent(
      page: currentPage,
      pageSize: pageSize,
      keyWord: searchKeyword,
      city: selectedCity,
      gender: selectedGender
    ));
  }

  void _fetchChartData({bool isNewFetch = false}) {
    if (isNewFetch) {
      chartSearchList.clear();
      currentChartPage = 1;
    }

    chartBloc.add(FetchChartSearchListEvent(
      page: currentChartPage,
      pageSize: chartPageSize,
      keyWord: searchKeyword,
    ));
  }

  void filterChartListData(
    String? city,
    String gender,
  ) {
    setState(() {
      currentPage = 1;
      isFetchingMore = false;
      friendsBloc.add(FetchFriendsAddListEvent(
        page: currentPage,
        pageSize: pageSize,
        keyWord: "",
        city: city ?? "",
        gender: gender ?? "",
      ));
    });
  }

  void _loadMoreData() {
    setState(() {
      isFetchingMore = true;
      currentPage++;
    });
    _fetchData();
  }

  @override
  void dispose() {
    _scrollController.dispose();
    _searchController.dispose();
    _debounce?.cancel();
    super.dispose();
  }

  void _refreshPageAfterEdit() {
    _fetchData();
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: true,
      onPopInvokedWithResult: (didPop, result) {
        if (didPop) {
          widget.refreshPageCallback();
        }
      },
      child: Scaffold(
        backgroundColor: COLORS.white,
        appBar: AppBar(
          toolbarHeight: 0,
          scrolledUnderElevation: 0,
          automaticallyImplyLeading: false,
          backgroundColor: COLORS.white,
        ),
        body: DefaultTabController(
          length: 2,
          child: SafeArea(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  padding: EdgeInsets.symmetric(
                    horizontal: SizeConfig.blockWidth * 4.5,
                    vertical: SizeConfig.blockHeight * 2,
                  ),
                  decoration: BoxDecoration(
                      border: Border(
                          bottom: BorderSide(
                              color: COLORS.neutralDarkTwo,
                              width: SizeConfig.blockWidth * 0.15))),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.start,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        child: TextField(
                          controller: _searchController,
                          style: TextStyle(
                            color: COLORS.neutralDarkOne,
                            fontSize: SizeConfig.blockWidth * 3.25,
                            fontWeight: FontWeight.w400,
                            fontFamily: "Poppins",
                          ),
                          cursorColor: COLORS.black,
                          decoration: InputDecoration(
                            fillColor: COLORS.neutralDarkTwo.withOpacity(0.6),
                            focusColor: COLORS.neutralDarkTwo.withOpacity(0.6),
                            filled: true,
                            hintText: 'Ex: Search'.tr(),
                            hintStyle: TextStyle(
                              color: COLORS.neutralDarkOne,
                              fontSize: SizeConfig.blockWidth * 3.25,
                              fontWeight: FontWeight.w400,
                              fontFamily: "Poppins",
                            ),
                            prefixIcon: Padding(
                              padding:
                                  EdgeInsets.all(SizeConfig.blockWidth * 4),
                              child: Image.asset(
                                'assets/images/home/search.png',
                                width: SizeConfig.blockWidth * 3.5,
                                height: SizeConfig.blockWidth * 3.5,
                                fit: BoxFit.cover,
                              ),
                            ),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(
                                  SizeConfig.blockWidth * 3.25),
                              borderSide: BorderSide(
                                  color: COLORS.neutralDarkTwo.withOpacity(0.6),
                                  width: SizeConfig.blockWidth * 0.1),
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(
                                  SizeConfig.blockWidth * 3.25),
                              borderSide: BorderSide(
                                  color: COLORS.neutralDarkTwo.withOpacity(0.6),
                                  width: SizeConfig.blockWidth * 0.1),
                            ),
                            enabledBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(
                                  SizeConfig.blockWidth * 3.25),
                              borderSide: BorderSide(
                                  color: COLORS.neutralDarkTwo.withOpacity(0.6),
                                  width: SizeConfig.blockWidth * 0.1),
                            ),
                          ),
                          onChanged: _onSearchChanged,
                        ),
                      ),
                      if (filterVisible) ...[
                        SizedBox(width: SizeConfig.blockWidth * 3),
                        InkWell(
                          onTap: () async {
                            final result = await showMaterialModalBottomSheet(
                                enableDrag: true,
                                expand: false,
                                isDismissible: true,
                                backgroundColor: COLORS.white,
                                closeProgressThreshold: 0,
                                duration: const Duration(seconds: 0),
                                context: context,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.vertical(
                                      top: Radius.circular(
                                          SizeConfig.blockWidth * 6)),
                                ),
                                builder: (context) => MultiBlocProvider(
                                      providers: [
                                        BlocProvider(
                                          create: (context) {
                                            final bloc = InitialRegisterBloc();
                                            bloc.add(const FetchCityEvent());
                                            bloc.add(
                                                const FetchChargeFeesEvent());
                                            bloc.add(
                                                const FetchWorkKnownLanguageProfileEvent());
                                            return bloc;
                                          },
                                        ),
                                      ],
                                      child: ChartSearchFilterBottomSheet(
                                        initialCity: selectedCity,
                                        initialGender: selectedGender,
                                      ),
                                    ));

                            if (result != null) {
                              selectedCity = result['selectedCity'];
                              selectedGender = result['selectedGender'];
                              filterChartListData(
                                selectedCity,
                                selectedGender,
                              );
                            }
                          },
                          borderRadius: BorderRadius.circular(
                              SizeConfig.blockWidth * 2.5),
                          child: Container(
                            padding:
                                EdgeInsets.all(SizeConfig.blockWidth * 3.5),
                            height: SizeConfig.blockHeight * 7,
                            width: SizeConfig.blockHeight * 7,
                            decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(
                                    SizeConfig.blockWidth * 2.5),
                                color: COLORS.neutralDarkTwo.withOpacity(0.6)),
                            child: Image.asset(
                              'assets/images/home/filter.png',
                              width: SizeConfig.blockWidth * 5.5,
                              height: SizeConfig.blockWidth * 5.5,
                              fit: BoxFit.contain,
                            ),
                          ),
                        )
                      ],
                    ],
                  ),
                ),
                Container(
                  color: COLORS.primaryOne.withOpacity(0.1),
                  width: SizeConfig.blockWidth * 100,
                  padding: EdgeInsets.symmetric(
                    horizontal: SizeConfig.blockWidth * 4.5,
                    vertical: SizeConfig.blockHeight,
                  ),
                  child: ButtonsTabBar(
                    backgroundColor: COLORS.primary,
                    unselectedBackgroundColor: COLORS.neutralDarkTwo,
                    unselectedLabelStyle: TextStyle(
                      color: COLORS.neutralDark,
                      fontSize: SizeConfig.blockWidth * 3.8,
                      fontWeight: FontWeight.w500,
                      fontFamily: "Poppins",
                    ),
                    labelStyle: TextStyle(
                      color: COLORS.white,
                      fontSize: SizeConfig.blockWidth * 3.8,
                      fontWeight: FontWeight.w500,
                      fontFamily: "Poppins",
                    ),
                    contentPadding: EdgeInsets.symmetric(
                        horizontal: SizeConfig.blockWidth * 3),
                    radius: SizeConfig.blockWidth * 2.25,
                    contentCenter: true,
                    buttonMargin: EdgeInsets.only(right: SizeConfig.blockWidth*4),
                    height: SizeConfig.blockHeight*5.5,
                    onTap: (value) {
                      FocusScope.of(context).unfocus();
                      setState(() {
                        if (value == 1) {
                          filterVisible = false;
                        } else {
                          filterVisible = true;
                        }
                      });
                    },

                    tabs: const [
                      Tab(
                        text: 'People',
                      ),
                      Tab(text: 'Groups'),
                    ],
                  ),
                ),
                Expanded(
                  child: TabBarView(
                    children: [
                      ChartFriendsScreen(
                        refreshPageCallback: widget.refreshPageCallback,
                        searchText: searchKeyword,
                          city: selectedCity!,
                          gender: selectedGender,
                      ),

                      GroupChartFriendsScreen(
                          refreshPageCallback: widget.refreshPageCallback,
                          searchText: searchKeyword)
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
