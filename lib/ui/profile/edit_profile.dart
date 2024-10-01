import 'dart:io';
import 'package:dropdown_button2/dropdown_button2.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:works_app/bloc/profile/profile_bloc.dart';
import 'package:works_app/bloc/register_account/initial_register_bloc.dart';
import 'package:works_app/dao/get_user_location.dart';
import 'package:works_app/models/fetch_profile_model.dart';
import 'package:works_app/ui/onboarding/login_success.dart';
import 'package:works_app/ui/onboarding/phone_number.dart';
import 'package:works_app/ui/profile/component.dart';
import '../../components/colors.dart';
import '../../components/size_config.dart';
import '../../global_helper/ImagePickerComponent.dart';
import '../../global_helper/dropdown.dart';
import '../../global_helper/reuse_widget.dart';
import 'package:multi_dropdown/multi_dropdown.dart';
import 'package:geolocator/geolocator.dart';
import 'package:geolocator/geolocator.dart';
import 'package:geolocator/geolocator.dart';

class Language {
  final String name;
  final int id;

  Language({required this.name, required this.id});
  @override
  String toString() {
    return 'Language(name: $name, id: $id)';
  }
}

class EditProfileRegisterForm extends StatefulWidget {
  final VoidCallback refreshPageCallback;
  final ProfileFetch profileFetch;
  const EditProfileRegisterForm(
      {super.key,
      required this.refreshPageCallback,
      required this.profileFetch});

  @override
  State<EditProfileRegisterForm> createState() =>
      _EditProfileRegisterFormState();
}

class _EditProfileRegisterFormState extends State<EditProfileRegisterForm> {
  final _formKey = GlobalKey<FormState>();
  late ProfileBloc profileBloc;
  late InitialRegisterBloc initialRegisterBloc;
  bool loading = false;
  final TextEditingController _enterName = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController experienceController = TextEditingController();
  final TextEditingController chargesController = TextEditingController();
  final TextEditingController bioController = TextEditingController();
  final TextEditingController pinCodeController = TextEditingController();
  final TextEditingController ageController = TextEditingController();
  late MultiSelectController<Language> controller;

  String? selectedYears;
  String? selectedCharges;
  String? _selectedCity;
  String? _selectedProfession;
  bool buttonVisible = true;
  bool nameError = false;
  bool emailError = false;
  bool pinError = false;
  bool bioError = false;
  bool yearError = false;
  bool chargeError = false;
  bool ageError = false;
  File? _profileImage;
  String? selectedValue;
  String? _selectedGender;
  String? selectedExperence = 'Year';
  String? selectedCharge;
  List<Language> selectedLanguage = [];
  bool isSubmitButtonEnabled = false;
  String userType = '';
  String mobileNumber = '';
  String profilePic = '';
  List<File> _selectedImages = [];
  bool imagesList = false;
  List<String> workImages = [];
  bool _isLoadingMap = false;
  String? latitude = "0.0";
  String? longitude = "0.0";
  String? profilePicture = "";

  void _validateForm() {}

