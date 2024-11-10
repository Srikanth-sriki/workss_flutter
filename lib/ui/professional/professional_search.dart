import 'dart:async';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:works_app/bloc/home/home_bloc.dart';
import 'package:works_app/components/colors.dart';
import 'package:works_app/global_helper/reuse_widget.dart';
import 'package:works_app/ui/home/work_details.dart';
import 'package:works_app/ui/professional/professional_view.dart';

import '../../bloc/professional/professional_bloc.dart';
import '../../bloc/show_interested/show_interested_bloc.dart';
import '../../components/size_config.dart';
import '../../global_helper/helper_function.dart';
import '../../global_helper/loading_placeholder/home_layout.dart';
import '../../models/professionals_list_model.dart';



class ProfessionalSearchList extends StatefulWidget {
  const ProfessionalSearchList({super.key});

  @override
  _ProfessionalSearchListState createState() => _ProfessionalSearchListState();
}

class _ProfessionalSearchListState extends State<ProfessionalSearchList> {
  late ProfessionalBloc professionalBloc;
  late ShowInterestedBloc showInterestedBloc;
  final ScrollController _scrollController = ScrollController();
  final TextEditingController _searchController = TextEditingController();
  Timer? _debounce;
  bool isFetchingMore = false;
  int currentPage = 1;
  int pageSize = 10;
  int maxPageNumber = 1;
  String searchKeyword = "";

  @override
  void initState() {
    super.initState();
    professionalBloc = BlocProvider.of<ProfessionalBloc>(context);
    showInterestedBloc = BlocProvider.of<ShowInterestedBloc>(context);
    _scrollController.addListener(() {
      if (_scrollController.position.pixels ==
          _scrollController.position.maxScrollExtent &&
          !isFetchingMore &&
          currentPage < maxPageNumber) {
        _loadMoreData();
      }
    });

    _fetchData();
  }

  void _onSearchChanged(String keyword) {
    if (_debounce?.isActive ?? false) _debounce?.cancel();
    _debounce = Timer(const Duration(milliseconds: 500), () {
      setState(() {
        searchKeyword = keyword;
        currentPage = 1;
      });
      _fetchData();
    });
  }


  void _fetchData() {
    professionalBloc.add(ProfessionalListEvent(
      page: currentPage,
      pageSize: pageSize,
      keyWord: searchKeyword,
      profession: "",
      city: "",
      gender: "",
    ));
  }

  void _loadMoreData() {
    setState(() {
      isFetchingMore = true;
      currentPage++;
    });
    _fetchData();
  }

