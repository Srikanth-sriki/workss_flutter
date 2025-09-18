import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:works_app/bloc/profile/profile_bloc.dart';
import 'package:works_app/bloc/show_interested/show_interested_bloc.dart';
import 'package:works_app/components/size_config.dart';
import 'package:works_app/global_helper/popup.dart';
import 'package:works_app/models/fetch_posted_work.dart';
import 'package:works_app/ui/profile/component.dart';
import 'package:works_app/ui/profile/view_insights.dart';

import '../../bloc/chart/chart_bloc.dart';
import '../../bloc/home/home_bloc.dart';
import '../../bloc/post_work/post_work_bloc.dart';
import '../../bloc/professional/professional_bloc.dart';
import '../../bloc/report_post_bloc.dart';
import '../../components/colors.dart';
import '../../global_helper/helper_function.dart';
import '../../global_helper/loading_placeholder/home_layout.dart';
import '../../global_helper/reuse_widget.dart';
import '../../models/fetch_profile_model.dart';
import '../home/component.dart';
import '../home/work_details.dart';
import '../post_work/edit_post_work.dart';

class PostedWorkList extends StatefulWidget {
  const PostedWorkList({super.key});

  @override
  State<PostedWorkList> createState() => _PostedWorkListState();
}

class _PostedWorkListState extends State<PostedWorkList> {
  late ProfileBloc profileBloc;
  late List<FetchPostedModel> fetchPostedModel;
  bool loading = true;
  bool error = false;

  @override
  void initState() {
    super.initState();
    profileBloc = BlocProvider.of<ProfileBloc>(context);
  }

  void _refreshPageAfterEdit() {
    profileBloc.add(const FetchPostedEvent());
  }

