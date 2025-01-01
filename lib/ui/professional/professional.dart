import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:modal_bottom_sheet/modal_bottom_sheet.dart';
import 'package:works_app/bloc/professional/professional_bloc.dart';
import 'package:works_app/bloc/show_interested/show_interested_bloc.dart';
import 'package:works_app/models/professionals_list_model.dart';
import 'package:works_app/ui/home/component.dart';
import 'package:works_app/ui/onboarding/language_selection.dart';
import 'package:works_app/ui/professional/categories.dart';
import 'package:works_app/ui/professional/professional_search.dart';
import 'package:works_app/ui/professional/professional_view.dart';
import '../../bloc/notification/notification_bloc.dart';
import '../../bloc/register_account/initial_register_bloc.dart';
import '../../components/colors.dart';
import '../../components/size_config.dart';
import '../../global_helper/helper_function.dart';
import '../../global_helper/loading_placeholder/home_layout.dart';
import '../../global_helper/reuse_widget.dart';
import '../../models/category_list_modal.dart';
import '../home/filter.dart';
import '../home/notification_list.dart';
import 'categories_item.dart';

class ProfessionalsScreen extends StatefulWidget {
  const ProfessionalsScreen({super.key});

  @override
  State<ProfessionalsScreen> createState() => _ProfessionalsScreenState();
}

class _ProfessionalsScreenState extends State<ProfessionalsScreen> {
  late ProfessionalBloc professionalBloc;
  late ShowInterestedBloc showInterestedBloc;
  List<ProfessionalsPostedWork> professionalsPostedWork = [];
  final ScrollController _scrollController = ScrollController();
  bool isFetchingMore = false;
  bool isProfessionalLoad = true;
  bool isCategoryLoad = true;
  int currentPage = 1;
  int pageSize = 10;
  int maxPageNumber = 1;
  String? selectedProfession = '';
  String? selectedCity = '';
  String selectedGender = '';
  late List<CategorySub> categoriesData = [];

  @override
  void initState() {
    super.initState();
    professionalBloc = BlocProvider.of<ProfessionalBloc>(context);
    showInterestedBloc = BlocProvider.of<ShowInterestedBloc>(context);
    _fetchData();
    _scrollController.addListener(() {
      if (_scrollController.position.atEdge && !isFetchingMore) {
        final isBottom = _scrollController.position.pixels ==
            _scrollController.position.maxScrollExtent;
        if (isBottom && currentPage < maxPageNumber) {
          _loadMoreData();
        }
      }
    });
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _fetchData();
  }

  void _fetchData({bool isNewFetch = false}) {
    if (isNewFetch) {
      professionalsPostedWork.clear();
      currentPage = 1;
    }
    professionalBloc.add(ProfessionalListEvent(
        page: currentPage,
        pageSize: pageSize,
        keyWord: "",
        profession: "",
        city: "",
        gender: "",
        currentLongitude: '',
        currentLatitude: ''));
    professionalBloc.add(const FetchCategoryListEvent());
  }

  void _loadMoreData() {
    if (!isFetchingMore && currentPage < maxPageNumber) {
      setState(() {
        isFetchingMore = true;
      });
      currentPage++;
      _fetchData();
    }
  }

  void filterProfessionalScreenData(
      String? profession, String? city, String gender) {
    setState(() {
      currentPage = 1;
      isFetchingMore = false;
      professionalBloc.add(ProfessionalListEvent(
          page: currentPage,
          pageSize: pageSize,
          keyWord: "",
          profession: profession ?? "",
          city: city ?? "",
          gender: gender ?? "",
          currentLongitude: '',
          currentLatitude: ''));
    });
  }

