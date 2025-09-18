import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:works_app/components/size_config.dart';
import 'package:works_app/global_helper/popup.dart';
import 'package:works_app/models/fetch_posted_work.dart';
import 'package:works_app/ui/profile/component.dart';

import '../../bloc/home/home_bloc.dart';
import '../../bloc/profile/profile_bloc.dart';
import '../../bloc/report_post_bloc.dart';
import '../../bloc/show_interested/show_interested_bloc.dart';
import '../../components/colors.dart';
import '../../global_helper/helper_function.dart';
import '../../global_helper/loading_placeholder/home_layout.dart';
import '../../global_helper/reuse_widget.dart';
import '../home/component.dart';
import '../home/work_details.dart';

class InterestedWorkList extends StatefulWidget {
  const InterestedWorkList({super.key});

  @override
  State<InterestedWorkList> createState() => _InterestedWorkListState();
}

class _InterestedWorkListState extends State<InterestedWorkList> {
  late ProfileBloc profileBloc;
  late ShowInterestedBloc showInterestedBloc;
  late List<FetchPostedModel> fetchPostedModel;
  bool loading = true;
  bool error = false;

  @override
  void initState() {
    super.initState();
    profileBloc = BlocProvider.of<ProfileBloc>(context);
    showInterestedBloc = BlocProvider.of<ShowInterestedBloc>(context);
  }


