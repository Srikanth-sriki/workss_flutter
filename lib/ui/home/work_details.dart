import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:works_app/components/colors.dart';
import 'package:works_app/components/size_config.dart';
import 'package:works_app/global_helper/reuse_widget.dart';

import '../../bloc/home/home_bloc.dart';
import '../../bloc/show_interested/show_interested_bloc.dart';
import '../../components/config.dart';
import '../../global_helper/helper_function.dart';
import '../../models/work_view_model.dart';
import '../professional/component/grid_image_card.dart';
import '../profile/component.dart';
import 'component.dart';

class WorkDetailsScreen extends StatefulWidget {
  final String id;
  const WorkDetailsScreen({super.key, required this.id});

  @override
  State<WorkDetailsScreen> createState() => _WorkDetailsScreenState();
}

class _WorkDetailsScreenState extends State<WorkDetailsScreen> {
  late HomeBloc homeBloc;
  late ShowInterestedBloc showInterestedBloc;
  late LatLng _initialLocation = LatLng(37.77483, -122.41942);
  late LatLng _center = const LatLng(45.521563, -122.677433);
  late GoogleMapController myController;

  void _onMapCreated(GoogleMapController controller) {
    myController = controller;
  }

  Future<void> _openGoogleMap() async {
    final Uri googleMapsUri = Uri.parse(
      'https://www.google.com/maps/search/?api=1&query=${_initialLocation.latitude},${_initialLocation.longitude}',
    );

    if (await canLaunchUrl(googleMapsUri)) {
      await launchUrl(googleMapsUri);
    } else {
      throw 'Could not open Google Maps';
    }
  }

