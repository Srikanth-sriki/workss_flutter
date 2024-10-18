import 'dart:math';

import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:works_app/bloc/profile/profile_bloc.dart';
import 'package:works_app/bloc/register_account/initial_register_bloc.dart';
import 'package:works_app/components/colors.dart';
import 'package:works_app/ui/profile/Interested_works.dart';
import 'package:works_app/ui/profile/bookmark_list.dart';
import 'package:works_app/ui/profile/conatct_us.dart';
import 'package:works_app/ui/profile/edit_profile.dart';
import 'package:works_app/ui/profile/faq.dart';
import 'package:works_app/ui/profile/posted_work.dart';
import 'package:works_app/ui/profile/setting.dart';
import '../../bloc/show_interested/show_interested_bloc.dart';
import '../../components/size_config.dart';
import '../../global_helper/reuse_widget.dart';
import '../../models/fetch_profile_model.dart';

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
              profileFetch = state.profileFetch!;
              phoneNumber = state.profileFetch.mobile!;
              profileImage = state.profileFetch.profilePic!;
              userName = state.profileFetch.name!;
              interestedWork= state.profileFetch.userType =='professional'?true:false;
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
              if (loading == false) ...[
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
                                  image: NetworkImage(profileImage),
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
                              Text(
                                userName,
                                style: TextStyle(
                                  color: COLORS.white,
                                  fontSize: SizeConfig.blockWidth * 4.25,
                                  fontWeight: FontWeight.w500,
                                  fontFamily: "Poppins",
                                ),
                              ),

                              Row(
                                children: [
                                  Text(
                                    '+91 ${phoneNumber}',
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
                                                create: (context) =>
                                                    InitialRegisterBloc(),
                                              )
                                            ],
                                            child: EditProfileRegisterForm(
                                              refreshPageCallback:
                                                  _refreshPageAfterEdit,
                                              profileFetch: profileFetch,
                                            ),
                                          )));
                            },
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
                                Icons.edit,
                                color: COLORS.accent,
                                size: SizeConfig.blockWidth * 4,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
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
                  ],
                )
              ],
              Expanded(
                child: ListView(
                  children: [
                    _buildListItem(
                        'assets/images/profile/posted_work.png', 'Posted Works',
                        () {
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
                                          ..add(const FetchSavedProfessionalEvent()),
                                      ),
                                      BlocProvider(
                                        create: (context) => ShowInterestedBloc(),
                                      ),
                                    ],
                                    child: const BookMarkListScreen(),
                                  )));

                    }),
                    if(interestedWork == true)...[
                      _buildListItem(
                          'assets/images/profile/like.png', 'Interested Works',
                              () {
                            Navigator.push(
                                context,
                                MaterialPageRoute(
                                    builder: (context) => MultiBlocProvider(
                                      providers: [
                                        BlocProvider(
                                          create: (context) => ProfileBloc()
                                            ..add(const FetchInterestedWorkEvent()),
                                        ),
                                      ],
                                      child: InterestedWorkList(),
                                    )));
                          }),
                    ],

                    _buildListItem('assets/images/profile/share.png',
                        'Share with Friends', () {}),
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
                                        create: (context) => ProfileBloc()

                                      ),
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
        margin: EdgeInsets.symmetric(horizontal: SizeConfig.blockHeight*3.5,vertical: SizeConfig.blockHeight*1.25),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Container(
              width: SizeConfig.blockWidth * 12,
              height: SizeConfig.blockWidth * 12,
              padding: EdgeInsets.all(SizeConfig.blockWidth * 3.5),
              margin: EdgeInsets.only(right: SizeConfig.blockWidth * 1,),
              decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(SizeConfig.blockWidth * 2.5),
                  color: COLORS.primaryOne.withOpacity(0.3)),
              child: Image.asset(
                imagePath,
                width: SizeConfig.blockWidth * 5, // Adjust size as needed
                height: SizeConfig.blockHeight * 5,
                fit: BoxFit.contain,
              ),
            ),
            SizedBox(width: SizeConfig.blockWidth*4,),
            Text(
              title.tr(),
              style: TextStyle(
                  fontSize: SizeConfig.blockWidth * 4,
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
