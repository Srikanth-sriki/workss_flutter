import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:works_app/components/size_config.dart';
import 'package:works_app/global_helper/helper_function.dart';

import '../../bloc/professional/professional_bloc.dart';
import '../../bloc/profile/profile_bloc.dart';
import '../../bloc/report_post_bloc.dart';
import '../../bloc/show_interested/show_interested_bloc.dart';
import '../../components/colors.dart';
import '../../global_helper/loading_placeholder/home_layout.dart';
import '../../global_helper/reuse_widget.dart';
import '../../models/professionals_list_model.dart';
import '../professional/professional_view.dart';

class BookMarkListScreen extends StatefulWidget {
  const BookMarkListScreen({super.key});

  @override
  State<BookMarkListScreen> createState() => _BookMarkListScreenState();
}

class _BookMarkListScreenState extends State<BookMarkListScreen> {
  late ProfileBloc profileBloc;
  late ShowInterestedBloc showInterestedBloc;
  late List<ProfessionalsPostedWork> professionalsPostedWork;
  bool loading = true;
  bool error = false;

  @override
  void initState() {
    super.initState();
    profileBloc = BlocProvider.of<ProfileBloc>(context);
    showInterestedBloc = BlocProvider.of<ShowInterestedBloc>(context);
  }
  void _refreshPageAfterEdit() {
    profileBloc.add(const FetchSavedProfessionalEvent());
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: COLORS.white,
      appBar: const CustomAppBar(
          title: 'Saved Professionals',
          backgroundColor: COLORS.white,
          titleColors: COLORS.neutralDark),
      body: SafeArea(
        child: BlocListener<ProfileBloc, ProfileState>(
          listener: (context, state) {
            if (state is ProfileLoading || state is ProfileInitial) {
              setState(() {
                loading = true;
                error = false;
              });
            } else if (state is FetchSavedProfessionalSuccess) {
              setState(() {
                loading = false;
                error = false;
                professionalsPostedWork = state.professionalsPostedWork!;
              });
            } else if (state is FetchSavedProfessionalFailed) {
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
                    child: ShimmerJobCards());
              } else if (error) {
                return SizedBox(
                  height: SizeConfig.screenHeight,
                  child: ErrorScreen(onRetry: (){
                    profileBloc.add(const FetchSavedProfessionalEvent());
                  }),
                );
              } else if (!loading && !error) {
                return professionalsPostedWork.isNotEmpty
                    ? SingleChildScrollView(
                      child: Padding(
                          padding: EdgeInsets.symmetric(
                              vertical: SizeConfig.blockHeight),
                          child: ListView.builder(
                              shrinkWrap: true,
                              physics: const NeverScrollableScrollPhysics(),
                              itemCount: professionalsPostedWork.length!,
                              itemBuilder: (context, index) {
                                var professionalData =
                                    professionalsPostedWork![index];
                                return Container(
                                  padding: EdgeInsets.symmetric(
                                      vertical: SizeConfig.blockWidth * 2,
                                      horizontal: SizeConfig.blockWidth * 4),
                                  child: buildProfessionalCard(
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
                                                        BlocProvider(create:(context)=>ReportPostBloc() )
                                                      ],
                                                      child:
                                                          ProfessionalViewScreen(
                                                        id: professionalData
                                                            .id!,
                                                            refreshPageCallback: _refreshPageAfterEdit,
                                                      ),
                                                    )));
                                      },
                                      accountVerified:
                                          professionalData!.isVerified!,
                                      image: professionalData!.profilePic!,
                                      name: professionalData!.name!,
                                      profession:
                                          professionalData.professionType!,
                                      location: professionalData.city!,
                                      languages: professionalData
                                          .knownLanguages!
                                          .join(", "),
                                      gender: professionalData.gender!,
                                      price: professionalData.charges!,
                                      paymentType: professionalData.chargeType!,
                                      contacted:
                                          professionalData.isContacted != null,
                                      saved: true,
                                      experience:
                                          professionalData.experiencedYears!,
                                      experienceImage:
                                          'assets/images/home/work_select.png',
                                      genderImage:
                                          'assets/images/home/gender.png',
                                      jobTypeImage:
                                          'assets/images/profile/prof.png',
                                      language: professionalData.knownLanguages!
                                          .join(", "),
                                      languageImage:
                                          'assets/images/home/speak.png',
                                      onShowInterest: () {
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
                                              makePhoneCall(professionalData.mobile!);
                                            },
                                            onError: () {},
                                          ));
                                        }
                                        else{
                                          makePhoneCall(professionalData.mobile!);
                                        }
                                      },
                                      jobType: professionalData.professionType!,
                                      onShare: () {
                                        shareJobDetails(
                                          experience: professionalData.experiencedYears!,
                                          location: professionalData.city!,
                                          jobTitle:  professionalData.professionType!,
                                        );
                                      },
                                      savedTap: () {
                                        showInterestedBloc.add(ProfessionalSavedUs(
                                          PropId: professionalData.id!,
                                          onSuccess: () {
                                            showCustomSnackBar(
                                              context: context,
                                              message:
                                              "Successfully removed from your saved list!",
                                              backgroundColor:
                                              COLORS
                                                  .semanticTwo,
                                            );
                                            profileBloc.add(const FetchSavedProfessionalEvent());
                                          },
                                          onError: () {
                                            showCustomSnackBar(
                                              context: context,
                                              message: "Something Went wrong",
                                            );
                                          },
                                        ));
                                      }),
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
            },
          ),
        ),
      ),
    );
  }
}
