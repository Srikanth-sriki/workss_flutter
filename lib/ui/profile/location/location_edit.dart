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
import 'package:works_app/components/size_config.dart';

import '../../../bloc/profile/profile_bloc.dart';
import '../../../bloc/register_account/initial_register_bloc.dart';
import '../../../components/colors.dart';
import '../../../dao/get_user_location.dart';
import '../../../global_helper/dropdown.dart';
import '../../../global_helper/helper_function.dart';
import '../../../global_helper/loading_placeholder/home_layout.dart';
import '../../../global_helper/reuse_widget.dart';
import '../../../models/address_location_list.dart';
import '../component.dart';
import '../modal/edit_address_cancel.dart';
import '../modal/edit_address_success.dart';

class EditAddressScreen extends StatefulWidget {
  late String routeType;
  late AddressListModal addressItem;
  EditAddressScreen(
      {super.key, required this.addressItem, required this.routeType});

  @override
  State<EditAddressScreen> createState() => _EditAddressScreenState();
}

class _EditAddressScreenState extends State<EditAddressScreen> {
  late InitialRegisterBloc initialRegisterBloc;
  late ProfileBloc profileBloc;
  GoogleMapController? _mapController;
  Location _location = Location();
  final TextEditingController houseNo = TextEditingController();
  final TextEditingController homeAddress = TextEditingController();
  final TextEditingController Instructions = TextEditingController();
  final TextEditingController otherName = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  late LatLng _initialPosition;
  late LatLng _currentPosition;
  String _currentAddress = 'Loading address...';
  bool isMapDragging = false;
  late String _selectedType;
  bool isChecked = false;
  bool otherNameError = false;
  bool loading = false;
  double latitude = 0.0;
  double longitude = 0.0;
  bool addressAdded = true;
  bool locationAdded = true;
  bool instructionAdded = true;
  bool nameAddressAdded = true;
  bool cityLoading = true;
  bool localityLoading = true;
  List<String> dropdownCityItem = [];
  List<String> localityListItem = [];
  Map<String, String> cityMap = {};
  String? _selectedCity;
  bool citySelected = true;
  String? _selectedLocality;
  bool localitySelected = true;
  bool isSubmitButtonEnabled = false;

