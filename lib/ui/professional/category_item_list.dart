import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:works_app/bloc/chart/chart_bloc.dart';
import 'package:works_app/ui/professional/professional_view.dart';

import '../../bloc/professional/professional_bloc.dart';
import '../../bloc/register_account/initial_register_bloc.dart';
import '../../bloc/report_post_bloc.dart';
import '../../bloc/show_interested/show_interested_bloc.dart';
import '../../components/colors.dart';
import '../../components/size_config.dart';
import '../../global_helper/helper_function.dart';
import '../../global_helper/loading_placeholder/home_layout.dart';
import '../../global_helper/reuse_widget.dart';
import '../../models/professionals_list_model.dart';
import '../chat/chat_view.dart';

class CategoryItemList extends StatefulWidget {
  final dynamic subCategory;
  const CategoryItemList({super.key,required this.subCategory});

  @override
  State<CategoryItemList> createState() => _CategoryItemListState();
}

class _CategoryItemListState extends State<CategoryItemList> {
  late ProfessionalBloc professionalBloc;
  late ShowInterestedBloc showInterestedBloc;
  late ChartBloc chartBloc;
  final ScrollController _scrollController = ScrollController();
  final TextEditingController _searchController = TextEditingController();
  late List<ProfessionalsPostedWork> professionalsPostedWork;
  bool isFetchingMore = false;
  int currentPage = 1;
  int pageSize = 10;
  int maxPageNumber = 1;


  @override
  void initState() {
    super.initState();
    professionalBloc = BlocProvider.of<ProfessionalBloc>(context);
    showInterestedBloc = BlocProvider.of<ShowInterestedBloc>(context);
    chartBloc = BlocProvider.of<ChartBloc>(context);
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

  void _fetchData({bool isNewFetch = false}) {

    professionalBloc.add(ProfessionalListEvent(
        page: currentPage,
        pageSize: pageSize,
        keyWord: "",
        profession: widget.subCategory.name!,
        city: "",
        gender: "",
        currentLongitude: '',knownLanguages: [],
        currentLatitude: ''));
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
    super.dispose();
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: COLORS.white,
      appBar: CustomAppBar(
          title: capitalizeEachWord(getCategoryName(widget.subCategory)),
          backgroundColor: COLORS.white,
          borderColor: false,
          titleColors: COLORS.neutralDark),
      body: SafeArea(child:  BlocConsumer<ProfessionalBloc, ProfessionalState>(
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
            // showCustomSnackBar(
            //   context: context,
            //   message: state.message,
            // );
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
      ),),
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
          final languages = professionalData?.knownLanguages!
              .map((lang) => lang.tr())
              .join(", ");
          return Container(
            padding: EdgeInsets.symmetric(
                horizontal: SizeConfig.blockWidth * 4.5,
                vertical: SizeConfig.blockHeight * 1.5),
            child: buildProfessionalCard(
              itemID:professionalData.id! ,
                accountVerified: professionalData!.isVerified!,
                image: professionalData!.profilePic!,
                name: professionalData!.name!,
                profession:  professionalData.professionalSubCategory != null ? getCategoryProfessionCardName(professionalData.professionalSubCategory) :professionalData
                    .professionType!,
                location: professionalData.city!,
                languages: languages!,
                gender: professionalData.gender!,
                price: professionalData.charges!,
                paymentType: professionalData.chargeType!,
                contacted: professionalData.isContacted != null,
                saved: professionalData.isSaved != null,
                experience: professionalData.experiencedYears!,
                experienceImage: 'assets/images/home/work_select.png',
                genderImage: 'assets/images/home/gender.png',
                jobTypeImage: 'assets/images/profile/prof.png',
                language: languages!,
                languageImage: 'assets/images/home/speak.png',
                smartControlEnable: isSmartControlEnabled(
                  professionalData.smartCallControl,
                  professionalData.smartCallSchedule,
                ),
                onShowInterest: () {
                  if (professionalData.isContacted == null) {
                    showInterestedBloc.add(ProfessionalContactUs(
                      PropId: professionalData.id!,
                      onSuccess: () {
                        setState(() {
                          professionalData.isContacted = IsContacted(id: '');
                        });
                        makePhoneCall(professionalData.mobile!);
                      },
                      onError: () {},
                    ));
                  } else {
                    makePhoneCall(professionalData.mobile!);
                  }
                },
                jobType: professionalData.professionType!,
                onShare: () {
                  shareJobDetails(
                    experience: professionalData.experiencedYears!,
                    location: professionalData.city!,
                    jobTitle: professionalData.professionType!,
                  );
                },
                onTap: () {
                  Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) => MultiBlocProvider(
                            providers: [
                              BlocProvider(
                                create: (context) => ProfessionalBloc()
                                  ..add(FetchProfessionalView(
                                      professionalData.id!)),
                              ),
                              BlocProvider(
                                create: (context) => ShowInterestedBloc(),
                              ),
                              BlocProvider(create:(context)=>ReportPostBloc() ),
                              BlocProvider(create: (context) => ChartBloc())
                            ],
                            child: ProfessionalViewScreen(
                              id: professionalData.id!,
                              refreshPageCallback: () {
                                _fetchData(isNewFetch: true);
                              },
                            ),
                          )));
                },
                savedTap: () {
                  if (professionalData.isSaved == null) {
                    showInterestedBloc.add(ProfessionalSavedUs(
                      PropId: professionalData.id!,
                      onSuccess: () {
                        setState(() {
                          professionalData.isSaved = IsContacted(id: '');
                        });
                      },
                      onError: () {
                        showCustomSnackBar(
                          context: context,
                          message: "Something Went wrong",
                        );
                      },
                    ));
                  } else {
                    showInterestedBloc.add(ProfessionalSavedUs(
                      PropId: professionalData.id!,
                      onSuccess: () {
                        setState(() {
                          professionalData.isSaved = null;
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
                },
                messageOnTap: (){
                  chartBloc.add(
                    StartMessageEvent(
                      chatId: professionalData.id!,
                      onSuccess: (chatId) {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => MultiBlocProvider(
                              providers: [
                                BlocProvider(create: (context) => ChartBloc()..add(FetchChartViewEvent(page: 1, pageSize: 10, chatId: chatId))),
                                BlocProvider(create: (context) => InitialRegisterBloc()),
                                BlocProvider(create: (context) => ShowInterestedBloc()),
                              ],
                              child: ChatViewScreen(
                                refreshPageCallback: (){
                                  _fetchData(isNewFetch: true);
                                },
                                chatId: chatId,
                                isGroup: false,
                              ),
                            ),
                          ),
                        );
                      },
                      onError: (message) {
                        showCustomSnackBar(context: context, message: message, backgroundColor: COLORS.neutralDarkTwo);
                      },
                    ),
                  );
                },
                context: context
            ),
          );
        } else if (isFetchingMore) {
          return Center(
              child: SizedBox(
                  height: SizeConfig.blockWidth * 5,
                  width: SizeConfig.blockWidth * 5,
                  child: const CircularProgressIndicator(
                    color: COLORS.primary,
                    strokeWidth: 2,
                  )));
        } else {
          return const SizedBox.shrink();
        }
      },
    );
  }
}