  @override
  void initState() {
    super.initState();
    homeBloc = BlocProvider.of<HomeBloc>(context);
    showInterestedBloc = BlocProvider.of<ShowInterestedBloc>(context);
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<HomeBloc, HomeState>(
      listener: (context, state) {
        if (state is FetchWorkViewSuccess) {
          setState(() {
            final singleWork = state.workViewModel.work!;
            _initialLocation = LatLng(
                double.parse(singleWork.latitude!), // Convert to double
                double.parse(singleWork.longitude!) // Convert to double
                );
            _center = LatLng(
                double.parse(singleWork.latitude!), // Convert to double
                double.parse(singleWork.longitude!) // Convert to double
                );
          });
        }
      },
      builder: (context, state) {
        if (state is FetchWorkViewLoading) {
          return Container();
        } else if (state is FetchWorkViewSuccess) {
          final singleWork = state.workViewModel.work!;
          final similarWorks = state.workViewModel.similarWorks!;
          return Scaffold(
            backgroundColor: Colors.white,
            appBar: AppBar(
              automaticallyImplyLeading: false,
              scrolledUnderElevation: 0,
              centerTitle: true,
              elevation: 0,
              backgroundColor: COLORS.white,
              leadingWidth: SizeConfig.blockWidth * 85,
              leading: Row(
                children: [
                  IconButton(
                    icon: Icon(Icons.arrow_back_ios,
                        color: COLORS.black, size: SizeConfig.blockWidth * 4.5),
                    onPressed: () {
                      Navigator.pop(context);
                    },
                  ),
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Flexible(
                        child: Text(
                          singleWork.requiredProfession!,
                          style: TextStyle(
                            color: COLORS.black,
                            fontSize: SizeConfig.blockWidth * 3.8,
                            fontWeight: FontWeight.w500,
                            fontFamily: "Poppins",
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      SizedBox(width: SizeConfig.blockWidth * 1),
                      Container(
                        padding: EdgeInsets.symmetric(
                          horizontal: SizeConfig.blockWidth * 1.5,
                          vertical: SizeConfig.blockHeight * 0.25,
                        ),
                        decoration: BoxDecoration(
                          color: COLORS.primaryOne,
                          borderRadius: BorderRadius.circular(
                              SizeConfig.blockWidth * 1.5),
                        ),
                        child: Text(
                          timeAgo(singleWork.updatedAt!),
                          style: TextStyle(
                            color: COLORS.black,
                            fontSize: SizeConfig.blockWidth * 2.8,
                            fontWeight: FontWeight.w500,
                            fontFamily: "Poppins",
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
              actions: [
                IconButton(
                  icon: Icon(Icons.more_vert,
                      color: COLORS.black, size: SizeConfig.blockWidth * 6.5),
                  onPressed: () {
                    // Add functionality for more button
                  },
                ),
              ],
              bottom: PreferredSize(
                preferredSize: const Size.fromHeight(1.0),
                child: Container(
                  color: COLORS.neutralDarkTwo,
                  height: 1.0,
                ),
              ),
            ),
            body: SingleChildScrollView(
              child: Container(
                color: COLORS.white,
                padding: EdgeInsets.symmetric(
                    vertical: SizeConfig.blockHeight * 2.5,
                    horizontal: SizeConfig.blockWidth * 4.5),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.start,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Padding(
                      padding:
                          EdgeInsets.only(bottom: SizeConfig.blockHeight * 0.5),
                      child: Text(
                        'Work Deatils',
                        style: TextStyle(
                          color: COLORS.neutralDarkOne,
                          fontSize: SizeConfig.blockWidth * 3.6,
                          fontWeight: FontWeight.w400,
                          fontFamily: "Poppins",
                        ),
                      ),
                    ),
                    registerTextCard(
                        text: singleWork.workPlace!,
                        image: 'assets/images/home/home.png',
                        color: COLORS.primary,
                        textColor: COLORS.neutralDark),
                    registerTextCard(
                        text: singleWork.experienceLevel!,
                        image: 'assets/images/home/work_select.png',
                        color: COLORS.primary,
                        textColor: COLORS.neutralDark),
                    registerTextCard(
                        text: singleWork.knowLanguage!.join(", "),
                        image: 'assets/images/home/speak.png',
                        color: COLORS.primary,
                        textColor: COLORS.neutralDark),
                    registerTextCard(
                        text: singleWork.gender!,
                        image: 'assets/images/home/gender.png',
                        color: COLORS.primary,
                        textColor: COLORS.neutralDark),
                    SizedBox(height: SizeConfig.blockHeight * 2),
                    Padding(
                      padding:
                          EdgeInsets.only(bottom: SizeConfig.blockHeight * 0.5),
                      child: Text(
                        'Work Address',
                        style: TextStyle(
                          color: COLORS.neutralDarkOne,
                          fontSize: SizeConfig.blockWidth * 3.6,
                          fontWeight: FontWeight.w400,
                          fontFamily: "Poppins",
                        ),
                      ),
                    ),
                    Container(
                      height: SizeConfig.blockHeight * 25,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.only(
                            topRight:
                                Radius.circular(SizeConfig.blockWidth * 3),
                            topLeft:
                                Radius.circular(SizeConfig.blockWidth * 3)),
                        border: BorderDirectional(
                            top: BorderSide(
                              color: COLORS.neutralDarkTwo,
                              width: SizeConfig.blockWidth * 0.25,
                            ),
                            end: BorderSide(
                              color: COLORS.neutralDarkTwo,
                              width: SizeConfig.blockWidth * 0.25,
                            ),
                            start: BorderSide(
                              color: COLORS.neutralDarkTwo,
                              width: SizeConfig.blockWidth * 0.25,
                            )),
                      ),
                      child: ClipRRect(
                        borderRadius: BorderRadius.only(
                            topRight:
                                Radius.circular(SizeConfig.blockWidth * 3),
                            topLeft:
                                Radius.circular(SizeConfig.blockWidth * 3)),
                        child: GoogleMap(
                          onMapCreated: _onMapCreated,
                          initialCameraPosition: CameraPosition(
                            target: _center, // LatLng coordinates
                            zoom: 18.0, // Initial zoom level
                          ),
                          markers: {
                            Marker(
                              markerId: MarkerId('initialMarker'),
                              position: _initialLocation,
                              infoWindow: const InfoWindow(
                                title: 'Marker Title',
                                snippet: 'Marker Description',
                              ),
                            ),
                          },
                          buildingsEnabled: true,
                          liteModeEnabled: true,
                          indoorViewEnabled: true,
                          trafficEnabled: true,
                          tiltGesturesEnabled: true,
                          mapToolbarEnabled: true,
                          mapType: MapType.hybrid,
                        ),
                      ),
                    ),
                    Container(
                      padding: EdgeInsets.symmetric(
                          vertical: SizeConfig.blockWidth * 2.5,
                          horizontal: SizeConfig.blockWidth * 3),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.only(
                            bottomLeft:
                                Radius.circular(SizeConfig.blockWidth * 3),
                            bottomRight:
                                Radius.circular(SizeConfig.blockWidth * 3)),
                        border: BorderDirectional(
                            bottom: BorderSide(
                              color: COLORS.neutralDarkTwo,
                              width: SizeConfig.blockWidth * 0.25,
                            ),
                            end: BorderSide(
                              color: COLORS.neutralDarkTwo,
                              width: SizeConfig.blockWidth * 0.25,
                            ),
                            start: BorderSide(
                              color: COLORS.neutralDarkTwo,
                              width: SizeConfig.blockWidth * 0.25,
                            )),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.start,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Icon(
                                Icons.location_on_rounded,
                                color: COLORS.accent,
                                size: SizeConfig.blockWidth * 5,
                              ),
                              SizedBox(width: SizeConfig.blockWidth * 1.5),
                              SizedBox(
                                width: SizeConfig.blockWidth * 60,
                                child: Text(
                                  singleWork.location!,
                                  style: TextStyle(
                                    color: COLORS.neutralDarkOne,
                                    fontSize: SizeConfig.blockWidth * 3,
                                    fontWeight: FontWeight.w400,
                                    fontFamily: "Poppins",
                                  ),
                                  softWrap: true,
                                ),
                              ),
                            ],
                          ),
                          IconActionCard(
                            onTap: _openGoogleMap,
                            iconBool: false,
                            imageUrl: Image.asset(
                              'assets/images/home/address-share.png',
                              width: SizeConfig.blockWidth * 5.2,
                              height: SizeConfig.blockHeight * 5.2,
                              fit: BoxFit.contain,
                            ),
                          ),
                        ],
                      ),
                    ),
                    SizedBox(height: SizeConfig.blockHeight * 2),
                    Padding(
                      padding:
                          EdgeInsets.only(bottom: SizeConfig.blockHeight * 0.5),
                      child: Text(
                        'Work Description',
                        style: TextStyle(
                          color: COLORS.neutralDarkOne,
                          fontSize: SizeConfig.blockWidth * 3.6,
                          fontWeight: FontWeight.w400,
                          fontFamily: "Poppins",
                        ),
                      ),
                    ),
                    Padding(
                      padding:
                          EdgeInsets.only(bottom: SizeConfig.blockHeight * 0.5),
                      child: Text(
                        singleWork.description!,
                        style: TextStyle(
                          color: COLORS.neutralDark,
                          fontSize: SizeConfig.blockWidth * 3.4,
                          fontWeight: FontWeight.w400,
                          fontFamily: "Poppins",
                        ),
                      ),
                    ),
                    SizedBox(height: SizeConfig.blockHeight * 2),
                    Padding(
                      padding:
                          EdgeInsets.only(bottom: SizeConfig.blockHeight * 0.5),
                      child: Text(
                        'Work Images',
                        style: TextStyle(
                          color: COLORS.neutralDarkOne,
                          fontSize: SizeConfig.blockWidth * 3.6,
                          fontWeight: FontWeight.w400,
                          fontFamily: "Poppins",
                        ),
                      ),
                    ),
                    // Container(
                    //   width: SizeConfig.blockWidth * 100,
                    //   height: SizeConfig.blockHeight * 40,
                    //   decoration: BoxDecoration(
                    //       color: COLORS.neutralDarkTwo,
                    //       borderRadius: BorderRadius.all(
                    //           Radius.circular(SizeConfig.blockWidth * 3))),
                    // ),
                    DynamicWorkListImage(
                      imageUrls: singleWork.workImages!,
                    ),
                    SizedBox(height: SizeConfig.blockHeight * 2),
                    if(similarWorks.isNotEmpty)...[
                      Padding(
                        padding:
                        EdgeInsets.only(bottom: SizeConfig.blockHeight * 0.5),
                        child: Text(
                          'Similar works',
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
                        itemCount: similarWorks.length,
                        itemBuilder: (context, index) {
                          var work = similarWorks[index]!;
                          return Container(
                            padding: EdgeInsets.symmetric(
                              vertical: SizeConfig.blockWidth * 2,
                            ),
                            child: WorkCard(
                              title: work.requiredProfession ?? '--',
                              location: work.location ?? '--',
                              timeAgo: timeAgo(work.updatedAt!),
                              jobType: work.workPlace ?? '--',
                              experience: work.experienceLevel ?? '--',
                              experienceImage:
                              'assets/images/home/work_select.png',
                              gender: work.gender ?? '--',
                              genderImage: 'assets/images/home/gender.png',
                              jobTypeImage: 'assets/images/home/home.png',
                              language: work.knowLanguage!.join(", ") ?? '--',
                              languageImage: 'assets/images/home/speak.png',
                              onShowInterest: () {},
                              onCardClick: () {
                                Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                        builder: (context) => MultiBlocProvider(
                                          providers: [
                                            BlocProvider(
                                              create: (context) => HomeBloc()
                                                ..add(FetchWorkSingleView(
                                                    workId: work.id!)),
                                            ),
                                            BlocProvider(
                                              create: (context) =>
                                                  ShowInterestedBloc(),
                                            )
                                          ],
                                          child: WorkDetailsScreen(
                                            id: work.id!,
                                          ),
                                        )));
                              },
                              actionRows: Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                crossAxisAlignment: CrossAxisAlignment.center,
                                children: [
                                  Expanded(
                                    child: customIconButton(
                                      text: work.intrestShown != null
                                          ? 'INTERESTED'
                                          : 'SHOW INTEREST',
                                      onPressed: () {
                                        if (Config.userType == 'professional') {
                                          if (work.intrestShown == null) {
                                            showInterestedBloc
                                                .add(SaveInterestedWork(
                                              workID: work.id!,
                                              contact: true,
                                              onSuccess: () {
                                                setState(() {
                                                  work.intrestShown =
                                                      IntrestShown(
                                                        isContacted: true,
                                                      );
                                                });
                                              },
                                              onError: () {},
                                            ));
                                          }
                                        } else {
                                          showInterestBottomSheet(context);
                                        }
                                      },
                                      backgroundColor: work.intrestShown != null
                                          ? COLORS.semanticTwo.withOpacity(0.08)
                                          : COLORS.primary,
                                      showIcon: false,
                                      width: SizeConfig.blockWidth * 55,
                                      height: SizeConfig.blockHeight * 6.5,
                                      image: true,
                                      imageChild: Padding(
                                        padding: EdgeInsets.only(
                                            right: SizeConfig.blockWidth),
                                        child: Image.asset(
                                          work.intrestShown == null
                                              ? 'assets/images/profile/like.png'
                                              : 'assets/images/home/like.png',
                                          width: SizeConfig.blockWidth * 5,
                                          height: SizeConfig.blockHeight * 5,
                                          fit: BoxFit.contain,
                                          color: work.intrestShown != null
                                              ? COLORS.semanticTwo
                                              : COLORS.white,
                                        ),
                                      ),
                                      textColor: work.intrestShown != null
                                          ? COLORS.semanticTwo
                                          : COLORS.white,
                                    ),
                                  ),
                                  Row(
                                    mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                    crossAxisAlignment: CrossAxisAlignment.center,
                                    children: [
                                      if (work.isProfessionalCanCall == true) ...[
                                        IconActionCard(
                                          iconBool: false,
                                          imageUrl: Image.asset(
                                            'assets/images/home/phone.png',
                                            width: SizeConfig.blockWidth * 4.25,
                                            height: SizeConfig.blockHeight * 4.25,
                                            fit: BoxFit.contain,
                                          ),
                                          onTap: () {
                                            makePhoneCall(work.user!.mobile!);
                                          },
                                        ),
                                      ],
                                      IconActionCard(
                                        iconBool: false,
                                        imageUrl: Image.asset(
                                          'assets/images/home/share.png',
                                          width: SizeConfig.blockWidth * 5.2,
                                          height: SizeConfig.blockHeight * 5.2,
                                          fit: BoxFit.contain,
                                        ),
                                        onTap: () {
                                          shareJobDetails();
                                        },
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                          );
                        },
                      )
                    ]

                  ],
                ),
              ),
            ),
            bottomNavigationBar: Container(
              padding: EdgeInsets.symmetric(
                  vertical: SizeConfig.blockWidth * 4,
                  horizontal: SizeConfig.blockHeight * 4.5),
              decoration: BoxDecoration(
                  border: Border(
                      top: BorderSide(
                          color: COLORS.neutralDarkTwo,
                          width: SizeConfig.blockWidth * 0.15))),
              child: showInterestButton(
                  canCall: singleWork.isProfessionalCanCall!,
                  interested: singleWork.intrestShown != null,
                  onTapIconOne: () {
                    makePhoneCall(singleWork.user!.mobile!);
                  },
                  onTapIconTwo: () {
                    shareJobDetails();
                  },
                  onShowInterest: () {
                    if (singleWork.intrestShown == null) {
                      showInterestedBloc.add(SaveInterestedWork(
                        workID: singleWork.id!,
                        contact: true,
                        onSuccess: () {
                          setState(() {
                            singleWork.intrestShown = IntrestShown(
                              isContacted: true,
                            );
                          });
                        },
                        onError: () {},
                      ));
                    } else {
                      showInterestBottomSheet(context);
                    }
                  }),
            ),
          );
        } else if (state is FetchWorkViewError) {}
        return Container();
      },
    );
  }
}
