import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:works_app/components/size_config.dart';
import 'package:works_app/models/fetch_posted_work.dart';
import 'package:works_app/ui/profile/component.dart';

import '../../bloc/profile/profile_bloc.dart';
import '../../components/colors.dart';
import '../../global_helper/helper_function.dart';
import '../../global_helper/reuse_widget.dart';
import '../home/component.dart';

class InterestedWorkList extends StatefulWidget {
  const InterestedWorkList({super.key});

  @override
  State<InterestedWorkList> createState() => _InterestedWorkListState();
}

class _InterestedWorkListState extends State<InterestedWorkList> {
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
          title: 'Interested Works',
          backgroundColor: COLORS.white,
          titleColors: COLORS.neutralDark),
      body: BlocListener<ProfileBloc, ProfileState>(
        listener: (context, state) {
          if (state is ProfileLoading) {
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
        child: SafeArea(child: SingleChildScrollView(
          child: Builder(builder: (context) {
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
                  itemBuilder: (context, index){
                var profile = fetchPostedModel[index];
                return Container(
                  padding: EdgeInsets.symmetric(
                      vertical: SizeConfig.blockWidth * 4,
                      horizontal: SizeConfig.blockHeight * 4),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      WorkCard(
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
                                text: 'INTERESTED',
                                onPressed: () {},
                                backgroundColor:
                                COLORS.semanticTwo.withOpacity(0.4),
                                showIcon: true,
                                width: SizeConfig.blockWidth * 50,
                                height: SizeConfig.blockHeight * 6.5,
                                textColor: COLORS.semanticTwo,
                                iconColor: COLORS.semanticTwo,
                                icon: Icons.thumb_up_alt),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
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
                        // actionRows: Row(
                        //   mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        //   crossAxisAlignment: CrossAxisAlignment.center,
                        //   children: [
                        //     customIconButton(
                        //         text: 'INTERESTED',
                        //         onPressed: () {},
                        //         backgroundColor: COLORS.semanticTwo.withOpacity(0.4),
                        //         showIcon: true,
                        //         width: SizeConfig.blockWidth * 62,
                        //         height: SizeConfig.blockHeight * 7.5,
                        //         textColor: COLORS.white,
                        //         iconColor: COLORS.semanticTwo,
                        //         icon: Icons.thumb_up_alt),
                        //     IconAction(
                        //       icon: Icons.share,
                        //     ),
                        //   ],
                        // ),
                      )
                    ],
                  ),
                );
              });
            }
            return Container();
          }),
        )),
      ),
    );
  }
}
