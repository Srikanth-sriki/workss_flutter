import 'dart:io';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';
import 'package:works_app/bloc/profile/profile_bloc.dart';
import 'package:works_app/bloc/register_account/initial_register_bloc.dart';
import 'package:works_app/dao/get_user_location.dart';
import 'package:works_app/models/fetch_profile_model.dart';
import 'package:works_app/ui/profile/component.dart';
import '../../bloc/professional/professional_bloc.dart';
import '../../components/colors.dart';
import '../../components/config.dart';
import '../../components/size_config.dart';
import '../../global_helper/ImagePickerComponent.dart';
import '../../global_helper/dropdown.dart';
import '../../global_helper/loading_placeholder/home_layout.dart';
import '../../global_helper/reuse_widget.dart';
import 'package:multi_dropdown/multi_dropdown.dart';

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
  late ProfessionalBloc professionalBloc;
  bool loading = false;
  final TextEditingController _enterName = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController experienceController = TextEditingController();
  final TextEditingController chargesController = TextEditingController();
  final TextEditingController bioController = TextEditingController();
  final TextEditingController pinCodeController = TextEditingController();
  final TextEditingController ageController = TextEditingController();
  late MultiSelectController<Language> controller;
  final langKey = languageCodeToTranslationKey[Config.languageSelected] ?? 'english';

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
  bool cityLoading = true;
  bool pinCodeLoading = true;
  List<String> dropdownCityItem = [];
  bool feesChargesLoading = true;
  List<String> feesChargesItem = [];
  bool knowLanguageLoading = true;
  List<DropdownItem<Language>> knownLanguageItems = [];
  bool professionalTypesLoading = true;
  List<String> professionalTypesItem = [];
  String? _selectedPinCode;
  Map<String, String> cityMap = {};
  bool citySelected = false;
  List<String> pinCodeListItem = [];
  bool pincodeSelected = false;

  void _validateForm() {}

  // String? formatChargeType(String? chargeType) {
  //   print(chargeType);
  //   switch (chargeType!.toLowerCase()) {
  //     case 'hourly':
  //       return 'Hourly';
  //     case 'perday':
  //       return 'Per Day';
  //     case 'monthly':
  //       return 'Monthly';
  //     default:
  //       return null;
  //   }
  // }

  String capitalizeWords(String input) {
    if (input.isEmpty) return input;
    return input
        .split(' ')
        .map((word) => word[0].toUpperCase() + word.substring(1).toLowerCase())
        .join(' ');
  }

  @override
  void initState() {
    super.initState();
    profileBloc = BlocProvider.of<ProfileBloc>(context);
    initialRegisterBloc = BlocProvider.of<InitialRegisterBloc>(context);
    professionalBloc = BlocProvider.of<ProfessionalBloc>(context);
    controller = MultiSelectController<Language>();
    initialData();
  }

  void initialData() {
    profilePic = widget.profileFetch.profilePic!;
    _enterName.text = widget.profileFetch.name!;
    _emailController.text = widget.profileFetch.email!;
    // pinCodeController.text = widget.profileFetch.pincode.toString()!;
    _selectedCity = widget.profileFetch.city!;
    _selectedPinCode= widget.profileFetch.pincode.toString();
    profilePicture = widget.profileFetch.profilePic!;
    workImages = widget.profileFetch.workImages!;
    bioController.text =
        widget.profileFetch.bio!.isEmpty ? "" : widget.profileFetch.bio!;
    if (widget.profileFetch.userType == 'professional') {
      experienceController.text = widget.profileFetch.userType == 'professional'
          ? widget.profileFetch.experiencedYears!
          : '';
      chargesController.text = widget.profileFetch.userType == 'professional'
          ? widget.profileFetch.charges!
          : "";

      ageController.text = widget.profileFetch.userType == 'professional'
          ? widget.profileFetch.age.toString()!
          : '';
      _selectedProfession = widget.profileFetch.userType == 'professional'
          ? widget.profileFetch.professionType!
          : '';
      _selectedGender = widget.profileFetch.userType == 'professional'
          ? widget.profileFetch.gender!
          : '';
      selectedLanguage = widget.profileFetch.userType == 'professional'
          ? convertLanguages(widget.profileFetch.knownLanguages!)
          : [];
      selectedCharge = widget.profileFetch.userType == 'professional'
          ? capitalizeWords(widget.profileFetch.chargeType!)
          : null;

      print(selectedCharge);
      print(widget.profileFetch.chargeType!);
    }
  }

  List<Language> convertLanguages(List<String> knownLanguages) {
    return List.generate(knownLanguages.length, (index) {
      return Language(
        name: knownLanguages[index],
        id: index + 1, // Assigning a dynamic ID starting from 1
      );
    });
  }

  void knownLanguageUpdate() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      List<DropdownItem<Language>> item = knownLanguageItems;
      controller.setItems(item);
      controller.selectWhere((item) =>
          widget.profileFetch.knownLanguages!.contains(item.value.name));
    });
    selectedLanguage = convertLanguages(widget.profileFetch.knownLanguages!);
    print(selectedLanguage);
  }

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
    }  else if ((selectedCharge == '' || selectedCharge == null) &&
        widget.profileFetch.userType == 'professional') {
    } else {
      List<String> languageSelect =
          selectedLanguage.map((lang) => lang.name).toList();
      profileBloc.add(EditProfileAccount(
        name: _enterName.text,
        age: widget.profileFetch.userType == 'professional'
            ? ageController.text
            : '0',
        profile_pic: profilePicture!,
        email: _emailController.text,
        user_type: widget.profileFetch.userType!,
        profession_type: widget.profileFetch.userType == 'professional'
            ? _selectedProfession
            : null,
        pincode: _selectedPinCode,
        city: _selectedCity!,
        gender: widget.profileFetch.userType == 'professional'
            ? _selectedGender?.toLowerCase()
            : null,
        known_languages: widget.profileFetch.userType == 'professional'
            ? languageSelect
            : [],
        workImages: workImages,
        bio: bioController.text,
        experienced_years: widget.profileFetch.userType == 'professional'
            ? experienceController.text
            : null,
        charges: widget.profileFetch.userType == 'professional'
            ? chargesController.text
            : null,
        charge_type: widget.profileFetch.userType == 'professional'
            ? selectedCharge?.toLowerCase()
            : null,
        userLongitude: longitude ?? '0.0',
        userLatitude: longitude ?? '0.0',
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
      }
      if (index >= 0 && index < workImages.length) {
        workImages.removeAt(index);
      }
    });
  }

  String? _onPinCodeChanged(String? value) {
    if (value != null && value.length == 6) {
      getLatLngFromPinCode(value).then((latLng) {
        setState(() {
          latitude = latLng['lat']?.toString();
          longitude = latLng['lng']?.toString();
          loading = false;
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
                  FocusScopeNode currentFocus = FocusScope.of(context);
                  if (!currentFocus.hasPrimaryFocus) {
                    currentFocus.unfocus();
                  }
                  loading = false;
                  workImages.add(state.filePath);
                } else if (state is UploadImageFailed) {
                  FocusScopeNode currentFocus = FocusScope.of(context);
                  if (!currentFocus.hasPrimaryFocus) {
                    currentFocus.unfocus();
                  }
                  loading = false;
                  showCustomSnackBar(
                    context: context,
                    message: state.message,
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
                    cityMap = {
                      for (var city in state.dropDownItems)
                        city.city: city.id,
                    };
                    dropdownCityItem = cityMap.keys.toList();
                    cityLoading = false;

                    if (widget.profileFetch.city != null && widget.profileFetch.city!.isNotEmpty) {
                      _selectedCity = widget.profileFetch.city!;
                      final selectedCityId = cityMap[_selectedCity];

                      if (selectedCityId != null) {
                        initialRegisterBloc.add(FetchPinListEvent(cityId: selectedCityId));
                      } else {
                        print("City '${_selectedCity}' not found in cityMap.");
                      }
                    }
                  });
                }
                else if (state is FetchCityFailed) {
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
                else if (state is FetchPinListLoading) {
                  setState(() {
                    pinCodeLoading = true;
                  });
                } else if (state is FetchPinListSuccess) {
                  setState(() {
                    pinCodeListItem = state.dropDownItems
                        .map((item) => item.pincode)
                        .toList();
                    pinCodeLoading = false;
                  });
                } else if (state is FetchPinListFailed) {
                  setState(() {
                    pinCodeLoading = false;
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
                    knownLanguageUpdate();
                  });
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
                  showCustomSnackBar(
                    context: context,
                    message: state.message,
                    backgroundColor: COLORS.semanticTwo
                  );
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
            ),
            BlocListener<ProfessionalBloc, ProfessionalState>(
              listener: (context, state) {
                if (state is FetchCategoryListLoading) {
                  setState(() {
                    professionalTypesLoading = true;
                  });
                } else if (state is FetchCategoryListSuccess) {
                  setState(() {
                    // professionalTypesItem =
                    //     state.categories.map((item) => item.name).toList();

                    professionalTypesItem = state.categories.map((item) {
                      final translated = item.translation?.getTranslation(langKey);
                      return translated?.isNotEmpty == true ? translated! : item.name;
                    }).toList();
                    if (widget.profileFetch.userType == 'professional') {
                      final matchedCategory = state.categories.firstWhere(
                            (item) => item.name == widget.profileFetch.professionType,
                      );
                      final translated = matchedCategory.translation?.getTranslation(langKey);
                      _selectedProfession = translated?.isNotEmpty == true ? translated! : matchedCategory.name;
                    }
                    else {
                      _selectedProfession = '';
                    }
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
                            title: 'name'.tr(),color: COLORS.neutralDarkOne,fontWeight: FontWeight.w400),
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
                            title: 'email'.tr(),color: COLORS.neutralDarkOne,fontWeight: FontWeight.w400),
                        // buildTextField(
                        //   label: 'Pincode',
                        //   inputNameType: TextInputType.phone,
                        //   controller: pinCodeController,
                        //   maxLength: 6,
                        //   hintText: "Enter your pincode".tr(),
                        //   validator: (value) {
                        //     if (value == null || value.isEmpty) {
                        //       setState(() => pinError = true);
                        //       return 'Please enter a pincode'.tr();
                        //     } else if (value!.length != 6) {
                        //       setState(() => pinError = true);
                        //       return 'Please enter valid pincode'.tr();
                        //     }
                        //     setState(() => pinError = false);
                        //     return null;
                        //   },
                        //   prefix: true,
                        //   prefixIcon: _isLoadingMap
                        //       ? Container(
                        //           height: SizeConfig.blockHeight,
                        //           width: SizeConfig.blockHeight,
                        //           padding: EdgeInsets.all(
                        //               SizeConfig.blockWidth * 3.5),
                        //           child: CircularProgressIndicator(
                        //               strokeWidth: SizeConfig.blockWidth * 0.5,
                        //               color: COLORS.accent))
                        //       : null,
                        //   onTap: () async {},
                        //   error: pinError,
                        //   onChanged: (value) {
                        //     if (value!.length == 6) {
                        //       setState(() {
                        //         loading = true;
                        //       });
                        //     }
                        //
                        //     _onPinCodeChanged(value);
                        //     return null;
                        //   },
                        //   title: 'Pincode'.tr(),
                        //     color: COLORS.neutralDarkOne,fontWeight: FontWeight.w400
                        // ),
                        buildDropdown(
                          label: 'city'.tr(),
                          value: _selectedCity,
                          hintText: 'Select your city'.tr(),
                          items: dropdownCityItem,
                          itemLoading: cityLoading,color: COLORS.neutralDarkOne,fontWeight: FontWeight.w400,
                          onChanged: (value) => setState(() {
                            _selectedCity = value;
                            citySelected = true;
                            _selectedPinCode = null;
                            pincodeSelected = false;
                            pinCodeListItem = [];
                            pinCodeLoading = true;

                            initialRegisterBloc.add(FetchPinListEvent(
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

                        if (pinCodeLoading == true) ...[
                          registerText(
                              text: 'Pincode'.tr(), color: COLORS.neutralDark),
                          dropDownLoader(hintText: 'Select your city pincode')
                        ],
                        if (pinCodeLoading == false) ...[
                          buildDropdown(
                              label: 'Pincode'.tr(),
                              value: _selectedPinCode,
                              hintText: 'Select your city pincode'.tr(),
                              items: pinCodeListItem,
                              onChanged: (value) => setState(() {
                                _selectedPinCode = value;
                                setState(() {
                                  pincodeSelected = true;
                                  if(value!.isNotEmpty) {
                                    _onPinCodeChanged(value);
                                  }
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
                              color: COLORS.neutralDarkOne,fontWeight: FontWeight.w400),
                        ],
                        if (widget.profileFetch.userType == 'professional') ...[
                          SizedBox(height: SizeConfig.blockHeight),
                          buildDropdown(
                              value: _selectedProfession??null,
                              label: 'profession_type'.tr(),
                              hintText: 'Select your Profession'.tr(),
                              items: professionalTypesItem,
                              itemLoading: professionalTypesLoading,
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
                              color: COLORS.neutralDarkOne,fontWeight: FontWeight.w400
                          )

                        ],
                        if (widget.profileFetch.userType == 'professional') ...[
                          SizedBox(height: SizeConfig.blockHeight),
                          registerText(text: 'years_of_experience'.tr(),color: COLORS.neutralDarkOne,fontWeight: FontWeight.w400),
                          normalTextField(
                              hintText: "Experience".tr(),
                              controller: experienceController,
                              maxLength: 4,
                              inputFormatters: [
                                FilteringTextInputFormatter.allow(RegExp(r'^\d*\.?\d{0,2}$')),
                              ],
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
                              hasError: yearError),
                          SizedBox(height: SizeConfig.blockHeight),
                        ],
                        if (widget.profileFetch.userType == 'professional') ...[
                          registerText(text: 'charges_daily_wages'.tr(),color: COLORS.neutralDarkOne,fontWeight: FontWeight.w400),
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
                                      maxWidth: SizeConfig.blockWidth * 35, // Add constraints
                                    ),
                                    child: CustomDropdownButtonFormField(
                                      selectedValue: selectedCharge,
                                      items: feesChargesItem,
                                      onChanged: (String? newValue) {
                                        setState(() {
                                          selectedCharge = newValue;
                                        });
                                      },
                                      hintText: 'Select Duration',
                                      iconSize: SizeConfig.blockWidth * 6,
                                      iconColor: COLORS.accent,
                                    ),
                                  )
                                ],
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
                            color: COLORS.neutralDarkOne,
                            fontWeight: FontWeight.w400,
                            groupValue: _selectedGender,
                            onChanged: (value) {
                              setState(() {
                                _selectedGender = value;
                              });
                            },
                            textFontWeight: FontWeight.w400,
                            options: [
                              {'label': 'Male', 'value': 'male'},
                              {'label': 'Female', 'value': 'female'},
                            ],
                          ),
                        ],
                        if (widget.profileFetch.userType == 'professional') ...[
                          SizedBox(height: SizeConfig.blockHeight),
                          registerText(text: 'Age'.tr(),color: COLORS.neutralDarkOne,fontWeight: FontWeight.w400),
                          normalTextField(
                              hintText: "Enter your age".tr(),
                              controller: ageController,
                              inputType: TextInputType.number,
                              maxLength: 2,
                              inputFormatters: [
                                FilteringTextInputFormatter.digitsOnly,
                              ],
                              onChanged: (value) {
                                _validateForm();
                              },
                              validator: (value) {
                                if (value == null || value.isEmpty) {
                                  setState(() => ageError = true);
                                  return 'Please enter your age'.tr();
                                }

                                final age = int.tryParse(value);
                                if (age == null || age < 14) {
                                  setState(() => ageError = true);
                                  return 'Age must be 14 or above'.tr();
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
                          registerText(text: 'known_language'.tr(),color: COLORS.neutralDarkOne,fontWeight: FontWeight.w400),
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
                                if (selectedLanguage.isEmpty) {
                                  return 'Please select a language'.tr();
                                }
                                return null;
                              },
                              onSelectionChange: (selectedItems) {
                                selectedLanguage = selectedItems;
                                debugPrint("OnSelectionChange: $selectedItems");
                                _validateForm();
                              },
                            )
                          ],
                          if (knowLanguageLoading) ...[
                            dropDownLoader(hintText: 'Select Languages',)
                          ]
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
                            title: 'Bio'.tr(),maxLines: 6,color: COLORS.neutralDarkOne ,fontWeight: FontWeight.w400),
                        MultipleImagePickerComponent(
                          onImagesSelected: _onImagesSelected,
                          error: imagesList,
                          removeImage: _removeImage,
                          defaultImages: workImages,
                            color: COLORS.neutralDarkOne ,fontWeight: FontWeight.w400
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
                  widget.refreshPageCallback();
                  Navigator.pop(context);
                },
                backgroundColor: COLORS.neutralDarkTwo,
                showIcon: false,
                width: SizeConfig.blockWidth * 42,
                height: SizeConfig.blockHeight * 7.5,
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
                  height: SizeConfig.blockHeight * 7.5,
                  textColor: COLORS.white,
                  loading: loading)
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
        registerText(text: 'profile_picture'.tr(),color: COLORS.neutralDarkOne),

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
                    width: SizeConfig.blockWidth * 0.25,
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
        registerText(text: 'mobile_number_label'.tr(),color: COLORS.neutralDarkOne),
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