  @override
  void initState() {
    super.initState();
    profileBloc = BlocProvider.of<ProfileBloc>(context);
    initialRegisterBloc = BlocProvider.of<InitialRegisterBloc>(context);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      initialData();
    });
  }

  void initialData() {
    _initialPosition = LatLng(
      double.tryParse(widget.addressItem.latitude ?? '0.0') ?? 0.0,
      double.tryParse(widget.addressItem.longitude ?? '0.0') ?? 0.0,
    );
    _currentPosition = LatLng(
      double.tryParse(widget.addressItem.latitude ?? '0.0') ?? 0.0,
      double.tryParse(widget.addressItem.longitude ?? '0.0') ?? 0.0,
    );
    _selectedType = capitalizeFirstLetter(widget.addressItem.addressType!);
    houseNo.text = widget.addressItem.houseNo!;
    homeAddress.text = widget.addressItem.area!;
    Instructions.text = widget.addressItem.instructions!;
    otherName.text = widget.addressItem.addressTypeName!;
    isChecked = widget.addressItem.isDefault!;
    latitude = double.tryParse(widget.addressItem.latitude ?? '0.0')!;
    longitude = double.tryParse(widget.addressItem.longitude ?? '0.0')!;
    _selectedCity = widget.addressItem.city!;
    _selectedLocality = widget.addressItem.locality!;

    bool newNameAddressAdded = widget.addressItem.addressTypeName!.isNotEmpty;
    bool newAddressAdded = widget.addressItem.area!.isNotEmpty;
    bool newInstructionAdded = widget.addressItem.instructions!.isNotEmpty;
    bool newLocationAdded = widget.addressItem.houseNo!.isNotEmpty;

    if (newNameAddressAdded != nameAddressAdded ||
        newAddressAdded != addressAdded ||
        newInstructionAdded != instructionAdded ||
        newLocationAdded != locationAdded) {
      setState(() {
        nameAddressAdded = newNameAddressAdded;
        addressAdded = newAddressAdded;
        instructionAdded = newInstructionAdded;
        locationAdded = newLocationAdded;
      });
    }
  }

  Future<void> _getCurrentLocation() async {
    setState(() {
      isMapDragging = true;
    });
    PermissionStatus permissionGranted = await _location.requestPermission();
    print("Permission status: $permissionGranted");

    if (permissionGranted == PermissionStatus.granted) {
      LocationData locationData = await _location.getLocation();
      setState(() {
        _currentPosition =
            LatLng(locationData.latitude!, locationData.longitude!);
        _initialPosition = _currentPosition;
        _currentAddress = 'Fetching address...';
        latitude = locationData.latitude!;
        longitude = locationData.longitude!;
        isMapDragging = false;
      });
      print(_currentPosition);
      _updateMapCamera(_currentPosition);
      _getAddressFromCoordinates(_currentPosition);
    } else {
      print("Location permission not granted");
    }
    setState(() {
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

  void _validateForm() {
    bool isValid = false;

    if (
        homeAddress.text.isNotEmpty &&
        (_selectedCity?.isNotEmpty ?? false) &&
        _selectedLocality?.isNotEmpty == true &&
        (_selectedType != 'Other' || otherName.text.isNotEmpty)) {
      isValid = true;
    }

    setState(() {
      isSubmitButtonEnabled = isValid;
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
      onTap: () {
        FocusScopeNode currentFocus = FocusScope.of(context);
        if (!currentFocus.hasPrimaryFocus) {
          currentFocus.unfocus();
        }
      },
      child: Scaffold(
        backgroundColor: COLORS.white,
        appBar: const CustomAppBar(
          title: 'Edit Location',
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
                    cityMap = {
                      for (var city in state.dropDownItems)
                        city.city: city.id,
                    };
                    dropdownCityItem = cityMap.keys.toList();
                    cityLoading = false;

                    if (widget.addressItem.city != null && widget.addressItem.city!.isNotEmpty) {
                      _selectedCity = widget.addressItem.city!;
                      final selectedCityId = cityMap[_selectedCity];

                      if (selectedCityId != null) {
                        initialRegisterBloc.add(FetchLocalitiesListEvent(cityId: selectedCityId));
                      } else {
                        print("City '${_selectedCity}' not found in cityMap.");
                      }
                    }
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
                    localityListItem = state.dropDownItems
                        .map((item) => item.locality)
                        .toList();
                    localityLoading = false;
                  });
                } else if (state is FetchLocalitiesListFailed) {
                  setState(() {
                    localityLoading = false;
                  });
                }

                setState(() {});
              },
            ),
            BlocListener<ProfileBloc, ProfileState>(listener: (context, state) {
              if (state is AddressLocationLoading) {
                setState(() {
                  loading = true;
                });
              } else if (state is AddressLocationEditSuccess) {
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
                  builder: (context) => EditAddressSuccessBottomSheet(
                    routeType: widget.routeType,
                  ),
                );
              } else if (state is AddressLocationEditFailed) {
                setState(() {
                  loading = false;
                });
                showCustomSnackBar(
                  context: context,
                  message: state.message,
                );
              }
              setState(() {});
            })
          ],
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
                                        });
                                      } else {
                                        setState(() {
                                          nameAddressAdded = false;
                                        });
                                      }
                                      _validateForm();
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
                                  validator: (value) {},
                                  error: false,
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
                                      });
                                    } else {
                                      setState(() {
                                        locationAdded = false;
                                      });
                                    }
                                    _validateForm();
                                  }),
                              buildDropdown(
                                label: 'city'.tr(),
                                value: _selectedCity,
                                hintText: 'Select your city'.tr(),
                                items: dropdownCityItem,
                                itemLoading: cityLoading,color: COLORS.neutralDarkOne,fontWeight: FontWeight.w400,
                                onChanged: (value) => setState(() {
                                  _selectedCity = value;
                                  citySelected = true;
                                  _selectedLocality = null;
                                  localitySelected = false;
                                  localityListItem = [];

                                  localityLoading = true;

                                  initialRegisterBloc.add(FetchLocalitiesListEvent(
                                      cityId: cityMap[value]!));

                                  _validateForm();
                                }),
                                validator: (value) {
                                  if (value == null || value.isEmpty) {
                                    return 'Please select your city'.tr();
                                  }
                                  return null;
                                },

                              ),

                              if (localityLoading == true) ...[
                                registerText(
                                    text: 'Locality'.tr(), color: COLORS.neutralDark),
                                dropDownLoader(hintText: 'Select Locality'),
                                SizedBox(height: SizeConfig.blockHeight*2,)
                              ],
                              if (localityLoading == false) ...[
                                buildDropdown(
                                    label: 'Locality'.tr(),
                                    value: _selectedLocality,
                                    hintText: 'Select Locality'.tr(),
                                    items: localityListItem,
                                    onChanged: (value) => setState(() {
                                      _selectedLocality = value;
                                      setState(() {});
                                      _validateForm();
                                    }),
                                    itemLoading: localityLoading,
                                    validator: (value) {
                                      if (value == null || value.isEmpty) {
                                        return 'Please Select Locality'.tr();
                                      }
                                      return null;
                                    },
                                    color: COLORS.neutralDarkOne,fontWeight: FontWeight.w400),
                              ],
                              buildBioTextField(
                                  label: 'Instructions (Optional)'.tr(),
                                  controller: Instructions,
                                  hintText:
                                  "Write instructions to reach out you"
                                      .tr(),
                                  validator: (value) {},
                                  error: false,
                                  title: 'Instructions'.tr(),
                                  maxLines: 6,
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
                              Row(
                                mainAxisAlignment:
                                MainAxisAlignment.spaceBetween,
                                crossAxisAlignment: CrossAxisAlignment.center,
                                children: [
                                  customButton(
                                      text: 'CANCEL'.tr(),
                                      onPressed: () {
                                        showMaterialModalBottomSheet(
                                          enableDrag: false,
                                          expand: false,
                                          isDismissible: false,
                                          backgroundColor: COLORS.white,
                                          context: context,
                                          shape: const RoundedRectangleBorder(
                                            borderRadius: BorderRadius.vertical(
                                                top: Radius.circular(20)),
                                          ),
                                          builder: (context) =>
                                              EditAddressCancelBottomSheet(
                                                reset: initialData,
                                              ),
                                        );
                                      },
                                      backgroundColor: COLORS.neutralDarkTwo,
                                      showIcon: false,
                                      width: SizeConfig.blockWidth * 42,
                                      height: SizeConfig.blockHeight * 8,
                                      textColor: COLORS.black,
                                      loading: loading),
                                  customButton(
                                      text: 'SAVE'.tr(),
                                      onPressed: () {
                                        if (isSubmitButtonEnabled) {
                                          if (_formKey.currentState!
                                              .validate()) {
                                            profileBloc.add(AddressLocationEdit(
                                                addressId:
                                                widget.addressItem.id!,
                                                addressType:
                                                _selectedType.toLowerCase(),
                                                addressTypeName: otherName.text,
                                                houseNo: houseNo.text,
                                                area: homeAddress.text,
                                                instructions: Instructions.text,
                                                isDefault: isChecked,
                                                city: _selectedCity!,
                                                locality: _selectedLocality!,
                                                latitude: latitude.toString(),
                                                longitude:
                                                longitude.toString()));
                                          }
                                        }
                                      },
                                      backgroundColor:
                                      isSubmitButtonEnabled
                                          ? COLORS.primary
                                          : COLORS.primary.withOpacity(0.4),
                                      showIcon: false,
                                      width: SizeConfig.blockWidth * 42,
                                      height: SizeConfig.blockHeight * 8,
                                      textColor: COLORS.white,
                                      loading: loading),
                                ],
                              ),
                              SizedBox(height: SizeConfig.blockHeight * 2),
                            ],
                          ),
                        ),
                      )
                    ],
                  ),
                ),
              ],
            )
        ),
      ),
    );
  }

  Widget _buildTypeButton(String type, String icon) {
    return ElevatedButton.icon(
      style: ElevatedButton.styleFrom(
          backgroundColor:
              _selectedType == type ? COLORS.primary : COLORS.neutralDarkTwo,
          foregroundColor: _selectedType == type ? Colors.white : Colors.black,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(SizeConfig.blockWidth * 2),
          ),
          elevation: 0),
      onPressed: () => _setSelectedType(type),
      icon: Image.asset(
        icon,
        width: SizeConfig.blockWidth * 4,
        height: SizeConfig.blockWidth * 4,
        fit: BoxFit.contain,
        color: _selectedType == type ? COLORS.white : COLORS.primary,
      ),
      label: Text(
        type.tr(),
        style: TextStyle(
          fontSize: SizeConfig.blockWidth * 3.5,
          fontWeight: FontWeight.w400,
          fontFamily: "Poppins",
        ),
      ),
    );
  }
}
