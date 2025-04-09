import 'dart:async';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:works_app/bloc/home/home_bloc.dart';
import 'package:works_app/components/colors.dart';
import 'package:works_app/global_helper/popup.dart';
import 'package:works_app/global_helper/reuse_widget.dart';
import 'package:works_app/ui/home/work_details.dart';
import 'package:flutter/material.dart';
import 'package:location/location.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

import '../../bloc/report_post_bloc.dart';
import '../../bloc/show_interested/show_interested_bloc.dart';
import '../../components/config.dart';
import '../../components/size_config.dart';
import '../../global_helper/helper_function.dart';
import '../../global_helper/loading_placeholder/home_layout.dart';
import '../../models/home_fetch_model.dart';
import 'component.dart';

class WorkSearchList extends StatefulWidget {
  const WorkSearchList({super.key});

  @override
  _WorkSearchListState createState() => _WorkSearchListState();
}

class _WorkSearchListState extends State<WorkSearchList> {
  late HomeBloc homeBloc;
  late ShowInterestedBloc showInterestedBloc;
  final ScrollController _scrollController = ScrollController();
  final TextEditingController _searchController = TextEditingController();
  late List<HomeFetchModel> homeFetchModel;
  Timer? _debounce;
  bool isFetchingMore = false;
  int currentPage = 1;
  int pageSize = 10;
  int maxPageNumber = 1;
  String searchKeyword = "";
  Location _location = Location();
  LatLng? _currentPosition;
  bool isLiveLocationEnabled = false;
  String currentLatitude = '';
  String currentLongitude = '';

  @override
  void initState() {
    super.initState();
    homeBloc = BlocProvider.of<HomeBloc>(context);
    showInterestedBloc = BlocProvider.of<ShowInterestedBloc>(context);
    _scrollController.addListener(() {
      if (_scrollController.position.pixels ==
              _scrollController.position.maxScrollExtent &&
          !isFetchingMore &&
          currentPage < maxPageNumber) {
        _loadMoreData();
      }
    });

    _fetchData();
  }

  void _onSearchChanged(String keyword) {
    if (_debounce?.isActive ?? false) _debounce?.cancel();
    _debounce = Timer(const Duration(milliseconds: 500), () {
      setState(() {
        searchKeyword = keyword;
        currentPage = 1;
      });
      _fetchData();
    });
  }

  void _fetchData({bool isNewFetch = false}) {
    if (isNewFetch) {
      homeFetchModel.clear();
      currentPage = 1;
    }

    homeBloc.add(FetchHomeScreenEvent(
        page: currentPage,
        pageSize: pageSize,
        keyWord: searchKeyword,
        profession: "",
        city: "",
        gender: "",
        currentLongitude: currentLongitude,
        currentLatitude: currentLatitude));
  }

  void _loadMoreData() {
    setState(() {
      isFetchingMore = true;
      currentPage++;
    });
    _fetchData();
  }

  void _toggleLiveLocation() {
    setState(() {
      isLiveLocationEnabled = !isLiveLocationEnabled;
    });

    if (isLiveLocationEnabled) {
      _getCurrentLocation();
    } else {
      setState(() {
        currentLatitude = '';
        currentLongitude = '';
      });
    }
  }

  Future<void> _getCurrentLocation() async {
    setState(() {});

    PermissionStatus permissionGranted = await _location.requestPermission();
    print("Permission status: $permissionGranted");

    if (permissionGranted == PermissionStatus.granted) {
      LocationData locationData = await _location.getLocation();

      setState(() {
        currentLatitude = locationData.latitude.toString();
        currentLongitude = locationData.longitude.toString();
        print(currentLatitude);
        _fetchData();
      });
    } else {
      print("Location permission not granted");
    }

    setState(() {});
  }

