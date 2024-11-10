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

import '../../../components/colors.dart';
import '../../../dao/get_user_location.dart';
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

  @override
  void initState() {
    super.initState();
    profileBloc = BlocProvider.of<ProfileBloc>(context);
    _getCurrentLocation();
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
        body: BlocListener<ProfileBloc, ProfileState>(
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
                  borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
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
                                    onChanged: (value) {})
                              ],
                              buildTextField(
                                  label: 'House/Flat/Block No',
                                  controller: houseNo,
                                  hintText: "Enter house/flat/block no".tr(),
                                  validator: (value) {},
                                  error: false,
                                  title: 'House/Flat/Block No'.tr(),
                                  onChanged: (value) {}),
                              buildTextField(
                                label: 'Apartment/Road/Area',
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
                                title: 'Apartment/Road/Area'.tr(),
                                onChanged: (value) {},
                              ),
                              buildBioTextField(
                                  label: 'Instructions'.tr(),
                                  controller: Instructions,
                                  hintText:
                                      "Write instructions to reach out you"
                                          .tr(),
                                  validator: (value) {},
                                  maxLines: 5,
                                  error: false,
                                  title: 'Instructions'.tr(),
                                  onChanged: (value) {}),
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
                                    if (_formKey.currentState!.validate() &&
                                        _currentAddress !=
                                            'Loading address...') {
                                      profileBloc.add(AddressLocationCreate(
                                          addressType:
                                              _selectedType.toLowerCase(),
                                          addressTypeName: otherName.text,
                                          houseNo: houseNo.text,
                                          area: homeAddress.text,
                                          instructions: Instructions.text,
                                          isDefault: isChecked,
                                          latitude: latitude.toString(),
                                          longitude: longitude.toString()));
                                    }
                                  },
                                  backgroundColor:
                                      _currentAddress != 'Loading address...'
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
    return ElevatedButton.icon(
      style: ElevatedButton.styleFrom(
        backgroundColor:
            _selectedType == type ? COLORS.primary : COLORS.neutralDarkTwo,
        foregroundColor: _selectedType == type ? Colors.white : Colors.black,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(SizeConfig.blockWidth * 2),
        ),
      ),
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
        textAlign: TextAlign.center,
      ),
    );
  }
}