  @override
  void dispose() {
    _scrollController.dispose();
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
      body: BlocListener<ProfessionalBloc, ProfessionalState>(
        listener: (context, state) {
          if (state is ProfessionalLoading && currentPage == 1) {
            isProfessionalLoad = true;
          } else if (state is FetchProfessionalListSuccess) {
            setState(() {
              if (currentPage == 1) {
                professionalsPostedWork = state.professionalsPostedWork;
              } else {
                // Filter out duplicates by checking ID before adding
                final newItems = state.professionalsPostedWork.where(
                    (newItem) => !professionalsPostedWork
                        .any((existingItem) => existingItem.id == newItem.id));
                professionalsPostedWork.addAll(newItems);
              }
              maxPageNumber = state.maxPageNumber;
              isFetchingMore = false;
              isProfessionalLoad = false;
            });
          } else if (state is FetchProfessionalListFailed) {
            setState(() {
              isFetchingMore = false;
              isProfessionalLoad = false;
            });
          } else if (state is FetchCategoryListLoading) {
            setState(() {
              isCategoryLoad = true;
            });
          } else if (state is FetchCategoryListSuccess) {
            setState(() {
              categoriesData = state.categories;
              isCategoryLoad = false;
            });
          } else if (state is FetchCategoryListFailed) {
            setState(() {
              isCategoryLoad = false;
            });
          }
          setState(() {});
        },
        child: SafeArea(
          child: Container(
            width: SizeConfig.screenWidth,
            padding: EdgeInsets.only(top: SizeConfig.blockHeight * 2),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: EdgeInsets.symmetric(
                    horizontal: SizeConfig.blockWidth * 5,
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Text(
                        '.Workss',
                        style: TextStyle(
                          color: COLORS.primary,
                          fontSize: SizeConfig.blockWidth * 6,
                          fontWeight: FontWeight.bold,
                          fontFamily: "Poppins",
                        ),
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          InkWell(
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                    builder: (BuildContext context) =>
                                        const LanguageSelectionScreen(
                                          routeType: 'homo',
                                        )),
                              );
                            },
                            child: Container(
                              padding:
                                  EdgeInsets.all(SizeConfig.blockWidth * 3),
                              margin: EdgeInsets.only(
                                  right: SizeConfig.blockWidth * 2.8),
                              decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(
                                      SizeConfig.blockWidth * 2.5),
                                  color: COLORS.primaryOne.withOpacity(0.3)),
                              child: Image.asset(
                                'assets/images/home/translation.png',
                                width: SizeConfig.blockWidth * 5.5,
                                height: SizeConfig.blockWidth * 5.5,
                                fit: BoxFit.contain,
                              ),
                            ),
                          ),
                          InkWell(
                            onTap: () {
                              Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                      builder: (context) => MultiBlocProvider(
                                            providers: [
                                              BlocProvider(
                                                create: (context) =>
                                                    NotificationBloc()
                                                      ..add(
                                                          const FetchNotificationList()),
                                              ),
                                            ],
                                            child:
                                                const NotificationListScreen(),
                                          )));
                            },
                            child: Container(
                              padding:
                                  EdgeInsets.all(SizeConfig.blockWidth * 3),
                              decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(
                                      SizeConfig.blockWidth * 2.5),
                                  color: COLORS.primaryOne.withOpacity(0.3)),
                              child: Icon(
                                Icons.notifications_none,
                                size: SizeConfig.blockWidth * 5.5,
                              ),
                            ),
                          ),
                        ],
                      )
                    ],
                  ),
                ),
                SizedBox(
                  height: SizeConfig.blockHeight * 3.5,
                ),
                Padding(
                  padding: EdgeInsets.symmetric(
                    horizontal: SizeConfig.blockWidth * 5,
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      InkWell(
                        onTap: () {
                          Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (context) => MultiBlocProvider(
                                        providers: [
                                          BlocProvider(
                                              create: (context) =>
                                                  ProfessionalBloc()
                                                    ..add(ProfessionalListEvent(
                                                        page: 1,
                                                        pageSize: 20,
                                                        profession: '',
                                                        keyWord: '',
                                                        city: '',
                                                        currentLongitude: '',
                                                        currentLatitude: '',
                                                        gender: ''))),
                                          BlocProvider(
                                            create: (context) =>
                                                ShowInterestedBloc(),
                                          )
                                        ],
                                        child: const ProfessionalSearchList(),
                                      )));
                        },
                        child: Container(
                          width: SizeConfig.blockWidth * 72,
                          height: SizeConfig.blockHeight * 8,
                          decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(
                                  SizeConfig.blockWidth * 3.25),
                              color: COLORS.neutralDarkTwo.withOpacity(0.6)),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.start,
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              Padding(
                                padding: EdgeInsets.symmetric(
                                    horizontal: SizeConfig.blockWidth * 4),
                                child: Icon(
                                  Icons.search,
                                  color: COLORS.neutralDarkOne,
                                  size: SizeConfig.blockWidth * 6,
                                ),
                              ),
                              Text(
                                'Search by Profession type'.tr(),
                                style: TextStyle(
                                  color: COLORS.neutralDarkOne,
                                  fontSize: SizeConfig.blockWidth * 3.3,
                                  fontWeight: FontWeight.w400,
                                  fontFamily: "Poppins",
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      InkWell(
                        onTap: () async {
                          final result = await showMaterialModalBottomSheet(
                              enableDrag: true,
                              expand: false,
                              isDismissible: true,
                              backgroundColor: COLORS.white,
                              closeProgressThreshold: 0,
                              duration: const Duration(seconds: 0),
                              context: context,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.vertical(
                                    top: Radius.circular(
                                        SizeConfig.blockWidth * 6)),
                              ),
                              builder: (context) => MultiBlocProvider(
                                    providers: [
                                      BlocProvider(
                                        create: (context) {
                                          final bloc = InitialRegisterBloc();
                                          bloc.add(const FetchCityEvent());
                                          bloc.add(
                                              const FetchChargeFeesEvent());
                                          bloc.add(
                                              const FetchWorkKnownLanguageProfileEvent());
                                          return bloc;
                                        },
                                      ),
                                      BlocProvider(
                                          create: (context) => ProfessionalBloc()
                                            ..add(
                                                const FetchCategoryListEvent())),
                                    ],
                                    child: SearchFilterBottomSheet(
                                      initialProfession: selectedProfession,
                                      initialCity: selectedCity,
                                      initialGender: selectedGender,
                                    ),
                                  ));

                          if (result != null) {
                            selectedProfession = result['selectedProfession'];
                            selectedCity = result['selectedCity'];
                            selectedGender = result['selectedGender'];
                            filterProfessionalScreenData(
                              selectedProfession,
                              selectedCity,
                              selectedGender,
                            );
                          }
                        },
                        child: Container(
                          padding: EdgeInsets.all(SizeConfig.blockWidth * 4),
                          height: SizeConfig.blockHeight * 8,
                          width: SizeConfig.blockHeight * 8,
                          decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(
                                  SizeConfig.blockWidth * 2.5),
                              color: COLORS.neutralDarkTwo.withOpacity(0.6)),
                          child: Image.asset(
                            'assets/images/home/filter.png',
                            width: SizeConfig.blockWidth * 5.5,
                            height: SizeConfig.blockWidth * 5.5,
                            fit: BoxFit.contain,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                Padding(
                  padding: EdgeInsets.symmetric(
                      vertical: SizeConfig.blockHeight * 1.5),
                  child: Divider(
                    height: SizeConfig.blockHeight,
                    color: COLORS.neutralDarkTwo,
                  ),
                ),
                Expanded(
                  child: SingleChildScrollView(
                    physics: const AlwaysScrollableScrollPhysics(),
                    controller: _scrollController,
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.start,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Padding(
                          padding: EdgeInsets.symmetric(
                            horizontal: SizeConfig.blockWidth * 5,
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              Text(
                                'Categories'.tr(),
                                style: TextStyle(
                                  color: COLORS.neutralDark,
                                  fontSize: SizeConfig.blockWidth * 3.8,
                                  fontWeight: FontWeight.w400,
                                  fontFamily: "Poppins",
                                ),
                              ),
                              InkWell(
                                onTap: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                        builder: (BuildContext context) =>
                                            CategoriesScreen(
                                                categoriesData:
                                                    categoriesData)),
                                  );
                                },
                                child: Text(
                                  'See All'.tr(),
                                  style: TextStyle(
                                    color: COLORS.accent,
                                    fontSize: SizeConfig.blockWidth * 3.6,
                                    fontWeight: FontWeight.w400,
                                    fontFamily: "Poppins",
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                        if (isCategoryLoad) ...[
                          Padding(
                            padding: EdgeInsets.only(
                              left: SizeConfig.blockWidth * 6,
                              right: SizeConfig.blockWidth * 6,
                            ),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: [
                                categoryLoading(),
                                categoryLoading(),
                                categoryLoading(),
                                categoryLoading()
                              ],
                            ),
                          ),
                        ],
                        if (!isCategoryLoad) ...[
                          SizedBox(
                            height: SizeConfig.blockHeight * 20,
                            child: ListView.builder(
                                itemCount: categoriesData.length,
                                shrinkWrap: true,
                                scrollDirection: Axis.horizontal,
                                padding: EdgeInsets.symmetric(
                                    horizontal: SizeConfig.blockWidth * 5,
                                    vertical: SizeConfig.blockHeight),
                                itemBuilder: (context, index) {
                                  return InkWell(
                                    onTap: () {
                                      Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                            builder: (BuildContext context) =>
                                                CategoriesItemScreen(
                                                    categoriesItem:
                                                        categoriesData[index])),
                                      );
                                    },
                                    child: Container(
                                      padding: EdgeInsets.all(
                                          SizeConfig.blockWidth * 3),
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.center,
                                        mainAxisAlignment:
                                            MainAxisAlignment.start,
                                        children: [
                                          Container(
                                            width: SizeConfig.blockWidth * 18,
                                            height: SizeConfig.blockWidth * 18,
                                            decoration: BoxDecoration(
                                                image: DecorationImage(
                                                  image: AssetImage(
                                                      categoriesData[index]
                                                          .image),
                                                  fit: BoxFit.contain,
                                                ),
                                                borderRadius:
                                                    BorderRadius.circular(
                                                        SizeConfig.blockWidth *
                                                            20),
                                                color: COLORS.primaryOne
                                                    .withOpacity(0.5)),
                                          ),
                                          SizedBox(
                                            height:
                                                SizeConfig.blockHeight * 0.5,
                                          ),
                                          Text(
                                            categoriesData[index].name,
                                            style: TextStyle(
                                              color: COLORS.neutralDark,
                                              fontSize:
                                                  SizeConfig.blockWidth * 3,
                                              fontWeight: FontWeight.w500,
                                              fontFamily: "Poppins",
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  );
                                }),
                          )
                        ],
                        Padding(
                          padding: EdgeInsets.symmetric(
                            horizontal: SizeConfig.blockWidth * 5,
                          ),
                          child: Text(
                            'Professionals'.tr(),
                            style: TextStyle(
                              color: COLORS.neutralDarkOne,
                              fontSize: SizeConfig.blockWidth * 3.8,
                              fontWeight: FontWeight.w400,
                              fontFamily: "Poppins",
                            ),
                            textAlign: TextAlign.end,
                          ),
                        ),
                        SizedBox(
                          height: SizeConfig.blockHeight * 0.5,
                        ),
                        if (isProfessionalLoad == true) ...[
                          professionalLoading(),
                          professionalLoading(),
                          professionalLoading(),
                        ] else ...[
                          professionalsPostedWork.isNotEmpty
                              ? ListView.builder(
                                  shrinkWrap: true,
                                  physics: NeverScrollableScrollPhysics(),
                                  itemCount: professionalsPostedWork.length!,
                                  itemBuilder: (context, index) {
                                    var professionalData =
                                        professionalsPostedWork![index];
                                    return Container(
                                      padding: EdgeInsets.symmetric(
                                          vertical: SizeConfig.blockWidth * 2,
                                          horizontal:
                                              SizeConfig.blockWidth * 4),
                                      child: buildProfessionalCard(
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
                                          paymentType:
                                              professionalData.chargeType!,
                                          contacted: professionalData.isContacted !=
                                              null,
                                          saved:
                                              professionalData.isSaved != null,
                                          experience: professionalData
                                              .experiencedYears!,
                                          experienceImage:
                                              'assets/images/home/work_select.png',
                                          genderImage:
                                              'assets/images/home/gender.png',
                                          jobTypeImage:
                                              'assets/images/profile/prof.png',
                                          language: professionalData
                                              .knownLanguages!
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
                                                    professionalData
                                                            .isContacted =
                                                        IsContacted(id: '');
                                                    makePhoneCall(
                                                        professionalData
                                                            .mobile!);
                                                  });
                                                },
                                                onError: () {},
                                              ));
                                            } else {
                                              makePhoneCall(
                                                  professionalData.mobile!);
                                            }
                                          },
                                          jobType:
                                              professionalData.professionType!,
                                          onShare: () {
                                            shareJobDetails(
                                              experience: professionalData
                                                  .experiencedYears!,
                                              location: professionalData.city!,
                                              jobTitle: professionalData
                                                  .professionType!,
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
                                                          child:
                                                              ProfessionalViewScreen(
                                                            id: professionalData
                                                                .id!,
                                                            refreshPageCallback:
                                                                () {
                                                              _fetchData(
                                                                  isNewFetch:
                                                                      true);
                                                            },
                                                          ),
                                                        )));
                                          },
                                          savedTap: () {
                                            if (professionalData.isSaved ==
                                                null) {
                                              showInterestedBloc
                                                  .add(ProfessionalSavedUs(
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
                                                    message:
                                                        "Something Went wrong",
                                                  );
                                                },
                                              ));
                                            } else {
                                              showInterestedBloc
                                                  .add(ProfessionalSavedUs(
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
                                                    message:
                                                        "Something Went wrong",
                                                  );
                                                },
                                              ));
                                            }
                                          }),
                                    );
                                  })
                              : Padding(
                                  padding: EdgeInsets.only(
                                      top: SizeConfig.blockHeight * 6),
                                  child: emptyComponent(),
                                )
                        ],
                      ],
                    ),
                  ),
                )
              ],
            ),
          ),
        ),
      ),
    );
  }
}
