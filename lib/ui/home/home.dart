import 'dart:io';

import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:modal_bottom_sheet/modal_bottom_sheet.dart';
import 'package:works_app/bloc/home/home_bloc.dart';
import 'package:works_app/components/config.dart';
import 'package:works_app/global_helper/loading_placeholder/home_layout.dart';
import 'package:works_app/global_helper/popup.dart';
import 'package:works_app/ui/home/component.dart';
import 'package:works_app/ui/home/notification_list.dart';
import 'package:works_app/ui/home/work_details.dart';
import 'package:works_app/ui/home/work_search.dart';
import 'package:works_app/ui/onboarding/language_selection.dart';
import '../../bloc/notification/notification_bloc.dart';
import '../../bloc/show_interested/show_interested_bloc.dart';
import '../../components/colors.dart';
import '../../components/size_config.dart';
import '../../global_helper/helper_function.dart';
import '../../global_helper/reuse_widget.dart';
import '../../models/home_fetch_model.dart';
import '../chat/addFriends.dart';
import '../friends/friends_search.dart';
import 'filter.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  late HomeBloc homeBloc;
  late ShowInterestedBloc showInterestedBloc;
  late List<HomeFetchModel> homeFetchModel = [];
  final ScrollController _scrollController = ScrollController();
  bool isFetchingMore = false;
  int currentPage = 1;
  int pageSize = 10;
  int maxPageNumber = 1;
  String? selectedProfession = '';
  String? selectedCity = '';
  String selectedGender = '';

  @override
  void initState() {
    super.initState();
    homeBloc = BlocProvider.of<HomeBloc>(context);
    showInterestedBloc = BlocProvider.of<ShowInterestedBloc>(context);
    _fetchData();
    _scrollController.addListener(() {
      if (_scrollController.position.pixels ==
              _scrollController.position.maxScrollExtent &&
          !isFetchingMore &&
          currentPage < maxPageNumber) {
        _loadMoreData();
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
        currentLongitude: '',
        currentLatitude: ''));
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

  void filterHomeScreenData(String? profession, String? city, String gender) {
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
      body: SafeArea(
        child: Container(
          width: SizeConfig.screenWidth,
          padding: EdgeInsets.only(top: SizeConfig.blockHeight * 2),
          child: Column(
            children: [
              _buildHeader(),
              Expanded(
                child: BlocConsumer<HomeBloc, HomeState>(
                  listener: (context, state) {
                    if (state is FetchHomeScreenSuccess) {
                      setState(() {
                        if (currentPage == 1) {
                          // Only set data for the first page
                          homeFetchModel = state.homeFetchModel;
                        } else {
                          // Only add new unique items for subsequent pages
                          final newItems = state.homeFetchModel
                              .where((item) => !homeFetchModel.contains(item));
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
                        homeBloc.add(FetchHomeScreenEvent(
                            page: currentPage,
                            pageSize: pageSize,
                            keyWord: "",
                            profession: "",
                            city: "",
                            gender: "",
                            currentLongitude: '',
                            currentLatitude: ''));
                      });
                    }
                    return Container();
                  },
                ),
              ),
            ],
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
          return Container(
            padding:
                EdgeInsets.symmetric(horizontal: SizeConfig.blockWidth * 5),
            margin: EdgeInsets.only(bottom: SizeConfig.blockHeight * 1.8),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (index == 0) ...[
                  addFriendText(textOne: 'Add Friends', textTwo: 'View All' ,onTap: (){
                    Navigator.push(context, MaterialPageRoute(builder: (BuildContext context)=> const AddFriendsScreen(header: 'Friend Suggestion')));
                  }),
                  SizedBox(
                    height: SizeConfig.blockHeight * 33,
                    child: ListView.builder(
                        itemCount: 8,
                        shrinkWrap: true,
                        scrollDirection: Axis.horizontal,
                        itemBuilder: (context, index) {
                          return addFriendCard(
                              added: index % 2 == 0?true:false,
                              image: 'assets/images/home/dumy1.png',
                              name: 'Julia Vandervort-Will');
                        }),
                  ),
                  SizedBox(height: SizeConfig.blockHeight * 2),
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
                WorkCard(
                  title: work.requiredProfession ?? '--',
                  location: work.location ?? '--',
                  timeAgo: timeAgo(work.updatedAt!),
                  jobType: work.workPlace ?? '--',
                  experience: work.experienceLevel ?? '--',
                  experienceImage: 'assets/images/home/work_select.png',
                  gender: work.gender ?? '--',
                  genderImage: 'assets/images/home/gender.png',
                  jobTypeImage: 'assets/images/home/home.png',
                  language: work.knowLanguage!.join(", ") ?? '--',
                  languageImage: 'assets/images/home/speak.png',
                  onShowInterest: () {},
                  onCardClick: () {
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
                                      create: (context) => ShowInterestedBloc(),
                                    )
                                  ],
                                  child: WorkDetailsScreen(
                                    id: work.id!,
                                    refreshPageCallback: () {
                                      _fetchData(isNewFetch: true);
                                    },
                                    routeType: 'general',
                                  ),
                                )));
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
                                makePhoneCall(work.user!.mobile!);
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
                              shareJobDetails(
                                experience: work.experienceLevel!,
                                location: work.location!,
                                jobTitle: work.requiredProfession!,
                              );
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
                    child: Container(
                      padding: EdgeInsets.all(SizeConfig.blockWidth * 3),
                      margin:
                          EdgeInsets.only(right: SizeConfig.blockWidth * 2.8),
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
                                    ],
                                    child: const NotificationListScreen(),
                                  )));
                    },
                    child: Container(
                      padding: EdgeInsets.all(SizeConfig.blockWidth * 3),
                      decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(
                              SizeConfig.blockWidth * 2.5),
                          color: COLORS.primaryOne.withOpacity(0.3)),
                      child: Icon(
                        Icons.notifications_none,
                        size: SizeConfig.blockWidth * 5.5,
                      ),
                    ),
                  ),
                ],
              )
            ],
          ),
        ),
        SizedBox(height: SizeConfig.blockHeight * 2),
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
                                            gender: ''))),
                                  BlocProvider(
                                    create: (context) => ShowInterestedBloc(),
                                  )
                                ],
                                child: const WorkSearchList(),
                              )));
                },
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
                        child: Icon(
                          Icons.search,
                          color: COLORS.neutralDarkOne,
                          size: SizeConfig.blockWidth * 6,
                        ),
                      ),
                      Text(
                        'Search by Works type'.tr(),
                        style: TextStyle(
                          color: COLORS.neutralDarkOne,
                          fontSize: SizeConfig.blockWidth * 3.25,
                          fontWeight: FontWeight.w400,
                          fontFamily: "Poppins",
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
                    builder: (context) => SearchFilterBottomSheet(
                      initialProfession: selectedProfession,
                      initialCity: selectedCity,
                      initialGender: selectedGender,
                    ),
                  );

                  if (result != null) {
                    selectedProfession = result['selectedProfession'];
                    selectedCity = result['selectedCity'];
                    selectedGender = result['selectedGender'];
                    filterHomeScreenData(
                      selectedProfession,
                      selectedCity,
                      selectedGender,
                    );
                  }
                },
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
