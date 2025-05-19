import 'dart:math';

import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';
import 'package:shimmer/shimmer.dart';
import 'package:works_app/bloc/post_work/post_work_bloc.dart';
import 'package:works_app/bloc/profile/profile_bloc.dart';
import 'package:works_app/bloc/register_account/initial_register_bloc.dart';
import 'package:works_app/components/colors.dart';
import 'package:works_app/components/config.dart';
import 'package:works_app/global_helper/helper_function.dart';
import 'package:works_app/ui/profile/Interested_works.dart';
import 'package:works_app/ui/profile/bookmark_list.dart';
import 'package:works_app/ui/profile/conatct_us.dart';
import 'package:works_app/ui/profile/edit_profile.dart';
import 'package:works_app/ui/profile/faq.dart';
import 'package:works_app/ui/profile/location/location_create.dart';
import 'package:works_app/ui/profile/posted_work.dart';
import 'package:works_app/ui/profile/setting.dart';
import '../../bloc/chart/chart_bloc.dart';
import '../../bloc/professional/professional_bloc.dart';
import '../../bloc/show_interested/show_interested_bloc.dart';
import '../../components/size_config.dart';
import '../../global_helper/reuse_widget.dart';
import '../../models/fetch_profile_model.dart';
import '../onboarding/select_user_type.dart';
import 'kyc_verify.dart';
import 'location/location_list.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  late ProfileBloc profileBloc;
  bool loading = true;
  String profileImage = "";
  String userName = "";
  String phoneNumber = "";
  bool verified = false;
  late ProfileFetch profileFetch;
  bool interestedWork = false;
  bool isVerified = false;
  bool isRegistered = false;

  @override
  void initState() {
    super.initState();
    profileBloc = BlocProvider.of<ProfileBloc>(context);
  }

  void _refreshPageAfterEdit() {
    profileBloc.add(const FetchProfileEvent());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: COLORS.white,
      appBar: CustomAppBar(
        title: 'My Account'.tr(),
        borderColor: true,
        showLeadingIcon: false,
      ),
      body: BlocListener<ProfileBloc, ProfileState>(
        listener: (context, state) {
          if (state is ProfileLoading) {
            loading = true;
            Container();
          } else if (state is FetchProfileSuccess) {
            loading = false;
            setState(() {
              profileFetch = state.profileFetch;
              Config.phoneNumber = state.profileFetch.mobile!;
              Config.name = state.profileFetch.name ?? "";
            });
          } else if (state is FetchProfileFailed) {
            loading = false;
          }
          setState(() {});
        },
        child: SafeArea(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              if (Config.profileCompleted != false) ...[
                Stack(
                  children: [
                    Container(
                      color: COLORS.primaryTwo,
                      padding: EdgeInsets.symmetric(
                          horizontal: SizeConfig.blockWidth * 5,
                          vertical: SizeConfig.blockHeight * 4),
                      margin:
                          EdgeInsets.only(bottom: SizeConfig.blockHeight * 3),
                      child: Row(
                        children: [
                          Container(
                            width: SizeConfig.blockWidth * 20,
                            height: SizeConfig.blockWidth * 20,
                            decoration: BoxDecoration(
                                image: DecorationImage(
                                  image: NetworkImage(Config.profilePic),
                                  fit: BoxFit.fill,
                                ),
                                border: Border.all(
                                    color: COLORS.primary,
                                    width: SizeConfig.blockWidth * 0.15),
                                borderRadius: BorderRadius.all(Radius.circular(
                                    SizeConfig.blockWidth * 3))),
                          ),
                          SizedBox(width: SizeConfig.blockWidth * 6),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              SizedBox(
                                width: SizeConfig.blockWidth * 48,
                                child: Text(
                                  Config.name,
                                  style: TextStyle(
                                    color: COLORS.white,
                                    fontSize: SizeConfig.blockWidth * 4.25,
                                    fontWeight: FontWeight.w500,
                                    fontFamily: "Poppins",
                                  ),
                                  maxLines: 1,
                                  softWrap: true,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                              Row(
                                children: [
                                  Text(
                                    '+91 ${Config.phoneNumber}',
                                    style: TextStyle(
                                      color: COLORS.primary,
                                      fontSize: SizeConfig.blockWidth * 3.8,
                                      fontWeight: FontWeight.w400,
                                      fontFamily: "Poppins",
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                          const Spacer(),
                          if (loading == false) ...[
                            InkWell(
                              onTap: () {
                                Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                        builder: (context) => MultiBlocProvider(
                                              providers: [
                                                BlocProvider(
                                                  create: (context) =>
                                                      ProfileBloc(),
                                                ),
                                                BlocProvider(
                                                  create: (context) {
                                                    final bloc =
                                                        InitialRegisterBloc();
                                                    bloc.add(
                                                        const FetchCityEvent());
                                                    bloc.add(
                                                        const FetchChargeFeesEvent());
                                                    bloc.add(
                                                        const FetchWorkKnownLanguageProfileEvent());
                                                    return bloc;
                                                  },
                                                ),
                                                BlocProvider(
                                                    create: (context) =>
                                                        ProfessionalBloc()..add(const FetchCategoryListEvent())),
                                              ],
                                              child: EditProfileRegisterForm(
                                                refreshPageCallback:
                                                    _refreshPageAfterEdit,
                                                profileFetch: profileFetch,
                                              ),
                                            )));
                              },
                              borderRadius: BorderRadius.all(
                                  Radius.circular(SizeConfig.blockWidth * 2)),
                              child: Container(
                                width: SizeConfig.blockWidth * 8,
                                height: SizeConfig.blockWidth * 8,
                                alignment: Alignment.center,
                                decoration: BoxDecoration(
                                    border: Border.all(
                                        color: COLORS.accent,
                                        width: SizeConfig.blockWidth * 0.3),
                                    borderRadius: BorderRadius.all(
                                        Radius.circular(
                                            SizeConfig.blockWidth * 2))),
                                child: Icon(
                                  Icons.edit_outlined,
                                  color: COLORS.accent,
                                  size: SizeConfig.blockWidth * 4,
                                ),
                              ),
                            )
                          ] else ...[
                            Padding(
                              padding: EdgeInsets.symmetric(
                                  horizontal: SizeConfig.blockWidth),
                              child: LoadingAnimationWidget.hexagonDots(
                                color: COLORS.accent,
                                size: SizeConfig.blockWidth * 5,
                              ),
                            )
                          ],
                        ],
                      ),
                    ),
                    if (Config.accountVerify == true) ...[
                      Positioned(
                        right: 0,
                        top: 0,
                        child: Container(
                          padding: EdgeInsets.symmetric(
                              horizontal: SizeConfig.blockWidth * 3,
                              vertical: SizeConfig.blockHeight * 1),
                          decoration: BoxDecoration(
                            color: COLORS.semanticTwo,
                            borderRadius: BorderRadius.only(
                                bottomLeft:
                                    Radius.circular(SizeConfig.blockWidth * 4)),
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              Icon(
                                Icons.verified,
                                color: COLORS.white,
                                size: SizeConfig.blockWidth * 3.5,
                              ),
                              SizedBox(
                                width: SizeConfig.blockWidth * 1.5,
                              ),
                              Text(
                                'Verified'.tr(),
                                style: TextStyle(
                                  color: COLORS.white,
                                  fontSize: SizeConfig.blockWidth * 3,
                                  fontWeight: FontWeight.w400,
                                  fontFamily: "Poppins",
                                ),
                              ),
                            ],
                          ),
                        ),
                      )
                    ]
                  ],
                )
              ] else ...[
                if (loading == true && Config.profileCompleted == false) ...[
                  Shimmer.fromColors(
                    baseColor: COLORS.primary.withOpacity(0.8),
                    highlightColor: COLORS.primary.withOpacity(0.5),
                    child: Container(
                      padding: EdgeInsets.symmetric(
                          horizontal: SizeConfig.blockWidth * 5,
                          vertical: SizeConfig.blockHeight * 4),
                      margin:
                          EdgeInsets.only(bottom: SizeConfig.blockHeight * 3),
                      decoration: BoxDecoration(
                        color: COLORS.primaryOne.withOpacity(0.25),
                        borderRadius:
                            BorderRadius.circular(SizeConfig.blockWidth * 3.5),
                      ),
                      child: Row(
                        children: [
                          Container(
                            width: SizeConfig.blockWidth * 20,
                            height: SizeConfig.blockWidth * 20,
                            decoration: BoxDecoration(
                              color: COLORS.primary.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(
                                  SizeConfig.blockWidth * 3),
                            ),
                          ),
                          SizedBox(width: SizeConfig.blockWidth * 6),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Container(
                                width: SizeConfig.blockWidth * 48,
                                height: SizeConfig.blockHeight * 3,
                                color: COLORS.primary.withOpacity(0.1),
                              ),
                              SizedBox(height: SizeConfig.blockHeight * 1),
                              Container(
                                width: SizeConfig.blockWidth * 30,
                                height: SizeConfig.blockHeight * 2.5,
                                color: COLORS.primary.withOpacity(0.1),
                              ),
                            ],
                          ),
                          const Spacer(),
                          Container(
                            width: SizeConfig.blockWidth * 8,
                            height: SizeConfig.blockWidth * 8,
                            decoration: BoxDecoration(
                              color: COLORS.primary.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(
                                  SizeConfig.blockWidth * 2),
                            ),
                          ),
                        ],
                      ),
                    ),
                  )
                ] else ...[
                  Container(
                    color: COLORS.primaryTwo,
                    width: SizeConfig.screenWidth,
                    padding: EdgeInsets.symmetric(
                        horizontal: SizeConfig.blockWidth * 5,
                        vertical: SizeConfig.blockHeight * 4),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Text(
                          "It looks like you haven't registered yet. \nPlease complete your registration!"
                              .tr(),
                          style: TextStyle(
                              fontSize: SizeConfig.blockWidth * 3.6,
                              fontFamily: 'Poppins',
                              fontWeight: FontWeight.w500,
                              color: COLORS.white),
                          textAlign: TextAlign.center,
                        ),
                        SizedBox(
                          height: SizeConfig.blockHeight * 2,
                        ),
                        customButton(
                            text: 'Register Now'.tr(),
                            backgroundColor: COLORS.primary,
                            showIcon: false,
                            width: SizeConfig.blockWidth * 50,
                            height: SizeConfig.blockHeight * 8,
                            textColor: COLORS.white,
                            onPressed: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                    builder: (BuildContext context) =>
                                        const SelectUserType()),
                              );
                            })
                      ],
                    ),
                  )
                ]
              ],
              Expanded(
                child: ListView(
                  children: [
                    if (Config.profileCompleted) ...[
                      _buildListItem('assets/images/profile/other_location.png',
                          'My Addresses', () {
                        Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (context) => MultiBlocProvider(
                                      providers: [
                                        BlocProvider(
                                            create: (context) => ProfileBloc()
                                              ..add(
                                                  const AddressLocationListEvent())),
                                      ],
                                      child: LocationListScreen(),
                                    )));
                      }),
                      _buildListItem(
                          'assets/images/profile/settings.png', 'KYC Verification', () {
                        Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (context) => MultiBlocProvider(
                                  providers: [
                                    BlocProvider(
                                      create: (context) => PostWorkBloc(),
                                    ),
                                  ],
                                  child: KYCVerificationScreen(isVerified: false),
                                )));

                      }),
                      _buildListItem('assets/images/profile/posted_work.png',
                          'Posted Works', () {
                        Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (context) => MultiBlocProvider(
                                      providers: [
                                        BlocProvider(
                                          create: (context) => ProfileBloc()
                                            ..add(const FetchPostedEvent()),
                                        ),
                                      ],
                                      child: PostedWorkList(),
                                    )));
                      }),
                      _buildListItem('assets/images/profile/bookmark.png',
                          'Saved Professionals', () {
                        Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (context) => MultiBlocProvider(
                                      providers: [
                                        BlocProvider(
                                          create: (context) => ProfileBloc()
                                            ..add(
                                                const FetchSavedProfessionalEvent()),
                                        ),
                                        BlocProvider(
                                          create: (context) =>
                                              ShowInterestedBloc(),
                                        ),
                                        BlocProvider(
                                            create: (context) => ChartBloc())
                                      ],
                                      child: const BookMarkListScreen(),
                                    )));
                      }),
                      if (Config.userType == 'professional') ...[
                        _buildListItem('assets/images/profile/like.png',
                            'Interested Works', () {
                          Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (context) => MultiBlocProvider(
                                        providers: [
                                          BlocProvider(
                                            create: (context) => ProfileBloc()
                                              ..add(
                                                  const FetchInterestedWorkEvent()),
                                          ),
                                          BlocProvider(
                                            create: (context) =>
                                                ShowInterestedBloc(),
                                          )
                                        ],
                                        child: InterestedWorkList(),
                                      )));
                        }),
                      ]
                    ],
                    if (Config.profileCompleted == false) ...[
                      SizedBox(
                        height: SizeConfig.blockHeight * 2,
                      ),
                    ],
                    _buildListItem(
                        'assets/images/profile/share.png', 'Share with Friends',
                        () {
                      shareAppWithFriend();
                    }),
                    _buildListItem('assets/images/profile/question.png', 'FAQs',
                        () {
                      Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) => MultiBlocProvider(
                                    providers: [
                                      BlocProvider(
                                        create: (context) => ProfileBloc()
                                          ..add(const FetchFaqEvent()),
                                      ),
                                    ],
                                    child: FaqScreen(),
                                  )));
                      // Navigator.push(
                      //   context,
                      //   MaterialPageRoute(
                      //       builder: (BuildContext context) => ()),
                      // );
                    }),
                    _buildListItem(
                        'assets/images/profile/contact.png', 'Help & Support',
                        () {
                      Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) => MultiBlocProvider(
                                    providers: [
                                      BlocProvider(
                                          create: (context) => ProfileBloc()),
                                    ],
                                    child: ContactUsScreen(),
                                  )));
                    }),
                    _buildListItem(
                        'assets/images/profile/settings.png', 'Settings', () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (BuildContext context) => SettingApp()),
                      );
                    }),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildListItem(
      String imagePath, String title, void Function()? onTap) {
    return InkWell(
      onTap: onTap,
      child: Container(
        margin: EdgeInsets.symmetric(
            horizontal: SizeConfig.blockHeight * 3.5,
            vertical: SizeConfig.blockHeight * 1.25),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Container(
              width: SizeConfig.blockWidth * 12,
              height: SizeConfig.blockWidth * 12,
              padding: EdgeInsets.all(SizeConfig.blockWidth * 3.5),
              margin: EdgeInsets.only(
                right: SizeConfig.blockWidth * 1,
              ),
              decoration: BoxDecoration(
                  borderRadius:
                      BorderRadius.circular(SizeConfig.blockWidth * 2.5),
                  color: COLORS.primaryOne.withOpacity(0.2)),
              child: Image.asset(
                imagePath,
                width: SizeConfig.blockWidth * 5, // Adjust size as needed
                height: SizeConfig.blockHeight * 5,
                fit: BoxFit.contain, color: COLORS.neutralDark,
              ),
            ),
            SizedBox(
              width: SizeConfig.blockWidth * 4,
            ),
            Text(
              title.tr(),
              style: TextStyle(
                  fontSize: SizeConfig.blockWidth * 3.6,
                  fontFamily: 'Poppins',
                  fontWeight: FontWeight.w500,
                  color: COLORS.primaryTwo),
            ),
            // ListTile(
            //   contentPadding:
            //   EdgeInsets.symmetric(horizontal: SizeConfig.blockWidth * 6),dense: true,
            //   leading: Container(
            //     width: SizeConfig.blockWidth * 12,
            //     height: SizeConfig.blockWidth * 12,
            //     padding: EdgeInsets.all(SizeConfig.blockWidth * 3.5),
            //     margin: EdgeInsets.only(right: SizeConfig.blockWidth * 1,),
            //     decoration: BoxDecoration(
            //         borderRadius: BorderRadius.circular(SizeConfig.blockWidth * 2.5),
            //         color: COLORS.primaryOne.withOpacity(0.3)),
            //     child: Image.asset(
            //       imagePath,
            //       width: SizeConfig.blockWidth * 5, // Adjust size as needed
            //       height: SizeConfig.blockHeight * 5,
            //       fit: BoxFit.contain,
            //     ),
            //   ),
            //   title: Text(
            //     title.tr(),
            //     style: TextStyle(
            //         fontSize: SizeConfig.blockWidth * 4,
            //         fontFamily: 'Poppins',
            //         fontWeight: FontWeight.w500,
            //         color: COLORS.primaryTwo),
            //   ),
            //   onTap: onTap,
            // )
          ],
        ),
      ),
    );
  }
}
