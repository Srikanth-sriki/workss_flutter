import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:works_app/components/size_config.dart';

import '../../bloc/professional/professional_bloc.dart';
import '../../bloc/show_interested/show_interested_bloc.dart';
import '../../components/colors.dart';
import '../../global_helper/helper_function.dart';
import '../../global_helper/readmore_text.dart';
import '../../global_helper/reuse_widget.dart';
import '../../models/professional_view_model.dart';
import '../profile/component.dart';
import 'component/grid_image_card.dart';

class ProfessionalViewScreen extends StatefulWidget {
  final String id;
  const ProfessionalViewScreen({super.key, required this.id});

  @override
  State<ProfessionalViewScreen> createState() => _ProfessionalViewScreenState();
}

class _ProfessionalViewScreenState extends State<ProfessionalViewScreen> {
  late ProfessionalBloc professionalBloc;
  late ShowInterestedBloc showInterestedBloc;
  final bool saved = false;

  @override
  void initState() {
    super.initState();
    professionalBloc = BlocProvider.of<ProfessionalBloc>(context);
    showInterestedBloc = BlocProvider.of<ShowInterestedBloc>(context);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        toolbarHeight: 0,
        scrolledUnderElevation: 0,
      ),
      body: BlocConsumer<ProfessionalBloc, ProfessionalState>(
        listener: (context, state) {},
        builder: (context, state) {
          if (state is ProfessionalViewLoading) {
            return Container();
          } else if (state is ProfessionalViewSuccess) {
            final professional = state.professionalViewModel.professional!;
            final similarProfessionals =
                state.professionalViewModel.similarProfessionals!;
            return SafeArea(
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
                                Container(
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
                                              SizeConfig.blockWidth * 2))),
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
                              Image.asset(
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
                              IconButton(
                                icon: Icon(Icons.more_vert,
                                    color: COLORS.black,
                                    size: SizeConfig.blockWidth * 6.5),
                                onPressed: () {
                                  // Add functionality for more button
                                },
                              )
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
                                'Professional Details',
                                style: TextStyle(
                                  color: COLORS.neutralDarkOne,
                                  fontSize: SizeConfig.blockWidth * 3.6,
                                  fontWeight: FontWeight.w400,
                                  fontFamily: "Poppins",
                                ),
                              ),
                            ),
                            registerTextCard(
                                text: professional.professionType!,
                                image: 'assets/images/home/home.png',
                                color: COLORS.primary,
                                textColor: COLORS.neutralDark),
                            registerTextCard(
                                text: professional.experiencedYears!,
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
                                  crossAxisAlignment: CrossAxisAlignment.start,
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
                                          professional.chargeType!),
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
                                'Bio',
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
                                'Gallery',
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
                            if(similarProfessionals.isNotEmpty)...[
                              Padding(
                                padding: EdgeInsets.only(
                                    bottom: SizeConfig.blockHeight * 0.5,top: SizeConfig.blockHeight),
                                child: Text(
                                  'Similar Professionals',
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
                                    return Container(
                                      padding: EdgeInsets.symmetric(
                                        vertical: SizeConfig.blockWidth * 2,
                                      ),
                                      child: buildProfessionalCard(
                                          accountVerified: professionalData!
                                              .isVerified!,
                                          image: professionalData!.profilePic!,
                                          name: professionalData!.name!,
                                          profession: professionalData
                                              .professionType!,
                                          location: professionalData.city!,
                                          languages:
                                          professionalData
                                              .knownLanguages!
                                              .join(", "),
                                          gender: professionalData.gender!,
                                          price: professionalData.charges!,
                                          paymentType: professionalData
                                              .chargeType!,
                                          contacted:
                                          professionalData
                                              .isContacted !=
                                              null,
                                          saved: professionalData.isSaved != null,
                                          experience: professionalData
                                              .experiencedYears!,
                                          experienceImage:
                                          'assets/images/home/work_select.png',
                                          genderImage:
                                          'assets/images/home/gender.png',
                                          jobTypeImage:
                                          'assets/images/profile/prof.png',
                                          language:
                                          professionalData
                                              .knownLanguages!
                                              .join(", "),
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
                                                    professionalData.isContacted =
                                                        IsContacted(id: '');
                                                  });
                                                },
                                                onError: () {},
                                              ));
                                            }
                                          },
                                          jobType:
                                          professionalData.professionType!,
                                          onShare: () {
                                            shareJobDetails();
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
                                                            )
                                                          ],
                                                          child:
                                                          ProfessionalViewScreen(
                                                            id: professionalData
                                                                .id!,
                                                          ),
                                                        )));
                                          },
                                          savedTap: () {
                                            showInterestedBloc
                                                .add(ProfessionalSavedUs(
                                              PropId: professionalData.id!,
                                              onSuccess: () {
                                                setState(() {
                                                  professionalData.isSaved =
                                                      IsContacted(id: '');
                                                });
                                              },
                                              onError: () {},
                                            ));
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
            );
          } else if (state is ProfessionalViewError) {
            return Container();
          }
          return Container();
        },
      ),
    );
  }
}
