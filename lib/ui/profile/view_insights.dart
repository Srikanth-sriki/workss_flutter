import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:lottie/lottie.dart';
import 'package:works_app/components/colors.dart';
import 'package:works_app/global_helper/loading_placeholder/work_insight.dart';

import '../../bloc/profile/profile_bloc.dart';
import '../../bloc/show_interested/show_interested_bloc.dart';
import '../../components/size_config.dart';
import '../../global_helper/reuse_widget.dart';
import '../../models/fetch_posted_view.dart';
import 'component.dart';

class ViewInsightsScreen extends StatefulWidget {
  const ViewInsightsScreen({super.key});

  @override
  State<ViewInsightsScreen> createState() => _ViewInsightsScreenState();
}

class _ViewInsightsScreenState extends State<ViewInsightsScreen> {
  late ProfileBloc profileBloc;
  late ShowInterestedBloc showInterestedBloc;
  late ViewFetchPostedWork viewFetchPostedWork;
  bool loading = true;
  bool error = false;

  @override
  void initState() {
    super.initState();
    profileBloc = BlocProvider.of<ProfileBloc>(context);
    showInterestedBloc = BlocProvider.of<ShowInterestedBloc>(context);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: COLORS.white,
      appBar: AppBar(
        toolbarHeight: 0,
        backgroundColor: COLORS.primary,
      ),
      body: BlocListener<ProfileBloc, ProfileState>(
        listener: (context, state) {
          if (state is PostedWorkViewLoading) {
            loading = true;
            error = false;
          } else if (state is FetchPostedViewWorkSuccess) {
            loading = false;
            error = false;
            setState(() {
              viewFetchPostedWork = state.viewFetchPostedWork;
            });
          } else if (state is FetchPostedViewWorkFailed) {
            loading = false;
            error = true;
          }
          setState(() {});
        },
        child: Builder(builder: (context) {
          if (loading) {
            return ShimmerInsightsScreen();
          } else if (error) {
            return Center(child: Text('Failed to load .'));
          } else if (!loading && !error) {
            return SafeArea(
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildTopCard(viewFetchPostedWork: viewFetchPostedWork),
                    SizedBox(height: SizeConfig.blockHeight * 4),
                    if (viewFetchPostedWork
                        .workIntrestsDetailsView!.isNotEmpty) ...[
                      _buildStatistics(
                          viewFetchPostedWork: viewFetchPostedWork),
                      SizedBox(height: SizeConfig.blockHeight * 3.5),
                      if (viewFetchPostedWork
                          .workIntrestsDetailsView!.isNotEmpty) ...[
                        Padding(
                          padding: EdgeInsets.symmetric(
                              horizontal: SizeConfig.blockWidth * 4.5),
                          child: Text(
                            'Interested Professionals'.tr(),
                            style: TextStyle(
                              color: COLORS.neutralDarkOne,
                              fontSize: SizeConfig.blockWidth * 3.8,
                              fontWeight: FontWeight.w400,
                              fontFamily: "Poppins",
                            ),
                          ),
                        ),
                      ],
                      _buildProfessionalList(
                          viewFetchPostedWork: viewFetchPostedWork),
                    ] else ...[
                      Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            SizedBox(height: SizeConfig.blockHeight*16,),
                            Lottie.asset(
                              'assets/images/lottie/insight_check.json',
                              width: SizeConfig.blockWidth *
                                  60,
                              height: SizeConfig.blockWidth *
                                  30,
                              fit: BoxFit
                                  .contain,
                            ),
                            SizedBox(
                              height: SizeConfig.blockHeight,
                            ),
                            Text(
                              'Professionals are looking at your \nwork! ',
                              style: TextStyle(
                                color: COLORS.neutralDarkOne,
                                fontSize: SizeConfig.blockWidth * 3.8,
                                fontWeight: FontWeight.w400,
                                fontFamily: "Poppins",

                              ),textAlign: TextAlign.center,
                            )
                          ],
                        ),
                      ),
                    ]
                  ],
                ),
              ),
            );
          }
          return Container();
        }),
      ),
    );
  }

  Widget _buildTopCard({required ViewFetchPostedWork viewFetchPostedWork}) {
    return Container(
      padding: EdgeInsets.all(SizeConfig.blockWidth * 4),
      decoration: BoxDecoration(
        color: COLORS.primary,
        borderRadius: BorderRadius.only(
          bottomLeft: Radius.circular(SizeConfig.blockWidth * 6),
          bottomRight: Radius.circular(SizeConfig.blockWidth * 6),
        ),
      ),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                InkWell(
                  onTap: () {
                    Navigator.of(context).pop();
                  },
                  child: Container(
                    padding: EdgeInsets.all(SizeConfig.blockWidth * 2.8),
                    margin: EdgeInsets.only(right: SizeConfig.blockWidth * 3),
                    decoration: BoxDecoration(
                      color: COLORS.primaryOne.withOpacity(0.3),
                      borderRadius:
                          BorderRadius.circular(SizeConfig.blockWidth * 1.5),
                    ),
                    child: Icon(
                      Icons.arrow_back_ios_new_sharp,
                      color: COLORS.white,
                      size: SizeConfig.blockWidth * 4,
                    ),
                  ),
                ),
                Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      viewFetchPostedWork.requiredProfession!,
                      style: TextStyle(
                        color: COLORS.white,
                        fontSize: SizeConfig.blockWidth * 4.2,
                        fontWeight: FontWeight.w500,
                        fontFamily: "Poppins",
                      ),
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.start,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.location_on,
                          color: COLORS.accent,
                          size: SizeConfig.blockWidth * 4,
                        ),
                        SizedBox(width: SizeConfig.blockWidth * 1.5),
                        SizedBox(
                          width: SizeConfig.blockWidth * 60,
                          child: Text(
                            viewFetchPostedWork.location!,
                            style: TextStyle(
                              color: COLORS.primaryOne,
                              fontSize: SizeConfig.blockWidth * 3.3,
                              fontWeight: FontWeight.w400,
                              fontFamily: "Poppins",
                            ),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                            softWrap: true,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ],
            ),
            Icon(
              Icons.more_vert,
              color: COLORS.white,
              size: SizeConfig.blockHeight * 4,
            ),
          ],
        ),
        Container(
          padding: EdgeInsets.symmetric(
              horizontal: SizeConfig.blockWidth * 12,
              vertical: SizeConfig.blockHeight * 0.5),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              registerTextCard(
                  text: viewFetchPostedWork.workPlace!,
                  image: "assets/images/home/home.png",
                  color: COLORS.white,
                  textColor: COLORS.primaryOne,
                  imageSize: 3.4,
                  textFontSize: 3.2),
              registerTextCard(
                  text: viewFetchPostedWork.experienceLevel!,
                  image: "assets/images/home/work_select.png",
                  color: COLORS.white,
                  textColor: COLORS.primaryOne,
                  imageSize: 3.4,
                  textFontSize: 3.2),
              registerTextCard(
                  text: viewFetchPostedWork.knowLanguage!.join(", "),
                  image: "assets/images/home/speak.png",
                  color: COLORS.white,
                  textColor: COLORS.primaryOne,
                  imageSize: 3.4,
                  textFontSize: 3.2),
              registerTextCard(
                  text: viewFetchPostedWork.gender!,
                  image: "assets/images/home/gender.png",
                  color: COLORS.white,
                  textColor: COLORS.primaryOne,
                  imageSize: 3.4,
                  textFontSize: 3.2),
            ],
          ),
        ),
      ]),
    );
  }

  Widget _buildStatistics({required ViewFetchPostedWork viewFetchPostedWork}) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: SizeConfig.blockWidth * 4.5),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          _buildStatBox(
              'Interested Professional',
              '${viewFetchPostedWork.workIntrestsDetailsView!.length}',
              COLORS.primary!),
          _buildStatBox(
              'Work Post Viewed by',
              '${viewFetchPostedWork.workViewsDetailsView!.length}',
              COLORS.accent!),
        ],
      ),
    );
  }

  Widget _buildStatBox(String label, String value, Color bgColor) {
    return Container(
      width: SizeConfig.blockWidth * 43,
      padding: EdgeInsets.all(SizeConfig.blockWidth * 4),
      decoration: BoxDecoration(
        color: bgColor.withOpacity(0.2),
        borderRadius: BorderRadius.circular(SizeConfig.blockWidth * 4),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label.tr(),
            style: TextStyle(
              color: COLORS.neutralDark,
              fontSize: SizeConfig.blockWidth * 3.8,
              fontWeight: FontWeight.w400,
              fontFamily: "Poppins",
            ),
          ),
          SizedBox(height: SizeConfig.blockHeight * 2.5),
          Text(
            value,
            style: TextStyle(
              color: bgColor,
              fontSize: SizeConfig.blockWidth * 6.5,
              fontWeight: FontWeight.w600,
              fontFamily: "Poppins",
            ),
          ),
          SizedBox(height: SizeConfig.blockHeight * 0.5),
          Container(
            padding: EdgeInsets.symmetric(
                horizontal: SizeConfig.blockWidth * 2.5,
                vertical: SizeConfig.blockHeight * 0.8),
            decoration: BoxDecoration(
                color: bgColor.withOpacity(0.2),
                borderRadius: BorderRadius.circular(SizeConfig.blockWidth * 4)),
            child: Text(
              'From 30 Days'.tr(),
              style: TextStyle(
                color: bgColor,
                fontSize: SizeConfig.blockWidth * 3,
                fontWeight: FontWeight.w400,
                fontFamily: "Poppins",
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProfessionalList(
      {required ViewFetchPostedWork viewFetchPostedWork}) {
    return ListView.builder(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        itemCount: viewFetchPostedWork.workIntrestsDetailsView!.length,
        itemBuilder: (context, index) {
          var professionalData =
              viewFetchPostedWork.workIntrestsDetailsView![index];
          return Container(
            padding: EdgeInsets.symmetric(
                vertical: SizeConfig.blockWidth * 2,
                horizontal: SizeConfig.blockWidth * 4),
            child: buildProfessionalCard(
                onTap: (){},
                accountVerified: professionalData!.user!.isVerified!,
                image: professionalData!.user!.profilePic!,
                name: professionalData!.user!.name!,
                profession: professionalData.user!.professionType!,
                location: professionalData.user!.city!,
                languages: professionalData.user!.knownLanguages!.join(", "),
                gender: professionalData.user!.gender!,
                price: professionalData.user!.charges!,
                paymentType: professionalData.user!.chargeType!,
                contacted: professionalData.isContacted!,
                experience: professionalData.user!.experiencedYears!,
                experienceImage: 'assets/images/home/work_select.png',
                genderImage: 'assets/images/home/gender.png',
                jobTypeImage: 'assets/images/profile/prof.png',
                language: professionalData.user!.knownLanguages!.join(", "),
                languageImage: 'assets/images/home/speak.png',
                saved: true,
                onShowInterest: () {
                  if (professionalData.isContacted == false) {
                    showInterestedBloc.add(ProfessionalContactUs(
                      PropId: professionalData.userId!,
                      onSuccess: () {
                        setState(() {
                          professionalData = WorkViewDetails(isContacted: true);
                        });
                      },
                      onError: () {},
                    ));
                  }
                },
                jobType: professionalData.user!.professionType!,
                onShare: () {},
                savedTap: () {}),
          );
        });
  }
}
