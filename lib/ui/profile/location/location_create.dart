import 'dart:convert';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';
import 'package:location/location.dart';
import 'package:http/http.dart' as http;
import 'package:modal_bottom_sheet/modal_bottom_sheet.dart';
import 'package:uuid/uuid.dart';
import 'package:works_app/bloc/profile/profile_bloc.dart';
import 'package:works_app/components/size_config.dart';
import 'package:works_app/ui/profile/modal/address_success.dart';

import '../../../bloc/register_account/initial_register_bloc.dart';
import '../../../components/colors.dart';
import '../../../dao/get_user_location.dart';
import '../../../global_helper/dropdown.dart';
import '../../../global_helper/loading_placeholder/home_layout.dart';
import '../../../global_helper/reuse_widget.dart';
import '../component.dart';

class AddressScreen extends StatefulWidget {
  final VoidCallback refreshPageCallback;
  final String routePage;
  const AddressScreen(
      {super.key, required this.refreshPageCallback, required this.routePage});

  @override
  State<AddressScreen> createState() => _AddressScreenState();
}

class _AddressScreenState extends State<AddressScreen> {
  late InitialRegisterBloc initialRegisterBloc;
  GoogleMapController? _mapController;
  Location _location = Location();
  final TextEditingController houseNo = TextEditingController();
  final TextEditingController homeAddress = TextEditingController();
  final TextEditingController Instructions = TextEditingController();
  final TextEditingController otherName = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  LatLng _initialPosition = LatLng(12.9716, 77.5946);
  LatLng _currentPosition = LatLng(12.9716, 77.5946);
  String _currentAddress = 'Loading address...';
  bool isMapDragging = true;
  bool loading = false;
  String _selectedType = 'Home';
  bool isChecked = false;
  double latitude = 0.0;
  double longitude = 0.0;
  bool addressArea = false;
  bool otherNameError = false;
  late ProfileBloc profileBloc;
  bool addressAdded = false;
  bool locationAdded = false;
  bool instructionAdded = false;
  bool nameAddressAdded = false;
  bool cityLoading = true;
  bool localityLoading = true;
  List<DropdownItemValue> dropdownCityItem = [];
  List<DropdownItemValue> localityListItem = [];
  Map<String, String> cityMap = {};
  String? _selectedCity;
  bool citySelected = false;
  String? _selectedLocality;
  bool localitySelected = false;
  bool isSubmitButtonEnabled = false;
  bool pinCodeLoading = true;
  String? _selectedPinCode;
  String? _selectedWorkCityId;
  String? _selectedWorkLocalityId;
  List<DropdownItemValue> pinCodeListItem = [];
  bool pincodeSelected = false;

  @override
  void initState() {
    super.initState();
    profileBloc = BlocProvider.of<ProfileBloc>(context);
    initialRegisterBloc = BlocProvider.of<InitialRegisterBloc>(context);
    _getCurrentLocation();
  }


  void _validateForm() {
    bool isValid = false;

    if (_currentAddress != 'Loading address...' &&
        homeAddress.text.isNotEmpty &&
        (_selectedCity?.isNotEmpty ?? false) &&
        _selectedLocality?.isNotEmpty == true && (_selectedPinCode?.isNotEmpty?? false) &&
        (_selectedType != 'Other' || otherName.text.isNotEmpty)) {
      isValid = true;
    }

    setState(() {
      isSubmitButtonEnabled = isValid;
    });
  }



  Future<void> _getCurrentLocation() async {
    setState(() {
      isMapDragging = true;
    });
    PermissionStatus permissionGranted = await _location.requestPermission();
    print("Permission status: $permissionGranted");

    if (permissionGranted == PermissionStatus.granted) {
      LocationData locationData = await _location.getLocation();
      _updateLocationState(locationData);
      _updateMapCamera(_currentPosition);
      _getAddressFromCoordinates(_currentPosition);
    } else {
      print("Location permission not granted");
    }
    setState(() {
      isMapDragging = false;
    });
  }

  void _updateLocationState(LocationData locationData) {
    setState(() {
      isMapDragging = true;
    });
    setState(() {
      _currentPosition =
          LatLng(locationData.latitude!, locationData.longitude!);
      _initialPosition = _currentPosition;
      _currentAddress = 'Fetching address...';
      latitude = locationData.latitude!;
      longitude = locationData.longitude!;
      isMapDragging = false;
    });
  }

