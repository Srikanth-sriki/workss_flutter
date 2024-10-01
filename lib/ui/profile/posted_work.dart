import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:works_app/bloc/profile/profile_bloc.dart';
import 'package:works_app/components/size_config.dart';
import 'package:works_app/models/fetch_posted_work.dart';
import 'package:works_app/ui/profile/component.dart';
import 'package:works_app/ui/profile/view_insights.dart';

import '../../components/colors.dart';
import '../../global_helper/helper_function.dart';
import '../../global_helper/reuse_widget.dart';
import '../../models/fetch_profile_model.dart';
import '../home/component.dart';

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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        backgroundColor: COLORS.white,
        appBar: const CustomAppBar(
            title: 'Posted Works',
            backgroundColor: COLORS.white,
            titleColors: COLORS.neutralDark),
        body: SafeArea(
          child: SingleChildScrollView(
            child: BlocListener<ProfileBloc, ProfileState>(
              listener: (context, state) {
                if (state is ProfileLoading) {
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
                    return Center(child: CircularProgressIndicator());
                  } else if (error) {
                    return Center(child: Text('Failed to load profile.'));
                  } else if (!loading && !error) {
                    return ListView.builder(
                      shrinkWrap: true,
                      physics:
                          NeverScrollableScrollPhysics(),
                      itemCount: fetchPostedModel
                          .length,
                      itemBuilder: (context, index) {
                        var profile = fetchPostedModel[index];
                        return Padding(
                          padding: EdgeInsets.symmetric(
                            vertical: SizeConfig.blockWidth * 1.5,
                            horizontal: SizeConfig.blockHeight * 4,
                          ),
                          child: WorkCard(
                            title: profile.requiredProfession!,
                            location: profile.location!,
                            timeAgo: timeAgo(profile.updatedAt!),
                            jobType: profile.workPlace!,
                            experience: profile.experienceLevel!,
                            gender: profile.gender!,
                            language: profile.knowLanguage!.join(", "),
                            experienceImage: 'assets/images/home/work.png',
                            genderImage: 'assets/images/home/gender.png',
                            jobTypeImage: 'assets/images/home/home.png',
                            languageImage: 'assets/images/home/speak.png',
                            onShowInterest: () {},
                            onCardClick: () {},
                            actionRows: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: [
                                customIconButton(
                                  text: 'VIEW INSIGHTS',
                                  onPressed: () {
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (BuildContext context) =>
                                            ViewInsightsScreen(),
                                      ),
                                    );
                                  },
                                  backgroundColor: COLORS.primary,
                                  showIcon: false,
                                  height: SizeConfig.blockHeight * 6.5,
                                  textColor: COLORS.white,
                                  width: SizeConfig.blockWidth * 50,
                                ),
                                Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  crossAxisAlignment: CrossAxisAlignment.center,
                                  children: [
                                    IconActionCard(
                                      iconBool: false,
                                      imageUrl: Image.asset(
                                        'assets/images/home/phone.png',
                                        width: SizeConfig.blockWidth * 4.25,
                                        height: SizeConfig.blockHeight * 4.25,
                                        fit: BoxFit.contain,
                                      ),
                                    ),
                                    IconActionCard(
                                      iconBool: false,
                                      imageUrl: Image.asset(
                                        'assets/images/home/share.png',
                                        width: SizeConfig.blockWidth * 5.2,
                                        height: SizeConfig.blockHeight * 5.2,
                                        fit: BoxFit.contain,
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    );
                  }

                  return Container();
                },
              ),
            ),
          ),
        )

        // SafeArea(
        //     child: SingleChildScrollView(
        //       child: BlocListener<ProfileBloc, ProfileState>(
        //         listener: (context, state) {
        //           if (state is ProfileLoading) {
        //             loading = true;
        //             error = false;
        //             Container();
        //           } else if (state is FetchProfileSuccess) {
        //             loading = false;
        //             error = false;
        //             setState(() {
        //               profileFetch = state.profileFetch!;
        //             });
        //           } else if (state is FetchProfileFailed) {
        //             loading = false;
        //             error = true;
        //           }
        //           setState(() {});
        //         },
        //         child: loading?
        //         Container():error?Container():(!loading&&error) &&
        //         Container(
        //           padding: EdgeInsets.symmetric(
        //               vertical: SizeConfig.blockWidth * 4,
        //               horizontal: SizeConfig.blockHeight * 4),
        //           child: Column(
        //             mainAxisAlignment: MainAxisAlignment.center,
        //             crossAxisAlignment: CrossAxisAlignment.center,
        //             children: [
        //               WorkCard(
        //                 title: 'UI/UX Designer',
        //                 location: 'Siddhartha Layout, Mysuru ',
        //                 timeAgo: '2d ago',
        //                 jobType: 'Home',
        //                 experience: 'Freshers',
        //                 experienceImage: 'assets/images/home/work.png',
        //                 gender: 'Male',
        //                 genderImage: 'assets/images/home/gender.png',
        //                 jobTypeImage: 'assets/images/home/home.png',
        //                 language: 'Kannada, Hindi, English',
        //                 languageImage: 'assets/images/home/speak.png',
        //                 onShowInterest: () {},
        //                 onCardClick: () {},
        //                 actionRows: Row(
        //                   mainAxisAlignment: MainAxisAlignment.spaceBetween,
        //                   crossAxisAlignment: CrossAxisAlignment.center,
        //                   children: [
        //                     customIconButton(
        //                       text: 'VIEW INSIGHTS',
        //                       onPressed: () {
        //                         Navigator.push(
        //                           context,
        //                           MaterialPageRoute(
        //                               builder: (BuildContext context) =>
        //                                   ViewInsightsScreen()),
        //                         );
        //                       },
        //                       backgroundColor: COLORS.primary,
        //                       showIcon: false,
        //                       height: SizeConfig.blockHeight * 6.5,
        //                       textColor: COLORS.white,
        //                       width: SizeConfig.blockWidth * 50,
        //                     ),
        //                     Row(
        //                       mainAxisAlignment: MainAxisAlignment.spaceBetween,
        //                       crossAxisAlignment: CrossAxisAlignment.center,
        //                       children: [
        //                         IconActionCard(
        //                           iconBool: false,
        //                           imageUrl: Image.asset(
        //                             'assets/images/home/phone.png',
        //                             width: SizeConfig.blockWidth * 4.25,
        //                             height: SizeConfig.blockHeight * 4.25,
        //                             fit: BoxFit.contain,
        //                           ),
        //                         ),
        //                         IconActionCard(
        //                           iconBool: false,
        //                           imageUrl: Image.asset(
        //                             'assets/images/home/share.png',
        //                             width: SizeConfig.blockWidth * 5.2,
        //                             height: SizeConfig.blockHeight * 5.2,
        //                             fit: BoxFit.contain,
        //                           ),
        //                         ),
        //                       ],
        //                     ),
        //                   ],
        //                 ),
        //                 // actionRows: Row(
        //                 //   mainAxisAlignment: MainAxisAlignment.spaceBetween,
        //                 //   crossAxisAlignment: CrossAxisAlignment.center,
        //                 //   children: [
        //                 //     customButton(
        //                 //       width: SizeConfig.blockWidth*45,
        //                 //         text: 'VIEW INSIGHTS',
        //                 //         onPressed: () {
        //                 //           Navigator.push(
        //                 //             context,
        //                 //             MaterialPageRoute(
        //                 //                 builder: (BuildContext context) =>  ViewInsightsScreen()
        //                 //             ),
        //                 //           );
        //                 //         },
        //                 //         backgroundColor: COLORS.primary,
        //                 //        showIcon: false,
        //                 //
        //                 //         height: SizeConfig.blockHeight * 8,
        //                 //         textColor: COLORS.white,
        //                 //     ),
        //                 //     const Row(
        //                 //       mainAxisAlignment: MainAxisAlignment.spaceBetween,
        //                 //       crossAxisAlignment: CrossAxisAlignment.center,
        //                 //       children: [
        //                 //         IconAction(icon: Icons.edit,),
        //                 //         IconAction(icon: Icons.delete_rounded,changeColor: true,bgColor: COLORS.accent),
        //                 //       ],
        //                 //     )
        //                 //   ],
        //                 // ),
        //               )
        //             ],
        //           ),
        //         ),
        //       ),
        //     )),
        );
  }
}