  void _removePostedWorkItem(String workId) {
    setState(() {
      fetchPostedModel.removeWhere((item) => item.id == workId);
    });
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: COLORS.white,
      appBar: const CustomAppBar(
        title: 'Posted Works',
        backgroundColor: COLORS.white,
        titleColors: COLORS.neutralDark,
      ),
      body: SafeArea(
        child: BlocListener<ProfileBloc, ProfileState>(
          listener: (context, state) {
            if (state is ProfileLoading || state is ProfileInitial) {
              setState(() {
                loading = true;
                error = false;
              });
            } else if (state is FetchPostedWorkSuccess) {
              setState(() {
                loading = false;
                error = false;
                fetchPostedModel = state.fetchPostedModel!;
              });
            } else if (state is FetchPostedWorkFailed) {
              setState(() {
                loading = false;
                error = true;
              });
            }
          },
          child: Builder(
            builder: (context) {
              if (loading) {
                return SizedBox(
                    height: SizeConfig.screenHeight,
                    child: const ShimmerJobCards());
              } else if (error) {
                return SizedBox(
                    height: SizeConfig.screenHeight,
                    child: ErrorScreen(onRetry: () {
                  _refreshPageAfterEdit();
                }));
              } else if (!loading && !error) {
                return fetchPostedModel.isNotEmpty
                    ? SingleChildScrollView(
                      child: Padding(
                          padding: EdgeInsets.symmetric(
                              vertical: SizeConfig.blockHeight),
                          child: ListView.builder(
                            shrinkWrap: true,
                            physics: const NeverScrollableScrollPhysics(),
                            itemCount: fetchPostedModel.length,
                            itemBuilder: (context, index) {
                              var profile = fetchPostedModel[index];
                              final languages = profile.knowLanguage!
                                  .map((lang) => lang.tr())
                                  .join(", ");
                              return Padding(
                                padding: EdgeInsets.symmetric(
                                  vertical: SizeConfig.blockWidth * 1.5,
                                  horizontal: SizeConfig.blockHeight * 2.5,
                                ),
                                child: WorkCard(
                                  title: profile.professionalSubCategory != null ? getCategoryProfessionCardName(profile.professionalSubCategory) :profile.requiredProfession!,
                                  location:'${profile.locality} ${profile.city}' ?? '--',
                                  timeAgo: timeAgo(profile.updatedAt!),
                                  jobType: profile.workPlaceCategory != null ? getCategoryWorkPlaceCardName(profile.workPlaceCategory) :profile.workPlace!,
                                  experience: profile.experienceLevel!,
                                  gender: profile.gender!,
                                  language: languages,
                                  experienceImage:
                                      'assets/images/home/work_select.png',
                                  genderImage: 'assets/images/home/gender.png',
                                  jobTypeImage: 'assets/images/home/home.png',
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
                                                        workId: profile.id!)),
                                                ),
                                                BlocProvider(
                                                  create: (context) => ShowInterestedBloc(),
                                                ),
                                                BlocProvider(create: (context)=>ReportPostBloc())
                                              ],
                                              child: WorkDetailsScreen(
                                                id: profile.id!,
                                                refreshPageCallback: _refreshPageAfterEdit,
                                                routeType: 'posted',
                                              ),
                                            )));
                                  },
                                  actionRows: Column(
                                    children: [
                                      Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.spaceBetween,
                                        crossAxisAlignment:
                                            CrossAxisAlignment.center,
                                        children: [
                                          Expanded(
                                            child: Container(
                                              padding: EdgeInsets.symmetric(
                                                vertical:
                                                    SizeConfig.blockHeight *
                                                        1.25,
                                                horizontal:
                                                    SizeConfig.blockWidth * 6,
                                              ),
                                              decoration: BoxDecoration(
                                                color: COLORS.primary
                                                    .withOpacity(0.2),
                                                borderRadius: BorderRadius.all(
                                                  Radius.circular(
                                                      SizeConfig.blockWidth *
                                                          3),
                                                ),
                                              ),
                                              child: Row(
                                                mainAxisAlignment:
                                                    MainAxisAlignment.center,
                                                crossAxisAlignment:
                                                    CrossAxisAlignment.center,
                                                children: [
                                                  Text(
                                                    profile
                                                        .workIntrests!.length!
                                                        .toString(),
                                                    style: TextStyle(
                                                      color: COLORS.primary,
                                                      fontSize: SizeConfig
                                                              .blockWidth *
                                                          6,
                                                      fontWeight:
                                                          FontWeight.w600,
                                                      fontFamily: "Poppins",
                                                    ),
                                                  ),
                                                  SizedBox(
                                                      width: SizeConfig
                                                              .blockWidth *
                                                          1.5),
                                                  Text(
                                                    'Interested \nProfessionals'.tr(),
                                                    style: TextStyle(
                                                      color: COLORS.black,
                                                      fontSize: SizeConfig
                                                              .blockWidth *
                                                          2.5,
                                                      fontWeight:
                                                          FontWeight.w400,
                                                      fontFamily: "Poppins",
                                                      height: SizeConfig
                                                              .blockHeight *
                                                          0,
                                                    ),
                                                  )
                                                ],
                                              ),
                                            ),
                                          ),
                                          SizedBox(
                                              width: SizeConfig.blockWidth *
                                                  2), // Space between the two containers
                                          Expanded(
                                            child: Container(
                                              padding: EdgeInsets.symmetric(
                                                vertical:
                                                    SizeConfig.blockHeight *
                                                        1.25,
                                                horizontal:
                                                    SizeConfig.blockWidth * 6,
                                              ),
                                              decoration: BoxDecoration(
                                                color: COLORS.primary
                                                    .withOpacity(0.2),
                                                borderRadius: BorderRadius.all(
                                                  Radius.circular(
                                                      SizeConfig.blockWidth *
                                                          3),
                                                ),
                                              ),
                                              child: Row(
                                                mainAxisAlignment:
                                                    MainAxisAlignment.center,
                                                crossAxisAlignment:
                                                    CrossAxisAlignment.center,
                                                children: [
                                                  Text(
                                                    profile.workViews!.length!
                                                        .toString(),
                                                    style: TextStyle(
                                                      color: COLORS.accent,
                                                      fontSize: SizeConfig
                                                              .blockWidth *
                                                          6,
                                                      fontWeight:
                                                          FontWeight.w600,
                                                      fontFamily: "Poppins",
                                                    ),
                                                  ),
                                                  SizedBox(
                                                      width: SizeConfig
                                                              .blockWidth *
                                                          1.5),
                                                  Text(
                                                    'Work Post \nViewed by'.tr(),
                                                    style: TextStyle(
                                                      color: COLORS.black,
                                                      fontSize: SizeConfig.blockWidth * 2.5,
                                                      fontWeight:
                                                          FontWeight.w400,
                                                      fontFamily: "Poppins",
                                                      height: SizeConfig
                                                              .blockHeight *
                                                          0,
                                                    ),
                                                  )
                                                ],
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                      SizedBox(
                                        height: SizeConfig.blockHeight * 1.5,
                                      ),
                                      Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.spaceBetween,
                                        crossAxisAlignment:
                                            CrossAxisAlignment.center,
                                        children: [
                                          customIconButton(
                                            text: 'VIEW INSIGHTS',
                                            onPressed: () {
                                              Navigator.push(
                                                  context,
                                                  MaterialPageRoute(
                                                      builder: (context) =>
                                                          MultiBlocProvider(
                                                            providers: [
                                                              BlocProvider(
                                                                create: (context) =>
                                                                    ProfileBloc()
                                                                      ..add(FetchPostViewEvent(
                                                                          workId:
                                                                              profile.id!)),
                                                              ),
                                                              BlocProvider(
                                                                create: (context) =>
                                                                    ShowInterestedBloc(),
                                                              ),
                                                              BlocProvider(create: (context) => ChartBloc())
                                                            ],
                                                            child:
                                                                ViewInsightsScreen(
                                                              id: profile.id!,
                                                            ),
                                                          )));
                                            },
                                            backgroundColor: COLORS.primary,
                                            showIcon: false,
                                            height:
                                                SizeConfig.blockHeight * 7,
                                            textColor: COLORS.white,
                                            width: SizeConfig.blockWidth * 55,
                                          ),
                                          Row(
                                            mainAxisAlignment:
                                                MainAxisAlignment.spaceBetween,
                                            crossAxisAlignment:
                                                CrossAxisAlignment.center,
                                            children: [
                                              IconActionCard(
                                                iconBool: false,
                                                imageUrl: Image.asset(
                                                  'assets/images/profile/edit.png',
                                                  width:
                                                      SizeConfig.blockWidth * 5,
                                                  height:
                                                      SizeConfig.blockHeight *
                                                          5,
                                                  fit: BoxFit.contain,
                                                ),
                                                onTap: () {
                                                  Navigator.push(
                                                    context,
                                                    MaterialPageRoute(
                                                      builder: (context) =>
                                                          MultiBlocProvider(
                                                        providers: [
                                                          BlocProvider(
                                                            create: (context) {
                                                              final bloc = PostWorkBloc();
                                                              bloc.add(const FetchWorkPlaceEvent());
                                                              bloc.add(const FetchWorkKnownLanguageEvent());
                                                              return bloc;
                                                            },
                                                          ),
                                                          BlocProvider(
                                                            create: (context) {
                                                              final bloc = ProfessionalBloc();
                                                              bloc.add(const FetchCategoryListEvent());
                                                              return bloc;
                                                            },
                                                          ),
                                                        ],
                                                        child:
                                                            EditPostWorkScreen(
                                                          fetchPostedModel:
                                                              profile,
                                                          refreshPageCallback:
                                                              _refreshPageAfterEdit,
                                                        ),
                                                      ),
                                                    ),
                                                  );
                                                },
                                              ),
                                              IconActionCard(
                                                iconBool: false,
                                                imageUrl: Image.asset(
                                                  'assets/images/profile/delete.png',
                                                  width:
                                                      SizeConfig.blockWidth * 5,
                                                  height:
                                                      SizeConfig.blockHeight *
                                                          5,
                                                  fit: BoxFit.contain,
                                                ),
                                                onTap: () {
                                                  showCustomAlertDialog(
                                                    context: context,
                                                    title: 'Do you want to Delete?',
                                                    message: 'Do you want to Delete your Posted Work?',
                                                    positiveButtonText: 'DELETE',
                                                    negativeButtonText: 'CANCEL',
                                                    onPositivePressed: () {
                                                      PostWorkBloc().add(
                                                        PostWorkDeleteEvent(
                                                          workID: profile.id!,
                                                          onSuccess: () {
                                                            _removePostedWorkItem(
                                                                profile.id!);
                                                            showCustomSnackBar(
                                                              context: context,
                                                              message:
                                                              "Posted Work deleted successfully!",
                                                              backgroundColor:
                                                              COLORS
                                                                  .semanticTwo,
                                                            );
                                                            Navigator.of(context).pop();
                                                          },
                                                          onError: () {
                                                            showCustomSnackBar(
                                                              context: context,
                                                              message: "Something Went wrong",
                                                            );
                                                            Navigator.of(context).pop();
                                                          },
                                                        ),
                                                      );
                                                    },
                                                    onNegativePressed: () {
                                                      Navigator.of(context).pop();
                                                    },
                                                  );

                                                },
                                                color: COLORS.accent.withOpacity(0.1),
                                              ),
                                            ],
                                          ),
                                        ],
                                      ),
                                    ],
                                  ),
                                ),
                              );
                            },
                          ),
                        ),
                    )
                    : SizedBox(
                        width: SizeConfig.screenWidth,
                        height: SizeConfig.blockHeight * 80,
                        child: emptyComponent());
              }

              return Container();
            },
          ),
        ),
      ),
    );
  }
}