  void _refreshPageAfterEdit() {
    profileBloc.add(const FetchInterestedWorkEvent());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: COLORS.white,
      appBar: const CustomAppBar(
          title: 'Interested Works',
          backgroundColor: COLORS.white,
          titleColors: COLORS.neutralDark),
      body: BlocListener<ProfileBloc, ProfileState>(
        listener: (context, state) {
          if (state is ProfileLoading || state is ProfileInitial) {
            setState(() {
              loading = true;
              error = false;
            });
          } else if (state is FetchInterestedWorkSuccess) {
            setState(() {
              loading = false;
              error = false;
              fetchPostedModel = state.fetchPostedModel!;
            });
          } else if (state is FetchInterestedWorkFailed) {
            setState(() {
              loading = false;
              error = true;
            });
          }
        },
        child: SafeArea(child: Builder(builder: (context) {
          if (loading) {
            return SizedBox(
                height: SizeConfig.screenHeight, child: ShimmerJobCards());
          } else if (error) {
            return SizedBox(
              height: SizeConfig.screenHeight,
              child: ErrorScreen(onRetry: () {
                profileBloc.add(const FetchInterestedWorkEvent());
              }),
            );
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
                            return Container(
                              padding: EdgeInsets.symmetric(
                                vertical: SizeConfig.blockWidth * 1.5,
                                horizontal: SizeConfig.blockHeight * 2.5,
                              ),
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                crossAxisAlignment: CrossAxisAlignment.center,
                                children: [
                                  WorkCard(
                                    title: profile.professionalSubCategory != null ? getCategoryProfessionCardName(profile.professionalSubCategory) :profile.requiredProfession!,
                                    location:'${profile.locality} ${profile.city}' ?? '--',
                                    timeAgo: timeAgo(profile.updatedAt!),
                                    jobType: profile.workPlaceCategory != null ? getCategoryWorkPlaceCardName(profile.workPlaceCategory) :profile.workPlace!,
                                    experience: profile.experienceLevel!,
                                    gender: profile.gender!,
                                    language: languages,
                                    experienceImage:
                                        'assets/images/home/work_select.png',
                                    genderImage:
                                        'assets/images/home/gender.png',
                                    jobTypeImage: 'assets/images/home/home.png',
                                    languageImage:
                                        'assets/images/home/speak.png',
                                    onShowInterest: () {},
                                    onCardClick: () {
                                      Navigator.push(
                                          context,
                                          MaterialPageRoute(
                                              builder: (context) =>
                                                  MultiBlocProvider(
                                                    providers: [
                                                      BlocProvider(
                                                        create: (context) =>
                                                            HomeBloc()
                                                              ..add(FetchWorkSingleView(
                                                                  workId: profile
                                                                      .id!)),
                                                      ),
                                                      BlocProvider(
                                                        create: (context) =>
                                                            ShowInterestedBloc(),
                                                      ),
                                                      BlocProvider(create: (context)=>ReportPostBloc())
                                                    ],
                                                    child: WorkDetailsScreen(
                                                      id: profile.id!,
                                                      refreshPageCallback: _refreshPageAfterEdit,
                                                      routeType: 'general',
                                                    ),
                                                  )));
                                    },
                                    actionRows: Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceBetween,
                                      crossAxisAlignment:
                                          CrossAxisAlignment.center,
                                      children: [
                                        Expanded(
                                          child: customIconButton(
                                              text: 'INTERESTED',
                                              onPressed: () {
                                                showCustomAlertDialog(
                                                  context: context,
                                                  title: 'Are you Sure?',
                                                  message:
                                                      'Do you want to Uninterest this Work?',
                                                  positiveButtonText: 'YES',
                                                  negativeButtonText: 'NO',
                                                  onPositivePressed: () {
                                                    showInterestedBloc
                                                        .add(SaveInterestedWork(
                                                      workID: profile.id!,
                                                      contact: true,
                                                      onSuccess: () {
                                                        setState(() {
                                                          Navigator.of(context)
                                                              .pop();
                                                          profileBloc.add(
                                                              const FetchInterestedWorkEvent());
                                                        });
                                                      },
                                                      onError: () {
                                                        showCustomSnackBar(
                                                          context: context,
                                                          message:
                                                              "Something Went wrong",
                                                        );
                                                        Navigator.of(context)
                                                            .pop();
                                                      },
                                                    ));
                                                  },
                                                  onNegativePressed: () {
                                                    Navigator.of(context).pop();
                                                  },
                                                );
                                              },
                                              backgroundColor: COLORS
                                                  .semanticTwo
                                                  .withOpacity(0.08),
                                              showIcon: true,
                                              width: SizeConfig.blockWidth * 50,
                                              height:
                                                  SizeConfig.blockHeight * 6.5,
                                              textColor: COLORS.semanticTwo,
                                              iconColor: COLORS.semanticTwo,
                                              icon: Icons.thumb_up_alt),
                                        ),
                                        Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.spaceBetween,
                                          crossAxisAlignment:
                                              CrossAxisAlignment.center,
                                          children: [
                                            if(profile.user != null && profile.isProfessionalCanCall == true)...[
                                              IconActionCard(
                                                onTap: () {
                                                  makePhoneCall(profile.user!.mobile!);
                                                },
                                                iconBool: false,
                                                imageUrl: Image.asset(
                                                  'assets/images/home/phone.png',
                                                  width: SizeConfig.blockWidth *
                                                      4.25,
                                                  height: SizeConfig.blockHeight *
                                                      4.25,
                                                  fit: BoxFit.contain,
                                                ),
                                              )
                                            ],
                                            IconActionCard(
                                              iconBool: false,
                                              onTap: () {
                                                shareJobDetails(
                                                  experience:
                                                      profile.experienceLevel!,
                                                  location: profile.workPlace!,
                                                  jobTitle: profile
                                                      .requiredProfession!,
                                                );
                                              },
                                              imageUrl: Image.asset(
                                                'assets/images/home/share.png',
                                                width:
                                                    SizeConfig.blockWidth * 5.2,
                                                height: SizeConfig.blockHeight *
                                                    5.2,
                                                fit: BoxFit.contain,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ],
                                    ),
                                  )
                                ],
                              ),
                            );
                          }),
                    ),
                )
                : SizedBox(
                    width: SizeConfig.screenWidth,
                    height: SizeConfig.blockHeight * 80,
                    child: emptyComponent());
          }
          return Container();
        })),
      ),
    );
  }
}
