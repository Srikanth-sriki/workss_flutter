import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:modal_bottom_sheet/modal_bottom_sheet.dart';
import 'package:works_app/global_helper/helper_function.dart';

import 'package:works_app/ui/profile/location/location_create.dart';
import 'package:works_app/ui/profile/location/location_edit.dart';
import 'package:works_app/ui/profile/modal/address_delete.dart';

import '../../../bloc/profile/profile_bloc.dart';
import '../../../components/colors.dart';
import '../../../components/size_config.dart';
import '../../../global_helper/loading_placeholder/home_layout.dart';
import '../../../global_helper/reuse_widget.dart';
import '../../../models/address_location_list.dart';

class LocationListScreen extends StatefulWidget {
  const LocationListScreen({super.key});

  @override
  State<LocationListScreen> createState() => _LocationListScreenState();
}

class _LocationListScreenState extends State<LocationListScreen> {
  late ProfileBloc profileBloc;
  late List<AddressListModal> addressListModal;
  bool loading = true;
  bool error = false;

  @override
  void initState() {
    super.initState();
    profileBloc = BlocProvider.of<ProfileBloc>(context);
  }

  void _refreshPageAfterEdit() {
    profileBloc.add(const AddressLocationListEvent());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: COLORS.white,
      appBar: const CustomAppBar(
        title: 'My Addresses',
        backgroundColor: COLORS.white,
        titleColors: COLORS.neutralDark,
      ),
      body: SafeArea(
        child: Stack(
          children: [
            SizedBox(
              height: SizeConfig.screenHeight,
              child: SingleChildScrollView(
                child: BlocListener<ProfileBloc, ProfileState>(
                  listener: (context, state) {
                    if (state is AddressLocationLoading ||
                        state is ProfileInitial) {
                      setState(() {
                        loading = true;
                        error = false;
                      });
                    } else if (state is AddressLocationListSuccess) {
                      setState(() {
                        loading = false;
                        error = false;
                        addressListModal = state.addressListModal!;
                      });
                    } else if (state is AddressLocationListFailed) {
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
                            child: const ShimmerJobCards());
                      } else if (error) {
                        return ErrorScreen(onRetry: () {
                          _refreshPageAfterEdit();
                        });
                      } else if (!loading && !error) {
                        return addressListModal.isNotEmpty
                            ? Padding(
                                padding: EdgeInsets.symmetric(
                                    vertical: SizeConfig.blockHeight * 1.5),
                                child: ListView.builder(
                                  shrinkWrap: true,
                                  physics: const NeverScrollableScrollPhysics(),
                                  itemCount: addressListModal.length,
                                  itemBuilder: (context, index) {
                                    var addressItem = addressListModal[index];
                                    return Padding(
                                      padding: EdgeInsets.symmetric(
                                        vertical: SizeConfig.blockWidth * 1.5,
                                        horizontal: SizeConfig.blockHeight * 3,
                                      ),
                                      child: Container(
                                        padding: EdgeInsets.symmetric(
                                          vertical: SizeConfig.blockWidth * 2,
                                          horizontal:
                                              SizeConfig.blockHeight * 3,
                                        ),
                                        decoration: BoxDecoration(
                                          color: COLORS.primaryOne
                                              .withOpacity(0.25),
                                          borderRadius: BorderRadius.circular(
                                              SizeConfig.blockWidth * 3),
                                        ),
                                        child: Column(
                                          mainAxisAlignment:
                                              MainAxisAlignment.start,
                                          crossAxisAlignment:
                                              CrossAxisAlignment.center,
                                          children: [
                                            SizedBox(
                                                height:
                                                SizeConfig.blockWidth * 1.5),
                                            Row(
                                              mainAxisAlignment:
                                                  MainAxisAlignment.start,
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.center,
                                              children: [
                                                Image.asset(
                                                  addressItem.addressType ==
                                                          'home'
                                                      ? 'assets/images/profile/home_location.png'
                                                      : addressItem
                                                                  .addressType ==
                                                              'office'
                                                          ? 'assets/images/profile/Buildings_location.png'
                                                          : 'assets/images/profile/other_location.png',
                                                  width:
                                                      SizeConfig.blockWidth * 4,
                                                  height:
                                                      SizeConfig.blockWidth * 4,
                                                  fit: BoxFit.contain,
                                                ),
                                                SizedBox(
                                                  width:
                                                      SizeConfig.blockWidth * 2,
                                                ),
                                                Text(
                                                  addressItem.addressType!
                                                      .toUpperCase(),
                                                  style: TextStyle(
                                                    fontSize:
                                                        SizeConfig.blockWidth *
                                                            3.25,
                                                    fontWeight: FontWeight.w400,
                                                    fontFamily: "Poppins",
                                                    color: COLORS.neutralDark,
                                                  ),
                                                ),
                                                SizedBox(
                                                  width:
                                                  SizeConfig.blockWidth * 2,
                                                ),
                                               if(addressItem
                                                   .addressType == 'other' && addressItem.addressTypeName!.isNotEmpty)...[
                                                 Container(
                                                   width: SizeConfig.blockWidth*50,
                                                   decoration: BoxDecoration(border: Border(left: BorderSide(color: COLORS.primaryOne,width: SizeConfig.blockWidth*0.2))),
                                                   padding: EdgeInsets.symmetric(horizontal: SizeConfig.blockWidth*2),
                                                   child: Text(
                                                     capitalizeFirstLetter(addressItem.addressTypeName!),
                                                     style: TextStyle(
                                                       fontSize:
                                                       SizeConfig.blockWidth *
                                                           3.25,
                                                       fontWeight: FontWeight.w400,
                                                       fontFamily: "Poppins",
                                                       color: COLORS.neutralDark,
                                                     ),maxLines: 1,
                                                     overflow: TextOverflow.ellipsis,
                                                   ),
                                                 )
                                               ],
                                              ],
                                            ),
                                            SizedBox(
                                                height:
                                                    SizeConfig.blockWidth * 2),
                                            SizedBox(
                                              width: SizeConfig.blockWidth * 80,
                                              child: Text(
                                                '${addressItem.houseNo ?? ''} ${addressItem.area ?? ''} ${addressItem.instructions ?? ''}',
                                                style: TextStyle(
                                                  color: COLORS.black,
                                                  fontSize:
                                                      SizeConfig.blockWidth *
                                                          3.25,
                                                  fontWeight: FontWeight.w400,
                                                  fontFamily: "Poppins",
                                                ),
                                                softWrap: true,
                                              ),
                                            ),
                                            Row(
                                              mainAxisAlignment:
                                                  MainAxisAlignment.end,
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.center,
                                              children: [
                                                TextButton(
                                                  onPressed: () {
                                                    Navigator.push(
                                                        context,
                                                        MaterialPageRoute(
                                                            builder: (context) =>
                                                                MultiBlocProvider(
                                                                  providers: [
                                                                    BlocProvider(
                                                                        create: (context) =>
                                                                            ProfileBloc()),
                                                                  ],
                                                                  child: EditAddressScreen(
                                                                      addressItem:
                                                                          addressItem),
                                                                )));
                                                  },
                                                  isSemanticButton: false,
                                                  child: Text(
                                                    'EDIT',
                                                    style: TextStyle(
                                                      fontSize: SizeConfig
                                                              .blockWidth *
                                                          3.25,
                                                      fontWeight:
                                                          FontWeight.w500,
                                                      fontFamily: "Poppins",
                                                      color: COLORS.accent,
                                                    ),
                                                  ),
                                                ),
                                                TextButton(
                                                  onPressed: () {
                                                    showMaterialModalBottomSheet(
                                                      enableDrag: true,
                                                      expand: false,
                                                      isDismissible: true,
                                                      backgroundColor:
                                                          COLORS.white,
                                                      context: context,
                                                      shape:
                                                          RoundedRectangleBorder(
                                                        borderRadius:
                                                            BorderRadius.vertical(
                                                                top: Radius.circular(
                                                                    SizeConfig
                                                                            .blockWidth *
                                                                        3.8)),
                                                      ),
                                                      builder: (context) =>
                                                          BlocProvider(
                                                        create: (context) =>
                                                            ProfileBloc(),
                                                        child:
                                                            AddressListDeleteBottomSheet(
                                                          addressId:
                                                              addressItem.id!,
                                                          refreshPageCallback:
                                                              _refreshPageAfterEdit,
                                                        ),
                                                      ),
                                                    );
                                                  },
                                                  isSemanticButton: false,
                                                  child: Text(
                                                    'DELETE',
                                                    style: TextStyle(
                                                      fontSize: SizeConfig
                                                              .blockWidth *
                                                          3.25,
                                                      fontWeight:
                                                          FontWeight.w500,
                                                      fontFamily: "Poppins",
                                                      color: COLORS.accent,
                                                    ),
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ],
                                        ),
                                      ),
                                    );
                                  },
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
            ),
            if(!loading && !error)...[
              Positioned(
                bottom: SizeConfig.blockHeight * 2.5,
                right: SizeConfig.blockHeight * 4,
                child: FloatingActionButton(
                  onPressed: () {
                    Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) => MultiBlocProvider(
                              providers: [
                                BlocProvider(
                                    create: (context) => ProfileBloc()),
                              ],
                              child: AddressScreen(
                                refreshPageCallback: _refreshPageAfterEdit,
                                routePage: 'screen',
                              ),
                            )));
                  },
                  backgroundColor: COLORS.primary,
                  child: Icon(
                    Icons.add,
                    color: COLORS.white,
                    size: SizeConfig.blockWidth * 6.5,
                  ),
                ),
              )
            ],
          ],
        ),
      ),
    );
  }
}
