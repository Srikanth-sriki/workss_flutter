import 'dart:io' as io;

import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:modal_bottom_sheet/modal_bottom_sheet.dart';
import 'package:socket_io_client/socket_io_client.dart';
import 'package:works_app/bloc/professional/professional_bloc.dart';
import 'package:works_app/bloc/show_interested/show_interested_bloc.dart';
import 'package:works_app/components/config.dart';
import 'package:works_app/models/professionals_list_model.dart';
import 'package:works_app/ui/home/component.dart';
import 'package:works_app/ui/onboarding/language_selection.dart';
import 'package:works_app/ui/professional/categories.dart';
import 'package:works_app/ui/professional/professional_search.dart';
import 'package:works_app/ui/professional/professional_view.dart';
import '../../bloc/chart/chart_bloc.dart';
import '../../bloc/friends/friends_bloc.dart';
import '../../bloc/notification/notification_bloc.dart';
import '../../bloc/register_account/initial_register_bloc.dart';
import '../../bloc/report_post_bloc.dart';
import '../../components/colors.dart';
import '../../components/size_config.dart';
import '../../global_helper/helper_function.dart';
import '../../global_helper/loading_placeholder/home_layout.dart';
import '../../global_helper/reuse_widget.dart';
import '../../helper/socket_service.dart';
import '../../models/category_list_modal.dart';
import '../../models/friends/global_search_list_modal.dart';
import '../chat/addFriends.dart';
import '../chat/chat_view.dart';
import '../friends/friends_details.dart';
import '../home/filter.dart';
import '../home/notification_list.dart';
import '../onboarding/register_form.dart';
import 'categories_item.dart';
import 'package:socket_io_client/socket_io_client.dart' as io;

class ProfessionalsScreen extends StatefulWidget {
  const ProfessionalsScreen({super.key});

  @override
  State<ProfessionalsScreen> createState() => _ProfessionalsScreenState();
}

class _ProfessionalsScreenState extends State<ProfessionalsScreen> {
  late ProfessionalBloc professionalBloc;
  late ShowInterestedBloc showInterestedBloc;
  late FriendsBloc friendsBloc;
  late ChartBloc chartBloc;
  List<ProfessionalsPostedWork> professionalsPostedWork = [];
  late List<SearchFriendLists> searchFriendLists = [];
  final ScrollController _scrollController = ScrollController();
  bool isFetchingMore = false;
  bool isProfessionalLoad = true;
  bool isCategoryLoad = true;
  int currentPage = 1;
  int pageSize = 10;
  int maxPageNumber = 1;
  String? selectedProfession = '';
  String? selectedCity = '';
  String selectedGender = '';
  late List<CategorySub> categoriesData = [];
  List<String> selectedLanguage = [];
  late io.Socket socket;
  bool _isMounted = false;

  @override
  void initState() {
    super.initState();
    professionalBloc = BlocProvider.of<ProfessionalBloc>(context);
    showInterestedBloc = BlocProvider.of<ShowInterestedBloc>(context);
    friendsBloc = BlocProvider.of<FriendsBloc>(context);
    chartBloc = BlocProvider.of<ChartBloc>(context);
    _fetchData();
    _fetchFriendList();
    _scrollController.addListener(() {
      if (_scrollController.position.atEdge && !isFetchingMore) {
        final isBottom = _scrollController.position.pixels ==
            _scrollController.position.maxScrollExtent;
        if (isBottom && currentPage < maxPageNumber) {
          _loadMoreData();
        }
      }
    });
    socket = io.io(Config.socketUrl, <String, dynamic>{
      'transports': ['websocket'],
      'autoConnect': true,
    });

    if (!socket.connected) {
      SocketService().reconnect();
    }
    connectToSocket();
  }

  void connectToSocket() {
    socket.on('new_notification', (data) {
      if (_isMounted) {
        setState(() {
          Config.notificationReceiveMessage.value = true;

          print(data);
        });
      }
    });
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _fetchData();
  }

