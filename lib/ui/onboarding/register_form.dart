import 'dart:convert';
import 'dart:io';
import 'package:dropdown_button2/dropdown_button2.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';
import 'package:works_app/dao/get_user_location.dart';
import 'package:works_app/ui/onboarding/login_success.dart';
import 'package:works_app/ui/onboarding/phone_number.dart';
import 'package:works_app/ui/profile/component.dart';
import '../../bloc/professional/professional_bloc.dart';
import '../../bloc/register_account/initial_register_bloc.dart';
import '../../components/colors.dart';
import '../../components/config.dart';
import '../../components/size_config.dart';
import '../../global_helper/ImagePickerComponent.dart';
import '../../global_helper/dropdown.dart';
import '../../global_helper/loading_placeholder/home_layout.dart';
import '../../global_helper/reuse_widget.dart';
import 'package:multi_dropdown/multi_dropdown.dart';
import 'package:geolocator/geolocator.dart';
import 'package:http/http.dart' as http;

class Language {
  final String name;
  final int id;

  Language({required this.name, required this.id});
  @override
  String toString() {
    return 'Language(name: $name, id: $id)';
  }
}

class RegisterForm extends StatefulWidget {
  final String mobileNumber;
  final String userType;
  const RegisterForm(
      {super.key, required this.mobileNumber, required this.userType});

  @override
  State<RegisterForm> createState() => _RegisterFormState();
}

