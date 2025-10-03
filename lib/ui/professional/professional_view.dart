import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:modal_bottom_sheet/modal_bottom_sheet.dart';
import 'package:works_app/components/size_config.dart';
import 'package:works_app/global_helper/image_preview_modal.dart';
import 'package:works_app/global_helper/loading_placeholder/home_layout.dart';

import '../../bloc/chart/chart_bloc.dart';
import '../../bloc/professional/professional_bloc.dart';
import '../../bloc/register_account/initial_register_bloc.dart';
import '../../bloc/report_post_bloc.dart';
import '../../bloc/show_interested/show_interested_bloc.dart';
import '../../components/colors.dart';
import '../../global_helper/helper_function.dart';
import '../../global_helper/readmore_text.dart';
import '../../global_helper/report_post.dart';
import '../../global_helper/reuse_widget.dart';
import '../../models/professional_view_model.dart';
import '../chat/chat_view.dart';
import '../chat/component.dart';
import '../profile/component.dart';
import 'component/grid_image_card.dart';

class ProfessionalViewScreen extends StatefulWidget {
  final VoidCallback refreshPageCallback;
  final String id;
  const ProfessionalViewScreen(
      {super.key, required this.id, required this.refreshPageCallback});

  @override
  State<ProfessionalViewScreen> createState() => _ProfessionalViewScreenState();
}

class _ProfessionalViewScreenState extends State<ProfessionalViewScreen> {
  late ProfessionalBloc professionalBloc;
  late ShowInterestedBloc showInterestedBloc;
  late ReportPostBloc reportPostBloc;
  late ChartBloc chartBloc;
  final bool saved = false;
  late final bool smartControlEnabled;

  @override
  void initState() {
    super.initState();
    professionalBloc = BlocProvider.of<ProfessionalBloc>(context);
    showInterestedBloc = BlocProvider.of<ShowInterestedBloc>(context);
    reportPostBloc = BlocProvider.of<ReportPostBloc>(context);
    chartBloc = BlocProvider.of<ChartBloc>(context);
  }