  Future<Position> _determinePosition() async {
    bool serviceEnabled;
    LocationPermission permission;
    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      return Future.error('Location services are disabled.');
    }
    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        return Future.error('Location permissions are denied');
      }
    }
    if (permission == LocationPermission.deniedForever) {
      return Future.error(
          'Location permissions are permanently denied, we cannot request permissions.');
    }
    return await Geolocator.getCurrentPosition();
  }
  String? formatChargeType(String? chargeType) {
    switch (chargeType!.toLowerCase()) {
      case 'hours':
        return 'Hours';
      case ' per day':
        return 'PerDay';
      case 'month':
        return 'Month';
      default:
        return null;
    }
  }


  @override
  void initState() {
    super.initState();
    profileBloc = BlocProvider.of<ProfileBloc>(context);
    initialRegisterBloc = BlocProvider.of<InitialRegisterBloc>(context);
    controller = MultiSelectController<Language>();
    initialData();
  }

  void initialData() {
    profilePic = widget.profileFetch.profilePic!;
    _enterName.text = widget.profileFetch.name!;
    _emailController.text = widget.profileFetch.email!;
    experienceController.text = widget.profileFetch.experiencedYears!;
    chargesController.text = widget.profileFetch.charges!;
    bioController.text = widget.profileFetch.bio!;
    pinCodeController.text = widget.profileFetch.pincode.toString()!;
    ageController.text = widget.profileFetch.age.toString()!;
    _selectedCity = widget.profileFetch.city!;
    _selectedProfession = widget.profileFetch.professionType!;
    _selectedGender = widget.profileFetch.gender!;
    profilePicture = widget.profileFetch.profilePic!;
    workImages = widget.profileFetch.workImages!;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      List<DropdownItem<Language>> item = items;
      controller.setItems(item);
      controller.selectWhere((item) =>
          widget.profileFetch.knownLanguages!.contains(item.value.name));
    });
    selectedLanguage= convertLanguages(widget.profileFetch.knownLanguages!);
    selectedCharge = formatChargeType(widget.profileFetch.chargeType!);
  }

  List<Language> convertLanguages(List<String> knownLanguages) {
    return List.generate(knownLanguages.length, (index) {
      return Language(
        name: knownLanguages[index],
        id: index + 1, // Assigning a dynamic ID starting from 1
      );
    });
  }



  void fetchCurrentLocation() async {
    setState(() {
      _isLoadingMap = true;
    });
    Position position = await _determinePosition();
    final result = await getAddress(position.latitude, position.longitude);
    setState(() {
      pinCodeController.text = result['pincode'] ?? '';
      _isLoadingMap = false;
      latitude = position.latitude.toString();
      longitude = position.longitude.toString();
    });
  }

  List<DropdownItem<Language>> items = [
    DropdownItem(label: 'English', value: Language(name: 'English', id: 1)),
    DropdownItem(label: 'Spanish', value: Language(name: 'Spanish', id: 2)),
    DropdownItem(label: 'French', value: Language(name: 'French', id: 3)),
    DropdownItem(label: 'German', value: Language(name: 'German', id: 4)),
    DropdownItem(label: 'Chinese', value: Language(name: 'Chinese', id: 5)),
    DropdownItem(label: 'Japanese', value: Language(name: 'Japanese', id: 6)),
    DropdownItem(label: 'Korean', value: Language(name: 'Korean', id: 7)),
    DropdownItem(label: 'Hindi', value: Language(name: 'Hindi', id: 8)),
  ];

  List<DropdownItem<Language>> convertLanguagesToDropdownItems(
      List<String> knownLanguages) {
    return knownLanguages.asMap().entries.map((entry) {
      int index = entry.key;
      String lang = entry.value;
      return DropdownItem(
          label: lang, value: Language(name: lang, id: index + 1));
    }).toList();
  }

  void _submitButton() {
    if (profilePicture == '') {
      print('objecta');
      showCustomSnackBar(
        context: context,
        message: 'Profile picture required',
      );
    } else if (workImages.isEmpty) {
      print('object');
      setState(() {
        imagesList = true;
      });
    } else {
      List<String> languageSelect =
          selectedLanguage.map((lang) => lang.name).toList();
      profileBloc.add(EditProfileAccount(
        name: _enterName.text,
        age: ageController.text,
        profile_pic: profilePicture!,
        email: _emailController.text,
        user_type: widget.profileFetch.userType!,
        profession_type: _selectedProfession ?? '',
        pincode: pinCodeController.text,
        city: _selectedCity ?? '',
        gender: _selectedGender?.toLowerCase() ?? "",
        known_languages: languageSelect,
        workImages: workImages,
        bio: bioController.text,
        experienced_years: experienceController.text ?? "",
        charges: chargesController.text,
        charge_type:selectedCharge?.toLowerCase() ?? '',
        userLongitude: longitude!,
        userLatitude: longitude!,
      ));
    }
  }

  void _onImagesSelected(List<File> images) {
    setState(() {
      _selectedImages = images;
      if (_selectedImages.isNotEmpty) {
        initialRegisterBloc.add(
          UploadMultipleImageEvent(
              imagePath: _selectedImages.length > 1
                  ? _selectedImages[1]
                  : _selectedImages[0]),
        );
      }
    });
  }

  void _removeImage(int index) {
    setState(() {
      if (index >= 0 && index < _selectedImages.length) {
        _selectedImages.removeAt(index);
        if (index < workImages.length) {
          workImages.removeAt(index);
        }
      }
    });
  }

  @override
  void dispose() {
    _enterName.dispose();
    _emailController.dispose();
    experienceController.dispose();
    chargesController.dispose();
    pinCodeController.dispose();
    ageController.dispose();
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
            title: 'My Profile',
            backgroundColor: COLORS.white,
            titleColors: COLORS.neutralDark),
        body: MultiBlocListener(
          listeners: [
            BlocListener<InitialRegisterBloc, InitialRegisterState>(
              listener: (context, state) {
                if (state is InitialRegisterLoading) {
                  loading = true;
                } else if (state is UploadImageSuccess) {
                  loading = false;
                  profilePicture = state.filePath;
                } else if (state is UploadMultipleImageSuccess) {
                  loading = false;
                  workImages.add(state.filePath);
                } else if (state is UploadImageFailed) {
                  loading = false;
                  showCustomSnackBar(
                    context: context,
                    message: state.message,
                  );
                }
                setState(() {});
              },
            ),
            BlocListener<ProfileBloc, ProfileState>(
              listener: (context, state) {
                if (state is ProfileLoading) {
                  loading = true;
                } else if (state is EditProfileSuccess) {
                  loading = false;
                  widget.refreshPageCallback();
                  Navigator.pop(context, true);
                } else if (state is EditProfileFailed) {
                  loading = false;
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
            child: SingleChildScrollView(
              child: Container(
                  width: SizeConfig.screenWidth,
                  padding: EdgeInsets.all(SizeConfig.blockWidth * 4.5),
                  child: Form(
                    key: _formKey,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _buildProfilePicture(),
                        buildTextField(
                            label: 'Name',
                            controller: _enterName,
                            hintText: "Enter your name".tr(),
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                setState(() => nameError = true);
                                return 'Please enter your name'.tr();
                              }
                              setState(() => nameError = false);
                              return null;
                            },
                            error: nameError,
                            onChanged: (value) {
                              _validateForm();
                            },
                            title: 'name'.tr()),
                        _buildMobileNumber(),
                        buildTextField(
                            label: 'Email Address',
                            controller: _emailController,
                            hintText:
                                "Enter your email address (Optional)".tr(),
                            validator: (value) {
                              if (value != null &&
                                  value.isNotEmpty &&
                                  !RegExp(r'^[^@]+@[^@]+\.[^@]+')
                                      .hasMatch(value)) {
                                return 'Please enter a valid email address'
                                    .tr();
                              }
                              return null;
                            },
                            error: emailError,
                            onChanged: (value) {
                              _validateForm();
                            },
                            title: 'email'.tr()),
                        buildTextField(
                          label: 'Pincode',
                          controller: pinCodeController,
                          hintText: "Enter your pincode".tr(),
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              setState(() => pinError = true);
                              return 'Please enter a pincode'.tr();
                            }
                            setState(() => pinError = false);
                            return null;
                          },
                          prefix: true,
                          prefixIcon: _isLoadingMap
                              ? Container(
                                  height: SizeConfig.blockHeight,
                                  width: SizeConfig.blockHeight,
                                  padding: EdgeInsets.all(
                                      SizeConfig.blockWidth * 3.5),
                                  child: CircularProgressIndicator(
                                      strokeWidth: SizeConfig.blockWidth * 0.5,
                                      color: COLORS.accent))
                              : null,
                          onTap: () {
                            fetchCurrentLocation();
                          },
                          error: pinError,
                          onChanged: (value) {
                            _validateForm();
                          },
                          title: 'Pincode'.tr(),
                        ),
                        buildDropdown(
                          label: 'city'.tr(),
                          value: _selectedCity,
                          hintText: 'Select your city'.tr(),
                          items: ['Mysore', 'Bangalore', 'Mangalore', 'Mandy'],
                          onChanged: (value) => setState(() {
                            _selectedCity = value;
                            _validateForm();
                          }),
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Please select your city'.tr();
                            }
                            return null;
                          },
                        ),
                        if (widget.profileFetch.userType == 'professional') ...[
                          SizedBox(height: SizeConfig.blockHeight),
                          buildDropdown(
                            value: _selectedProfession,
                            label: 'profession_type'.tr(),
                            hintText: 'Select your Profession'.tr(),
                            items: [
                              'Technology',
                              'Healthcare',
                              'Finance',
                              'Education'
                            ],
                            onChanged: (value) => setState(() {
                              _selectedProfession = value;
                              _validateForm();
                            }),
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return 'Please select your profession'.tr();
                              }
                              return null;
                            },
                          ),
                        ],
                        if (widget.profileFetch.userType == 'professional') ...[
                          SizedBox(height: SizeConfig.blockHeight),
                          registerText(text: 'years_of_experience'.tr()),
                          normalTextField(
                              hintText: "Experience".tr(),
                              controller: experienceController,
                              inputType: TextInputType.number,
                              onChanged: (value) {
                                _validateForm();
                              },
                              validator: (value) {
                                if (value == null || value.isEmpty) {
                                  setState(() => yearError = true);
                                  return 'Please enter a valid experience'.tr();
                                }
                                setState(() => yearError = false);
                                return null;
                              },
                              fontWeight: FontWeight.w400,
                              errorMessage: '',
                              suffix: false,
                              prefix: false,
                              suffixIcon: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Container(
                                    decoration: BoxDecoration(
                                      color: COLORS.neutralDarkTwo,
                                      border: Border(
                                        right: BorderSide(
                                          width: SizeConfig.blockWidth * 0.1,
                                          color: COLORS.neutralDarkTwo,
                                        ),
                                      ),
                                    ),
                                    height: SizeConfig.blockHeight * 5,
                                    width: SizeConfig.blockWidth * 0.4,
                                    margin: EdgeInsets.symmetric(
                                        horizontal: SizeConfig.blockWidth * 1),
                                  ),
                                  Container(
                                    constraints: BoxConstraints(
                                      maxWidth: SizeConfig.blockWidth *
                                          30, // Add constraints
                                    ),
                                    child: CustomDropdownButtonFormField(
                                      selectedValue: selectedExperence,
                                      items: const ['Year', 'Month'],
                                      onChanged: (String? newValue) {
                                        setState(() {
                                          selectedExperence = newValue;
                                        });
                                      },
                                      hintText: 'Select Duration',
                                      iconSize: SizeConfig.blockWidth * 6,
                                      iconColor: COLORS.accent,
                                    ),
                                  ),
                                ],
                              ),
                              hasError: yearError),
                          SizedBox(height: SizeConfig.blockHeight),
                        ],
                        if (widget.profileFetch.userType == 'professional') ...[
                          registerText(text: 'charges_daily_wages'.tr()),
                          normalTextField(
                            hintText: "Charges".tr(),
                            controller: chargesController,
                            inputType: TextInputType.number,
                            onChanged: (value) {
                              _validateForm();
                            },
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                setState(() => chargeError = true);
                                return 'Please enter a valid charge'.tr();
                              }
                              setState(() => chargeError = false);
                              return null;
                            },
                            hasError: chargeError,
                            fontWeight: FontWeight.w400,
                            errorMessage: '',
                            suffix: true,
                            prefix: true,
                            suffixIcon: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Container(
                                  decoration: BoxDecoration(
                                      color: COLORS.neutralDarkTwo,
                                      border: Border(
                                          right: BorderSide(
                                              width:
                                                  SizeConfig.blockWidth * 0.1,
                                              color: COLORS.neutralDarkTwo))),
                                  height: SizeConfig.blockHeight * 5,
                                  width: SizeConfig.blockWidth * 0.4,
                                  margin: EdgeInsets.symmetric(
                                      horizontal: SizeConfig.blockWidth * 1),
                                ),
                                Container(
                                  constraints: BoxConstraints(
                                    maxWidth: SizeConfig.blockWidth *
                                        30, // Add constraints
                                  ),
                                  child: CustomDropdownButtonFormField(
                                    selectedValue: selectedCharge,
                                    items: const ['Hours', 'PerDay', 'Month'],
                                    onChanged: (String? newValue) {
                                      setState(() {
                                        selectedCharge = newValue;
                                        _validateForm();
                                      });
                                    },
                                    hintText: 'Select Duration',
                                    iconSize: SizeConfig.blockWidth * 6,
                                    iconColor: COLORS.accent,
                                  ),
                                ),
                              ],
                            ),
                            prefixIcon: Container(
                              padding: EdgeInsets.symmetric(
                                  horizontal: SizeConfig.blockWidth * 4),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Text(
                                    '₹',
                                    style: TextStyle(
                                      color: COLORS.primary,
                                      fontSize: SizeConfig.blockWidth * 4.25,
                                      fontWeight: FontWeight.w500,
                                      fontFamily: "Poppins",
                                    ),
                                  ),
                                  Container(
                                    decoration: BoxDecoration(
                                        color: COLORS.neutralDarkTwo,
                                        border: Border(
                                            right: BorderSide(
                                                width:
                                                    SizeConfig.blockWidth * 0.1,
                                                color: COLORS.neutralDarkTwo))),
                                    height: SizeConfig.blockHeight * 5,
                                    width: SizeConfig.blockWidth * 0.4,
                                    margin: EdgeInsets.only(
                                        left: SizeConfig.blockWidth * 3),
                                  )
                                ],
                              ),
                            ),
                          ),
                        ],
                        if (widget.profileFetch.userType == 'professional') ...[
                          SizedBox(height: SizeConfig.blockHeight * 0.5),
                          buildGenderSelection(
                            groupValue: _selectedGender,
                            onChanged: (value) {
                              setState(() {
                                _selectedGender = value;
                              });
                            },
                          ),
                        ],
                        if (widget.profileFetch.userType == 'professional') ...[
                          SizedBox(height: SizeConfig.blockHeight),
                          registerText(text: 'Age'.tr()),
                          normalTextField(
                              hintText: "Enter your age".tr(),
                              controller: ageController,
                              inputType: TextInputType.number,
                              onChanged: (value) {
                                _validateForm();
                              },
                              validator: (value) {
                                if (value == null || value.isEmpty) {
                                  setState(() => ageError = true);
                                  return 'Please enter your age'.tr();
                                }
                                setState(() => ageError = false);
                                return null;
                              },
                              fontWeight: FontWeight.w400,
                              errorMessage: '',
                              suffix: true,
                              prefix: false,
                              suffixIcon: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Container(
                                    decoration: BoxDecoration(
                                      border: Border(
                                        left: BorderSide(
                                          width: SizeConfig.blockWidth * 0.3,
                                          color: COLORS.neutralDarkTwo,
                                        ),
                                      ),
                                    ),
                                    height: SizeConfig.blockHeight * 5,
                                    width: SizeConfig.blockWidth * 20,
                                    padding: EdgeInsets.symmetric(
                                        horizontal: SizeConfig.blockWidth * 2.5,
                                        vertical: SizeConfig.blockWidth * 1),
                                    child: Text(
                                      'Year',
                                      style: TextStyle(
                                          color: COLORS.accent,
                                          fontWeight: FontWeight.w400,
                                          fontFamily: "Poppins",
                                          fontSize:
                                              SizeConfig.blockWidth * 3.5),
                                      textAlign: TextAlign.center,
                                    ),
                                  ),
                                ],
                              ),
                              hasError: ageError),
                        ],
                        if (widget.profileFetch.userType == 'professional') ...[
                          SizedBox(height: SizeConfig.blockHeight),
                          registerText(text: 'known_language'.tr()),
                          MultiDropdown<Language>(
                            items: items,
                            controller: controller,
                            enabled: true,
                            searchEnabled: false,
                            closeOnBackButton: true,
                            chipDecoration: ChipDecoration(
                                backgroundColor:
                                    COLORS.primary.withOpacity(0.1),
                                wrap: true,
                                labelStyle: TextStyle(
                                    color: COLORS.primary,
                                    fontWeight: FontWeight.w500,
                                    fontFamily: "Poppins",
                                    fontSize: SizeConfig.blockWidth * 3.5),
                                runSpacing: 8,
                                spacing: 10,
                                borderRadius: BorderRadius.circular(
                                    SizeConfig.blockWidth * 2),
                                deleteIcon: Icon(
                                  Icons.clear,
                                  color: COLORS.black,
                                  size: SizeConfig.blockWidth * 4.5,
                                )),
                            fieldDecoration: FieldDecoration(
                              suffixIcon: Icon(
                                Icons.keyboard_arrow_down_outlined,
                                color: COLORS.accent,
                                size: SizeConfig.blockWidth * 6,
                              ),
                              hintText: 'Select Languages'.tr(),
                              hintStyle: TextStyle(
                                color: COLORS.neutralDark,
                                fontWeight: FontWeight.w400,
                                fontFamily: "Poppins",
                                fontSize: SizeConfig.blockWidth * 3.2,
                              ),
                              backgroundColor: COLORS.white,
                              showClearIcon: true,
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                                borderSide: const BorderSide(
                                    color: COLORS.neutralDarkTwo),
                              ),
                              focusedBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                                borderSide: const BorderSide(
                                  color: COLORS.neutralDarkTwo,
                                ),
                              ),
                            ),
                            dropdownDecoration: DropdownDecoration(
                                maxHeight: SizeConfig.blockHeight * 50,
                                elevation: SizeConfig.blockWidth * 5),
                            dropdownItemDecoration: DropdownItemDecoration(
                              selectedIcon: Icon(
                                Icons.check,
                                color: COLORS.accent,
                                size: SizeConfig.blockWidth * 5,
                              ),
                              disabledIcon:
                                  Icon(Icons.lock, color: Colors.grey.shade300),
                            ),
                            validator: (value) {
                              if ( selectedLanguage.isEmpty) {
                                return 'Please select a language'.tr();
                              }
                              return null;
                            },
                            onSelectionChange: (selectedItems) {
                              selectedLanguage = selectedItems;
                              debugPrint("OnSelectionChange: $selectedItems");
                              _validateForm();
                            },
                          ),
                        ],
                        SizedBox(
                          height: SizeConfig.blockHeight * 2.5,
                        ),
                        buildBioTextField(
                            label: 'Bio'.tr(),
                            controller: bioController,
                            hintText: "Write about you and your work".tr(),
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                setState(() => bioError = true);
                                return 'Please enter Bio'.tr();
                              }
                              setState(() => bioError = false);
                              return null;
                            },
                            error: bioError,
                            onChanged: (value) {
                              _validateForm();
                            },
                            title: 'Bio'.tr()),
                        MultipleImagePickerComponent(
                          onImagesSelected: _onImagesSelected,
                          error: imagesList,
                          removeImage: _removeImage,
                          defaultImages: workImages,
                        ),
                      ],
                    ),
                  )),
            ),
          ),
        ),
        bottomNavigationBar: Container(
          padding: EdgeInsets.symmetric(vertical: SizeConfig.blockHeight * 2),
          decoration: BoxDecoration(
            border: Border(
                top: BorderSide(
                    color: COLORS.neutralDarkTwo,
                    width: SizeConfig.blockWidth * 0.3)),
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              customButton(
                text: 'back'.tr(),
                onPressed: () {
                  Navigator.pop(context);
                },
                backgroundColor: COLORS.neutralDarkTwo,
                showIcon: false,
                width: SizeConfig.blockWidth * 42,
                height: SizeConfig.blockHeight * 8,
                textColor: COLORS.black,
              ),
              customButton(
                text: 'submit_button'.tr(),
                onPressed: () {
                  if (_formKey.currentState!.validate()) {
                    _submitButton();
                  }
                },
                backgroundColor: COLORS.primary,
                showIcon: false,
                width: SizeConfig.blockWidth * 42,
                height: SizeConfig.blockHeight * 8,
                textColor: COLORS.white,loading: loading
              )
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildProfilePicture() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.start,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        registerText(text: 'profile_picture'.tr()),

        // Conditional for displaying the profile picture
        if (_profileImage == null && profilePic.isEmpty) ...[
          // Show the image picker if no profile picture is set
          ImagePickerComponent(
            onImageSelected: (File image) {
              setState(() {
                _profileImage = image;
                profilePic = '';
              });
              initialRegisterBloc
                  .add(UploadImageEvent(imagePath: _profileImage!));
            },
          ),
        ] else if (_profileImage != null) ...[
          // Show the local file image if _profileImage is set
          Stack(
            children: [
              Container(
                height: SizeConfig.blockWidth * 32,
                width: SizeConfig.blockWidth * 34,
                decoration: BoxDecoration(
                  border: Border.all(
                    color: COLORS.primary,
                    width: SizeConfig.blockWidth * 0.5,
                  ),
                  image: DecorationImage(
                    image: FileImage(
                      File(_profileImage!.path),
                    ),
                    fit: BoxFit.fill,
                  ),
                  borderRadius:
                      BorderRadius.circular(SizeConfig.blockWidth * 3.5),
                ),
              ),
              // Image picker modal for changing the image
              Positioned(
                bottom: 0,
                right: 0,
                child: ImagePickerModal(
                  onImageSelected: (File image) {
                    setState(() {
                      _profileImage = image;
                      profilePic = '';
                    });
                    initialRegisterBloc
                        .add(UploadImageEvent(imagePath: _profileImage!));
                  },
                ),
              )
            ],
          ),
        ] else if (profilePic.isNotEmpty) ...[
          Stack(
            children: [
              Container(
                height: SizeConfig.blockWidth * 32,
                width: SizeConfig.blockWidth * 34,
                decoration: BoxDecoration(
                  border: Border.all(
                    color: COLORS.primary,
                    width: SizeConfig.blockWidth * 0.5,
                  ),
                  image: DecorationImage(
                    image: NetworkImage(profilePic),
                    fit: BoxFit.fill,
                  ),
                  borderRadius:
                      BorderRadius.circular(SizeConfig.blockWidth * 3.5),
                ),
              ),
              // Image picker modal for changing the image
              Positioned(
                bottom: 0,
                right: 0,
                child: ImagePickerModal(
                  onImageSelected: (File image) {
                    setState(() {
                      _profileImage = image;
                      profilePic = '';
                    });
                    initialRegisterBloc
                        .add(UploadImageEvent(imagePath: _profileImage!));
                  },
                ),
              )
            ],
          ),
        ],

        SizedBox(height: SizeConfig.blockHeight * 3),
      ],
    );
  }

  Widget _buildMobileNumber() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        registerText(text: 'mobile_number_label'.tr()),
        Container(
          width: SizeConfig.blockWidth * 100,
          height: SizeConfig.blockHeight * 8,
          padding: EdgeInsets.all(SizeConfig.blockWidth * 4),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(SizeConfig.blockWidth * 3),
            color: COLORS.neutralDarkTwo,
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    '+91',
                    style: TextStyle(
                      color: COLORS.primary,
                      fontSize: SizeConfig.blockWidth * 4,
                      fontWeight: FontWeight.w500,
                      fontFamily: "Poppins",
                    ),
                  ),
                  Container(
                    decoration: BoxDecoration(
                      color: COLORS.neutralDarkTwo,
                      border: Border(
                        right: BorderSide(
                          width: SizeConfig.blockWidth * 0.1,
                          color: COLORS.neutralDarkOne,
                        ),
                      ),
                    ),
                    height: SizeConfig.blockHeight * 4.5,
                    width: SizeConfig.blockWidth * 0.4,
                    margin: EdgeInsets.symmetric(
                      horizontal: SizeConfig.blockWidth * 3,
                    ),
                  ),
                  Text(
                    widget.profileFetch.mobile!,
                    style: TextStyle(
                      color: COLORS.neutralDark,
                      fontSize: SizeConfig.blockWidth * 4,
                      fontWeight: FontWeight.w400,
                      fontFamily: "Poppins",
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
        SizedBox(height: SizeConfig.blockHeight * 3),
      ],
    );
  }
}