  @override
  void dispose() {
    _scrollController.dispose();
    _searchController.dispose();
    _debounce?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: COLORS.white,
      appBar: AppBar(
        toolbarHeight: 0,
        backgroundColor: COLORS.white,
        scrolledUnderElevation: 0,
        elevation: 0,
        automaticallyImplyLeading: false,
      ),
      body: SafeArea(
        child: Column(
          children: [
            Container(
              padding:  EdgeInsets.symmetric(horizontal: SizeConfig.blockWidth*4.5,vertical: SizeConfig.blockHeight*2),
              child: TextField(
                controller: _searchController,
                style: TextStyle(
                  color: COLORS.neutralDarkOne,
                  fontSize: SizeConfig.blockWidth * 3.25,
                  fontWeight: FontWeight.w400,
                  fontFamily: "Poppins",
                ),
                cursorColor: COLORS.black,
                decoration: InputDecoration(
                  fillColor: COLORS.neutralDarkTwo.withOpacity(0.6),
                  focusColor: COLORS.neutralDarkTwo.withOpacity(0.6),
                  filled: true,
                  hintText: 'Ex: Plumber, Swimming Coach'.tr(),
                  hintStyle: TextStyle(
                    color: COLORS.neutralDarkOne,
                    fontSize: SizeConfig.blockWidth * 3.25,
                    fontWeight: FontWeight.w400,
                    fontFamily: "Poppins",
                  ),
                  prefixIcon: Icon(
                    Icons.search,
                    color: COLORS.neutralDarkOne,
                    size: SizeConfig.blockWidth * 5,
                  ),
                  border: OutlineInputBorder(
                    borderRadius:
                    BorderRadius.circular(SizeConfig.blockWidth * 3.25),
                    borderSide: BorderSide(
                        color: COLORS.neutralDarkTwo.withOpacity(0.6),
                        width: SizeConfig.blockWidth * 0.1),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius:
                    BorderRadius.circular(SizeConfig.blockWidth * 3.25),
                    borderSide: BorderSide(
                        color: COLORS.neutralDarkTwo.withOpacity(0.6),
                        width: SizeConfig.blockWidth * 0.1),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius:
                    BorderRadius.circular(SizeConfig.blockWidth * 3.25),
                    borderSide: BorderSide(
                        color: COLORS.neutralDarkTwo.withOpacity(0.6),
                        width: SizeConfig.blockWidth * 0.1),
                  ),
                ),
                onChanged: _onSearchChanged,
              ),
            ),
            // Divider(
            //   height: SizeConfig.blockHeight*0,
            //   color: COLORS.neutralDarkTwo,
            // ),
            // SizedBox(height: SizeConfig.blockHeight*2,),
            Expanded(
              child: BlocConsumer<ProfessionalBloc, ProfessionalState>(
                listener: (context, state) {
                  if (state is FetchProfessionalListSuccess) {
                    setState(() {
                      isFetchingMore = false;
                      maxPageNumber = state.maxPageNumber;
                    });
                  } else if (state is FetchProfessionalListFailed) {
                    setState(() {
                      isFetchingMore = false;
                    });
                    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                      content: Text(state.message),
                    ));
                  }
                },
                builder: (context, state) {
                  if (state is ProfessionalLoading && currentPage == 1) {
                    return const ShimmerJobCards();
                  } else if (state is FetchProfessionalListSuccess) {
                    return _buildListView(state.professionalsPostedWork);
                  } else if (state is FetchProfessionalListFailed) {
                    return ErrorScreen(onRetry: () {
                      _fetchData();
                    });
                  }
                  return Container();
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildListView(List<ProfessionalsPostedWork> professionalsPostedWork) {
    if (professionalsPostedWork.isEmpty) {
      return emptyComponent();
    }
    return ListView.builder(
      controller: _scrollController,
      itemCount: professionalsPostedWork.length + (isFetchingMore ? 1 : 0),
      itemBuilder: (context, index) {
        if (index < professionalsPostedWork.length) {
          final professionalData = professionalsPostedWork[index];
          return Container(
            padding:  EdgeInsets.symmetric(horizontal: SizeConfig.blockWidth*4.5,vertical: SizeConfig.blockHeight*0.5),
            child: buildProfessionalCard(
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
                saved: professionalData.isSaved != null,
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
                                child: ProfessionalViewScreen(
                                  id: professionalData.id!,
                                ),
                              )));
                },
                savedTap: () {
                  if(professionalData.isSaved ==null){
                    showInterestedBloc.add(ProfessionalSavedUs(
                      PropId: professionalData.id!,
                      onSuccess: () {
                        setState(() {
                          professionalData.isSaved =
                              IsContacted(id: '');
                        });
                      },
                      onError: () {
                        showCustomSnackBar(
                          context: context,
                          message: "Something Went wrong",
                        );
                      },
                    ));
                  }
                  else{
                    showInterestedBloc.add(ProfessionalSavedUs(
                      PropId: professionalData.id!,
                      onSuccess: () {
                        setState(() {
                          professionalData.isSaved =
                          null;
                        });
                      },
                      onError: () {
                        showCustomSnackBar(
                          context: context,
                          message: "Something Went wrong",
                        );
                      },
                    ));
                  }
                }),
          );
        } else if (isFetchingMore) {
          return  Center(child: SizedBox(
              height: SizeConfig.blockWidth*5,
              width: SizeConfig.blockWidth*5,
              child: const CircularProgressIndicator(color: COLORS.primary,strokeWidth: 2,)));
        } else {
          return const SizedBox.shrink();
        }
      },
    );
  }
}