  void _fetchData({bool isNewFetch = false}) {
    if (isNewFetch) {
      professionalsPostedWork.clear();
      currentPage = 1;
    }
    professionalBloc.add(ProfessionalListEvent(
        page: currentPage,
        pageSize: pageSize,
        keyWord: "",
        profession: "",
        city: "",
        gender: "",
        currentLongitude: '',knownLanguages: [],
        currentLatitude: ''));
    professionalBloc.add(const FetchCategoryListEvent());
  }

  void _fetchFriendList() {
    friendsBloc.add(
      FetchFriendsAddListEvent(page: 1, pageSize: 10, keyWord: ''),
    );
  }

  void _loadMoreData() {
    if (!isFetchingMore && currentPage < maxPageNumber) {
      setState(() {
        isFetchingMore = true;
      });
      currentPage++;
      _fetchData();
    }
  }

  void filterProfessionalScreenData(
      String? profession, String? city, String gender,List<String>selectedLanguages) {
    setState(() {
      currentPage = 1;
      isFetchingMore = false;
      professionalBloc.add(ProfessionalListEvent(
          page: currentPage,
          pageSize: pageSize,
          keyWord: "",
          profession: profession ?? "",
          city: city ?? "",
          gender: gender ?? "",
          currentLongitude: '', knownLanguages: selectedLanguages,
          currentLatitude: ''));
    });
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: COLORS.white,
      appBar: AppBar(
        toolbarHeight: 0,
        backgroundColor: COLORS.white,
        scrolledUnderElevation: 0,
        elevation: 0,
        automaticallyImplyLeading: false,
      ),
      body: MultiBlocListener(
        listeners: [
          BlocListener<ProfessionalBloc, ProfessionalState>(
            listener: (context, state) {
              if (state is ProfessionalLoading && currentPage == 1) {
                isProfessionalLoad = true;
              } else if (state is FetchProfessionalListSuccess) {
                setState(() {
                  if (currentPage == 1) {
                    professionalsPostedWork = state.professionalsPostedWork;
                  } else {
                    // Filter out duplicates by checking ID before adding
                    final newItems = state.professionalsPostedWork.where(
                        (newItem) => !professionalsPostedWork.any(
                            (existingItem) => existingItem.id == newItem.id));
                    professionalsPostedWork.addAll(newItems);
                  }
                  maxPageNumber = state.maxPageNumber;
                  isFetchingMore = false;
                  isProfessionalLoad = false;
                });
              } else if (state is FetchProfessionalListFailed) {
                setState(() {
                  isFetchingMore = false;
                  isProfessionalLoad = false;
                });
              } else if (state is FetchCategoryListLoading) {
                setState(() {
                  isCategoryLoad = true;
                });
              } else if (state is FetchCategoryListSuccess) {
                setState(() {
                  categoriesData = state.categories;
                  isCategoryLoad = false;
                });
              } else if (state is FetchCategoryListFailed) {
                setState(() {
                  isCategoryLoad = false;
                });
              }
              setState(() {});
            },
          ),
          BlocListener<FriendsBloc, FriendsState>(
            listener: (context, state) {
              if (state is FriendsAddListSuccess) {
                setState(() {
                  searchFriendLists = state.searchFriendLists
                      .where((friend) => friend.isFriend == null)
                      .toList();
                  ;
                });
              }
            },
          ),
        ],
        child: SafeArea(
          child: RefreshIndicator(
            onRefresh: () async {
              _fetchData(isNewFetch: true); // your existing method

            },
            child: Container(
              width: SizeConfig.screenWidth,
              padding: EdgeInsets.only(top: SizeConfig.blockHeight * 2),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Padding(
                    padding: EdgeInsets.symmetric(
                      horizontal: SizeConfig.blockWidth * 5,
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Text(
                          '.Workss',
                          style: TextStyle(
                            color: COLORS.primary,
                            fontSize: SizeConfig.blockWidth * 6,
                            fontWeight: FontWeight.bold,
                            fontFamily: "Poppins",
                          ),
                        ),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            InkWell(
                              onTap: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                      builder: (BuildContext context) =>
                                          const LanguageSelectionScreen(
                                            routeType: 'homo',
                                          )),
                                );
                              },
                              borderRadius: BorderRadius.circular(
                                  SizeConfig.blockWidth * 2.5),
                              child: Container(
                                padding:
                                    EdgeInsets.all(SizeConfig.blockWidth * 3),
                                decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(
                                        SizeConfig.blockWidth * 2.5),
                                    color: COLORS.primaryOne.withOpacity(0.3)),
                                child: Image.asset(
                                  'assets/images/home/translation.png',
                                  width: SizeConfig.blockWidth * 5.5,
                                  height: SizeConfig.blockWidth * 5.5,
                                  fit: BoxFit.contain,
                                ),
                              ),
                            ),
                            SizedBox(
                              width: SizeConfig.blockWidth * 2.8,
                            ),
                            InkWell(
                              onTap: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => MultiBlocProvider(
                                      providers: [
                                        BlocProvider(
                                          create: (context) => NotificationBloc()
                                            ..add(const FetchNotificationList()),
                                        ),
                                        BlocProvider(
                                          create: (context) => ShowInterestedBloc(),
                                        ),
                                        BlocProvider(
                                          create: (context) => ChartBloc(),
                                        ),
                                        BlocProvider(
                                          create: (context) => FriendsBloc()
                                            ..add(
                                              FetchFriendsRequestListEvent(
                                                page: 1,
                                                pageSize: 10,
                                                keyWord: '',
                                              ),
                                            ),
                                        ),
                                      ],
                                      child: const NotificationListScreen(),
                                    ),
                                  ),
                                );
                              },
                              borderRadius:
                              BorderRadius.circular(SizeConfig.blockWidth * 2.5),
                              child: Container(
                                padding: EdgeInsets.all(SizeConfig.blockWidth * 3),
                                decoration: BoxDecoration(
                                  borderRadius:
                                  BorderRadius.circular(SizeConfig.blockWidth * 2.5),
                                  color: COLORS.primaryOne.withOpacity(0.3),
                                ),
                                child: Stack(
                                  children: [
                                    Image.asset(
                                      'assets/images/home/notification.png',
                                      width: SizeConfig.blockWidth * 5.5,
                                      height: SizeConfig.blockWidth * 5.5,
                                      fit: BoxFit.contain,
                                    ),
                                    ValueListenableBuilder<bool>(
                                      valueListenable: Config.notificationReceiveMessage,
                                      builder: (context, hasNewMessage, _) {
                                        return hasNewMessage
                                            ? Positioned(
                                          top: 0,
                                          right: 0,
                                          child: Container(
                                            width: SizeConfig.blockWidth * 3,
                                            height: SizeConfig.blockWidth * 3,
                                            decoration: const BoxDecoration(
                                              color: Colors.red,
                                              shape: BoxShape.circle,
                                            ),
                                          ),
                                        )
                                            : const SizedBox
                                            .shrink(); // Return empty widget if false
                                      },
                                    ),
                                  ],
                                ),
                              ),
                            )
                          ],
                        )
                      ],
                    ),
                  ),
                  SizedBox(
                    height: SizeConfig.blockHeight * 3.5,
                  ),
                  Padding(
                    padding: EdgeInsets.symmetric(
                      horizontal: SizeConfig.blockWidth * 5,
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        InkWell(
                          onTap: () {
                            Navigator.push(
                                context,
                                MaterialPageRoute(
                                    builder: (context) => MultiBlocProvider(
                                          providers: [
                                            BlocProvider(
                                                create: (context) =>
                                                    ProfessionalBloc()
                                                      ..add(ProfessionalListEvent(
                                                          page: 1,
                                                          pageSize: 20,
                                                          profession: '',
                                                          keyWord: '',
                                                          city: '',
                                                          currentLongitude: '',
                                                          currentLatitude: '',knownLanguages: [],
                                                          gender: ''))),
                                            BlocProvider(
                                              create: (context) =>
                                                  ShowInterestedBloc(),
                                            ),
                                            BlocProvider(create: (context) => ChartBloc())
                                          ],
                                          child: const ProfessionalSearchList(),
                                        )));
                          },
                          borderRadius:
                              BorderRadius.circular(SizeConfig.blockWidth * 3.25),
                          child: Container(
                            width: SizeConfig.blockWidth * 72,
                            height: SizeConfig.blockHeight * 8,
                            decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(
                                    SizeConfig.blockWidth * 3.25),
                                color: COLORS.neutralDarkTwo.withOpacity(0.6)),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.start,
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: [
                                Padding(
                                  padding: EdgeInsets.symmetric(
                                      horizontal: SizeConfig.blockWidth * 4),
                                  child: Image.asset(
                                    'assets/images/home/search.png',
                                    width: SizeConfig.blockWidth * 5.5,
                                    height: SizeConfig.blockWidth * 5.5,
                                    fit: BoxFit.contain,
                                  ),
                                ),
                                SizedBox(
                                  width: SizeConfig.blockWidth * 50,
                                  child: Text(
                                    'Search by Profession type'.tr(),
                                    style: TextStyle(
                                      color: COLORS.neutralDarkOne,
                                      fontSize: SizeConfig.blockWidth * 3.3,
                                      fontWeight: FontWeight.w400,
                                      fontFamily: "Poppins",
                                    ),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
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
                                        BlocProvider(
                                            create: (context) => ProfessionalBloc()
                                              ..add(
                                                  const FetchCategoryListEvent())),
                                      ],
                                      child: SearchFilterBottomSheet(
                                        initialProfession: selectedProfession,
                                        initialCity: selectedCity,
                                        initialGender: selectedGender,
                                        selectedLanguage: selectedLanguage,
                                        experienceLevelVisible: false,
                                        selectedLanguageVisible: true,
                                      ),
                                    ));

                            if (result != null) {
                              selectedProfession = result['selectedProfession'];
                              selectedCity = result['selectedCity'];
                              selectedGender = result['selectedGender'];
                              selectedLanguage = List<String>.from(result['selectedLanguage'] ?? []);
                              filterProfessionalScreenData(
                                selectedProfession,
                                selectedCity,
                                selectedGender, selectedLanguage
                              );
                            }
                          },
                          borderRadius:
                              BorderRadius.circular(SizeConfig.blockWidth * 2.5),
                          splashColor: COLORS.white.withOpacity(0.2),
                          child: Container(
                            padding: EdgeInsets.all(SizeConfig.blockWidth * 4),
                            height: SizeConfig.blockHeight * 8,
                            width: SizeConfig.blockHeight * 8,
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
                        ),
                      ],
                    ),
                  ),
                  Padding(
                    padding: EdgeInsets.symmetric(
                        vertical: SizeConfig.blockHeight * 1.5),
                    child: Divider(
                      height: SizeConfig.blockHeight,
                      color: COLORS.neutralDarkTwo,
                    ),
                  ),
                  Expanded(
                    child: SingleChildScrollView(
                      physics: const AlwaysScrollableScrollPhysics(),
                      controller: _scrollController,
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.start,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Padding(
                            padding: EdgeInsets.symmetric(
                              horizontal: SizeConfig.blockWidth * 5,
                            ),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: [
                                Text(
                                  'Categories'.tr(),
                                  style: TextStyle(
                                    color: COLORS.neutralDark,
                                    fontSize: SizeConfig.blockWidth * 3.8,
                                    fontWeight: FontWeight.w400,
                                    fontFamily: "Poppins",
                                  ),
                                ),
                                InkWell(
                                  onTap: () {
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                          builder: (BuildContext context) =>
                                              CategoriesScreen(
                                                  categoriesData:
                                                      categoriesData)),
                                    );
                                  },
                                  child: Text(
                                    'See All'.tr(),
                                    style: TextStyle(
                                      color: COLORS.accent,
                                      fontSize: SizeConfig.blockWidth * 3.6,
                                      fontWeight: FontWeight.w400,
                                      fontFamily: "Poppins",
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          if (isCategoryLoad) ...[
                            Padding(
                              padding: EdgeInsets.only(
                                  left: SizeConfig.blockWidth * 6,
                                  right: SizeConfig.blockWidth * 6,
                                  top: SizeConfig.blockHeight * 3),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                crossAxisAlignment: CrossAxisAlignment.center,
                                children: [
                                  categoryLoading(),
                                  categoryLoading(),
                                  categoryLoading(),
                                  categoryLoading()
                                ],
                              ),
                            ),
                          ],
                          if (!isCategoryLoad) ...[
                            SizedBox(
                              height: SizeConfig.blockHeight * 20.5,
                              child: ListView.builder(
                                  itemCount: categoriesData.length,
                                  shrinkWrap: true,
                                  scrollDirection: Axis.horizontal,
                                  padding: EdgeInsets.symmetric(
                                      horizontal: SizeConfig.blockWidth * 5,
                                      vertical: SizeConfig.blockHeight * 0.5),
                                  itemBuilder: (context, index) {
                                    return InkWell(
                                      splashColor: Colors.white.withOpacity(0),
                                      borderRadius: BorderRadius.circular(
                                          SizeConfig.blockWidth * 4),
                                      onTap: () {
                                        Navigator.push(
                                          context,
                                          MaterialPageRoute(
                                              builder: (BuildContext context) =>
                                                  CategoriesItemScreen(
                                                      categoriesItem:
                                                          categoriesData[index])),
                                        );
                                      },
                                      child: Container(
                                        padding: EdgeInsets.symmetric(
                                            horizontal: SizeConfig.blockWidth * 3,
                                            vertical: SizeConfig.blockHeight),
                                        child: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.center,
                                          mainAxisAlignment:
                                              MainAxisAlignment.start,
                                          children: [
                                            Container(
                                              width: SizeConfig.blockWidth * 19,
                                              height: SizeConfig.blockWidth * 19,
                                              decoration: BoxDecoration(
                                                shape: BoxShape.circle,
                                                color: COLORS.primaryOne
                                                    .withOpacity(0.3),
                                                image: DecorationImage(image: NetworkImage(
                                                  categoriesData[index]
                                                      .image,
                                                  scale: SizeConfig.blockWidth*1

                                                ))
                                              ),
                                              // child: Center(
                                              //   child: AspectRatio(
                                              //     aspectRatio: 1 / 1.25,
                                              //     child: categoriesData[index]
                                              //             .image
                                              //             .isNotEmpty
                                              //         ? Image.network(
                                              //             categoriesData[index]
                                              //                 .image,
                                              //             fit: BoxFit.contain,
                                              //           )
                                              //         : null,
                                              //   ),
                                              // ),
                                            ),
                                            SizedBox(
                                              height:
                                                  SizeConfig.blockHeight * 0.5,
                                            ),
                                            SizedBox(
                                              width: SizeConfig.blockWidth * 19,
                                              child: Text(
                                                capitalizeEachWord(
                                                    categoriesData[index].name),
                                                style: TextStyle(
                                                  color: COLORS.neutralDark,
                                                  fontSize:
                                                      SizeConfig.blockWidth * 3,
                                                  fontWeight: FontWeight.w500,
                                                  fontFamily: "Poppins",
                                                  overflow: TextOverflow.ellipsis,
                                                ),
                                                maxLines: 2,
                                                textAlign: TextAlign.center,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    );
                                  }),
                            )
                          ],
                          Padding(
                            padding: EdgeInsets.symmetric(
                              horizontal: SizeConfig.blockWidth * 5,
                            ),
                            child: Text(
                              'Professionals'.tr(),
                              style: TextStyle(
                                color: COLORS.neutralDarkOne,
                                fontSize: SizeConfig.blockWidth * 3.8,
                                fontWeight: FontWeight.w400,
                                fontFamily: "Poppins",
                              ),
                              textAlign: TextAlign.end,
                            ),
                          ),
                          SizedBox(
                            height: SizeConfig.blockHeight * 0.5,
                          ),
                          if (isProfessionalLoad == true) ...[
                            professionalLoading(),
                            professionalLoading(),
                            professionalLoading(),
                          ] else ...[
                            professionalsPostedWork.isNotEmpty
                                ? ListView.builder(
                                    shrinkWrap: true,
                                    physics: NeverScrollableScrollPhysics(),
                                    itemCount: professionalsPostedWork.length!,
                                    itemBuilder: (context, index) {
                                      var professionalData =
                                          professionalsPostedWork![index];
                                      return Container(
                                        padding: EdgeInsets.symmetric(
                                            vertical: SizeConfig.blockWidth * 2,
                                            horizontal:
                                                SizeConfig.blockWidth * 4),
                                        child: Column(
                                          mainAxisAlignment:
                                              MainAxisAlignment.center,
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            if ((index == 3 ||
                                                    index == 15 ||
                                                    index == 30 ||
                                                    index == 50) &&
                                                searchFriendLists.isNotEmpty &&
                                                Config.profileCompleted) ...[
                                              SizedBox(
                                                  height: SizeConfig.blockHeight),
                                              addFriendText(
                                                  textOne: 'Add Friends',
                                                  textTwo: 'View All',
                                                  onTap: () {
                                                    Navigator.push(
                                                        context,
                                                        MaterialPageRoute(
                                                            builder: (context) =>
                                                                MultiBlocProvider(
                                                                  providers: [
                                                                    BlocProvider(
                                                                      create: (context) => FriendsBloc()
                                                                        ..add(FetchFriendsAddListEvent(
                                                                            page:
                                                                                1,
                                                                            pageSize:
                                                                                10,
                                                                            keyWord:
                                                                                '')),
                                                                    ),
                                                                    BlocProvider(
                                                                        create: (context) =>
                                                                            ShowInterestedBloc()),
                                                                    BlocProvider(
                                                                        create: (context) =>
                                                                            ChartBloc() ..add(FetchChartSearchListEvent(page: 1, pageSize: 10, keyWord: '')))
                                                                  ],
                                                                  child:
                                                                      AddFriendsScreen(
                                                                    header:
                                                                        'Friend Suggestion',
                                                                    refreshPageCallback:
                                                                        _fetchFriendList,
                                                                  ),
                                                                )));
                                                  }),
                                              SizedBox(
                                                height:
                                                    SizeConfig.blockHeight * 26,
                                                child: ListView.builder(
                                                    itemCount: searchFriendLists
                                                                .length >=
                                                            6
                                                        ? 6
                                                        : searchFriendLists
                                                            .length,
                                                    shrinkWrap: true,
                                                    scrollDirection:
                                                        Axis.horizontal,
                                                    itemBuilder:
                                                        (context, index) {
                                                      return addFriendCard(
                                                          added: searchFriendLists[
                                                                          index]
                                                                      .friendRequestSent !=
                                                                  null
                                                              ? true
                                                              : false,
                                                          image:
                                                              searchFriendLists[
                                                                      index]
                                                                  .profilePic,
                                                          name: searchFriendLists[
                                                                  index]
                                                              .name,
                                                          onTap: () {
                                                            if (Config
                                                                .isRegistered) {
                                                              if (searchFriendLists[
                                                                          index]
                                                                      .friendRequestSent !=
                                                                  null) {
                                                                showInterestedBloc.add(
                                                                    UnSendFriendEvent(
                                                                        userId:
                                                                            searchFriendLists[index]
                                                                                .id,
                                                                        onSuccess:
                                                                            (message) {
                                                                          setState(
                                                                              () {
                                                                            searchFriendLists[index].friendRequestSent =
                                                                                null;
                                                                          });
                                                                        },
                                                                        onError:
                                                                            (message) {
                                                                          showCustomSnackBar(
                                                                            context:
                                                                                context,
                                                                            message:
                                                                                message,
                                                                          );
                                                                        }));
                                                              } else {
                                                                showInterestedBloc.add(
                                                                    AddFriendEvent(
                                                                        userId:
                                                                            searchFriendLists[index]
                                                                                .id,
                                                                        onSuccess:
                                                                            (message) {
                                                                          setState(
                                                                              () {
                                                                            searchFriendLists[index].friendRequestSent =
                                                                                FriendRequestSent(
                                                                              userId:
                                                                                  searchFriendLists[index].id,
                                                                            );
                                                                          });
                                                                        },
                                                                        onError:
                                                                            (message) {
                                                                          showCustomSnackBar(
                                                                            context:
                                                                                context,
                                                                            message:
                                                                                message,
                                                                          );
                                                                        }));
                                                              }
                                                            } else {
                                                              loginUserBottomSheet(
                                                                  context);
                                                            }
                                                          },
                                                          onTapCard: () {
                                                            if (Config
                                                                .isRegistered) {
                                                              Navigator.push(
                                                                  context,
                                                                  MaterialPageRoute(
                                                                      builder:
                                                                          (context) =>
                                                                              MultiBlocProvider(
                                                                                providers: [
                                                                                  BlocProvider(
                                                                                    create: (context) {
                                                                                      final bloc = FriendsBloc();
                                                                                      bloc.add(FetchFriendsSingleView(friendId: searchFriendLists[index].id));
                                                                                      return bloc;
                                                                                    },
                                                                                  ),
                                                                                  BlocProvider(
                                                                                    create: (context) => ShowInterestedBloc(),
                                                                                  ),
                                                                                  BlocProvider(create: (context) => ReportPostBloc()),
                                                                                  BlocProvider(create: (context) => ShowInterestedBloc()),
                                                                                  BlocProvider(create: (context) => ChartBloc())
                                                                                ],
                                                                                child: FriendsDetailsScreen(
                                                                                  refreshPageCallback: _fetchFriendList,
                                                                                  id: searchFriendLists[index].id,
                                                                                ),
                                                                              )));
                                                            } else {
                                                              loginUserBottomSheet(
                                                                  context);
                                                            }
                                                          });
                                                    }),
                                              ),
                                              SizedBox(
                                                  height:
                                                      SizeConfig.blockHeight ),
                                            ],
                                            buildProfessionalCard(
                                                accountVerified:
                                                    professionalData!.isVerified!,
                                                image:
                                                    professionalData!.profilePic!,
                                                name: professionalData!.name!,
                                                profession: professionalData
                                                    .professionType!,
                                                location: professionalData.city!,
                                                languages: professionalData
                                                    .knownLanguages!
                                                    .join(", "),
                                                gender: professionalData.gender!,
                                                price: professionalData.charges!,
                                                paymentType:
                                                    professionalData.chargeType!,
                                                smartControlEnable: isSmartControlEnabled(
                                                  professionalData.smartCallControl,
                                                  professionalData.smartCallSchedule,
                                                ),
                                                contacted: professionalData
                                                        .isContacted !=
                                                    null,
                                                saved: professionalData.isSaved !=
                                                    null,
                                                experience: professionalData
                                                    .experiencedYears!,
                                                experienceImage:
                                                    'assets/images/home/work_select.png',
                                                genderImage:
                                                    'assets/images/home/gender.png',
                                                jobTypeImage:
                                                    'assets/images/profile/prof.png',
                                                language: professionalData
                                                    .knownLanguages!
                                                    .join(", "),
                                                languageImage:
                                                    'assets/images/home/speak.png',
                                                onShowInterest: () {
                                                  if (Config.profileCompleted) {
                                                    if (professionalData
                                                            .isContacted ==
                                                        null) {
                                                      showInterestedBloc.add(
                                                          ProfessionalContactUs(
                                                        PropId:
                                                            professionalData.id!,
                                                        onSuccess: () {
                                                          setState(() {
                                                            professionalData
                                                                    .isContacted =
                                                                IsContacted(
                                                                    id: '');
                                                            makePhoneCall(
                                                                professionalData
                                                                    .mobile!);
                                                          });
                                                        },
                                                        onError: () {},
                                                      ));
                                                    } else {
                                                      makePhoneCall(
                                                          professionalData
                                                              .mobile!);
                                                    }
                                                  }
                                                  else {loginUserBottomSheet(context);}
                                                },
                                                messageOnTap: (){
                                                  chartBloc.add(
                                                    StartMessageEvent(
                                                      chatId: professionalData.id!,
                                                      onSuccess: (chatId) {
                                                        Navigator.push(
                                                          context,
                                                          MaterialPageRoute(
                                                            builder: (context) => MultiBlocProvider(
                                                              providers: [
                                                                BlocProvider(create: (context) => ChartBloc()..add(FetchChartViewEvent(page: 1, pageSize: 10, chatId: chatId))),
                                                                BlocProvider(create: (context) => InitialRegisterBloc()),
                                                                BlocProvider(create: (context) => ShowInterestedBloc()),
                                                              ],
                                                              child: ChatViewScreen(
                                                                refreshPageCallback: (){
                                                                  _fetchData(isNewFetch: true);
                                                                },
                                                                chatId: chatId,
                                                                isGroup: false,
                                                              ),
                                                            ),
                                                          ),
                                                        );
                                                      },
                                                      onError: (message) {
                                                        showCustomSnackBar(context: context, message: message, backgroundColor: COLORS.neutralDarkTwo);
                                                      },
                                                    ),
                                                  );
                                                },
                                                jobType: professionalData
                                                    .professionType!,
                                                onShare: () {
                                                  if (Config.profileCompleted){
                                                    shareJobDetails(
                                                      experience: professionalData
                                                          .experiencedYears!,
                                                      location:
                                                      professionalData.city!,
                                                      jobTitle: professionalData
                                                          .professionType!,
                                                    );
                                                  }
                                                  else {loginUserBottomSheet(context);}

                                                },
                                                onTap: () {
                                                  if (Config.profileCompleted){
                                                    Navigator.push(
                                                        context,
                                                        MaterialPageRoute(
                                                            builder: (context) =>
                                                                MultiBlocProvider(
                                                                  providers: [
                                                                    BlocProvider(
                                                                      create: (context) => ProfessionalBloc()
                                                                        ..add(FetchProfessionalView(
                                                                            professionalData
                                                                                .id!)),
                                                                    ),
                                                                    BlocProvider(
                                                                      create: (context) =>
                                                                          ShowInterestedBloc(),
                                                                    ),
                                                                    BlocProvider(
                                                                        create: (context) =>
                                                                            ReportPostBloc()),
                                                                    BlocProvider(create: (context) => ChartBloc())
                                                                  ],
                                                                  child:
                                                                  ProfessionalViewScreen(
                                                                    id: professionalData
                                                                        .id!,
                                                                    refreshPageCallback:
                                                                        () {
                                                                      _fetchData(
                                                                          isNewFetch:
                                                                          true);
                                                                    },
                                                                  ),
                                                                )));
                                                  }
                                                  else {loginUserBottomSheet(context);}

                                                },
                                                savedTap: () {
                if (Config.profileCompleted){
                  if (professionalData.isSaved ==
            null) {
                    showInterestedBloc
              .add(ProfessionalSavedUs(
            PropId:
            professionalData.id!,
            onSuccess: () {
              setState(() {
                professionalData
                    .isSaved =
                    IsContacted(id: '');
              });
            },
            onError: () {
              showCustomSnackBar(
                context: context,
                message:
                "Something Went wrong",
              );
            },
                    ));
                  } else {
                    showInterestedBloc
              .add(ProfessionalSavedUs(
            PropId:
            professionalData.id!,
            onSuccess: () {
              setState(() {
                professionalData
                    .isSaved = null;
              });
            },
            onError: () {
              showCustomSnackBar(
                context: context,
                message:
                "Something Went wrong",
              );
            },
                    ));
                  }
                }
                else {loginUserBottomSheet(context);}

                                                }),
                                          ],
                                        ),
                                      );
                                    })
                                : Padding(
                                    padding: EdgeInsets.only(
                                        top: SizeConfig.blockHeight * 6),
                                    child: emptyComponent(),
                                  )
                          ],
                        ],
                      ),
                    ),
                  )
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
