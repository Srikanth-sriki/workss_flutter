import 'dart:io';
import 'dart:math';

import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:modal_bottom_sheet/modal_bottom_sheet.dart';
import 'package:multi_dropdown/multi_dropdown.dart';
import 'package:works_app/components/colors.dart';
import 'package:works_app/ui/onboarding/register_form.dart';
import 'package:works_app/ui/post_work/address_dropdown.dart';
import 'package:works_app/ui/post_work/post_work_success.dart';
import 'package:works_app/ui/profile/component.dart';
import 'package:geolocator/geolocator.dart';
import 'package:works_app/ui/profile/location/location_list_modal.dart';
import '../../bloc/post_work/post_work_bloc.dart';
import '../../bloc/professional/professional_bloc.dart';
import '../../bloc/profile/profile_bloc.dart';
import '../../components/config.dart';
import '../../components/size_config.dart';
import '../../dao/get_user_location.dart';
import '../../global_helper/ImagePickerComponent.dart';
import '../../global_helper/dropdown.dart';
import '../../global_helper/loading_placeholder/home_layout.dart';
import '../../global_helper/reuse_widget.dart';
import '../../models/dropDown_modal.dart';

class PostWorkScreen extends StatefulWidget {
  final bool arrowBack;
  const PostWorkScreen({super.key, required this.arrowBack});

  @override
  State<PostWorkScreen> createState() => _PostWorkScreenState();
}

class _PostWorkScreenState extends State<PostWorkScreen> {
  late PostWorkBloc postWorkBloc;
  late ProfileBloc profileBloc;
  late ProfessionalBloc professionalBloc;
  final _formKey = GlobalKey<FormState>();
  final controller = MultiSelectController<Language>();
  final TextEditingController bioController = TextEditingController();
  final TextEditingController addressController = TextEditingController();

  String? _selectedWorkPlace;
  String? _selectedWorkPlaceId;
  String? _selectedProfession;
  String? _selectedProfessionId;
  String? _selectedGender = 'Male';
  String? _experienceLevel = 'Any';
  List<Language> selectedLanguage = [];
  List<File> _selectedImages = [];
  List<String> workImages = [];
  bool isChecked = false;
  bool buttonVisible = false;
  bool bioError = false;
  bool imagesList = false;
  bool loading = false;
  bool _isLoadingMap = false;
  String? latitude = "0.0";
  String? longitude = "0.0";
  bool addressError = false;
  String addressId = '';
  String addressSelected = 'Select work location';
  bool workPlaceLoading = false;
  bool knowLanguageLoading = true;
  List<DropdownItemValue> dropdownWorkPlaceItem = [];
  List<DropdownItem<Language>> knownLanguageItems = [];
  bool professionalTypesLoading = true;
  List<DropdownItemValue> professionalTypesItem = [];
  late Map<String, String> translatedToProfessionalTypes;
  late Map<String, String> translatedToWorkPlaceItemTypes;
  bool professionalSelected = false;
  bool experienceLevelSelected = true;
  bool genderSelected = true;
  bool knownLangSelected = false;
  bool workAddressSelected = false;
  bool workPlaceSelected = false;
  bool workDetailsSelected = false;
  String citySelected = '';
  String pincodeSelected = '';
  String localitySelected = '';
  final langKey =
      languageCodeToTranslationKey[Config.languageSelected] ?? 'english';

  void _validateForm() {
    bool isValid = false;
    if ((_selectedProfession?.isNotEmpty ?? false) &&
        bioController.text.isNotEmpty &&
        (_experienceLevel?.isNotEmpty ?? false) &&
        selectedLanguage.isNotEmpty) {
      isValid = true;
    }
    setState(() {
      buttonVisible = isValid;
    });
  }

