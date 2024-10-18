import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:works_app/components/size_config.dart';

import '../../bloc/profile/profile_bloc.dart';
import '../../bloc/show_interested/show_interested_bloc.dart';
import '../../components/colors.dart';
import '../../global_helper/loading_placeholder/home_layout.dart';
import '../../global_helper/reuse_widget.dart';
import '../../models/professionals_list_model.dart';

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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: COLORS.white,
      appBar: const CustomAppBar(
          title: 'Saved Professionals',
          backgroundColor: COLORS.white,
          titleColors: COLORS.neutralDark),
      body: SafeArea(
        child: SingleChildScrollView(
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
                  return  SizedBox(
                      height: SizeConfig.screenHeight,
                      child: ShimmerJobCards());
                } else if (error) {
                  return Center(child: Text('Failed to load.'));
                } else if (!loading && !error) {
                  return Padding(
                    padding: EdgeInsets.symmetric(vertical: SizeConfig.blockHeight),
                    child:  ListView.builder(
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
                                onTap: (){},
                                accountVerified:
                                professionalData!.isVerified!,
                                image: professionalData!.profilePic!,
                                name: professionalData!.name!,
                                profession: professionalData.professionType!,
                                location: professionalData.city!,
                                languages: professionalData.knownLanguages!
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
                                genderImage: 'assets/images/home/gender.png',
                                jobTypeImage:
                                'assets/images/profile/prof.png',
                                language: professionalData.knownLanguages!
                                    .join(", "),
                                languageImage: 'assets/images/home/speak.png',
                                onShowInterest: () {
                                  if (professionalData.isContacted == null) {
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
                                jobType: professionalData.professionType!,
                                onShare: () {},
                                savedTap: () {

                                }),
                          );
                        }),
                  );
                }

                return Container();
              },
            ),
          ),
        ),
      ),
    );
  }
}
