// import 'dart:async';
// import 'package:easy_localization/easy_localization.dart';
// import 'package:flutter/cupertino.dart';
// import 'package:flutter/material.dart';
// import 'package:flutter_bloc/flutter_bloc.dart';
// import 'package:modal_bottom_sheet/modal_bottom_sheet.dart';
// import 'package:works_app/components/colors.dart';
// import 'package:works_app/components/size_config.dart';
// import 'package:works_app/global_helper/ImagePickerComponent.dart';
// import 'package:works_app/global_helper/reuse_widget.dart';
// import 'package:works_app/ui/friends/component.dart';
// import 'package:works_app/ui/friends/friends_details.dart';
//
// import '../../bloc/chart/chart_bloc.dart';
// import '../../bloc/friends/friends_bloc.dart';
// import '../../bloc/register_account/initial_register_bloc.dart';
// import '../../bloc/report_post_bloc.dart';
// import '../../bloc/show_interested/show_interested_bloc.dart';
// import '../../global_helper/loading_placeholder/home_layout.dart';
// import '../../models/friends/global_search_list_modal.dart';
// import 'chat_view.dart';
// import 'modal/filter_search_modal.dart';
//
// class AddFriendsScreen extends StatefulWidget {
//   final String header;
//   final VoidCallback refreshPageCallback;
//
//   const AddFriendsScreen(
//       {super.key, required this.header, required this.refreshPageCallback});
//
//   @override
//   State<AddFriendsScreen> createState() => _AddFriendsScreenState();
// }
//
// class _AddFriendsScreenState extends State<AddFriendsScreen> {
//   late FriendsBloc friendsBloc;
//   late ShowInterestedBloc showInterestedBloc;
//   late ChartBloc chartBloc;
//   final ScrollController _scrollController = ScrollController();
//   final TextEditingController _searchController = TextEditingController();
//   late List<SearchFriendLists> searchFriendLists;
//   Timer? _debounce;
//   String searchKeyword = "";
//   bool isFetchingMore = false;
//   int currentPage = 1;
//   int pageSize = 10;
//   int maxPageNumber = 1;
//
//   @override
//   void initState() {
//     super.initState();
//     friendsBloc = BlocProvider.of<FriendsBloc>(context);
//     showInterestedBloc = BlocProvider.of<ShowInterestedBloc>(context);
//     chartBloc = BlocProvider.of<ChartBloc>(context);
//     searchFriendLists = [];
//     _scrollController.addListener(() {
//       if (_scrollController.position.pixels >=
//           _scrollController.position.maxScrollExtent - 100 &&
//           !isFetchingMore &&
//           currentPage < maxPageNumber) {
//         _loadMoreData(); // load next page
//       }
//     });
//     _fetchData();
//   }
//
//   void _onSearchChanged(String keyword) {
//     if (_debounce?.isActive ?? false) _debounce?.cancel();
//     _debounce = Timer(const Duration(milliseconds: 500), () {
//       setState(() {
//         searchKeyword = keyword;
//         currentPage = 1;
//       });
//       _fetchData();
//     });
//   }
//
//
//
//   void _fetchData({bool isNewFetch = false}) {
//     if (isNewFetch) {
//       setState(() {
//         currentPage = 1;
//         searchFriendLists.clear();
//       });
//     }
//
//     friendsBloc.add(FetchFriendsAddListEvent(
//       page: currentPage,
//       pageSize: pageSize,
//       keyWord: searchKeyword,
//     ));
//   }
//
//
//   void _loadMoreData() {
//     setState(() {
//       isFetchingMore = true;
//       currentPage++;
//     });
//     _fetchData();
//   }
//
//
//   @override
//   void dispose() {
//     _scrollController.dispose();
//     _searchController.dispose();
//     _debounce?.cancel();
//     super.dispose();
//   }
//
//   void _refreshPageAfterEdit() {
//     _fetchData();
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     return PopScope(
//       canPop: true,
//       onPopInvokedWithResult: (didPop, result) {
//         if (didPop) {
//           widget.refreshPageCallback();
//         }
//       },
//       child: Scaffold(
//         backgroundColor: COLORS.white,
//
//         appBar: CustomAppBar(
//             title: widget.header,
//             backgroundColor: COLORS.white,
//             titleColors: COLORS.neutralDark,
//             onBackPress: () {
//               widget.refreshPageCallback();
//               Navigator.of(context).pop();
//             }),
//         body: SafeArea(
//             child: Column(
//               crossAxisAlignment: CrossAxisAlignment.center,
//               mainAxisAlignment: MainAxisAlignment.start,
//               children: [
//             Container(
//             padding: EdgeInsets.symmetric(
//             horizontal: SizeConfig.blockWidth * 4.5,
//               vertical: SizeConfig.blockHeight * 2,
//             ),
//             child: Row(
//               children: [
//                 Expanded(
//                   child: TextField(
//                     controller: _searchController,
//                     style: TextStyle(
//                       color: COLORS.neutralDarkOne,
//                       fontSize: SizeConfig.blockWidth * 3.25,
//                       fontWeight: FontWeight.w400,
//                       fontFamily: "Poppins",
//                     ),
//                     cursorColor: COLORS.black,
//                     decoration: InputDecoration(
//                       fillColor: COLORS.neutralDarkTwo.withOpacity(0.6),
//                       focusColor: COLORS.neutralDarkTwo.withOpacity(0.6),
//                       filled: true,
//                       hintText: 'Ex: Search'.tr(),
//                       hintStyle: TextStyle(
//                         color: COLORS.neutralDarkOne,
//                         fontSize: SizeConfig.blockWidth * 3.25,
//                         fontWeight: FontWeight.w400,
//                         fontFamily: "Poppins",
//                       ),
//                       prefixIcon: Icon(
//                         Icons.search,
//                         color: COLORS.neutralDarkOne,
//                         size: SizeConfig.blockWidth * 5,
//                       ),
//                       border: OutlineInputBorder(
//                         borderRadius: BorderRadius.circular(
//                             SizeConfig.blockWidth * 3.25),
//                         borderSide: BorderSide(
//                             color: COLORS.neutralDarkTwo.withOpacity(0.6),
//                             width: SizeConfig.blockWidth * 0.1),
//                       ),
//                       focusedBorder: OutlineInputBorder(
//                         borderRadius: BorderRadius.circular(
//                             SizeConfig.blockWidth * 3.25),
//                         borderSide: BorderSide(
//                             color: COLORS.neutralDarkTwo.withOpacity(0.6),
//                             width: SizeConfig.blockWidth * 0.1),
//                       ),
//                       enabledBorder: OutlineInputBorder(
//                         borderRadius: BorderRadius.circular(
//                             SizeConfig.blockWidth * 3.25),
//                         borderSide: BorderSide(
//                             color: COLORS.neutralDarkTwo.withOpacity(0.6),
//                             width: SizeConfig.blockWidth * 0.1),
//                       ),
//                     ),
//                     onChanged: _onSearchChanged,
//                   ),
//                   =======
//                 appBar: AppBar(
//                 toolbarHeight: 0,
//                 scrolledUnderElevation: 0,
//                 automaticallyImplyLeading: false,
//                 backgroundColor: COLORS.white,
//                 ),
//                 body: DefaultTabController(
//                     length: 2,
//                     child: Column(
//                       children: [
//                       Container(
//                       color: COLORS.white,
//                       child: TabBar(
//                         labelColor: COLORS.neutralDark,
//                         unselectedLabelColor: COLORS.neutralDarkOne,
//                         indicatorColor: COLORS.primary,
//                         dividerColor: COLORS.neutralDarkTwo,
//                         // dividerHeight: SizeConfig.blockHeight,
//                         padding: EdgeInsets.zero,indicatorPadding: EdgeInsets.zero,
//
//                         labelStyle: TextStyle(
//                             color: COLORS.neutralDark,
//                             fontSize: SizeConfig.blockWidth * 4,
//                             fontWeight: FontWeight.w400,
//                             fontFamily: "Poppins",
//                             >>>>>>> 0651470ac4778c022b0e8b2b5e9969a56adf3355
//                         ),
//                         tabs: const [
//                           Tab(text: 'People'),
//                           Tab(text: 'Groups'),
//                         ],
//                       ),
//                     ),
//                     <<<<<<< HEAD
//                 ),
//                 Divider(
//                   color: COLORS.neutralDarkTwo,
//                   height: SizeConfig.blockHeight,
//                 ),
//                 BlocConsumer<FriendsBloc, FriendsState>(
//                   listener: (context, state) {
//                     if (state is FriendsAddListSuccess) {
//                       setState(() {
//                         if (currentPage == 1) {
//                           searchFriendLists = state.searchFriendLists;
//                         } else {
//                           searchFriendLists.addAll(state.searchFriendLists);
//                         }
//                         isFetchingMore = false;
//                         maxPageNumber = state.maxPageNumber;
//                       });
//                     }
//                     else if (state is FriendsAddListFailed) {
//                       setState(() {
//                         isFetchingMore = false;
//                       });
//                     }
//                   },
//                   builder: (context, state) {
//                     if (state is FriendsListLoading && currentPage == 1) {
//                       return friendsListLoading();
//                     } else if (state is FriendsAddListSuccess) {
//                       return Expanded(
//                         child: Padding(
//                           padding: EdgeInsets.only(
//                             left: SizeConfig.blockWidth * 4.5,
//                             right: SizeConfig.blockWidth * 4.5,
//                             top: SizeConfig.blockHeight * 0.2,
//                             bottom: SizeConfig.blockHeight,
//                           ),
//                           child: ListView.builder(
//                               controller: _scrollController,
//                               itemCount: searchFriendLists.length +
//                                   (isFetchingMore ? 1 : 0),
//                               shrinkWrap: true,
//                               scrollDirection: Axis.vertical,
//                               itemBuilder: (context, index) {
//                                 if (index < searchFriendLists.length) {
//                                   return friendSearchDetailsCards(
//                                     image: searchFriendLists[index].profilePic,
//                                     name: searchFriendLists[index].name,
//                                     onTapCard: () {
//                                       Navigator.push(
//                                           context,
//                                           MaterialPageRoute(
//                                               builder: (context) =>
//                                                   MultiBlocProvider(
//                                                     providers: [
//                                                       BlocProvider(
//                                                         create: (context) {
//                                                           final bloc =
//                                                           FriendsBloc();
//                                                           bloc.add(
//                                                               FetchFriendsSingleView(
//                                                                   friendId: state
//                                                                       .searchFriendLists[
//                                                                   index]
//                                                                       .id));
//                                                           return bloc;
//                                                         },
//                                                       ),
//                                                       BlocProvider(
//                                                         create: (context) =>
//                                                             ShowInterestedBloc(),
//                                                       ),
//                                                       BlocProvider(
//                                                           create: (context) =>
//                                                               ReportPostBloc()),
//                                                       BlocProvider(
//                                                           create: (context) =>
//                                                               ShowInterestedBloc()),
//                                                       BlocProvider(
//                                                           create: (context) =>
//                                                               ChartBloc())
//                                                     ],
//                                                     child: FriendsDetailsScreen(
//                                                       refreshPageCallback:
//                                                       _refreshPageAfterEdit,
//                                                       id: state
//                                                           .searchFriendLists[index]
//                                                           .id,
//                                                     ),
//                                                   )));
//                                     },
//                                     added: searchFriendLists[index]
//                                         .friendRequestSent !=
//                                         null
//                                         ? true
//                                         : false,
//                                     disc: searchFriendLists[index].professionType!,
//                                     bgFriend: true,
//                                     onTapButtonCard: () {
//                                       if (searchFriendLists[index].isFriend !=
//                                           null) {
//                                         chartBloc.add(StartMessageEvent(
//                                             chatId: searchFriendLists[index]
//                                                 .isFriend!
//                                                 .friendId!,
//                                             onSuccess: (chatId) {
//                                               print(chatId);
//                                               Navigator.push(
//                                                   context,
//                                                   MaterialPageRoute(
//                                                       builder: (context) =>
//                                                           MultiBlocProvider(
//                                                             providers: [
//                                                               BlocProvider(
//                                                                 create: (context) =>
//                                                                 ChartBloc()
//                                                                   ..add(FetchChartViewEvent(
//                                                                       page: 1,
//                                                                       pageSize:
//                                                                       10,
//                                                                       chatId:
//                                                                       chatId)),
//                                                               ),
//                                                               BlocProvider(
//                                                                   create: (context) =>
//                                                                       InitialRegisterBloc()),
//                                                               BlocProvider(
//                                                                   create: (context) =>
//                                                                       ShowInterestedBloc()),
//                                                             ],
//                                                             child: ChatViewScreen(
//                                                               refreshPageCallback:
//                                                               _refreshPageAfterEdit,
//                                                               chatId: chatId,
//                                                               isGroup: false,
//                                                             ),
//                                                           )));
//                                             },
//                                             onError: (message) {
//                                               showCustomSnackBar(
//                                                   context: context,
//                                                   message: message,
//                                                   backgroundColor:
//                                                   COLORS.neutralDarkTwo);
//                                             }));
//                                       } else if (searchFriendLists[index]
//                                           .friendRequestSent !=
//                                           null) {
//                                         showInterestedBloc.add(UnSendFriendEvent(
//                                             userId: searchFriendLists[index].id,
//                                             onSuccess: (message) {
//                                               setState(() {
//                                                 searchFriendLists[index]
//                                                     .friendRequestSent = null;
//                                               });
//                                             },
//                                             onError: (message) {
//                                               showCustomSnackBar(
//                                                 context: context,
//                                                 message: message,
//                                               );
//                                             }));
//                                       } else {
//                                         showInterestedBloc.add(AddFriendEvent(
//                                             userId: searchFriendLists[index].id,
//                                             onSuccess: (message) {
//                                               setState(() {
//                                                 searchFriendLists[index]
//                                                     .friendRequestSent =
//                                                     FriendRequestSent(
//                                                       userId:
//                                                       searchFriendLists[index].id,
//                                                     );
//                                               });
//                                             },
//                                             onError: (message) {
//                                               showCustomSnackBar(
//                                                 context: context,
//                                                 message: message,
//                                               );
//                                             }));
//                                       }
//                                     },
//                                     buttonRequired:
//                                     searchFriendLists[index].isFriend == null,
//                                     sendMessageButtonRequired:
//                                     searchFriendLists[index].isFriend != null,
//                                   );
//                                 } else if (isFetchingMore) {
//                                   return Center(
//                                       child: SizedBox(
//                                           height: SizeConfig.blockHeight * 3,
//                                           width: SizeConfig.blockHeight * 3,
//                                           child: CircularProgressIndicator(
//                                             color: COLORS.primary,
//                                             strokeWidth:
//                                             SizeConfig.blockWidth * 0.8,
//                                           )));
//                                 } else {
//                                   return const SizedBox.shrink();
//                                 }
//                               }),
//                         ),
//                       );
//                     } else if (state is FriendsAddListFailed) {
//                       return ErrorScreen(onRetry: () {
//                         _fetchData();
//                       });
//                     }
//                     return Container();
//                   },
//                 )
//               ],
//             )),
//         =======
//       Expanded(
//       child: TabBarView(
//       children: [
//       SafeArea(
//       child: Column(
//       crossAxisAlignment: CrossAxisAlignment.center,
//       mainAxisAlignment: MainAxisAlignment.start,
//         children: [
//         Container(
//         padding: EdgeInsets.symmetric(
//       horizontal: SizeConfig.blockWidth * 4.5,
//       vertical: SizeConfig.blockHeight * 2,
//       ),
//       child: Row(
//         children: [
//           Expanded(
//             child: TextField(
//               controller: _searchController,
//               style: TextStyle(
//                 color: COLORS.neutralDarkOne,
//                 fontSize: SizeConfig.blockWidth * 3.25,
//                 fontWeight: FontWeight.w400,
//                 fontFamily: "Poppins",
//               ),
//               cursorColor: COLORS.black,
//               decoration: InputDecoration(
//                 fillColor:
//                 COLORS.neutralDarkTwo.withOpacity(0.6),
//                 focusColor:
//                 COLORS.neutralDarkTwo.withOpacity(0.6),
//                 filled: true,
//                 hintText: 'Ex: Search'.tr(),
//                 hintStyle: TextStyle(
//                   color: COLORS.neutralDarkOne,
//                   fontSize: SizeConfig.blockWidth * 3.25,
//                   fontWeight: FontWeight.w400,
//                   fontFamily: "Poppins",
//                 ),
//                 prefixIcon: Padding(
//                   padding: EdgeInsets.all(
//                       SizeConfig.blockWidth * 4),
//                   child: Image.asset(
//                     'assets/images/home/search.png',
//                     width: SizeConfig.blockWidth * 3.5,
//                     height: SizeConfig.blockWidth * 3.5,
//                     fit: BoxFit.cover,
//                   ),
//                 ),
//                 border: OutlineInputBorder(
//                   borderRadius: BorderRadius.circular(
//                       SizeConfig.blockWidth * 3.25),
//                   borderSide: BorderSide(
//                       color: COLORS.neutralDarkTwo
//                           .withOpacity(0.6),
//                       width: SizeConfig.blockWidth * 0.1),
//                 ),
//                 focusedBorder: OutlineInputBorder(
//                   borderRadius: BorderRadius.circular(
//                       SizeConfig.blockWidth * 3.25),
//                   borderSide: BorderSide(
//                       color: COLORS.neutralDarkTwo
//                           .withOpacity(0.6),
//                       width: SizeConfig.blockWidth * 0.1),
//                 ),
//                 enabledBorder: OutlineInputBorder(
//                   borderRadius: BorderRadius.circular(
//                       SizeConfig.blockWidth * 3.25),
//                   borderSide: BorderSide(
//                       color: COLORS.neutralDarkTwo
//                           .withOpacity(0.6),
//                       width: SizeConfig.blockWidth * 0.1),
//                 ),
//               ),
//               onChanged: _onSearchChanged,
//             ),
//           ),
//           SizedBox(width: SizeConfig.blockWidth * 3),
//           InkWell(
//             onTap: () async {
//               final result =
//               await showMaterialModalBottomSheet(
//                   enableDrag: true,
//                   expand: false,
//                   isDismissible: true,
//                   backgroundColor: COLORS.white,
//                   closeProgressThreshold: 0,
//                   duration: const Duration(seconds: 0),
//                   context: context,
//                   shape: RoundedRectangleBorder(
//                     borderRadius: BorderRadius.vertical(
//                         top: Radius.circular(
//                             SizeConfig.blockWidth * 6)),
//                   ),
//                   builder: (context) =>
//                       MultiBlocProvider(
//                           providers: [
//                             BlocProvider(
//                               create: (context) {
//                                 final bloc =
//                                 InitialRegisterBloc();
//                                 bloc.add(
//                                     const FetchCityEvent());
//                                 return bloc;
//                               },
//                             ),
//                           ],
//                           child:
//                           CustomFilterBottomSheet(
//                             title: 'City',
//                             showSearch: true,
//                             options: [
//                               'All',
//                               'Bengaluru',
//                               'Mysuru',
//                               'Mangaluru',
//                               'Hubballi',
//                               'Belagavi',
//                               'Davanagere',
//                               'Ballari',
//                               'Tumakuru',
//                               'Shivamogga',
//                               'Kalaburagi',
//                               'Vijayapur',
//                               'Raichur',
//                               'Bidar',
//                               'Hassan',
//                               'Chitradurga',
//                               'Mandya',
//                               'Karwar',
//                               'Udupi',
//                             ],
//                             selectedOptions: [
//                               'Bengaluru'
//                             ],
//                             onSubmit: (selectedList) {
//                               // Do something with selectedList
//                               print(
//                                   "Selected cities: $selectedList");
//                               Navigator.pop(context);
//                             },
//                           )));
//
//               if (result != null) {}
//             },
//             borderRadius: BorderRadius.circular(
//                 SizeConfig.blockWidth * 2.5),
//             child: Container(
//               padding:
//               EdgeInsets.all(SizeConfig.blockWidth * 4),
//               height: SizeConfig.blockHeight * 8,
//               width: SizeConfig.blockHeight * 8,
//               decoration: BoxDecoration(
//                   borderRadius: BorderRadius.circular(
//                       SizeConfig.blockWidth * 2.5),
//                   color: COLORS.neutralDarkTwo
//                       .withOpacity(0.6)),
//               child: Image.asset(
//                 'assets/images/home/filter.png',
//                 width: SizeConfig.blockWidth * 5.5,
//                 height: SizeConfig.blockWidth * 5.5,
//                 fit: BoxFit.contain,
//               ),
//             ),
//           ),
//         ],
//       ),
//     ),
//     Divider(
//     color: COLORS.neutralDarkTwo,
//     height: SizeConfig.blockHeight,
//     ),
//     BlocConsumer<FriendsBloc, FriendsState>(
//     listener: (context, state) {
//     if (state is FriendsAddListSuccess) {
//     setState(() {
//     searchFriendLists = state.searchFriendLists;
//     isFetchingMore = false;
//     maxPageNumber = state.maxPageNumber;
//     });
//     } else if (state is FriendsAddListFailed) {
//     setState(() {
//     isFetchingMore = false;
//     });
//     }
//     },
//     builder: (context, state) {
//     if (state is FriendsListLoading &&
//     currentPage == 1) {
//     return friendsListLoading();
//     } else if (state is FriendsAddListSuccess) {
//     return Expanded(
//     child: Padding(
//     padding: EdgeInsets.only(
//     left: SizeConfig.blockWidth * 4.5,
//     right: SizeConfig.blockWidth * 4.5,
//     top: SizeConfig.blockHeight * 0.2,
//     bottom: SizeConfig.blockHeight,
//     ),
//     child: ListView.builder(
//     itemCount: searchFriendLists.length,
//     shrinkWrap: true,
//     scrollDirection: Axis.vertical,
//     itemBuilder: (context, index) {
//     return friendSearchDetailsCards(
//     image: searchFriendLists[index]
//         .profilePic,
//     name: searchFriendLists[index].name,
//     onTapCard: () {
//     Navigator.push(
//     context,
//     MaterialPageRoute(
//     builder:
//     (context) =>
//     MultiBlocProvider(
//     providers: [
//     BlocProvider(
//     create:
//     (context) {
//     final bloc =
//     FriendsBloc();
//     bloc.add(FetchFriendsSingleView(
//     friendId: state
//         .searchFriendLists[index]
//         .id));
//     return bloc;
//     },
//     ),
//     BlocProvider(
//     create: (context) =>
//     ShowInterestedBloc(),
//     ),
//     BlocProvider(
//     create: (context) =>
//     ReportPostBloc()),
//     BlocProvider(
//     create: (context) =>
//     ShowInterestedBloc()),
//     BlocProvider(
//     create: (context) =>
//     ChartBloc())
//     ],
//     child:
//     FriendsDetailsScreen(
//     refreshPageCallback:
//     _refreshPageAfterEdit,
//     id: state
//         .searchFriendLists[
//     index]
//         .id,
//     ),
//     )));
//     },
//     added: searchFriendLists[index]
//         .friendRequestSent !=
//     null
//     ? true
//         : false,
//     disc: searchFriendLists[index]
//         .professionType!,
//     bgFriend: true,
//     onTapButtonCard: () {
//     if (searchFriendLists[index]
//         .isFriend !=
//     null) {
//     chartBloc.add(StartMessageEvent(
//     chatId:
//     searchFriendLists[index]
//         .isFriend!
//         .friendId!,
//     onSuccess: (chatId) {
//     print(chatId);
//     Navigator.push(
//     context,
//     MaterialPageRoute(
//     builder: (context) =>
//     MultiBlocProvider(
//     providers: [
//     BlocProvider(
//     create: (context) => ChartBloc()
//     ..add(FetchChartViewEvent(
//     page:
//     1,
//     pageSize:
//     10,
//     chatId:
//     chatId)),
//     ),
//     BlocProvider(
//     create: (context) =>
//     InitialRegisterBloc()),
//     BlocProvider(
//     create: (context) =>
//     ShowInterestedBloc()),
//     ],
//     child:
//     ChatViewScreen(
//     refreshPageCallback:
//     _refreshPageAfterEdit,
//     chatId:
//     chatId,
//     isGroup:
//     false,
//     ),
//     )));
//     },
//     onError: (message) {
//     showCustomSnackBar(
//     context: context,
//     message: message,
//     backgroundColor: COLORS
//         .neutralDarkTwo);
//     }));
//     } else if (searchFriendLists[index]
//         .friendRequestSent !=
//     null) {
//     showInterestedBloc.add(
//     UnSendFriendEvent(
//     userId: searchFriendLists[
//     index]
//         .id,
//     onSuccess: (message) {
//     setState(() {
//     searchFriendLists[
//     index]
//         .friendRequestSent =
//     null;
//     });
//     },
//     onError: (message) {
//     showCustomSnackBar(
//     context: context,
//     message: message,
//     );
//     }));
//     } else {
//     showInterestedBloc.add(
//     AddFriendEvent(
//     userId: searchFriendLists[
//     index]
//         .id,
//     onSuccess: (message) {
//     setState(() {
//     searchFriendLists[
//     index]
//         .friendRequestSent =
//     FriendRequestSent(
//     userId:
//     searchFriendLists[
//     index]
//         .id,
//     );
//     });
//     },
//     onError: (message) {
//     showCustomSnackBar(
//     context: context,
//     message: message,
//     );
//     }));
//     }
//     },
//     buttonRequired:
//     searchFriendLists[index]
//         .isFriend ==
//     null,
//     sendMessageButtonRequired:
//     searchFriendLists[index]
//         .isFriend !=
//     null,
//     );
//     }),
//     ),
//     );
//     } else if (state is FriendsAddListFailed) {
//     return ErrorScreen(onRetry: () {
//     _fetchData();
//     });
//     }
//     return Container();
//     },
//     )
//     ],
//     )),
//     SafeArea(
//     child: Column(
//     crossAxisAlignment: CrossAxisAlignment.center,
//     mainAxisAlignment: MainAxisAlignment.start,
//     children: [
//     Container(
//     padding: EdgeInsets.symmetric(
//     horizontal: SizeConfig.blockWidth * 4.5,
//     vertical: SizeConfig.blockHeight * 2,
//     ),
//     child: Row(
//     children: [
//     Expanded(
//     child: TextField(
//     controller: _searchController,
//     style: TextStyle(
//     color: COLORS.neutralDarkOne,
//     fontSize: SizeConfig.blockWidth * 3.25,
//     fontWeight: FontWeight.w400,
//     fontFamily: "Poppins",
//     ),
//     cursorColor: COLORS.black,
//     decoration: InputDecoration(
//     fillColor:
//     COLORS.neutralDarkTwo.withOpacity(0.6),
//     focusColor:
//     COLORS.neutralDarkTwo.withOpacity(0.6),
//     filled: true,
//     hintText: 'Ex: Search'.tr(),
//     hintStyle: TextStyle(
//     color: COLORS.neutralDarkOne,
//     fontSize: SizeConfig.blockWidth * 3.25,
//     fontWeight: FontWeight.w400,
//     fontFamily: "Poppins",
//     ),
//     prefixIcon: Padding(
//     padding: EdgeInsets.all(
//     SizeConfig.blockWidth * 4),
//     child: Image.asset(
//     'assets/images/home/search.png',
//     width: SizeConfig.blockWidth * 3.5,
//     height: SizeConfig.blockWidth * 3.5,
//     fit: BoxFit.cover,
//     ),
//     ),
//     border: OutlineInputBorder(
//     borderRadius: BorderRadius.circular(
//     SizeConfig.blockWidth * 3.25),
//     borderSide: BorderSide(
//     color: COLORS.neutralDarkTwo
//         .withOpacity(0.6),
//     width: SizeConfig.blockWidth * 0.1),
//     ),
//     focusedBorder: OutlineInputBorder(
//     borderRadius: BorderRadius.circular(
//     SizeConfig.blockWidth * 3.25),
//     borderSide: BorderSide(
//     color: COLORS.neutralDarkTwo
//         .withOpacity(0.6),
//     width: SizeConfig.blockWidth * 0.1),
//     ),
//     enabledBorder: OutlineInputBorder(
//     borderRadius: BorderRadius.circular(
//     SizeConfig.blockWidth * 3.25),
//     borderSide: BorderSide(
//     color: COLORS.neutralDarkTwo
//         .withOpacity(0.6),
//     width: SizeConfig.blockWidth * 0.1),
//     ),
//     ),
//     onChanged: _onSearchChanged,
//     ),
//     ),
//     SizedBox(width: SizeConfig.blockWidth * 3),
//     InkWell(
//     onTap: () async {
//     final result =
//     await showMaterialModalBottomSheet(
//     enableDrag: true,
//     expand: false,
//     isDismissible: true,
//     backgroundColor: COLORS.white,
//     closeProgressThreshold: 0,
//     duration: const Duration(seconds: 0),
//     context: context,
//     shape: RoundedRectangleBorder(
//     borderRadius: BorderRadius.vertical(
//     top: Radius.circular(
//     SizeConfig.blockWidth * 6)),
//     ),
//     builder: (context) =>
//     MultiBlocProvider(
//     providers: [
//     BlocProvider(
//     create: (context) {
//     final bloc =
//     InitialRegisterBloc();
//     bloc.add(
//     const FetchCityEvent());
//     return bloc;
//     },
//     ),
//     ],
//     child:
//     CustomFilterBottomSheet(
//     title: 'City',
//     showSearch: true,
//     options: [
//     'All',
//     'Bengaluru',
//     'Mysuru',
//     'Mangaluru',
//     'Hubballi',
//     'Belagavi',
//     'Davanagere',
//     'Ballari',
//     'Tumakuru',
//     'Shivamogga',
//     'Kalaburagi',
//     'Vijayapur',
//     'Raichur',
//     'Bidar',
//     'Hassan',
//     'Chitradurga',
//     'Mandya',
//     'Karwar',
//     'Udupi',
//     ],
//     selectedOptions: [
//     'Bengaluru'
//     ],
//     onSubmit: (selectedList) {
//     // Do something with selectedList
//     print(
//     "Selected cities: $selectedList");
//     Navigator.pop(context);
//     },
//     )));
//
//     if (result != null) {}
//     },
//     borderRadius: BorderRadius.circular(
//     SizeConfig.blockWidth * 2.5),
//     child: Container(
//     padding:
//     EdgeInsets.all(SizeConfig.blockWidth * 4),
//     height: SizeConfig.blockHeight * 8,
//     width: SizeConfig.blockHeight * 8,
//     decoration: BoxDecoration(
//     borderRadius: BorderRadius.circular(
//     SizeConfig.blockWidth * 2.5),
//     color: COLORS.neutralDarkTwo
//         .withOpacity(0.6)),
//     child: Image.asset(
//     'assets/images/home/filter.png',
//     width: SizeConfig.blockWidth * 5.5,
//     height: SizeConfig.blockWidth * 5.5,
//     fit: BoxFit.contain,
//     ),
//     ),
//     ),
//     ],
//     ),
//     ),
//     Divider(
//     color: COLORS.neutralDarkTwo,
//     height: SizeConfig.blockHeight,
//     ),
//     BlocConsumer<FriendsBloc, FriendsState>(
//     listener: (context, state) {
//     if (state is FriendsAddListSuccess) {
//     setState(() {
//     searchFriendLists = state.searchFriendLists;
//     isFetchingMore = false;
//     maxPageNumber = state.maxPageNumber;
//     });
//     } else if (state is FriendsAddListFailed) {
//     setState(() {
//     isFetchingMore = false;
//     });
//     }
//     },
//     builder: (context, state) {
//     if (state is FriendsListLoading &&
//     currentPage == 1) {
//     return friendsListLoading();
//     } else if (state is FriendsAddListSuccess) {
//     return Expanded(
//     child: Padding(
//     padding: EdgeInsets.only(
//     left: SizeConfig.blockWidth * 4.5,
//     right: SizeConfig.blockWidth * 4.5,
//     top: SizeConfig.blockHeight * 0.2,
//     bottom: SizeConfig.blockHeight,
//     ),
//     child: ListView.builder(
//     itemCount: searchFriendLists.length,
//     shrinkWrap: true,
//     scrollDirection: Axis.vertical,
//     itemBuilder: (context, index) {
//     return friendSearchDetailsCards(
//     image: searchFriendLists[index]
//         .profilePic,
//     name: searchFriendLists[index].name,
//     onTapCard: () {
//     Navigator.push(
//     context,
//     MaterialPageRoute(
//     builder:
//     (context) =>
//     MultiBlocProvider(
//     providers: [
//     BlocProvider(
//     create:
//     (context) {
//     final bloc =
//     FriendsBloc();
//     bloc.add(FetchFriendsSingleView(
//     friendId: state
//         .searchFriendLists[index]
//         .id));
//     return bloc;
//     },
//     ),
//     BlocProvider(
//     create: (context) =>
//     ShowInterestedBloc(),
//     ),
//     BlocProvider(
//     create: (context) =>
//     ReportPostBloc()),
//     BlocProvider(
//     create: (context) =>
//     ShowInterestedBloc()),
//     BlocProvider(
//     create: (context) =>
//     ChartBloc())
//     ],
//     child:
//     FriendsDetailsScreen(
//     refreshPageCallback:
//     _refreshPageAfterEdit,
//     id: state
//         .searchFriendLists[
//     index]
//         .id,
//     ),
//     )));
//     },
//     added: searchFriendLists[index]
//         .friendRequestSent !=
//     null
//     ? true
//         : false,
//     disc: searchFriendLists[index]
//         .professionType!,
//     bgFriend: true,
//     onTapButtonCard: () {
//     if (searchFriendLists[index]
//         .isFriend !=
//     null) {
//     chartBloc.add(StartMessageEvent(
//     chatId:
//     searchFriendLists[index]
//         .isFriend!
//         .friendId!,
//     onSuccess: (chatId) {
//     print(chatId);
//     Navigator.push(
//     context,
//     MaterialPageRoute(
//     builder: (context) =>
//     MultiBlocProvider(
//     providers: [
//     BlocProvider(
//     create: (context) => ChartBloc()
//     ..add(FetchChartViewEvent(
//     page:
//     1,
//     pageSize:
//     10,
//     chatId:
//     chatId)),
//     ),
//     BlocProvider(
//     create: (context) =>
//     InitialRegisterBloc()),
//     BlocProvider(
//     create: (context) =>
//     ShowInterestedBloc()),
//     ],
//     child:
//     ChatViewScreen(
//     refreshPageCallback:
//     _refreshPageAfterEdit,
//     chatId:
//     chatId,
//     isGroup:
//     false,
//     ),
//     )));
//     },
//     onError: (message) {
//     showCustomSnackBar(
//     context: context,
//     message: message,
//     backgroundColor: COLORS
//         .neutralDarkTwo);
//     }));
//     } else if (searchFriendLists[index]
//         .friendRequestSent !=
//     null) {
//     showInterestedBloc.add(
//     UnSendFriendEvent(
//     userId: searchFriendLists[
//     index]
//         .id,
//     onSuccess: (message) {
//     setState(() {
//     searchFriendLists[
//     index]
//         .friendRequestSent =
//     null;
//     });
//     },
//     onError: (message) {
//     showCustomSnackBar(
//     context: context,
//     message: message,
//     );
//     }));
//     } else {
//     showInterestedBloc.add(
//     AddFriendEvent(
//     userId: searchFriendLists[
//     index]
//         .id,
//     onSuccess: (message) {
//     setState(() {
//     searchFriendLists[
//     index]
//         .friendRequestSent =
//     FriendRequestSent(
//     userId:
//     searchFriendLists[
//     index]
//         .id,
//     );
//     });
//     },
//     onError: (message) {
//     showCustomSnackBar(
//     context: context,
//     message: message,
//     );
//     }));
//     }
//     },
//     buttonRequired:
//     searchFriendLists[index]
//         .isFriend ==
//     null,
//     sendMessageButtonRequired:
//     searchFriendLists[index]
//         .isFriend !=
//     null,
//     );
//     }),
//     ),
//     );
//     } else if (state is FriendsAddListFailed) {
//     return ErrorScreen(onRetry: () {
//     _fetchData();
//     });
//     }
//     return Container();
//     },
//     )
//     ],
//     ))
//     ],
//     ),
//     ),
//     ],
//     ),
//     ),
//     >>>>>>> 0651470ac4778c022b0e8b2b5e9969a56adf3355
//     ),
//     );
//   }
// }