  void _refreshPageAfterEdit() {
    professionalBloc.add(FetchProfessionalView(widget.id));
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<ProfessionalBloc, ProfessionalState>(
      listener: (context, state) {
        if(state is ProfessionalViewSuccess){
          final professional = state.professionalViewModel.professional!;
          setState(() {
            smartControlEnabled = isSmartControlEnabled(
              professional.smartCallControl,
              professional.smartCallSchedule,
            );
          });
        }
      },
      builder: (context, state) {
        if (state is ProfessionalViewLoading || state is ProfessionalInitial) {
          return globalLoadingWidget();
        } else if (state is ProfessionalViewSuccess) {
          final professional = state.professionalViewModel.professional!;
          final similarProfessionals =
              state.professionalViewModel.similarProfessionals!;
          return Scaffold(
            backgroundColor: COLORS.white,
            appBar: AppBar(
              toolbarHeight: 0,
              scrolledUnderElevation: 0,
              automaticallyImplyLeading: false,
              backgroundColor: COLORS.white,
            ),
            body: SafeArea(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Container(
                    padding: EdgeInsets.symmetric(
                        horizontal: SizeConfig.blockWidth * 2.5,
                        vertical: SizeConfig.blockHeight),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.start,
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            IconButton(
                              icon: Icon(Icons.arrow_back_ios,
                                  color: COLORS.black,
                                  size: SizeConfig.blockWidth * 4.5),
                              onPressed: () {
                                Navigator.pop(context);
                              },
                            ),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.start,
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                InkWell(
                                  onTap: () => showModernImagePreview(context, professional.profilePic!,heroTag:  'profView_${professional.id!}'),
                                  splashColor: COLORS.white.withOpacity(0.2),
                                  borderRadius: BorderRadius.circular(SizeConfig.blockWidth * 12 / 2),
                                  child: Container(
                                    width: SizeConfig.blockWidth * 12,
                                    height: SizeConfig.blockWidth * 12,
                                    decoration: BoxDecoration(
                                        border: Border.all(
                                            color: COLORS.primary,
                                            width: SizeConfig.blockWidth * 0.2),
                                        image: DecorationImage(
                                            image: NetworkImage(
                                                professional.profilePic!),
                                            fit: BoxFit.cover),
                                        borderRadius: BorderRadius.all(
                                            Radius.circular(
                                                SizeConfig.blockWidth * 6))),
                                  ),
                                ),
                                SizedBox(width: SizeConfig.blockWidth * 2),
                                Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Row(
                                      children: [
                                        SizedBox(
                                          width: professional.isVerified == true
                                              ? SizeConfig.blockWidth * 15
                                              : SizeConfig.blockWidth * 45,
                                          child: Text(professional.name!,
                                              style: TextStyle(
                                                color: COLORS.neutralDark,
                                                fontSize:
                                                    SizeConfig.blockWidth * 4,
                                                fontWeight: FontWeight.w500,
                                                fontFamily: "Poppins",
                                                overflow: TextOverflow.ellipsis,
                                              ),
                                              maxLines: 1),
                                        ),
                                        if (professional.isVerified ==
                                            true) ...[
                                          Container(
                                            padding: EdgeInsets.symmetric(
                                                horizontal:
                                                    SizeConfig.blockWidth * 3,
                                                vertical:
                                                    SizeConfig.blockHeight *
                                                        0.5),
                                            decoration: BoxDecoration(
                                              color: COLORS.semanticTwo,
                                              borderRadius: BorderRadius.all(
                                                  Radius.circular(
                                                      SizeConfig.blockWidth *
                                                          3.8)),
                                            ),
                                            child: Row(
                                              mainAxisAlignment:
                                                  MainAxisAlignment.center,
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.center,
                                              children: [
                                                Icon(
                                                  Icons.verified,
                                                  color: COLORS.white,
                                                  size: SizeConfig.blockWidth *
                                                      3.5,
                                                ),
                                                SizedBox(
                                                  width: SizeConfig.blockWidth *
                                                      1.5,
                                                ),
                                                Text(
                                                  'Verified'.tr(),
                                                  style: TextStyle(
                                                    color: COLORS.white,
                                                    fontSize:
                                                        SizeConfig.blockWidth *
                                                            3,
                                                    fontWeight: FontWeight.w400,
                                                    fontFamily: "Poppins",
                                                  ),
                                                ),
                                              ],
                                            ),
                                          )
                                        ],
                                      ],
                                    ),
                                    Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.start,
                                      crossAxisAlignment:
                                          CrossAxisAlignment.center,
                                      children: [
                                        Icon(
                                          Icons.location_on_rounded,
                                          color: COLORS.accent,
                                          size: SizeConfig.blockWidth * 3.5,
                                        ),
                                        SizedBox(
                                            width: SizeConfig.blockWidth * 1),
                                        SizedBox(
                                          width: SizeConfig.blockWidth * 40,
                                          child: Text(
                                            professional.city!,
                                            style: TextStyle(
                                              color: COLORS.neutralDarkOne,
                                              fontSize:
                                                  SizeConfig.blockWidth * 3,
                                              fontWeight: FontWeight.w400,
                                              fontFamily: "Poppins",
                                              overflow: TextOverflow.ellipsis,
                                            ),
                                            maxLines: 1,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ],
                        ),
                        Row(
                            mainAxisAlignment: MainAxisAlignment.start,
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              InkWell(
                                onTap: () {
                                  if (professional.isSaved == null) {
                                    showInterestedBloc.add(ProfessionalSavedUs(
                                      PropId: professional.id!,
                                      onSuccess: () {
                                        setState(() {
                                          professional.isSaved =
                                              IsContacted(id: '');
                                        });
                                        widget.refreshPageCallback();
                                      },
                                      onError: () {},
                                    ));
                                  } else {
                                    showInterestedBloc.add(ProfessionalSavedUs(
                                      PropId: professional.id!,
                                      onSuccess: () {
                                        setState(() {
                                          professional.isSaved = null;
                                        });
                                        widget.refreshPageCallback();
                                      },
                                      onError: () {
                                        showCustomSnackBar(
                                          context: context,
                                          message: "Something Went wrong",
                                        );
                                      },
                                    ));
                                  }
                                },
                                child: Image.asset(
                                  professional.isSaved != null
                                      ? 'assets/images/professions/bookmarked.png'
                                      : 'assets/images/profile/bookmark.png',
                                  width: professional.isSaved != null
                                      ? SizeConfig.blockWidth * 5.25
                                      : SizeConfig.blockWidth * 4.25,
                                  height: professional.isSaved != null
                                      ? SizeConfig.blockHeight * 5.25
                                      : SizeConfig.blockHeight * 4.25,
                                  fit: BoxFit.contain,
                                  color: professional.isSaved != null
                                      ? COLORS.accent
                                      : COLORS.neutralDarkOne,
                                ),
                              ),
                              IconButton(
                                icon: Icon(Icons.more_vert,
                                    color: COLORS.black,
                                    size: SizeConfig.blockWidth * 6.5),
                                onPressed: () async {
                                  showDynamicBottomSheet(
                                      context,
                                      'OPTIONS',
                                      [
                                        BottomSheetItem(
                                          title: 'Report',
                                          onTap: () async {
                                            final result =
                                                await showMaterialModalBottomSheet(
                                                    enableDrag: true,
                                                    expand: false,
                                                    isDismissible: true,
                                                    backgroundColor:
                                                        COLORS.white,
                                                    closeProgressThreshold: 0,
                                                    duration: const Duration(
                                                        seconds: 0),
                                                    context: context,
                                                    shape:
                                                        RoundedRectangleBorder(
                                                      borderRadius:
                                                          BorderRadius.vertical(
                                                              top: Radius.circular(
                                                                  SizeConfig
                                                                          .blockWidth *
                                                                      6)),
                                                    ),
                                                    builder: (context) =>
                                                        const ReportPostsBottomSheet(
                                                          message: '',
                                                        ));

                                            if (result != null) {
                                              setState(() {
                                                reportPostBloc.add(
                                                    ReportProfessionalEvent(
                                                  reason: result['message']!,
                                                  userId: professional.id!,
                                                  onSuccess: (message) {
                                                    Navigator.pop(context);
                                                    showCustomSnackBar(
                                                        context: context,
                                                        message: message,
                                                        backgroundColor: COLORS
                                                            .neutralDarkOne);
                                                  },
                                                  onError: (message) {
                                                    Navigator.pop(context);
                                                    showCustomSnackBar(
                                                      context: context,
                                                      message: message,
                                                    );
                                                  },
                                                ));
                                              });
                                            }
                                          },
                                        ),
                                        BottomSheetItem(
                                            title: professional.isFriend != null ? 'UNFRIEND'.tr() : professional.friendRequestSent != null ? 'REQUEST SENT'.tr() : 'ADD FRIEND'.tr(),
                                            onTap: () async {
                                              if (professional.isFriend != null) {
                                                showInterestedBloc.add(
                                                    UnfriendsEvent(
                                                        friendId:
                                                            professional.id!,
                                                        onSuccess: (message) {
                                                          Navigator.pop(context);
                                                          setState(() {
                                                            professional
                                                                    .isFriend =
                                                                null;
                                                            professional
                                                                    .friendRequestSent =
                                                                null;
                                                            widget.refreshPageCallback();
                                                          });
                                                          showCustomSnackBar(
                                                              context: context,
                                                              message:
                                                                  "Successfully unfriended!",
                                                              backgroundColor:
                                                                  COLORS
                                                                      .semanticTwo);
                                                        },
                                                        onError: (message) {
                                                          showCustomSnackBar(
                                                            context: context,
                                                            message: message,
                                                          );
                                                        }));
                                              } else if (professional
                                                      .friendRequestSent !=
                                                  null) {
                                                showInterestedBloc.add(
                                                    UnSendFriendEvent(
                                                        userId:
                                                            professional.id!,
                                                        onSuccess: (message) {
                                                          Navigator.pop(context);
                                                          setState(() {
                                                            professional.isFriend = null;
                                                            professional.friendRequestSent = null;

                                                            widget.refreshPageCallback();
                                                          });
                                                          showCustomSnackBar(
                                                            context: context,
                                                            message: message,
                                                            backgroundColor: COLORS.neutralDarkTwo
                                                          );
                                                        },
                                                        onError: (message) {
                                                          showCustomSnackBar(
                                                            context: context,
                                                            message: message,
                                                          );
                                                        }));
                                              } else {
                                                showInterestedBloc.add(
                                                    AddFriendEvent(
                                                        userId:
                                                            professional.id!,
                                                        onSuccess: (message) {
                                                          widget
                                                              .refreshPageCallback();
                                                          Navigator.pop(context);
                                                          setState(() {
                                                            professional
                                                                    .friendRequestSent =
                                                                FriendRequestSent(
                                                              id: professional
                                                                  .id,
                                                            );
                                                          });
                                                          showCustomSnackBar(
                                                              context: context,
                                                              message: message,
                                                              backgroundColor: COLORS.neutralDarkTwo
                                                          );
                                                        },
                                                        onError: (message) {
                                                          showCustomSnackBar(
                                                            context: context,
                                                            message: message,
                                                          );
                                                        }));
                                              }
                                            })
                                      ]);
                                },
                              ),
                            ]),
                      ],
                    ),
                  ),
                  Divider(
                    color: COLORS.neutralDarkTwo,
                    thickness: SizeConfig.blockHeight * 0.15,
                    height: SizeConfig.blockHeight * 1.5,
                  ),
                  Expanded(
                    child: SingleChildScrollView(
                      child: Padding(
                        padding: EdgeInsets.symmetric(
                            horizontal: SizeConfig.blockWidth * 6,
                            vertical: SizeConfig.blockHeight),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Padding(
                              padding: EdgeInsets.only(
                                  bottom: SizeConfig.blockHeight * 0.5),
                              child: Text(
                                'Professional Details'.tr(),
                                style: TextStyle(
                                  color: COLORS.neutralDarkOne,
                                  fontSize: SizeConfig.blockWidth * 3.6,
                                  fontWeight: FontWeight.w400,
                                  fontFamily: "Poppins",
                                ),
                              ),
                            ),
                            registerTextCard(
                                text: professional.professionalSubCategory != null ? getCategoryProfessionCardName(professional.professionalSubCategory) :professional
                                    .professionType!,
                                image: 'assets/images/home/home.png',
                                color: COLORS.primary,
                                textColor: COLORS.neutralDark),
                            registerTextCard(
                                text:
                                    "${professional.experiencedYears!}y ${'Experience'.tr()}",
                                image: 'assets/images/home/work_select.png',
                                color: COLORS.primary,
                                textColor: COLORS.neutralDark),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: [
                                SizedBox(
                                  width: SizeConfig.blockWidth * 55,
                                  child: Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      registerTextCard(
                                          text: professional.knownLanguages!
                                              .map((lang) => lang.tr())
                                              .join(", "),
                                          image: 'assets/images/home/speak.png',
                                          color: COLORS.primary,
                                          textColor: COLORS.neutralDark),
                                      registerTextCard(
                                          text: professional.gender!,
                                          image:
                                              'assets/images/home/gender.png',
                                          color: COLORS.primary,
                                          textColor: COLORS.neutralDark),
                                    ],
                                  ),
                                ),
                                Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  crossAxisAlignment: CrossAxisAlignment.center,
                                  children: [
                                    Text(
                                      formatPrice(professional.charges!),
                                      style: TextStyle(
                                          color: COLORS.primary,
                                          fontSize: SizeConfig.blockWidth * 4.8,
                                          fontWeight: FontWeight.w600,
                                          fontFamily: "Poppins",
                                          height: SizeConfig.blockHeight * 0.2),
                                    ),
                                    Text(
                                      capitalizeEachWord(
                                          professional.chargeType!).tr(),
                                      style: TextStyle(
                                        color: COLORS.neutralDarkOne,
                                        fontSize: SizeConfig.blockWidth * 2.8,
                                        fontWeight: FontWeight.w400,
                                        fontFamily: "Poppins",
                                      ),
                                    ),
                                  ],
                                )
                              ],
                            ),
                            SizedBox(height: SizeConfig.blockHeight * 2),
                            Padding(
                              padding: EdgeInsets.only(
                                  bottom: SizeConfig.blockHeight * 0.5),
                              child: Text(
                                'Bio'.tr(),
                                style: TextStyle(
                                  color: COLORS.neutralDarkOne,
                                  fontSize: SizeConfig.blockWidth * 3.4,
                                  fontWeight: FontWeight.w400,
                                  fontFamily: "Poppins",
                                ),
                              ),
                            ),
                            ReadMoreText(
                              text: professional.bio!,
                            ),
                            SizedBox(height: SizeConfig.blockHeight * 2),
                            Padding(
                              padding: EdgeInsets.only(
                                  bottom: SizeConfig.blockHeight * 0.5),
                              child: Text(
                                'Gallery'.tr(),
                                style: TextStyle(
                                  color: COLORS.neutralDarkOne,
                                  fontSize: SizeConfig.blockWidth * 3.6,
                                  fontWeight: FontWeight.w400,
                                  fontFamily: "Poppins",
                                ),
                              ),
                            ),
                            SizedBox(height: SizeConfig.blockHeight),
                            DynamicGridExample(
                              imageUrls: professional.workImages!,
                            ),
                            SizedBox(height: SizeConfig.blockHeight * 2),
                            if (similarProfessionals.isNotEmpty) ...[
                              Padding(
                                padding: EdgeInsets.only(
                                    bottom: SizeConfig.blockHeight * 0.5,
                                    top: SizeConfig.blockHeight),
                                child: Text(
                                  'Similar Professionals'.tr(),
                                  style: TextStyle(
                                    color: COLORS.neutralDarkOne,
                                    fontSize: SizeConfig.blockWidth * 3.6,
                                    fontWeight: FontWeight.w400,
                                    fontFamily: "Poppins",
                                  ),
                                ),
                              ),
                              ListView.builder(
                                  shrinkWrap: true,
                                  physics: const NeverScrollableScrollPhysics(),
                                  itemCount: similarProfessionals.length!,
                                  itemBuilder: (context, index) {
                                    var professionalData =
                                        similarProfessionals![index];
                                    final languages = professionalData?.knownLanguages!
                                        .map((lang) => lang.tr())
                                        .join(", ");
                                    return Container(
                                      padding: EdgeInsets.symmetric(
                                        vertical: SizeConfig.blockWidth * 2,
                                      ),
                                      child: buildProfessionalCard(
                                          itemID:professionalData.id! ,
                                          context: context,
                                          accountVerified:
                                              professionalData!.isVerified!,
                                          image: professionalData!.profilePic!,
                                          name: professionalData!.name!,
                                          smartControlEnable: isSmartControlEnabled(
                                            professionalData.smartCallControl,
                                            professionalData.smartCallSchedule,
                                          ),
                                          profession:
                                          professionalData.professionalSubCategory != null ? getCategoryProfessionCardName(professionalData.professionalSubCategory) :professionalData
                                              .professionType!,
                                          location: professionalData.city!,
                                          languages: languages!,
                                          gender: professionalData.gender!,
                                          price: professionalData.charges!,
                                          paymentType:
                                              professionalData.chargeType!,
                                          contacted: professionalData.isContacted !=
                                              null,
                                          saved:
                                              professionalData.isSaved != null,
                                          experience: professionalData
                                              .experiencedYears!,
                                          experienceImage:
                                              'assets/images/home/work_select.png',
                                          genderImage:
                                              'assets/images/home/gender.png',
                                          jobTypeImage:
                                              'assets/images/profile/prof.png',
                                          language: languages!,
                                          languageImage:
                                              'assets/images/home/speak.png',
                                          onShowInterest: () {
                                            print(professionalData.id);
                                            if (professionalData.isContacted ==
                                                null) {
                                              showInterestedBloc
                                                  .add(ProfessionalContactUs(
                                                PropId: professionalData.id!,
                                                onSuccess: () {
                                                  setState(() {
                                                    professionalData
                                                            .isContacted =
                                                        IsContacted(id: '');
                                                    makePhoneCall(
                                                        professionalData
                                                            .mobile!);
                                                  });
                                                  widget.refreshPageCallback();
                                                },
                                                onError: () {},
                                              ));
                                            } else {
                                              makePhoneCall(
                                                  professionalData.mobile!);
                                            }
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
                                                           _refreshPageAfterEdit();
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
                                          jobType:
                                              professionalData.professionType!,
                                          onShare: () {
                                            shareJobDetails(
                                              experience: professionalData
                                                  .experiencedYears!,
                                              location: professionalData.city!,
                                              jobTitle: professionalData
                                                  .professionType!,
                                            );
                                          },
                                          onTap: () {
                                            Navigator.push(
                                                context,
                                                MaterialPageRoute(
                                                    builder: (context) =>
                                                        MultiBlocProvider(
                                                          providers: [
                                                            BlocProvider(
                                                              create: (context) =>
                                                                  ProfessionalBloc()
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
                                                                _refreshPageAfterEdit,
                                                          ),
                                                        )));
                                          },
                                          savedTap: () {
                                            if (professionalData.isSaved ==
                                                null) {
                                              showInterestedBloc
                                                  .add(ProfessionalSavedUs(
                                                PropId: professionalData.id!,
                                                onSuccess: () {
                                                  setState(() {
                                                    professionalData.isSaved =
                                                        IsContacted(id: '');
                                                  });
                                                  widget.refreshPageCallback();
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
                                                PropId: professionalData.id!,
                                                onSuccess: () {
                                                  setState(() {
                                                    professionalData.isSaved =
                                                        null;
                                                  });
                                                  widget.refreshPageCallback();
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
                                          }),
                                    );
                                  })
                            ]
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            bottomNavigationBar: Container(
              padding: EdgeInsets.symmetric(
                  vertical: SizeConfig.blockWidth * 4,
                  horizontal: SizeConfig.blockHeight * 4.5),
              decoration: BoxDecoration(
                  border: Border(
                      top: BorderSide(
                          color: COLORS.neutralDarkTwo,
                          width: SizeConfig.blockWidth * 0.15))),
              child: showContactUsButton(
                message: smartControlEnabled,
                  contacted: professional.isContacted != null,
                  saved: professional.isSaved != null,
                  buttonText: smartControlEnabled
                      ? (professional.isContacted != null ? 'CONTACTED' : 'CONTACT')
                      : 'Message',
                  onShare: () {
                    shareJobDetails(
                      experience: professional.experiencedYears!,
                      location: professional.city!,
                      jobTitle: professional.professionType!,
                    );
                  },
                  savedTap: () {
                    if (professional.isSaved == null) {
                      showInterestedBloc.add(ProfessionalSavedUs(
                        PropId: professional.id!,
                        onSuccess: () {
                          setState(() {
                            professional.isSaved = IsContacted(id: '');
                          });
                        },
                        onError: () {
                          showCustomSnackBar(
                            context: context,
                            message: "Something Went wrong",
                          );
                        },
                      ));
                    } else {
                      showInterestedBloc.add(ProfessionalSavedUs(
                        PropId: professional.id!,
                        onSuccess: () {
                          setState(() {
                            professional.isSaved = null;
                          });
                        },
                        onError: () {
                          showCustomSnackBar(
                            context: context,
                            message: "Something Went wrong",
                          );
                        },
                      ));
                    }
                  },
                  onShowInterest: () {
                    final smartEnabled = isSmartControlEnabled(
                      professional.smartCallControl,
                      professional.smartCallSchedule,
                    );

                    if (!smartEnabled) {
                      chartBloc.add(
                        StartMessageEvent(
                          chatId: professional.id!,
                          onSuccess: (chatId) {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => MultiBlocProvider(
                                  providers: [
                                    BlocProvider(
                                      create: (_) => ChartBloc()
                                        ..add(FetchChartViewEvent(
                                          page: 1,
                                          pageSize: 10,
                                          chatId: chatId,
                                        )),
                                    ),
                                    BlocProvider(create: (_) => InitialRegisterBloc()),
                                    BlocProvider(create: (_) => ShowInterestedBloc()),
                                  ],
                                  child: ChatViewScreen(
                                    refreshPageCallback: _refreshPageAfterEdit,
                                    chatId: chatId,
                                    isGroup: false,
                                  ),
                                ),
                              ),
                            );
                          },
                          onError: (message) {
                            showCustomSnackBar(
                              context: context,
                              message: message,
                              backgroundColor: COLORS.neutralDarkTwo,
                            );
                          },
                        ),
                      );
                    } else {
                      if (professional.isContacted == null) {
                        showInterestedBloc.add(
                          ProfessionalContactUs(
                            PropId: professional.id!,
                            onSuccess: () {
                              setState(() {
                                professional.isContacted = IsContacted(id: '');
                                makePhoneCall(professional.mobile!);
                              });
                              widget.refreshPageCallback();
                            },
                            onError: () {
                              showCustomSnackBar(
                                context: context,
                                message: "Failed to contact. Please try again.",
                              );
                            },
                          ),
                        );
                      } else {
                        makePhoneCall(professional.mobile!);
                      }
                    }
                  }

              ),
            ),
          );
        } else if (state is ProfessionalViewError) {
          return Scaffold(
            backgroundColor: COLORS.white,
            appBar: AppBar(
              toolbarHeight: 0,
              scrolledUnderElevation: 0,
            ),
            body: ErrorScreen(onRetry: () {
              professionalBloc.add(FetchProfessionalView(widget.id));
            }),
          );
        }
        return Container();
      },
    );
  }
}