  void _updateMapCamera(LatLng newPosition) {
    print("Updating map camera to new position: $newPosition");
    _mapController?.animateCamera(CameraUpdate.newLatLng(newPosition));
  }

  Future<void> _getAddressFromCoordinates(LatLng coordinates) async {
    print("Fetching address for coordinates: $coordinates");
    Map<String, String> addressData =
        await getAddress(coordinates.latitude, coordinates.longitude);
    setState(() {
      _currentAddress = addressData['address'] ?? '';
      homeAddress.text = addressData['address'] ?? '';
      if(addressData['address']!.isNotEmpty){
        locationAdded = true;
      }
      _validateForm();
    });
  }

  Future<void> _setSelectedType(String type) async {
    setState(() {
      _selectedType = type;
    });
  }

  void _onCameraMove(CameraPosition position) {
    setState(() {
      _currentPosition = position.target;
      latitude = position.target.latitude;
      longitude = position.target.longitude;
    });
  }

  @override
  void dispose() {
    houseNo.dispose();
    homeAddress.dispose();
    Instructions.dispose();
    otherName.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => FocusScope.of(context).unfocus(),
      child: Scaffold(
        backgroundColor: COLORS.white,
        appBar: const CustomAppBar(
          title: 'Add New Location',
          backgroundColor: COLORS.white,
          titleColors: COLORS.neutralDark,
        ),
        body: MultiBlocListener(
          listeners: [
            BlocListener<InitialRegisterBloc, InitialRegisterState>(
              listener: (context, state) {
               if (state is FetchCityLoading) {
                  setState(() {
                    cityLoading = true;
                  });
                }else if (state is FetchCitySuccess) {
                  setState(() {
                    dropdownCityItem.addAll([
                      for (var city in state.dropDownItems)
                        DropdownItemValue(id: city.id, label: city.city),
                    ]);
                    cityLoading = false;
                  });
                } else if (state is FetchCityFailed) {
                  setState(() {
                    cityLoading = false;
                  });
                } else if (state is FetchLocalitiesListLoading) {
                  setState(() {
                    localityLoading = true;
                  });
                } else if (state is FetchLocalitiesListSuccess) {
                  setState(() {
                    localityListItem.addAll([
                      for (var city in state.dropDownItems)
                        DropdownItemValue(id: city.id, label: city.locality),
                    ]);
                    localityLoading = false;
                  });
                } else if (state is FetchLocalitiesListFailed) {
                  setState(() {
                    localityLoading = false;
                  });
                }
               else if (state is FetchPinListLoading) {
                 setState(() {
                   pinCodeLoading = true;
                 });
               } else if (state is FetchPinListSuccess) {
                 setState(() {
                   pinCodeListItem.addAll([
                     for (var city in state.dropDownItems)
                       DropdownItemValue(id: city.id, label: city.pincode),
                   ]);
                   pinCodeLoading = false;
                 });
               } else if (state is FetchPinListFailed) {
                 setState(() {
                   pinCodeLoading = false;
                 });
               }

                setState(() {});
              },
            ),
            BlocListener<ProfileBloc, ProfileState>(
              listener: (context, state) {
                if (state is AddressLocationLoading) {
                  setState(() {
                    loading = true;
                  });
                } else if (state is AddressLocationCreateSuccess) {
                  setState(() {
                    loading = false;
                  });
                  showMaterialModalBottomSheet(
                    enableDrag: false,
                    expand: false,
                    isDismissible: false,
                    backgroundColor: COLORS.white,
                    context: context,
                    shape: const RoundedRectangleBorder(
                      borderRadius:
                          BorderRadius.vertical(top: Radius.circular(20)),
                    ),
                    builder: (context) => AddressSuccessBottomSheet(
                      routePage: widget.routePage,
                    ),
                  );
                } else if (state is AddressLocationCreateFailed) {
                  setState(() {
                    loading = false;
                  });
                  showCustomSnackBar(
                    context: context,
                    message: state.message,
                  );
                }
                setState(() {});
              },
            )
          ],
          child: SafeArea(
            child: CustomScrollView(
              slivers: [
                SliverAppBar(
                  pinned: true,
                  backgroundColor: COLORS.white,
                  forceMaterialTransparency: true,
                  automaticallyImplyLeading: false,
                  elevation: 0,
                  expandedHeight: SizeConfig.blockHeight * 80,
                  flexibleSpace: FlexibleSpaceBar(
                    background: Stack(
                      children: [
                        GoogleMap(
                          gestureRecognizers: <Factory<
                              OneSequenceGestureRecognizer>>{
                            Factory<OneSequenceGestureRecognizer>(
                                () => EagerGestureRecognizer()),
                          },
                          mapType: MapType.normal,
                          zoomControlsEnabled: true,
                          zoomGesturesEnabled: true,
                          scrollGesturesEnabled: true,
                          myLocationButtonEnabled: false,
                          rotateGesturesEnabled: false,
                          tiltGesturesEnabled: false,
                          initialCameraPosition: CameraPosition(
                              target: _initialPosition, zoom: 18),
                          onMapCreated: (controller) =>
                              _mapController = controller,
                          onCameraMove: (position) => _onCameraMove(position),
                          onCameraIdle: () =>
                              _getAddressFromCoordinates(_currentPosition),
                          myLocationEnabled: true,
                        ),
                        Center(
                          child: Icon(
                            Icons.location_on,
                            color: COLORS.semantic,
                            size: SizeConfig.blockWidth * 10,
                          ),
                        ),
                        Positioned(
                          bottom: SizeConfig.blockHeight * 5,
                          left: 0,
                          right: 0,
                          child: InkWell(
                            onTap: _getCurrentLocation,
                            borderRadius: BorderRadius.circular(
                                SizeConfig.blockWidth * 3),
                            child: Container(
                              width: SizeConfig.blockWidth * 40,
                              margin: EdgeInsets.symmetric(
                                horizontal: SizeConfig.blockWidth * 20,
                              ),
                              padding: EdgeInsets.symmetric(
                                horizontal: SizeConfig.blockWidth * 2,
                                vertical: SizeConfig.blockWidth * 2,
                              ),
                              decoration: BoxDecoration(
                                color: COLORS.white,
                                borderRadius: BorderRadius.circular(
                                    SizeConfig.blockWidth * 3),
                              ),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(
                                    Icons.my_location_rounded,
                                    color: COLORS.accent,
                                    size: SizeConfig.blockWidth * 5,
                                  ),
                                  SizedBox(width: SizeConfig.blockWidth * 1.5),
                                  Text(
                                    'Use my Current Location'.tr(),
                                    style: TextStyle(
                                      color: COLORS.black,
                                      fontSize: SizeConfig.blockWidth * 3.25,
                                      fontWeight: FontWeight.w400,
                                      fontFamily: "Poppins",
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                        if (isMapDragging) ...[
                          Positioned(
                            top: SizeConfig.blockHeight * 35,
                            left: 0,
                            right: 0,
                            child: Center(
                              child: Container(
                                width: SizeConfig.blockWidth * 65,
                                alignment: Alignment.center,
                                padding: EdgeInsets.symmetric(
                                    horizontal: SizeConfig.blockWidth * 4,
                                    vertical: SizeConfig.blockHeight * 2),
                                decoration: BoxDecoration(
                                  color: COLORS.primaryTwo.withOpacity(0.3),
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                child: Row(
                                  children: [
                                    LoadingAnimationWidget.hexagonDots(
                                      color: COLORS.accent,
                                      size: SizeConfig.blockHeight * 3.5,
                                    ),
                                    SizedBox(
                                      width: SizeConfig.blockWidth * 3,
                                    ),
                                    Text(
                                      'Updating location...'.tr(),
                                      style: TextStyle(
                                        color: COLORS.white,
                                        fontSize: SizeConfig.blockWidth * 3.8,
                                        fontWeight: FontWeight.w400,
                                        fontFamily: "Poppins",
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        ]
                      ],
                    ),
                  ),
                ),
                // Address form
                SliverToBoxAdapter(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Padding(
                        padding: EdgeInsets.symmetric(
                          horizontal: SizeConfig.blockWidth * 4.5,
                          vertical: SizeConfig.blockWidth * 4,
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.start,
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.location_on_rounded,
                              color: COLORS.accent,
                              size: SizeConfig.blockWidth * 5,
                            ),
                            SizedBox(
                              width: SizeConfig.blockWidth * 3,
                            ),
                            SizedBox(
                              width: SizeConfig.blockWidth * 80,
                              child: Text(
                                _currentAddress.tr(),
                                style: TextStyle(
                                  color: COLORS.black,
                                  fontSize: SizeConfig.blockWidth * 3.25,
                                  fontWeight: FontWeight.w400,
                                  fontFamily: "Poppins",
                                ),
                                softWrap: true,
                              ),
                            ),
                          ],
                        ),
                      ),
                      Divider(
                        color: COLORS.neutralDarkTwo,
                        thickness: SizeConfig.blockHeight * 0.1,
                      ),
                      SizedBox(height: SizeConfig.blockHeight * 2),
                      Padding(
                        padding: EdgeInsets.symmetric(
                            horizontal: SizeConfig.blockWidth * 4.5),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.start,
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            _buildTypeButton('Home',
                                'assets/images/profile/home_location.png'),
                            SizedBox(
                              width: SizeConfig.blockWidth * 4,
                            ),
                            _buildTypeButton('Office',
                                'assets/images/profile/Buildings_location.png'),
                            SizedBox(
                              width: SizeConfig.blockWidth * 4,
                            ),
                            _buildTypeButton('Other',
                                'assets/images/profile/other_location.png'),
                          ],
                        ),
                      ),
                      Padding(
                        padding: EdgeInsets.symmetric(
                          horizontal: SizeConfig.blockWidth * 4.5,
                          vertical: SizeConfig.blockWidth * 4.5,
                        ),
                        child: Form(
                          key: _formKey,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              if (_selectedType == 'Other') ...[
                                buildTextField(
                                    label: 'Name of Address',
                                    controller: otherName,
                                    hintText: "Name of Address".tr(),
                                    validator: (value) {
                                      if (value == null || value.isEmpty) {
                                        setState(() => otherNameError = true);
                                        return 'Enter name of address'.tr();
                                      }
                                      setState(() => otherNameError = false);
                                      return null;
                                    },
                                    error: otherNameError,
                                    title: 'Name of Address'.tr(),
                                    color: nameAddressAdded
                                        ? COLORS.neutralDarkOne
                                        : COLORS.neutralDark,
                                    fontWeight: nameAddressAdded
                                        ? FontWeight.w400
                                        : FontWeight.w500,
                                    onChanged: (value) {
                                      if (value!.isNotEmpty) {
                                        setState(() {
                                          nameAddressAdded = true;
                                          _validateForm();
                                        });
                                      } else {
                                        setState(() {
                                          nameAddressAdded = false;
                                        });
                                      }
                                    })
                              ],
                              // buildTextField(
                              //     label: 'Address',
                              //     controller: houseNo,
                              //     hintText: "Enter house/flat/block no".tr(),
                              //     validator: (value) {},
                              //     error: false,
                              //     title: 'Address'.tr(),
                              //     color: addressAdded
                              //         ? COLORS.neutralDarkOne
                              //         : COLORS.neutralDark,
                              //     fontWeight: addressAdded
                              //         ? FontWeight.w400
                              //         : FontWeight.w500,
                              //     onChanged: (value) {
                              //       if (value!.isNotEmpty) {
                              //         setState(() {
                              //           addressAdded = true;
                              //         });
                              //       } else {
                              //         setState(() {
                              //           addressAdded = false;
                              //         });
                              //       }
                              //     }),
                              buildTextField(
                                  label: 'Location',
                                  controller: homeAddress,
                                  hintText: "Enter apartment/road/area".tr(),
                                  validator: (value) {
                                    if (value == null || value.isEmpty) {
                                      setState(() => addressArea = true);
                                      return 'Enter apartment/road/area'.tr();
                                    }
                                    setState(() => addressArea = false);
                                    return null;
                                  },
                                  error: addressArea,
                                  title: 'Location'.tr(),
                                  color: locationAdded
                                      ? COLORS.neutralDarkOne
                                      : COLORS.neutralDark,
                                  fontWeight: locationAdded
                                      ? FontWeight.w400
                                      : FontWeight.w500,
                                  onChanged: (value) {
                                    if (value!.isNotEmpty) {
                                      setState(() {
                                        locationAdded = true;
                                        _validateForm();
                                      });
                                    } else {
                                      setState(() {
                                        locationAdded = false;
                                      });
                                    }
                                  }),
                              buildDropdownTwo(
                                  label: 'city'.tr(),
                                  hintText: 'Select your city'.tr(),
                                  items: dropdownCityItem,
                                  onChanged: (value) => setState(() {
                                    _selectedCity = value.label;
                                    _selectedWorkCityId =value.id;
                                    citySelected = true;


                                    _selectedLocality = '';
                                    localitySelected = false;
                                    localityListItem = [];
                                    _selectedPinCode = '';
                                    pincodeSelected = false;
                                    pinCodeListItem = [];
                                    _selectedWorkLocalityId = null;

                                    pinCodeLoading = true;
                                    localityLoading = true;

                                    initialRegisterBloc.add(FetchLocalitiesListEvent(
                                        cityId: value.id));



                                    initialRegisterBloc.add(FetchPinListEvent(
                                        cityId: value.id));


                                    _validateForm();
                                  }),
                                  itemLoading: cityLoading,
                                  validator: (value) {
                                    if (value == null || value.isEmpty) {
                                      return 'Please select your city'.tr();
                                    }
                                    return null;
                                  },
                                  color: citySelected
                                      ? COLORS.neutralDarkOne
                                      : COLORS.neutralDark,
                                  fontWeight: citySelected
                                      ? FontWeight.w400
                                      : FontWeight.w500),
                              if (localityLoading == true) ...[
                                registerText(
                                    text: 'Locality'.tr(), color: COLORS.neutralDark),
                                dropDownLoader(hintText: 'Select Locality'),
                                SizedBox(height: SizeConfig.blockHeight*2,)
                              ],
                              if (localityLoading == false) ...[
                                buildDropdownTwo(
                                    label: 'Locality'.tr(),
                                    hintText: 'Select Locality'.tr(),
                                    items: localityListItem,
                                    onChanged: (value) => setState(() {

                                      setState(() {
                                        _selectedLocality = value.label;
                                        _selectedWorkLocalityId = value.id;
                                        localitySelected = true;
                                      });
                                     _validateForm();
                                    }),
                                    itemLoading: localityLoading,
                                    validator: (value) {
                                      if (value == null || value.isEmpty) {
                                        return 'Please select your city locality'.tr();
                                      }
                                      return null;
                                    },
                                    color: localitySelected
                                        ? COLORS.neutralDarkOne
                                        : COLORS.neutralDark,
                                    fontWeight: localitySelected
                                        ? FontWeight.w400
                                        : FontWeight.w500)
                              ],
                              if (pinCodeLoading == true) ...[
                                registerText(
                                    text: 'Pincode'.tr(), color: COLORS.neutralDark),
                                dropDownLoader(hintText: 'Select your city pincode'),
                                SizedBox(height: SizeConfig.blockHeight*2,)
                              ],
                              if (pinCodeLoading == false) ...[
                                buildDropdownTwo(
                                    label: 'Pincode'.tr(),
                                    hintText: 'Select your city pincode'.tr(),
                                    items: pinCodeListItem,
                                    onChanged: (value) => setState(() {
                                      setState(() {
                                        _selectedPinCode = value.label;
                                        pincodeSelected = true;
                                      });
                                      _validateForm();
                                    }),
                                    itemLoading: pinCodeLoading,
                                    validator: (value) {
                                      if (value == null || value.isEmpty) {
                                        return 'Please select your city pincode'.tr();
                                      }
                                      return null;
                                    },
                                    color: pincodeSelected
                                        ? COLORS.neutralDarkOne
                                        : COLORS.neutralDark,
                                    fontWeight: pincodeSelected
                                        ? FontWeight.w400
                                        : FontWeight.w500)
                              ],
                              buildBioTextField(
                                  label: 'Instructions'.tr(),
                                  controller: Instructions,
                                  hintText:
                                      "Write instructions to reach out you"
                                          .tr(),
                                  validator: (value) {},
                                  maxLines: 4,
                                  error: false,
                                  title: 'Instructions (Optional)'.tr(),
                                  color: instructionAdded
                                      ? COLORS.neutralDarkOne
                                      : COLORS.neutralDark,
                                  fontWeight: instructionAdded
                                      ? FontWeight.w400
                                      : FontWeight.w500,
                                  onChanged: (value) {
                                    if (value!.isNotEmpty) {
                                      setState(() {
                                        instructionAdded = true;
                                      });
                                    } else {
                                      setState(() {
                                        instructionAdded = false;
                                      });
                                    }
                                  }),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.start,
                                crossAxisAlignment: CrossAxisAlignment.center,
                                children: [
                                  Checkbox(
                                    value: isChecked,
                                    side: BorderSide(
                                        color: COLORS.neutralDarkOne,
                                        width: SizeConfig.blockWidth * 0.3),
                                    checkColor: COLORS.white,
                                    activeColor: COLORS.primary,
                                    onChanged: (bool? value) {
                                      setState(() {
                                        isChecked = value!;
                                      });
                                    },
                                  ),
                                  Text(
                                    'Save it as a default address'.tr(),
                                    style: TextStyle(
                                      color: COLORS.neutralDark,
                                      fontSize: SizeConfig.blockWidth * 3.5,
                                      fontWeight: FontWeight.w400,
                                      fontFamily: "Poppins",
                                    ),
                                  ),
                                ],
                              ),
                              SizedBox(height: SizeConfig.blockHeight * 2),
                              customButton(
                                  text: 'SAVE'.tr(),
                                  onPressed: () {
                                    if (isSubmitButtonEnabled) {
                                      if (_formKey.currentState!.validate()) {
                                        profileBloc.add(AddressLocationCreate(
                                            addressType: _selectedType.toLowerCase(),
                                            addressTypeName: otherName.text,
                                            houseNo: houseNo.text,
                                            area: homeAddress.text,
                                            instructions: Instructions.text,
                                            isDefault: isChecked,
                                            latitude: latitude.toString(),
                                            longitude: longitude.toString(),
                                            city: _selectedCity!,
                                            locality: _selectedLocality!,
                                            pincode: _selectedPinCode!,
                                            localityId: _selectedWorkLocalityId!,
                                            cityId: _selectedWorkCityId!

                                        ));
                                      }
                                    }
                                  },
                                  backgroundColor: (isSubmitButtonEnabled)
                                      ? COLORS.primary
                                      : COLORS.primary.withOpacity(0.2),
                                  showIcon: false,
                                  width: SizeConfig.blockWidth * 100,
                                  height: SizeConfig.blockHeight * 8,
                                  textColor: COLORS.white,
                                  loading: loading),
                              SizedBox(height: SizeConfig.blockHeight * 2),
                            ],
                          ),
                        ),
                      )
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTypeButton(String type, String icon) {
    return InkWell(
      onTap: () => _setSelectedType(type),
      borderRadius: BorderRadius.circular(SizeConfig.blockWidth * 2),
      child: Container(
        padding: EdgeInsets.symmetric(
          vertical: SizeConfig.blockWidth * 2,
          horizontal: SizeConfig.blockWidth * 4,
        ),
        decoration: BoxDecoration(
          color: _selectedType == type ? COLORS.primary : COLORS.neutralDarkTwo,
          borderRadius: BorderRadius.circular(SizeConfig.blockWidth * 2),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Image.asset(
              icon,
              width: SizeConfig.blockWidth * 4,
              height: SizeConfig.blockWidth * 4,
              fit: BoxFit.contain,
              color: _selectedType == type ? COLORS.white : COLORS.primary,
            ),
            SizedBox(width: SizeConfig.blockWidth * 2),
            Text(
              type.tr(),
              style: TextStyle(
                fontSize: SizeConfig.blockWidth * 3.5,
                fontWeight: FontWeight.w400,
                fontFamily: "Poppins",
                color: _selectedType == type ? Colors.white : Colors.black,
              ),
              textAlign: TextAlign.center,
              // textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}
