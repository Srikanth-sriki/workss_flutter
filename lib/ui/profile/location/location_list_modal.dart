import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:lottie/lottie.dart';
import 'package:modal_bottom_sheet/modal_bottom_sheet.dart';
import 'package:works_app/components/colors.dart';
import 'package:works_app/components/size_config.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:works_app/ui/profile/logout_success.dart';

import '../../../bloc/profile/profile_bloc.dart';
import '../../../bloc/register_account/initial_register_bloc.dart';
import '../../../components/global_handle.dart';
import '../../../global_helper/helper_function.dart';
import '../../../global_helper/loading_placeholder/home_layout.dart';
import '../../../global_helper/reuse_widget.dart';
import '../../../models/address_location_list.dart';
import 'location_create.dart';
import 'location_edit.dart';

class AddressListModalBottomSheet extends StatefulWidget {
  final String? selectedAddressId; // Accept selected ID
  final Function(String id, String address, String latitude,String longitude,String city,String locality,String pincode,String cityId,String localityId) onAddressSelected;

  const AddressListModalBottomSheet({
    super.key,
    this.selectedAddressId,
    required this.onAddressSelected,
  });

  @override
  _AddressListModalBottomSheetState createState() =>
      _AddressListModalBottomSheetState();
}

class _AddressListModalBottomSheetState
    extends State<AddressListModalBottomSheet> {
  late ProfileBloc profileBloc;
  late List<AddressListModal> addressListModal;
  bool loading = true;
  bool error = false;
  String? selectedAddressId;

  @override
  void initState() {
    super.initState();
    profileBloc = BlocProvider.of<ProfileBloc>(context);
    profileBloc.add(const AddressLocationListEvent());
    selectedAddressId = widget.selectedAddressId;
  }

  void _refreshPageAfterEdit() {
    profileBloc.add(const AddressLocationListEvent());
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<ProfileBloc, ProfileState>(
      listener: (context, state) {
        if (state is AddressLocationLoading || state is ProfileInitial) {
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
              height: SizeConfig.blockHeight * 60,
              child: globalLoadingWidget(),
            );
          } else if (error) {
            return SizedBox(
              height: SizeConfig.blockHeight * 60,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Lottie.asset(
                    'assets/images/lottie/error.json',
                    width: SizeConfig.blockWidth * 60,
                    fit: BoxFit.cover,
                  ),
                  SizedBox(height: SizeConfig.blockHeight * 2),
                  Text(
                    'Something went wrong!',
                    style: TextStyle(
                      color: COLORS.neutralDark,
                      fontSize: SizeConfig.blockWidth * 3.6,
                      fontWeight: FontWeight.w400,
                      fontFamily: "Poppins",
                    ),
                    textAlign: TextAlign.center,
                  ),
                  SizedBox(height: SizeConfig.blockHeight * 4),
                  customButton(
                    text: 'Retry now'.tr(),
                    onPressed: _refreshPageAfterEdit,
                    backgroundColor: COLORS.primary,
                    showIcon: false,
                    width: SizeConfig.blockWidth * 42,
                    height: SizeConfig.blockHeight * 8,
                    textColor: COLORS.white,
                  ),
                ],
              ),
            );
          } else {
            return Container(
                height: SizeConfig.blockHeight * 60,
                padding: EdgeInsets.symmetric(
                    vertical: SizeConfig.blockHeight * 2),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.start,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Container(
                      padding: EdgeInsets.symmetric(
                          horizontal: SizeConfig.blockHeight * 3,
                          vertical: SizeConfig.blockHeight * 0.5),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Text(
                            'Select Address'.tr(),
                            style: TextStyle(
                              fontSize: SizeConfig.blockWidth * 4,
                              fontWeight: FontWeight.w400,
                              fontFamily: "Poppins",
                              color: COLORS.neutralDark,
                            ),
                          ),
                          customButton(
                              text: 'Add New'.tr(),
                              onPressed: () {
                                Navigator.pop(context);
                                Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                        builder: (context) =>
                                            MultiBlocProvider(
                                              providers: [
                                                BlocProvider(
                                                    create: (context) =>
                                                        ProfileBloc()),
                                                BlocProvider(
                                                  create: (context) {
                                                    final bloc = InitialRegisterBloc();
                                                    bloc.add(const FetchCityEvent());
                                                    return bloc;
                                                  },
                                                ),
                                              ],
                                              child: AddressScreen(
                                                refreshPageCallback:
                                                _refreshPageAfterEdit,
                                                routePage: 'modal',
                                              ),
                                            )));
                              },
                              backgroundColor: COLORS.primary,
                              showIcon: false,
                              width: SizeConfig.blockWidth * 30,
                              height: SizeConfig.blockHeight * 6.5,
                              textColor: COLORS.white,
                              icon: Icons.add,
                              prefixIconBool: false),
                        ],
                      ),
                    ),
                    if (addressListModal.isNotEmpty) ...[
                      Expanded(
                        child: ListView.builder(
                          itemCount: addressListModal.length,
                          padding: EdgeInsets.zero,
                          itemBuilder: (context, index) {
                            var addressItem = addressListModal[index];
                            bool isSelected =
                                selectedAddressId == addressItem.id;
                            return GestureDetector(
                              onTap: () {
                                setState(() {
                                  selectedAddressId = addressItem.id;
                                });
                                widget.onAddressSelected(
                                  addressItem.id!,
                                  '${addressItem.houseNo ?? ''} ${addressItem.area ?? ''} ${addressItem.instructions ?? ''}',
                                    addressItem.latitude!,addressItem.longitude!,
                                  addressItem.city!,addressItem.locality!,addressItem.pincode!,addressItem.cityId!,addressItem.localityId!
                                );

                                Navigator.pop(context);
                              },
                              child: Padding(
                                padding: EdgeInsets.symmetric(
                                  vertical: SizeConfig.blockWidth * 1.5,
                                  horizontal: SizeConfig.blockHeight * 3,
                                ),
                                child: Container(
                                  padding: EdgeInsets.symmetric(
                                    vertical: SizeConfig.blockWidth * 2,
                                    horizontal: SizeConfig.blockHeight * 3,
                                  ),
                                  decoration: BoxDecoration(
                                    color:
                                    COLORS.primaryOne.withOpacity(0.25),
                                    borderRadius: BorderRadius.circular(
                                        SizeConfig.blockWidth * 3),
                                    border: Border.all(
                                      color: isSelected
                                          ? COLORS.primaryOne
                                          : Colors.transparent,
                                      width: SizeConfig.blockWidth * 0.3,
                                    ),
                                  ),
                                  child: Column(
                                    crossAxisAlignment:
                                    CrossAxisAlignment.start,
                                    children: [
                                      Row(
                                        mainAxisAlignment: MainAxisAlignment.start,
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Image.asset(
                                            addressItem.addressType ==
                                                'home'
                                                ? 'assets/images/profile/home_location.png'
                                                : addressItem.addressType ==
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
                                              width: SizeConfig.blockWidth *
                                                  2),
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
                                              width: SizeConfig.blockWidth *
                                                  2),
                                          if(addressItem
                                              .addressType == 'other' && addressItem.addressTypeName!.isNotEmpty)...[
                                            Container(
                                              width: SizeConfig.blockWidth*40,
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
                                      Text(
                                        '${addressItem.area ?? addressItem.houseNo} ',
                                        style: TextStyle(
                                          color: COLORS.black,
                                          fontSize:
                                          SizeConfig.blockWidth * 3.25,
                                          fontWeight: FontWeight.w400,
                                          fontFamily: "Poppins",
                                        ),
                                        softWrap: true,
                                      ),
                                      Align(
                                        alignment: Alignment.bottomRight,
                                        child:    InkWell(
                                          onTap: (){
                                            Navigator.push(
                                                context,
                                                MaterialPageRoute(
                                                    builder: (context) =>
                                                        MultiBlocProvider(
                                                          providers: [
                                                            BlocProvider(
                                                                create: (context) =>
                                                                    ProfileBloc()),
                                                            BlocProvider(
                                                              create: (context) {
                                                                final bloc = InitialRegisterBloc();
                                                                bloc.add(const FetchCityEvent());
                                                                return bloc;
                                                              },
                                                            ),
                                                          ],
                                                          child: EditAddressScreen(
                                                              routeType:"modal",
                                                              addressItem:
                                                              addressItem),
                                                        )));
                                          },
                                          child: Padding(
                                            padding: EdgeInsets.only(
                                              top: SizeConfig.blockHeight,
                                              bottom: SizeConfig.blockHeight
                                            ),
                                            child: Row(
                                              mainAxisAlignment: MainAxisAlignment.end,
                                              crossAxisAlignment: CrossAxisAlignment.center,
                                              children: [
                                                Image.asset(
                                                  'assets/images/profile/edit.png',
                                                  width:
                                                  SizeConfig.blockWidth * 4,
                                                  height:
                                                  SizeConfig.blockWidth *
                                                      4,
                                                  fit: BoxFit.contain,
                                                ),
                                                SizedBox(width: SizeConfig.blockWidth,),
                                                Text(
                                                  'EDIT'.tr(),
                                                  style: TextStyle(
                                                    fontSize: SizeConfig
                                                        .blockWidth *
                                                        3,
                                                    fontWeight:
                                                    FontWeight.w500,
                                                    fontFamily: "Poppins",
                                                    color: COLORS.accent,
                                                  ),
                                                )
                                              ],
                                            ),
                                          ),
                                        ),
                                      )
                                    ],
                                  ),
                                ),
                              ),
                            );
                          },
                        ),
                      )
                    ] else ...[
                      Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            SizedBox(height: SizeConfig.blockHeight*5,),
                            Lottie.asset(
                              'assets/images/lottie/empty.json',
                              width: SizeConfig.blockWidth * 60,
                              height: SizeConfig.blockWidth * 30,
                              fit: BoxFit.contain,
                            ),
                            SizedBox(height: SizeConfig.blockHeight * 2),

                            customButton(
                                text: 'Add New Address'.tr(),
                                onPressed: () {
                                  Navigator.pop(context);
                                  Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                          builder: (context) =>
                                              MultiBlocProvider(
                                                providers: [
                                                  BlocProvider(
                                                      create: (context) =>
                                                          ProfileBloc()),
                                                  BlocProvider(
                                                    create: (context) {
                                                      final bloc = InitialRegisterBloc();
                                                      bloc.add(const FetchCityEvent());
                                                      return bloc;
                                                    },
                                                  ),
                                                ],
                                                child: AddressScreen(
                                                  refreshPageCallback:
                                                  _refreshPageAfterEdit,
                                                  routePage: 'modal',
                                                ),
                                              )));
                                },
                                backgroundColor: COLORS.primary,
                                showIcon: true,
                                height: SizeConfig.blockHeight * 6.5,
                                textColor: COLORS.white,
                                icon: Icons.add,
                                prefixIconBool: false),
                          ],
                        ),
                      )
                    ]
                  ],
                ));
          }
        },
      ),
    );
  }
}