class _RegisterFormState extends State<RegisterForm> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _enterName = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController experienceController = TextEditingController();
  final TextEditingController chargesController = TextEditingController();
  final TextEditingController bioController = TextEditingController();
  final TextEditingController pinCodeController = TextEditingController();
  final TextEditingController ageController = TextEditingController();
  final controller = MultiSelectController<Language>();
  List<File> _selectedImages = [];
  late InitialRegisterBloc initialRegisterBloc;
  late ProfessionalBloc professionalBloc;
  late String profilePicture;
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
  String? _selectedGender = 'male';
  String? selectedExperence = 'Year';
  String? selectedCharge = 'Per Day';
  List<Language> selectedLanguage = [];
  bool isSubmitButtonEnabled = false;
  bool imagesList = false;
  bool loading = false;
  List<String> workImages = [];
  bool _isLoadingMap = false;
  String? latitude = "0.0";
  String? longitude = "0.0";
  bool cityLoading = true;
  List<String> dropdownCityItem = [];
  bool feesChargesLoading = true;
  List<String> feesChargesItem = [];
  bool knowLanguageLoading = true;
  List<DropdownItem<Language>> knownLanguageItems = [];
  bool professionalTypesLoading = true;
  List<String> professionalTypesItem = [];
  bool profileSelected =false;
  bool nameSelected =false;
  bool emailSelected =false;
  bool pincodeSelected =false;
  bool professionalSelected =false;
  bool experienceSelected =false;
  bool chargesSelected =false;
  bool ageSelected =false;
  bool languageSelected =false;
  bool bioSelected =false;
  bool imagesSelected =false;
  bool citySelected = false;

  void _validateForm() {

    bool isValid = false;

    if (widget.userType != 'jobs' &&
        _enterName.text.isNotEmpty &&
        (_selectedCity?.isNotEmpty ?? false) &&
        pinCodeController.text.isNotEmpty &&
        bioController.text.isNotEmpty ) {
      isValid = true;
    }

    if (widget.userType == 'jobs' &&
        _enterName.text.isNotEmpty &&
        (_selectedCity?.isNotEmpty ?? false) &&
        (_selectedProfession?.isNotEmpty ?? false) &&
        experienceController.text.isNotEmpty &&
        chargesController.text.isNotEmpty &&
        (_selectedGender != null) &&
        bioController.text.isNotEmpty &&
        pinCodeController.text.isNotEmpty &&
        ageController.text.isNotEmpty &&
        selectedLanguage.isNotEmpty ) {
      isValid = true;
    }

    setState(() {
      isSubmitButtonEnabled = isValid;
    });
  }


  void _submitButton() {
    if (_profileImage == null) {
      const snackBar = SnackBar(
        backgroundColor: COLORS.semantic,
        content: Text(
          'Profile picture required',
          style: TextStyle(
            color: COLORS.white,
            fontWeight: FontWeight.w400,
            fontFamily: "Poppins",
          ),
        ),
      );
      ScaffoldMessenger.of(context).showSnackBar(snackBar);
    }  else {
      if (isSubmitButtonEnabled == true) {
        List<String> languageSelect =
            selectedLanguage.map((lang) => lang.name).toList();
        initialRegisterBloc.add(RegisterAccountEvent(
          name: _enterName.text,
          age: widget.userType == 'jobs' ? ageController.text : null,
          profile_pic: profilePicture,
          email: _emailController.text,
          user_type:
              widget.userType == 'jobs' ? 'professional' : 'non_professional',
          profession_type:
              widget.userType == 'jobs' ? _selectedProfession : null,
          pincode: pinCodeController.text,
          city: _selectedCity!,
          gender:
              widget.userType == 'jobs' ? _selectedGender!.toLowerCase() : null,
          known_languages: widget.userType == 'jobs' ? languageSelect : null,
          workImages: workImages,
          bio: bioController.text,
          experienced_years:
              widget.userType == 'jobs' ? experienceController.text : null,
          charges: widget.userType == 'jobs' ? chargesController.text : null,
          charge_type:
              widget.userType == 'jobs' ? selectedCharge?.toLowerCase() : null,
          userLongitude: longitude ?? '0.0',
          userLatitude: longitude ?? '0.0',
        ));
        // Navigator.push(
        //   context,
        //   MaterialPageRoute(
        //       builder: (BuildContext context) => const LoginSuccess()),
        // );
      } else {
        _validateForm();
      }
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
  void initState() {
    super.initState();
    profilePicture = "";
    initialRegisterBloc = BlocProvider.of<InitialRegisterBloc>(context);
    professionalBloc = BlocProvider.of<ProfessionalBloc>(context);
  }

  String? _onPinCodeChanged(String? value) {
    if (value != null && value.length == 6) {
      FocusScope.of(context).unfocus();
      getLatLngFromPinCode(value).then((latLng) {
        setState(() {
          latitude = latLng['lat']?.toString();
          longitude = latLng['lng']?.toString();
        });

        print('Latitude: $latitude, Longitude: $longitude');
      });
    }
    return null;
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
        appBar: customAppBar(
            context: context, onSkipPressed: () {}, skipVisible: true),
        body: SafeArea(
          child: MultiBlocListener(
            listeners: [
              BlocListener<InitialRegisterBloc, InitialRegisterState>(
                listener: (context, state) {
                  if (state is InitialRegisterLoading) {
                    loading = true;
                  } else if (state is UploadImageSuccess) {
                    loading = false;
                    profilePicture = state.filePath;
                    profileSelected = true;
                  } else if (state is UploadMultipleImageSuccess) {
                    loading = false;
                    workImages.add(state.filePath);
                  } else if (state is UploadImageFailed) {
                    loading = false;
                    showCustomSnackBar(
                      context: context,
                      message: state.message,
                    );
                  } else if (state is InitialRegisterFailed) {
                    loading = false;
                    showCustomSnackBar(
                      context: context,
                      message: state.message,
                    );
                  } else if (state is InitialRegisterSuccess) {
                    setState(() {
                      loading = false;
                    });
                    // showCustomSnackBar(
                    //     context: context,
                    //     message: "Registered Successfully",
                    //     backgroundColor: COLORS.semanticTwo);
                    Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(
                        builder: (BuildContext context) => const LoginSuccess(),
                      ),
                    );
                  } else if (state is FetchCityLoading) {
                    setState(() {
                      cityLoading = true;
                    });
                  } else if (state is FetchChargeFeesLoading) {
                    setState(() {
                      feesChargesLoading = true;
                    });
                  } else if (state is FetchCitySuccess) {
                    setState(() {
                      dropdownCityItem =
                          state.dropDownItems.map((item) => item.city).toList();
                      cityLoading = false;
                    });
                  } else if (state is FetchCityFailed) {
                    setState(() {
                      cityLoading = false;
                    });
                  } else if (state is FetchChargeFeesSuccess) {
                    setState(() {
                      feesChargesItem = state.fetchChargeFeesItems
                          .map((item) => item.type)
                          .toList();
                      feesChargesLoading = false;
                    });
                  } else if (state is FetchChargeFeesFailed) {
                    setState(() {
                      feesChargesLoading = false;
                    });
                  }
                  if (state is FetchDropDownLoading) {
                    setState(() {
                      knowLanguageLoading = true;
                    });
                  } else if (state is FetchKnownLanguageSuccess) {
                    setState(() {
                      knownLanguageItems =
                          state.dropDownItems.asMap().entries.map((entry) {
                        int index = entry.key + 1;
                        var item = entry.value;
                        return DropdownItem(
                            label: item.language,
                            value: Language(name: item.language, id: index));
                      }).toList();
                      knowLanguageLoading = false;
                    });
                  }
                  setState(() {});
                },
              ),
              BlocListener<ProfessionalBloc, ProfessionalState>(
                listener: (context, state) {
                  if (state is FetchCategoryListLoading) {
                    setState(() {
                      professionalTypesLoading = true;
                    });
                  } else if (state is FetchCategoryListSuccess) {
                    setState(() {
                      professionalTypesItem =
                          state.categories.map((item) => item.name).toList();

                      professionalTypesLoading = false;
                    });
                  } else if (state is FetchCategoryListFailed) {
                    setState(() {
                      professionalTypesLoading = false;
                    });
                  }
                  setState(() {});
                },
              ),
            ],
            child: SingleChildScrollView(
              child: Container(
                  width: SizeConfig.screenWidth,
                  padding: EdgeInsets.all(SizeConfig.blockWidth * 4.5),
                  child: Form(
                    key: _formKey,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _buildTitle(),
                        _buildProfilePicture(),
                        _buildTextField(
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
                              if(value!.isNotEmpty){
                                setState(() {
                                  nameSelected = true;
                                });
                              }
                              else{
                                setState(() {
                                  nameSelected = false;
                                });
                              }
                            },
                            title: 'name'.tr(),
                            color: nameSelected?COLORS.neutralDarkOne:COLORS.neutralDark,
                            fontWeight: nameSelected?FontWeight.w400:FontWeight.w500
                        ),
                        _buildMobileNumber(),
                        _buildTextField(
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
                              if(value!.isNotEmpty){
                                setState(() {
                                  emailSelected = true;
                                });
                              }
                              else{
                                setState(() {
                                  emailSelected = false;
                                });
                              }
                            },
                            title: 'email'.tr(),
                            color: emailSelected?COLORS.neutralDarkOne:COLORS.neutralDark,
                            fontWeight: emailSelected?FontWeight.w400:FontWeight.w500
                        ),
                        buildTextField(
                          label: 'Pincode',
                          inputNameType: TextInputType.phone,
                          maxLength: 6,
                          controller: pinCodeController,
                          hintText: _isLoadingMap
                              ? "Fetching current pincode..."
                              : "Enter your pincode".tr(),
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              setState(() => pinError = true);
                              return 'Please enter a pincode'.tr();
                            } else if (value!.length != 6) {
                              setState(() => pinError = true);
                              return 'Please enter valid pincode'.tr();
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
                          onTap: () async {},
                          error: pinError,
                          onChanged: (value) {
                            _onPinCodeChanged(value);
                            if(value!.isNotEmpty){
                              setState(() {
                                pincodeSelected = true;
                              });
                            }
                            else{
                              setState(() {
                                pincodeSelected = false;
                              });
                            }
                            return null;
                          },
                          title: 'Pincode'.tr(),
                            color: pincodeSelected?COLORS.neutralDarkOne:COLORS.neutralDark,
                            fontWeight: pincodeSelected?FontWeight.w400:FontWeight.w500
                        ),
                        buildDropdown(
                          label: 'city'.tr(),
                          hintText: 'Select your city'.tr(),
                          items: dropdownCityItem,
                          onChanged: (value) => setState(() {
                            _selectedCity = value;
                            citySelected = true;
                            _validateForm();
                          }),
                          itemLoading: cityLoading,
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Please select your city'.tr();
                            }
                            return null;
                          },
                            color: citySelected?COLORS.neutralDarkOne:COLORS.neutralDark,
                            fontWeight: citySelected?FontWeight.w400:FontWeight.w500
                        ),
                        if (widget.userType == 'jobs') ...[
                          SizedBox(height: SizeConfig.blockHeight),
                          buildDropdown(
                            label: 'profession_type'.tr(),
                            hintText: 'Select your Profession'.tr(),
                            items: professionalTypesItem,
                            onChanged: (value) => setState(() {
                              _selectedProfession = value;
                              profileSelected = true;
                              _validateForm();
                            }),
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return 'Please select your profession'.tr();
                              }
                              return null;
                            },
                            itemLoading: professionalTypesLoading,
                              color: profileSelected?COLORS.neutralDarkOne:COLORS.neutralDark,
                              fontWeight: profileSelected?FontWeight.w400:FontWeight.w500
                          )
                        ],
                        if (widget.userType == 'jobs') ...[
                          SizedBox(height: SizeConfig.blockHeight),
                          registerText(text: 'years_of_experience'.tr(),
                              color: experienceSelected?COLORS.neutralDarkOne:COLORS.neutralDark,
                              fontWeight: experienceSelected?FontWeight.w400:FontWeight.w500
                          ),
                          normalTextField(
                              hintText: "Experience".tr(),
                              controller: experienceController,
                              inputType: TextInputType.number,
                              maxLength: 4,
                              inputFormatters: [
                                FilteringTextInputFormatter.allow(RegExp(r'^\d*\.?\d{0,2}$')),
                              ],
                              onChanged: (value) {
                                _validateForm();
                                if(value!.isNotEmpty){
                                  setState(() {
                                    experienceSelected = true;
                                  });
                                }
                                else{
                                  setState(() {
                                    experienceSelected = false;
                                  });
                                }
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
                              suffix: true,
                              prefix: false,
                              hasError: yearError,

                          ),
                          SizedBox(height: SizeConfig.blockHeight),
                        ],
                        if (widget.userType == 'jobs') ...[
                          registerText(text: 'charges_daily_wages'.tr(),
                              color: chargesSelected?COLORS.neutralDarkOne:COLORS.neutralDark,
                              fontWeight: chargesSelected?FontWeight.w400:FontWeight.w500
                          ),
                          normalTextField(
                            hintText: "Charges".tr(),
                            controller: chargesController,
                            inputType: TextInputType.number,
                            maxLength: 7,
                            inputFormatters: [
                              FilteringTextInputFormatter.digitsOnly,
                            ],
                            onChanged: (value) {
                              _validateForm();
                              if(value!.isNotEmpty){
                                setState(() {
                                  chargesSelected = true;
                                });
                              }
                              else{
                                setState(() {
                                  chargesSelected = false;
                                });
                              }
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
                                if (feesChargesLoading) ...[
                                  Padding(
                                    padding: EdgeInsets.symmetric(
                                        horizontal: SizeConfig.blockWidth * 4),
                                    child:
                                        LoadingAnimationWidget.discreteCircle(
                                      color: COLORS.accent,
                                      size: SizeConfig.blockWidth * 4,
                                    ),
                                  )
                                ],
                                if (!feesChargesLoading) ...[
                                  Container(
                                    constraints: BoxConstraints(
                                      maxWidth: SizeConfig.blockWidth *
                                          35, // Add constraints
                                    ),
                                    padding: EdgeInsets.only(right: SizeConfig.blockWidth*3),
                                    child: CustomDropdownButtonFormField(
                                      selectedValue: selectedCharge,
                                      items: feesChargesItem,
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
                                ]
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
                        if (widget.userType == 'jobs') ...[
                          SizedBox(height: SizeConfig.blockHeight * 0.5),
                          // buildGenderSelection(
                          //   groupValue: _selectedGender,
                          //   onChanged: (value) {
                          //     setState(() {
                          //       _selectedGender = value;
                          //     });
                          //   },
                          // ),
                          buildDynamicRadioSelection(
                            options: [
                              {'label': 'Male', 'value': 'male'},
                              {'label': 'Female', 'value': 'female'},

                            ],
                            onChanged: (value) => setState(() {
                              _selectedGender = value;
                            }),
                            groupValue: _selectedGender,
                            title: 'select_gender'.tr(),
                              color: COLORS.neutralDarkOne,
                              fontWeight: FontWeight.w400
                          ),
                        ],
                        if (widget.userType == 'jobs') ...[
                          SizedBox(height: SizeConfig.blockHeight),
                          registerText(text: 'Age'.tr(),
                              color: ageSelected?COLORS.neutralDarkOne:COLORS.neutralDark,
                              fontWeight: ageSelected?FontWeight.w400:FontWeight.w500
                          ),
                          normalTextField(
                              hintText: "Enter your age".tr(),
                              controller: ageController,
                              maxLength: 2,
                              inputType: TextInputType.number,
                              inputFormatters: [
                                FilteringTextInputFormatter.digitsOnly,
                              ],
                              onChanged: (value) {
                                _validateForm();
                                if(value!.isNotEmpty){
                                  setState(() {
                                    ageSelected = true;
                                  });
                                }
                                else{
                                  setState(() {
                                    ageSelected = false;
                                  });
                                }
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
                                    alignment: Alignment.center,
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
                                      'Years',
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
                        if (widget.userType == 'jobs') ...[
                          SizedBox(height: SizeConfig.blockHeight),
                          registerText(text: 'known_language'.tr(),
                              color: languageSelected?COLORS.neutralDarkOne:COLORS.neutralDark,
                              fontWeight: languageSelected?FontWeight.w400:FontWeight.w500
                          ),
                          if (!knowLanguageLoading) ...[
                            MultiDropdown<Language>(
                              items: knownLanguageItems,
                              controller: controller,
                              enabled: true,
                              searchEnabled: false,
                              closeOnBackButton: true,
                              dropdownDecoration: DropdownDecoration(
                                  maxHeight: SizeConfig.blockHeight * 30,
                                  elevation: SizeConfig.blockWidth * 5,
                                  marginTop: SizeConfig.blockHeight,
                                  backgroundColor: COLORS.white),
                              chipDecoration: ChipDecoration(
                                  backgroundColor:
                                      COLORS.primary.withOpacity(0.05),
                                  wrap: true,
                                  labelStyle: TextStyle(
                                      color: COLORS.primary,
                                      fontWeight: FontWeight.w500,
                                      fontFamily: "Poppins",
                                      fontSize: SizeConfig.blockWidth * 3.25),
                                  runSpacing: 8,
                                  spacing: 10,
                                  borderRadius: BorderRadius.circular(
                                      SizeConfig.blockWidth * 2),
                                  deleteIcon: Icon(
                                    Icons.clear,
                                    color: COLORS.black,
                                    size: SizeConfig.blockWidth * 4,
                                  )),
                              fieldDecoration: FieldDecoration(
                                animateSuffixIcon: true,
                                borderRadius:  SizeConfig.blockWidth * 4,
                                padding: EdgeInsets.only(
                                  top: SizeConfig.blockHeight * 2.7,
                                  bottom: SizeConfig.blockHeight * 2.7,
                                  left: SizeConfig.blockWidth * 4,
                                  right: SizeConfig.blockWidth * 3,
                                ),
                                suffixIcon: Icon(
                                  Icons.keyboard_arrow_down_outlined,
                                  color: COLORS.accent,
                                  size: SizeConfig.blockWidth * 6,
                                ),
                                hintText: 'Select Languages'.tr(),
                                hintStyle: TextStyle(
                                  color: COLORS.neutralDarkOne,
                                  fontWeight: FontWeight.w400,
                                  fontFamily: "Poppins",
                                  fontSize: SizeConfig.blockWidth * 3.2,
                                ),
                                backgroundColor: COLORS.white,
                                showClearIcon: true,
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(
                                      SizeConfig.blockWidth * 4),
                                  borderSide: const BorderSide(
                                      color: COLORS.neutralDarkTwo),
                                ),
                                focusedBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(
                                      SizeConfig.blockWidth * 4),
                                  borderSide: const BorderSide(
                                    color: COLORS.neutralDarkTwo,
                                  ),
                                ),
                              ),
                              dropdownItemDecoration: DropdownItemDecoration(
                                backgroundColor: COLORS.white,
                                textColor: COLORS.neutralDark,
                                selectedIcon: Icon(
                                  Icons.check,
                                  color: COLORS.accent,
                                  size: SizeConfig.blockWidth * 5,
                                ),
                                selectedTextColor: COLORS.neutralDark,
                                disabledTextColor: COLORS.neutralDark,
                                disabledIcon: Icon(Icons.lock,
                                    color: Colors.grey.shade300),
                              ),
                              validator: (value) {
                                if (value == null || value.isEmpty) {
                                  return 'Please select a language'.tr();
                                }
                                return null;
                              },
                              onSelectionChange: (selectedItems) {
                                selectedLanguage = selectedItems;
                                debugPrint("OnSelectionChange: $selectedItems");
                                setState(() {
                                  languageSelected = true;
                                });
                                _validateForm();
                              },
                            )
                          ],
                          if (knowLanguageLoading) ...[
                            dropDownLoader(hintText: 'Select Languages')
                          ],

                          SizedBox(
                            height: SizeConfig.blockHeight * 2.5,
                          ),
                          _buildBioTextField(
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
                                if(value!.isNotEmpty){
                                  setState(() {
                                    bioSelected = true;
                                  });
                                }
                                else{
                                  setState(() {
                                    bioSelected = false;
                                  });
                                }
                              },
                              title: 'Bio'.tr(),
                              color: bioSelected?COLORS.neutralDarkOne:COLORS.neutralDark,
                              fontWeight: bioSelected?FontWeight.w400:FontWeight.w500
                          ),


                          MultipleImagePickerComponent(
                            onImagesSelected: _onImagesSelected,
                            error: imagesList,
                            removeImage: _removeImage,
                          ),
                        ],

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
                  if(isSubmitButtonEnabled) {
                    if (_formKey.currentState!.validate()) {
                      _submitButton();
                    }
                  }

                },
                backgroundColor: isSubmitButtonEnabled
                    ? COLORS.primary
                    : COLORS.primary.withOpacity(0.4),
                showIcon: false,
                width: SizeConfig.blockWidth * 42,
                height: SizeConfig.blockHeight * 8,
                textColor: COLORS.white,
              )
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTitle() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'create_account'.tr(),
          style: TextStyle(
            color: COLORS.neutralDark,
            fontSize: SizeConfig.blockWidth * 4.25,
            fontWeight: FontWeight.w500,
            fontFamily: "Poppins",
          ),
        ),
        SizedBox(height: SizeConfig.blockHeight * 0.5),
        Text(
          'reg_sub'.tr(),
          style: TextStyle(
            color: COLORS.neutralDarkOne,
            fontSize: SizeConfig.blockWidth * 3.25,
            fontWeight: FontWeight.w400,
            fontFamily: "Poppins",
          ),
        ),
        SizedBox(height: SizeConfig.blockHeight * 3),
      ],
    );
  }

  Widget _buildProfilePicture() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.start,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        registerText(text: 'profile_picture'.tr(),color: profileSelected?COLORS.neutralDarkOne:COLORS.neutralDark,
        fontWeight: profileSelected?FontWeight.w400:FontWeight.w500
        ),
        _profileImage == null
            ? ImagePickerComponent(
                onImageSelected: (File image) {
                  setState(() {
                    print(image);
                    _profileImage = image;
                    initialRegisterBloc
                        .add(UploadImageEvent(imagePath: _profileImage!));
                  });
                },
              )
            : Stack(
                children: [
                  Container(
                    height: SizeConfig.blockWidth * 32,
                    width: SizeConfig.blockWidth * 34,
                    decoration: BoxDecoration(
                        border: Border.all(
                          color: COLORS.primary,
                          width: 1.2,
                        ),
                        image: DecorationImage(
                          image: FileImage(
                            File(_profileImage!.path),
                          ),
                          fit: BoxFit.fill,
                        ),
                        borderRadius:
                            BorderRadius.circular(SizeConfig.blockWidth * 3.5)),
                  ),
                  Positioned(
                    bottom: 0,
                    right: 0,
                    child: ImagePickerModal(
                      onImageSelected: (File image) {
                        setState(() {
                          _profileImage = image;
                        });
                      },
                    ),
                  )
                ],
              ),
        SizedBox(height: SizeConfig.blockHeight * 3),
      ],
    );
  }

  Widget _buildTextField(
      {required String label,
      required TextEditingController controller,
      required String hintText,
      required String? Function(String?) validator,
      required String? Function(String?) onChanged,
      required bool error,
      required String title,
        Color? color = COLORS.neutralDark,
        FontWeight? fontWeight = FontWeight. w500,
      }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        registerText(text: title,color: color,fontWeight: fontWeight),
        normalTextField(
          hintText: hintText,
          controller: controller,
          inputType: TextInputType.text,
          onChanged: onChanged,
          validator: validator,
          fontWeight: FontWeight.w400,
          prefix: false,
          errorMessage: '',
          hasError: error,
        ),
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
                    widget.mobileNumber,
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

  Widget _buildBioTextField(
      {required String label,
      required TextEditingController controller,
      required String hintText,
      required String? Function(String?) validator,
      required String? Function(String?) onChanged,
      required bool error,
      required String title,
        Color? color = COLORS.neutralDark,
        FontWeight? fontWeight = FontWeight. w500,
      }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        registerText(text: title,color: color,fontWeight: fontWeight),
        normalTextField(
            hintText: hintText,
            controller: controller,
            inputType: TextInputType.text,
            onChanged: onChanged,
            validator: validator,
            fontWeight: FontWeight.w400,
            prefix: false,
            errorMessage: '',
            hasError: error,
            maxLines: 6),
      ],
    );
  }
}