  void _onImagesSelected(List<File> images) {
    setState(() {
      _selectedImages = images;
      if (_selectedImages.isNotEmpty) {
        postWorkBloc.add(
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
    postWorkBloc = BlocProvider.of<PostWorkBloc>(context);
    profileBloc = BlocProvider.of<ProfileBloc>(context);
    professionalBloc = BlocProvider.of<ProfessionalBloc>(context);
    _fetchData();
  }

  void _fetchData() {
    professionalBloc.add(const FetchCategoryListEvent());
    postWorkBloc.add(const FetchWorkKnownLanguageEvent());
    postWorkBloc.add(const FetchWorkPlaceEvent());
  }

  void _submitButton() {
    // if (_selectedImages.isEmpty) {
    //   setState(() {
    //     imagesList = true;
    //   });
    // } else

    if (_experienceLevel == null) {
      showCustomSnackBar(
        context: context,
        message: "Please select experience level",
      );
    } else if (_selectedGender == null) {
      showCustomSnackBar(
        context: context,
        message: "Please select gender",
      );
    } else if (addressSelected == 'Select work location') {
      showCustomSnackBar(
        context: context,
        message: "Please select work address",
      );
    } else {
      List<String> languageSelect =
          selectedLanguage.map((lang) => lang.name).toList();
      postWorkBloc.add(CreatePostWorkEvent(
          requiredProfession: _selectedProfession!,
          experienceLevel: _experienceLevel!.toLowerCase(),
          gender: _selectedGender!.toLowerCase(),
          knowLanguage: languageSelect,
          location: addressSelected ?? '',
          workPlace: _selectedWorkPlace!.toLowerCase(),
          workImages: workImages,
          isProfessionalCanCall: isChecked,
          latitude: latitude!,
          longitude: longitude!,
          description: bioController.text,
          pincode: pincodeSelected,
          city: citySelected,
          locality: localitySelected,
          workPlaceId: _selectedWorkPlaceId!,
          profCategoryId: _selectedProfessionId!,
          localityId: '150630d5-694e-442d-8f9f-c0b7e8bd3672',
          cityId: '150630d5-694e-442d-8f9f-c0b7e8bd3672'
      ));
    }
  }

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

  @override
  void dispose() {
    bioController.dispose();
    addressController.dispose();
    _selectedWorkPlace = '';
    _selectedProfession = '';
    _selectedProfessionId='';
    _selectedWorkPlaceId = '';
    _selectedGender = null;
    _experienceLevel = null;
    selectedLanguage = [];
    _selectedImages = [];
    workImages = [];
    isChecked = false;
    buttonVisible = false;
    addressSelected = 'Select work location';
    super.dispose();
  }

  void clearData() async {
    setState(() {
      _selectedWorkPlace = null;
      _selectedProfession = null;
      _selectedGender = null;
      _experienceLevel = null;
      _selectedProfessionId=null;
      _selectedWorkPlaceId = null;
      selectedLanguage = [];
      _selectedImages = [];
      workImages = [];
      isChecked = false;
      buttonVisible = false;
      addressController.clear();
      bioController.clear();
      controller.clearAll();
      addressSelected = 'Select work location';
    });
  }

  String? workAddress;

  void updateWorkAddress(String? newAddress) {
    setState(() {
      workAddress = newAddress;
    });
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        clearData();
        return true;
      },
      child: GestureDetector(
        onTap: () {
          FocusScopeNode currentFocus = FocusScope.of(context);
          if (!currentFocus.hasPrimaryFocus) {
            currentFocus.unfocus();
          }
        },
        child: Scaffold(
          backgroundColor: COLORS.white,
          appBar: AppBar(
            backgroundColor: COLORS.primary,
            scrolledUnderElevation: 0,
            elevation: 0,
            automaticallyImplyLeading: false,
            toolbarHeight: SizeConfig.blockHeight * 11,
            title: Row(
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (widget.arrowBack) ...[
                  InkWell(
                    onTap: () {
                      Navigator.pop(context);
                    },
                    child: Padding(
                      padding:
                          EdgeInsets.only(top: SizeConfig.blockHeight * 0.5),
                      child: Icon(
                        Icons.arrow_back_ios_new,
                        color: COLORS.white,
                        size: SizeConfig.blockHeight * 2.5,
                      ),
                    ),
                  ),
                ],
                SizedBox(
                  width: SizeConfig.blockWidth * 2,
                ),
                Column(
                  mainAxisAlignment: MainAxisAlignment.start,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Post Work'.tr(),
                      style: TextStyle(
                        color: COLORS.white,
                        fontSize: SizeConfig.blockWidth * 4.6,
                        fontWeight: FontWeight.w400,
                        fontFamily: "Poppins",
                      ),
                    ),
                    Text(
                      'Hire professionals/workers for your work'.tr(),
                      style: TextStyle(
                        color: COLORS.primaryOne,
                        fontSize: SizeConfig.blockWidth * 3.5,
                        fontWeight: FontWeight.w400,
                        fontFamily: "Poppins",
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          body: SafeArea(
            child: MultiBlocListener(
              listeners: [
                BlocListener<PostWorkBloc, PostWorkState>(
                  listener: (context, state) {
                    if (state is PostWorkLoading) {
                      loading = true;
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
                    } else if (state is PostWorkSuccess) {
                      loading = false;
                      // showCustomSnackBar(
                      //     context: context,
                      //     message: state.message,
                      //     backgroundColor: COLORS.semanticTwo);
                      FocusScopeNode currentFocus = FocusScope.of(context);
                      if (!currentFocus.hasPrimaryFocus) {
                        currentFocus.unfocus();
                      }
                      clearData();
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (BuildContext context) =>
                              PostWorkSuccessScreen(
                            workId: state.workId,
                          ),
                        ),
                      );
                    } else if (state is PostWorkFailed) {
                      setState(() {
                        loading = false;
                      });
                      showCustomSnackBar(
                        context: context,
                        message: state.message,
                      );
                    } else if (state is FetchDropDownLoading) {
                      setState(() {
                        workPlaceLoading = true;
                        knowLanguageLoading = true;
                      });
                    } else if (state is FetchDropDownSuccess) {
                      setState(() {
                        workPlaceLoading = false;
                        translatedToWorkPlaceItemTypes = {};
                        dropdownWorkPlaceItem = state.dropDownItems.map((item) {
                          final translated = item.translation?.getTranslation(langKey) ?? item.place;

                          translatedToWorkPlaceItemTypes[translated] = item.place;

                          return DropdownItemValue(id: item.place, label: translated);
                        }).toList();
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
                        translatedToProfessionalTypes = {};
                        professionalTypesItem.clear();

                        for (final category in state.categories) {
                          for (final subCategory in category.professionalSubCategories) {
                            final translated = subCategory.translation?.getTranslation(langKey) ?? subCategory.name;
                            translatedToProfessionalTypes[translated] = subCategory.name;
                            professionalTypesItem.add(DropdownItemValue(id: subCategory.id, label: translated));
                          }
                        }
                        professionalTypesItem.sort((a, b) => a.label.compareTo(b.label));
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
                        buildDropdownTwo(
                            label: 'Professional/Worker Required'.tr(),
                            hintText: 'Select Profession'.tr(),
                            items: professionalTypesItem,
                            onChanged: (value) => setState(() {
                              _selectedProfession = translatedToProfessionalTypes[value.label] ?? value.label;
                              _selectedProfessionId =  value.id;
                                  professionalSelected = true;
                                  print(_selectedProfession);
                                  _validateForm();
                                }),
                            itemLoading: professionalTypesLoading,
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return 'Please select your profession'.tr();
                              }
                              return null;
                            },
                            color: professionalSelected
                                ? COLORS.neutralDarkOne
                                : COLORS.neutralDark),
                        buildDynamicRadioSelection(
                            title: 'Experience Level'.tr(),
                            options: [
                              {'label': 'Fresher', 'value': 'Fresher'},
                              {'label': 'Experienced', 'value': 'Experienced'},
                              {'label': 'Any', 'value': 'Any'},
                            ],
                            onChanged: (value) {
                              setState(() {
                                _experienceLevel = value;
                                _validateForm();
                              });
                            },
                            groupValue: _experienceLevel,
                            color: COLORS.neutralDarkOne),
                        SizedBox(height: SizeConfig.blockHeight * 1),
                        buildDynamicRadioSelection(
                            title: 'Gender'.tr(),
                            options: [
                              {'label': 'Male', 'value': 'Male'},
                              {'label': 'Female', 'value': 'Female'}
                            ],
                            onChanged: (value) {
                              setState(() {
                                _selectedGender = value;
                                _validateForm();
                              });
                            },
                            groupValue: _selectedGender,
                            color: COLORS.neutralDarkOne),
                        SizedBox(height: SizeConfig.blockHeight * 1),
                        registerText(
                            text: 'known_language'.tr(),
                            color: knownLangSelected
                                ? COLORS.neutralDarkOne
                                : COLORS.neutralDark),
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
                              // labelStyle: TextStyle(
                              //   color: COLORS.accent,
                              //   fontWeight: FontWeight.w400,
                              //   fontFamily: "Poppins",
                              //   fontSize: SizeConfig.blockWidth * 3.2,
                              // ),
                              animateSuffixIcon: true,
                              borderRadius: SizeConfig.blockWidth * 4,
                              padding: EdgeInsets.only(
                                top: SizeConfig.blockHeight * 2.7,
                                bottom: SizeConfig.blockHeight * 2.7,
                                left: SizeConfig.blockWidth * 4,
                                right: SizeConfig.blockWidth * 3,
                              ),
                              hintText: 'Select your known languages'.tr(),
                              hintStyle: TextStyle(
                                color: COLORS.neutralDarkOne,
                                fontWeight: FontWeight.w400,
                                fontFamily: "Poppins",
                                fontSize: SizeConfig.blockWidth * 3.2,
                              ),
                              suffixIcon: Icon(
                                Icons.keyboard_arrow_down_outlined,
                                color: COLORS.accent,
                                size: SizeConfig.blockWidth * 6,
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
                              disabledIcon:
                                  Icon(Icons.lock, color: Colors.grey.shade300),
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
                                knownLangSelected = true;
                              });
                              _validateForm();
                            },
                          )
                        ],
                        if (knowLanguageLoading) ...[
                          dropDownLoader(hintText: 'Select Languages')
                        ],
                        SizedBox(height: SizeConfig.blockHeight * 1.5),
                        registerText(
                            text: 'Work Address',
                            color: workAddressSelected
                                ? COLORS.neutralDarkOne
                                : COLORS.neutralDark),
                        InkWell(
                          onTap: () {
                            showMaterialModalBottomSheet(
                              enableDrag: true,
                              expand: false,
                              isDismissible: true,
                              backgroundColor: COLORS.white,
                              context: context,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.vertical(
                                  top: Radius.circular(
                                      SizeConfig.blockWidth * 3.8),
                                ),
                              ),
                              builder: (context) => BlocProvider(
                                create: (context) => ProfileBloc()
                                  ..add(const AddressLocationListEvent()),
                                child: AddressListModalBottomSheet(
                                  selectedAddressId: addressId,
                                  onAddressSelected: (id,
                                      address,
                                      latitudeAdd,
                                      longitudeAdd,
                                      cityAdd,
                                      localityAdd,
                                      pincodeAdd) {
                                    setState(() {
                                      addressId = id;
                                      addressSelected = address;
                                      latitude = latitudeAdd;
                                      longitude = longitudeAdd;
                                      citySelected = cityAdd;
                                      localitySelected = localityAdd;
                                      pincodeSelected = pincodeAdd;
                                      if (addressId.isNotEmpty) {
                                        workAddressSelected = true;
                                      }
                                    });
                                  },
                                ),
                              ),
                            );
                          },
                          borderRadius: BorderRadius.circular(
                              SizeConfig.blockWidth * 3.5),
                          child: Container(
                            width: SizeConfig.blockWidth * 100,
                            height: SizeConfig.blockHeight * 7.5,
                            alignment: Alignment.centerLeft,
                            padding: EdgeInsets.symmetric(
                                vertical: SizeConfig.blockHeight,
                                horizontal: SizeConfig.blockWidth * 3.5),
                            decoration: BoxDecoration(
                                border: Border.all(
                                    width: SizeConfig.blockWidth * 0.2,
                                    color: COLORS.neutralDarkTwo),
                                borderRadius: BorderRadius.circular(
                                    SizeConfig.blockWidth * 3.5)),
                            child: Text(
                              addressSelected.tr(),
                              style: TextStyle(
                                color: addressSelected == 'Select work location'
                                    ? COLORS.neutralDarkOne
                                    : COLORS.neutralDark,
                                fontWeight: FontWeight.w400,
                                fontFamily: "Poppins",
                                fontSize:
                                    addressSelected == 'Select work location'
                                        ? SizeConfig.blockWidth * 3.2
                                        : SizeConfig.blockWidth * 3.5,
                              ),
                              textAlign: TextAlign.center,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ),
                        SizedBox(height: SizeConfig.blockHeight * 1.5),
                        // _buildTextField(
                        //   label: 'Work Address',
                        //   controller: addressController,
                        //   hintText: "Select work location".tr(),
                        //   validator: (value) {
                        //     if (value == null || value.isEmpty) {
                        //       setState(() => addressError = true);
                        //       return 'Please enter your address'.tr();
                        //     }
                        //     setState(() => addressError = false);
                        //     return null;
                        //   },
                        //   error: addressError,
                        //   onChanged: (value) {
                        //     _validateForm();
                        //     return null;
                        //   },
                        //
                        //   title: 'Work Address'.tr(),
                        // ),
                        buildDropdownTwo(
                            label: 'Work Place'.tr(),
                            hintText: 'Ex : Home, Bank, etc'.tr(),
                            items: dropdownWorkPlaceItem,
                            onChanged: (value) => setState(() {
                                  _selectedWorkPlace = translatedToWorkPlaceItemTypes[value.label] ?? value.label;
                                  _selectedWorkPlaceId = value.id;
                                  setState(() {
                                    workPlaceSelected = true;
                                  });
                                  _validateForm();
                                }),
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return 'Please select work place'.tr();
                              }
                              return null;
                            },
                            itemLoading: workPlaceLoading,
                            color: workPlaceSelected
                                ? COLORS.neutralDarkOne
                                : COLORS.neutralDark),
                        SizedBox(height: SizeConfig.blockHeight * 0.5),
                        _buildBioTextField(
                            label: 'Work Details'.tr(),
                            controller: bioController,
                            hintText: "Write a work details".tr(),
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
                              if (value!.isNotEmpty) {
                                setState(() {
                                  workDetailsSelected = true;
                                });
                              } else {
                                setState(() {
                                  workDetailsSelected = false;
                                });
                              }
                            },
                            color: workDetailsSelected
                                ? COLORS.neutralDarkOne
                                : COLORS.neutralDark,
                            title: 'Work Details'.tr()),
                        MultipleImagePickerComponent(
                          onImagesSelected: _onImagesSelected,
                          error: imagesList,
                          removeImage: _removeImage,
                          defaultImages: [],
                        ),
                        SizedBox(height: SizeConfig.blockHeight * 4),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.start,
                          crossAxisAlignment: CrossAxisAlignment.start,
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
                            Column(
                              mainAxisAlignment: MainAxisAlignment.start,
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Professional can call you?'.tr(),
                                  style: TextStyle(
                                    color: COLORS.neutralDark,
                                    fontSize: SizeConfig.blockWidth * 3.8,
                                    fontWeight: FontWeight.w400,
                                    fontFamily: "Poppins",
                                  ),
                                ),
                                SizedBox(
                                  width: SizeConfig.blockWidth * 65,
                                  child: Text(
                                    'Enabling this option allows you to receive callbacks from professionals.'
                                        .tr(),
                                    style: TextStyle(
                                      color: COLORS.neutralDarkOne,
                                      fontSize: SizeConfig.blockWidth * 3.2,
                                      fontWeight: FontWeight.w400,
                                      fontFamily: "Poppins",
                                    ),
                                    overflow: TextOverflow.visible,
                                    softWrap: true,
                                  ),
                                )
                              ],
                            ),
                          ],
                        ),
                        SizedBox(height: SizeConfig.blockHeight * 3),
                        customButton(
                          text: 'POST WORK'.tr(),
                          loading: loading,
                          onPressed: () {
                            if (buttonVisible) {
                              if (_formKey.currentState!.validate()) {
                                _submitButton();
                              }
                            }
                          },
                          backgroundColor: buttonVisible
                              ? COLORS.primary
                              : COLORS.primary.withOpacity(0.4),
                          showIcon: false,
                          width: SizeConfig.blockWidth * 100,
                          height: SizeConfig.blockHeight * 8,
                          textColor: COLORS.white,
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildBioTextField(
      {required String label,
      required TextEditingController controller,
      required String hintText,
      required String? Function(String?) validator,
      required String? Function(String?) onChanged,
      required bool error,
      Color? color = COLORS.neutralDark,
      FontWeight? fontWeight = FontWeight.w500,
      required String title}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        registerText(text: title, color: color, fontWeight: fontWeight),
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
            maxLines: 5),
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
      required void Function()? onTap,
      required String title}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        registerText(text: title),
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
            onTap: onTap),
      ],
    );
  }
}