  // Future<void> _getCurrentLocation() async {
  //   bool serviceEnabled = await _location.serviceEnabled();
  //   if (!serviceEnabled) {
  //     serviceEnabled = await _location.requestService();
  //     if (!serviceEnabled) {
  //       print("Location services are disabled.");
  //       return;
  //     }
  //   }
  //   PermissionStatus permissionGranted = await _location.requestPermission();
  //   print("Permission status: $permissionGranted");
  //
  //   if (permissionGranted == PermissionStatus.granted) {
  //     try {
  //       LocationData locationData = await _location.getLocation();
  //       setState(() {
  //         _currentPosition =
  //             LatLng(locationData.latitude!, locationData.longitude!);
  //         latitude = locationData.latitude!;
  //         longitude = locationData.longitude!;
  //       });
  //       print(_currentPosition);
  //     } catch (e) {
  //       print("Error retrieving location: $e");
  //     }
  //   } else {
  //     print("Location permission not granted");
  //   }
  // }

  @override
  void dispose() {
    _scrollController.dispose();
    _searchController.dispose();
    _debounce?.cancel();
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
        child: Column(
          children: [
            Container(
              // width: SizeConfig.blockWidth * 80,
              padding: EdgeInsets.symmetric(
                  horizontal: SizeConfig.blockWidth * 4.5,
                  vertical: SizeConfig.blockHeight * 2),
              child: Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _searchController,
                      style: TextStyle(
                        color: COLORS.neutralDark,
                        fontSize: SizeConfig.blockWidth * 3.25,
                        fontWeight: FontWeight.w400,
                        fontFamily: "Poppins",
                      ),
                      cursorColor: COLORS.black,
                      decoration: InputDecoration(
                        fillColor: COLORS.neutralDarkTwo.withOpacity(0.6),
                        focusColor: COLORS.neutralDarkTwo.withOpacity(0.6),
                        filled: true,
                        hintText: 'Ex: Plumber, Swimming Coach'.tr(),
                        hintStyle: TextStyle(
                          color: COLORS.neutralDarkOne,
                          fontSize: SizeConfig.blockWidth * 3.25,
                          fontWeight: FontWeight.w400,
                          fontFamily: "Poppins",
                        ),
                        prefixIcon: Icon(
                          Icons.search,
                          color: COLORS.neutralDarkOne,
                          size: SizeConfig.blockWidth * 5,
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
                  // SizedBox(width: SizeConfig.blockWidth*3),
                  // GestureDetector(
                  //   onTap: _toggleLiveLocation,
                  //   child: Icon(
                  //     Icons.my_location,
                  //     color: isLiveLocationEnabled ? COLORS.primary:COLORS.primaryOne,
                  //     size: SizeConfig.blockWidth*6,
                  //   ),
                  // ),
                ],
              ),
            ),
            // Row(
            //   mainAxisAlignment: MainAxisAlignment.spaceBetween,
            //   crossAxisAlignment: CrossAxisAlignment.center,
            //   children: [
            //     Container(
            //       // width: SizeConfig.blockWidth * 80,
            //       padding: EdgeInsets.symmetric(
            //           horizontal: SizeConfig.blockWidth * 4.5,
            //           vertical: SizeConfig.blockHeight * 2),
            //       child: TextField(
            //         controller: _searchController,
            //         style: TextStyle(
            //           color: COLORS.neutralDarkOne,
            //           fontSize: SizeConfig.blockWidth * 3.25,
            //           fontWeight: FontWeight.w400,
            //           fontFamily: "Poppins",
            //         ),
            //         cursorColor: COLORS.black,
            //         decoration: InputDecoration(
            //           fillColor: COLORS.neutralDarkTwo.withOpacity(0.6),
            //           focusColor: COLORS.neutralDarkTwo.withOpacity(0.6),
            //           filled: true,
            //           hintText: 'Ex: Plumber, Swimming Coach'.tr(),
            //           hintStyle: TextStyle(
            //             color: COLORS.neutralDarkOne,
            //             fontSize: SizeConfig.blockWidth * 3.25,
            //             fontWeight: FontWeight.w400,
            //             fontFamily: "Poppins",
            //           ),
            //           prefixIcon: Icon(
            //             Icons.search,
            //             color: COLORS.neutralDarkOne,
            //             size: SizeConfig.blockWidth * 5,
            //           ),
            //           border: OutlineInputBorder(
            //             borderRadius:
            //                 BorderRadius.circular(SizeConfig.blockWidth * 3.25),
            //             borderSide: BorderSide(
            //                 color: COLORS.neutralDarkTwo.withOpacity(0.6),
            //                 width: SizeConfig.blockWidth * 0.1),
            //           ),
            //           focusedBorder: OutlineInputBorder(
            //             borderRadius:
            //                 BorderRadius.circular(SizeConfig.blockWidth * 3.25),
            //             borderSide: BorderSide(
            //                 color: COLORS.neutralDarkTwo.withOpacity(0.6),
            //                 width: SizeConfig.blockWidth * 0.1),
            //           ),
            //           enabledBorder: OutlineInputBorder(
            //             borderRadius:
            //                 BorderRadius.circular(SizeConfig.blockWidth * 3.25),
            //             borderSide: BorderSide(
            //                 color: COLORS.neutralDarkTwo.withOpacity(0.6),
            //                 width: SizeConfig.blockWidth * 0.1),
            //           ),
            //         ),
            //         onChanged: _onSearchChanged,
            //       ),
            //     ),
            //     // Container(
            //     //   margin: EdgeInsets.symmetric(
            //     //       horizontal: SizeConfig.blockWidth * 4.5),
            //     //   child: IconButton(
            //     //       onPressed: () {
            //     //         _getCurrentLocation();
            //     //       },
            //     //       icon: Icon(
            //     //         Icons.my_location,
            //     //         size: SizeConfig.blockWidth * 5,
            //     //       )),
            //     // )
            //   ],
            // ),
            // Divider(
            //   height: SizeConfig.blockHeight*0,
            //   color: COLORS.neutralDarkTwo,
            // ),
            // SizedBox(height: SizeConfig.blockHeight*2,),
            Expanded(
              child: BlocConsumer<HomeBloc, HomeState>(
                listener: (context, state) {
                  if (state is FetchHomeScreenSuccess) {
                    setState(() {
                      isFetchingMore = false;
                      maxPageNumber = state.maxPageNumber;
                    });
                  } else if (state is FetchHomeScreenFailed) {
                    setState(() {
                      isFetchingMore = false;
                    });
                    // showCustomSnackBar(
                    //   context: context,
                    //   message: state.message,
                    // );
                  }
                },
                builder: (context, state) {
                  if (state is HomeScreenLoading && currentPage == 1) {
                    return const ShimmerJobCards();
                  } else if (state is FetchHomeScreenSuccess) {
                    return _buildListView(state.homeFetchModel);
                  } else if (state is FetchHomeScreenFailed) {
                    return ErrorScreen(onRetry: () {
                      _fetchData();
                    });
                  }
                  return Container();
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildListView(List<HomeFetchModel> homeFetchModel) {
    if (homeFetchModel.isEmpty) {
      return emptyComponent();
    }
    return ListView.builder(
      controller: _scrollController,
      itemCount: homeFetchModel.length + (isFetchingMore ? 1 : 0),
      itemBuilder: (context, index) {
        if (index < homeFetchModel.length) {
          final work = homeFetchModel[index];
          return Container(
            padding: EdgeInsets.symmetric(
                horizontal: SizeConfig.blockWidth * 4.5,
                vertical: SizeConfig.blockHeight * 0.5),
            child: WorkCard(
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
                                    create: (context) => ShowInterestedBloc(),
                                  ),
                                  BlocProvider(
                                      create: (context) => ReportPostBloc())
                                ],
                                child: WorkDetailsScreen(
                                  id: work.id!,
                                  refreshPageCallback: _fetchData,
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
                                onError: () {},
                              ));
                            } else {
                              showCustomAlertDialog(
                                context: context,
                                title: 'Are you Sure?',
                                message: 'Do you want to Uninterest this Work?',
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
                        padding: EdgeInsets.only(right: SizeConfig.blockWidth),
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
                      if (work.isProfessionalCanCall == true) ...[
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
          );
        } else if (isFetchingMore) {
          return Center(
              child: SizedBox(
                  height: SizeConfig.blockWidth * 5,
                  width: SizeConfig.blockWidth * 5,
                  child: const CircularProgressIndicator(
                    color: COLORS.primary,
                    strokeWidth: 2,
                  )));
        } else {
          return const SizedBox.shrink();
        }
      },
    );
  }
}
