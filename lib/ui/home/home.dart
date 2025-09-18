import 'dart:io';

import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:modal_bottom_sheet/modal_bottom_sheet.dart';
import 'package:works_app/bloc/chart/chart_bloc.dart';
import 'package:works_app/bloc/home/home_bloc.dart';
import 'package:works_app/bloc/report_post_bloc.dart';
import 'package:works_app/components/config.dart';
import 'package:works_app/global_helper/loading_placeholder/home_layout.dart';
import 'package:works_app/global_helper/popup.dart';
import 'package:works_app/helper/socket_service.dart';
import 'package:works_app/ui/home/component.dart';
import 'package:works_app/ui/home/notification_list.dart';
import 'package:works_app/ui/home/work_details.dart';
import 'package:works_app/ui/home/work_search.dart';
import 'package:works_app/ui/onboarding/language_selection.dart';
import '../../bloc/friends/friends_bloc.dart';
import '../../bloc/notification/notification_bloc.dart';
import '../../bloc/post_work/post_work_bloc.dart';
import '../../bloc/professional/professional_bloc.dart';
import '../../bloc/profile/profile_bloc.dart';
import '../../bloc/register_account/initial_register_bloc.dart';
import '../../bloc/show_interested/show_interested_bloc.dart';
import '../../components/colors.dart';
import '../../components/size_config.dart';
import '../../global_helper/helper_function.dart';
import '../../global_helper/reuse_widget.dart';
import '../../models/friends/global_search_list_modal.dart';
import '../../models/home_fetch_model.dart';
import '../chat/addFriends.dart';
import '../friends/friends_details.dart';
import '../friends/friends_search.dart';
import '../onboarding/register_form.dart';
import '../post_work/post_work.dart';
import 'filter.dart';
import 'package:socket_io_client/socket_io_client.dart' as io;

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  late HomeBloc homeBloc;
  late ShowInterestedBloc showInterestedBloc;
  late FriendsBloc friendsBloc;
  late List<HomeFetchModel> homeFetchModel = [];
  late List<SearchFriendLists> searchFriendLists = [];
  final ScrollController _scrollController = ScrollController();
  bool isFetchingMore = false;
  int currentPage = 1;
  int pageSize = 10;
  int maxPageNumber = 1;
  String? selectedProfession = '';
  String? selectedCity = '';
  String selectedGender = '';
  String experienceLevel = '';
  List<String> selectedLanguage = [];
  late io.Socket socket;
  bool _isMounted = false;

  @override
  void initState() {
    super.initState();
    _isMounted = true;
    homeBloc = BlocProvider.of<HomeBloc>(context);
    showInterestedBloc = BlocProvider.of<ShowInterestedBloc>(context);
    friendsBloc = BlocProvider.of<FriendsBloc>(context);
    _fetchData();
    _fetchFriendList();
    _scrollController.addListener(() {
      if (_scrollController.position.pixels ==
              _scrollController.position.maxScrollExtent &&
          !isFetchingMore &&
          currentPage < maxPageNumber) {
        _loadMoreData();
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

  // void _fetchData() {
  //   homeBloc.add(FetchHomeScreenEvent(
  //       page: currentPage,
  //       pageSize: pageSize,
  //       keyWord: "",
  //       profession: "",
  //       city: "",
  //       gender: "",
  //       currentLongitude: '',
  //       currentLatitude: ''));
  // }
  void _fetchData({bool isNewFetch = false}) {
    if (isNewFetch) {
      homeFetchModel.clear();
      currentPage = 1;
    }

    homeBloc.add(FetchHomeScreenEvent(
        page: currentPage,
        pageSize: pageSize,
        keyWord: "",
        profession: selectedProfession ?? "",
        city: selectedCity ?? "",
        gender: selectedGender ?? "",
        knownLanguages: [],
        experienceLevel: experienceLevel ?? '',
        currentLongitude: '',
        currentLatitude: ''));
  }

  void _fetchFriendList() {
    friendsBloc.add(
      FetchFriendsAddListEvent(page: 1, pageSize: 10, keyWord: ''),
    );
  }

  // void _loadMoreData() {
  //   setState(() {
  //     isFetchingMore = true;
  //   });
  //   currentPage++;
  //   _fetchData();
  // }
  void _loadMoreData() {
    if (!isFetchingMore && currentPage < maxPageNumber) {
      setState(() {
        isFetchingMore = true;
      });
      currentPage++;
      _fetchData();
    }
  }

  void filterHomeScreenData(String? profession, String? city, String gender,
      String experienceLevel, List<String> selectedLanguages) {
    setState(() {
      currentPage = 1;
      isFetchingMore = false;
      homeBloc.add(FetchHomeScreenEvent(
          page: currentPage,
          pageSize: pageSize,
          keyWord: "",
          profession: profession ?? "",
          city: city ?? "",
          gender: gender ?? "",
          currentLongitude: '',
          currentLatitude: '',
          knownLanguages: selectedLanguages,
          experienceLevel: experienceLevel ?? ""));
    });
  }

  @override
  void dispose() {
    _isMounted = false;
    // socket.off('new_notification');
    // socket.disconnect();
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
      body: SafeArea(
        child: RefreshIndicator(
          onRefresh: () async {
            _fetchData(isNewFetch: true); // your existing method

          },
          child: Container(
            width: SizeConfig.screenWidth,
            padding: EdgeInsets.only(top: SizeConfig.blockHeight * 2),
            child: Stack(
              children: [
                Column(
                  children: [
                    _buildHeader(),
                    Expanded(
                      child: MultiBlocListener(
                        listeners: [
                          BlocListener<HomeBloc, HomeState>(
                            listener: (context, state) {
                              if (state is FetchHomeScreenSuccess) {
                                setState(() {
                                  if (currentPage == 1) {
                                    homeFetchModel = state.homeFetchModel;
                                  } else {
                                    final newItems = state.homeFetchModel.where(
                                        (item) => !homeFetchModel.contains(item));
                                    homeFetchModel.addAll(newItems);
                                  }
                                  maxPageNumber = state.maxPageNumber;
                                  isFetchingMore = false;
                                });

                                //context.read<FriendsBloc>().add(FetchFriendsListEvent(page: 1,pageSize: 10, keyWord: ''),);
                              } else if (state is FetchHomeScreenFailed) {
                                setState(() {
                                  isFetchingMore = false;
                                });
                              }
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
                        child: BlocConsumer<HomeBloc, HomeState>(
                          listener: (context, state) {
                            if (state is FetchHomeScreenSuccess) {
                              setState(() {
                                if (currentPage == 1) {
                                  homeFetchModel = state.homeFetchModel;
                                } else {
                                  final newItems = state.homeFetchModel.where(
                                      (item) => !homeFetchModel.contains(item));
                                  homeFetchModel.addAll(newItems);
                                }
                                maxPageNumber = state.maxPageNumber;
                                isFetchingMore = false;
                              });
                            } else if (state is FetchHomeScreenFailed) {
                              setState(() {
                                isFetchingMore = false;
                              });
                            }
                          },
                          builder: (context, state) {
                            if (state is HomeScreenLoading && currentPage == 1 ||
                                state is HomeInitial) {
                              return const ShimmerJobCards();
                            } else if (state is FetchHomeScreenSuccess) {
                              return _buildListView();
                            } else if (state is FetchHomeScreenFailed) {
                              return ErrorScreen(onRetry: () {
                                context.read<HomeBloc>().add(FetchHomeScreenEvent(
                                    page: currentPage,
                                    pageSize: pageSize,
                                    keyWord: "",
                                    profession: "",
                                    city: "",
                                    gender: "",
                                    currentLongitude: '',
                                    currentLatitude: '',
                                    knownLanguages: [],
                                    experienceLevel: ''));
                              });
                            }
                            return Container();
                          },
                        ),
                      ),
                    ),
                  ],
                ),
                // if (Config.profileCompleted) ...[
                //   Positioned(
                //     bottom: SizeConfig.blockHeight * 2.5,
                //     right: SizeConfig.blockHeight * 4,
                //     child: FloatingActionButton(
                //         onPressed: () {
                //           Navigator.push(
                //               context,
                //               MaterialPageRoute(
                //                   builder: (context) => MultiBlocProvider(
                //                         providers: [
                //                           BlocProvider(
                //                             create: (context) {
                //                               final bloc = PostWorkBloc();
                //                               bloc.add(
                //                                   const FetchWorkPlaceEvent());
                //                               bloc.add(
                //                                   const FetchWorkKnownLanguageEvent());
                //                               return bloc;
                //                             },
                //                           ),
                //                           BlocProvider(
                //                               create: (context) => ProfileBloc()),
                //                           BlocProvider(
                //                               create: (context) =>
                //                                   ProfessionalBloc()),
                //                         ],
                //                         child: const PostWorkScreen(
                //                           arrowBack: true,
                //                         ),
                //                       )));
                //         },
                //         backgroundColor: COLORS.primary,
                //         child: Icon(
                //           Icons.add,
                //           color: COLORS.white,
                //           size: SizeConfig.blockWidth * 6.5,
                //         )),
                //   )
                // ]
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildListView() {
    if (homeFetchModel.isEmpty) {
      return emptyComponent();
    }

    return ListView.builder(
      controller: _scrollController,
      itemCount: homeFetchModel.length + (isFetchingMore ? 1 : 0),
      shrinkWrap: true,
      itemBuilder: (context, index) {
        if (index < homeFetchModel.length) {
          final work = homeFetchModel[index];
          final languages = work.knowLanguage!
              .map((lang) => lang.tr())
              .join(", ");
          return Container(
            padding:
                EdgeInsets.symmetric(horizontal: SizeConfig.blockWidth * 4.5),
            margin: EdgeInsets.only(bottom: SizeConfig.blockHeight * 1.8),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (index == 0) ...[
                  Padding(
                    padding:
                        EdgeInsets.symmetric(vertical: SizeConfig.blockHeight),
                    child: Text(
                      'Works'.tr(),
                      style: TextStyle(
                        color: COLORS.neutralDarkOne,
                        fontSize: SizeConfig.blockWidth * 3.8,
                        fontWeight: FontWeight.w400,
                        fontFamily: "Poppins",
                      ),
                      textAlign: TextAlign.end,
                    ),
                  ),
                ],
                if ((index == 3 || index == 15 || index == 30 || index == 50) &&
                    searchFriendLists.isNotEmpty &&
                    Config.profileCompleted) ...[
                  SizedBox(height: SizeConfig.blockHeight),
                  addFriendText(
                      textOne: 'Add Friends',
                      textTwo: 'View All',
                      onTap: () {
                        Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (context) => MultiBlocProvider(
                                      providers: [
                                        BlocProvider(
                                          create: (context) => FriendsBloc()
                                            ..add(FetchFriendsAddListEvent(
                                                page: 1,
                                                pageSize: 10,
                                                keyWord: '')),
                                        ),
                                        BlocProvider(
                                            create: (context) =>
                                                ShowInterestedBloc()),
                                        BlocProvider(
                                            create: (context) => ChartBloc()
                                              ..add(FetchChartSearchListEvent(
                                                  page: 1,
                                                  pageSize: 10,
                                                  keyWord: '')))
                                      ],
                                      child: AddFriendsScreen(
                                        header: 'Friend Suggestion',
                                        refreshPageCallback: _fetchFriendList,
                                      ),
                                    )));
                      }),
                  SizedBox(
                    height: SizeConfig.blockHeight * 26,
                    child: ListView.builder(
                        itemCount: searchFriendLists.length >= 6
                            ? 6
                            : searchFriendLists.length,
                        shrinkWrap: true,
                        scrollDirection: Axis.horizontal,
                        itemBuilder: (context, index) {
                          return addFriendCard(
                              added:
                                  searchFriendLists[index].friendRequestSent !=
                                          null
                                      ? true
                                      : false,
                              image: searchFriendLists[index].profilePic,
                              name: searchFriendLists[index].name,
                              onTap: () {
                                if (searchFriendLists[index]
                                        .friendRequestSent !=
                                    null) {
                                  showInterestedBloc.add(UnSendFriendEvent(
                                      userId: searchFriendLists[index].id,
                                      onSuccess: (message) {
                                        setState(() {
                                          searchFriendLists[index]
                                              .friendRequestSent = null;
                                        });
                                      },
                                      onError: (message) {
                                        showCustomSnackBar(
                                          context: context,
                                          message: message,
                                        );
                                      }));
                                } else {
                                  showInterestedBloc.add(AddFriendEvent(
                                      userId: searchFriendLists[index].id,
                                      onSuccess: (message) {
                                        setState(() {
                                          searchFriendLists[index]
                                                  .friendRequestSent =
                                              FriendRequestSent(
                                            userId: searchFriendLists[index].id,
                                          );
                                        });
                                      },
                                      onError: (message) {
                                        showCustomSnackBar(
                                          context: context,
                                          message: message,
                                        );
                                      }));
                                }
                              },
                              onTapCard: () {
                                Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                        builder: (context) => MultiBlocProvider(
                                              providers: [
                                                BlocProvider(
                                                  create: (context) {
                                                    final bloc = FriendsBloc();
                                                    bloc.add(
                                                        FetchFriendsSingleView(
                                                            friendId:
                                                                searchFriendLists[
                                                                        index]
                                                                    .id));
                                                    return bloc;
                                                  },
                                                ),
                                                BlocProvider(
                                                  create: (context) =>
                                                      ShowInterestedBloc(),
                                                ),
                                                BlocProvider(
                                                    create: (context) =>
                                                        ReportPostBloc()),
                                                BlocProvider(
                                                    create: (context) =>
                                                        ShowInterestedBloc()),
                                                BlocProvider(
                                                    create: (context) =>
                                                        ChartBloc())
                                              ],
                                              child: FriendsDetailsScreen(
                                                refreshPageCallback:
                                                    _fetchFriendList,
                                                id: searchFriendLists[index].id,
                                              ),
                                            )));
                              });
                        }),
                  ),
                  SizedBox(height: SizeConfig.blockHeight * 1),
                ],
                WorkCard(
                  title:work.professionalSubCategory != null ? getCategoryProfessionCardName(work.professionalSubCategory) :work.requiredProfession?? '--',
                  location: '${work.locality} ${work.city}' ?? '--',
                  timeAgo: timeAgo(work.updatedAt!),
                  jobType: work.workPlaceCategory != null ? getCategoryWorkPlaceCardName(work.workPlaceCategory) :work.workPlace ?? '--',
                  experience: work.experienceLevel ?? '--',
                  experienceImage: 'assets/images/home/work_select.png',
                  gender: work.gender ?? '--',
                  genderImage: 'assets/images/home/gender.png',
                  jobTypeImage: 'assets/images/home/home.png',
                  language: languages ?? '--',
                  languageImage: 'assets/images/home/speak.png',
                  onShowInterest: () {},
                  onCardClick: () {
                    if (Config.profileCompleted) {
                      Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) => MultiBlocProvider(
                                    providers: [
                                      BlocProvider(
                                        create: (context) => HomeBloc()
                                          ..add(FetchWorkSingleView(
                                              workId: work.id!)),
                                      ),
                                      BlocProvider(
                                        create: (context) =>
                                            ShowInterestedBloc(),
                                      ),
                                      BlocProvider(
                                          create: (context) => ReportPostBloc())
                                    ],
                                    child: WorkDetailsScreen(
                                      id: work.id!,
                                      refreshPageCallback: () {
                                        _fetchData(isNewFetch: true);
                                      },
                                      routeType: 'general',
                                    ),
                                  )));
                    } else {
                      loginUserBottomSheet(context);
                    }
                  },
                  actionRows: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Expanded(
                        child: customIconButton(
                          text: work.intrestShown != null
                              ? 'INTERESTED'
                              : 'SHOW INTEREST',
                          onPressed: () {
                            if (Config.profileCompleted) {
                              if (Config.userType == 'professional') {
                                if (work.intrestShown == null) {
                                  showInterestedBloc.add(SaveInterestedWork(
                                    workID: work.id!,
                                    contact: true,
                                    onSuccess: () {
                                      setState(() {
                                        work.intrestShown = IntrestShown(
                                          isContacted: true,
                                        );
                                      });
                                    },
                                    onError: () {
                                      showCustomSnackBar(
                                        context: context,
                                        message: "Something Went wrong",
                                      );
                                      Navigator.of(context).pop();
                                    },
                                  ));
                                } else {
                                  showCustomAlertDialog(
                                    context: context,
                                    title: 'Are you Sure?',
                                    message:
                                        'Do you want to Uninterest this Work?',
                                    positiveButtonText: 'YES',
                                    negativeButtonText: 'NO',
                                    onPositivePressed: () {
                                      showInterestedBloc.add(SaveInterestedWork(
                                        workID: work.id!,
                                        contact: true,
                                        onSuccess: () {
                                          setState(() {
                                            work.intrestShown = null;
                                            Navigator.of(context).pop();
                                          });
                                        },
                                        onError: () {
                                          showCustomSnackBar(
                                            context: context,
                                            message: "Something Went wrong",
                                          );
                                          Navigator.of(context).pop();
                                        },
                                      ));
                                    },
                                    onNegativePressed: () {
                                      Navigator.of(context).pop();
                                    },
                                  );
                                }
                              } else {
                                showInterestBottomSheet(context);
                              }
                            } else {
                              loginUserBottomSheet(context);
                            }
                          },
                          backgroundColor: work.intrestShown != null
                              ? COLORS.semanticTwo.withOpacity(0.08)
                              : COLORS.primary,
                          showIcon: false,
                          width: SizeConfig.blockWidth * 55,
                          height: SizeConfig.blockHeight * 7,
                          image: true,
                          imageChild: Padding(
                            padding:
                                EdgeInsets.only(right: SizeConfig.blockWidth),
                            child: Image.asset(
                              work.intrestShown == null
                                  ? 'assets/images/profile/like.png'
                                  : 'assets/images/home/like.png',
                              width: SizeConfig.blockWidth * 5,
                              height: SizeConfig.blockHeight * 5,
                              fit: BoxFit.contain,
                              color: work.intrestShown != null
                                  ? COLORS.semanticTwo
                                  : COLORS.white,
                            ),
                          ),
                          textColor: work.intrestShown != null
                              ? COLORS.semanticTwo
                              : COLORS.white,
                        ),
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          if (work.isProfessionalCanCall == true &&
                              work.user != null) ...[
                            IconActionCard(
                              iconBool: false,
                              imageUrl: Image.asset(
                                'assets/images/home/phone.png',
                                width: SizeConfig.blockWidth * 4.25,
                                height: SizeConfig.blockHeight * 4.25,
                                fit: BoxFit.contain,
                              ),
                              onTap: () {
                                if (Config.profileCompleted) {
                                  makePhoneCall(work.user!.mobile!);
                                } else {
                                  loginUserBottomSheet(context);
                                }
                              },
                            ),
                          ],
                          IconActionCard(
                            iconBool: false,
                            imageUrl: Image.asset(
                              'assets/images/home/share.png',
                              width: SizeConfig.blockWidth * 5.2,
                              height: SizeConfig.blockHeight * 5.2,
                              fit: BoxFit.contain,
                            ),
                            onTap: () {
                              if (Config.profileCompleted) {
                                shareJobDetails(
                                  experience: work.experienceLevel!,
                                  location: work.location!,
                                  jobTitle: work.requiredProfession!,
                                );
                              } else {
                                loginUserBottomSheet(context);
                              }
                            },
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          );
        } else if (isFetchingMore) {
          return Center(
              child: SizedBox(
                  height: SizeConfig.blockHeight * 3,
                  width: SizeConfig.blockHeight * 3,
                  child: CircularProgressIndicator(
                    color: COLORS.primary,
                    strokeWidth: SizeConfig.blockWidth * 0.8,
                  )));
        } else {
          return const SizedBox.shrink();
        }
      },
    );
  }

  Widget _buildHeader() {
    return Column(
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
                    borderRadius:
                        BorderRadius.circular(SizeConfig.blockWidth * 2.5),
                    child: Container(
                      padding: EdgeInsets.all(SizeConfig.blockWidth * 3),
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
        SizedBox(height: SizeConfig.blockHeight * 2.5),
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
                                      create: (context) => HomeBloc()
                                        ..add(FetchHomeScreenEvent(
                                            page: 1,
                                            pageSize: 20,
                                            profession: '',
                                            keyWord: '',
                                            city: '',
                                            currentLongitude: '',
                                            currentLatitude: '',
                                            gender: '',
                                            knownLanguages: [],
                                            experienceLevel: ''))),
                                  BlocProvider(
                                    create: (context) => ShowInterestedBloc(),
                                  )
                                ],
                                child: const WorkSearchList(),
                              )));
                },
                borderRadius:
                    BorderRadius.circular(SizeConfig.blockWidth * 3.25),
                child: Container(
                  width: SizeConfig.blockWidth * 72,
                  height: SizeConfig.blockHeight * 8,
                  decoration: BoxDecoration(
                      borderRadius:
                          BorderRadius.circular(SizeConfig.blockWidth * 3.25),
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
                            fontSize: SizeConfig.blockWidth * 3.25,
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
                            top: Radius.circular(SizeConfig.blockWidth * 6)),
                      ),
                      builder: (context) => MultiBlocProvider(
                            providers: [
                              BlocProvider(
                                create: (context) {
                                  final bloc = InitialRegisterBloc();
                                  bloc.add(const FetchCityEvent());
                                  bloc.add(const FetchChargeFeesEvent());
                                  bloc.add(
                                      const FetchWorkKnownLanguageProfileEvent());
                                  return bloc;
                                },
                              ),
                              BlocProvider(
                                  create: (context) => ProfessionalBloc()
                                    ..add(const FetchCategoryListEvent())),
                            ],
                            child: SearchFilterBottomSheet(
                              initialProfession: selectedProfession,
                              initialCity: selectedCity,
                              initialGender: selectedGender,
                              experienceLevel: experienceLevel,
                              experienceLevelVisible: true,
                              selectedLanguageVisible: false,
                            ),
                          ));

                  if (result != null) {
                    selectedProfession = result['selectedProfession'];
                    selectedCity = result['selectedCity'];
                    selectedGender = result['selectedGender'];
                    experienceLevel = result['_experienceLevel'];
                    selectedLanguage = result['selectedLanguage'];
                    filterHomeScreenData(selectedProfession, selectedCity,
                        selectedGender, experienceLevel, selectedLanguage);
                  }
                },
                borderRadius:
                    BorderRadius.circular(SizeConfig.blockWidth * 2.5),
                child: Container(
                  padding: EdgeInsets.all(SizeConfig.blockWidth * 4),
                  height: SizeConfig.blockHeight * 8,
                  width: SizeConfig.blockHeight * 8,
                  decoration: BoxDecoration(
                      borderRadius:
                          BorderRadius.circular(SizeConfig.blockWidth * 2.5),
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
          padding: EdgeInsets.only(top: SizeConfig.blockHeight * 1.5),
          child: Divider(
            height: SizeConfig.blockHeight,
            color: COLORS.neutralDarkTwo,
          ),
        ),
      ],
    );
  }
}
