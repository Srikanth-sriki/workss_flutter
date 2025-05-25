import 'dart:io';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:modal_bottom_sheet/modal_bottom_sheet.dart';
import 'package:multi_dropdown/multi_dropdown.dart';
import 'package:works_app/components/colors.dart';
import 'package:works_app/ui/onboarding/register_form.dart';
import 'package:works_app/ui/post_work/post_work_success.dart';
import 'package:works_app/ui/profile/component.dart';
import 'package:geolocator/geolocator.dart';
import '../../bloc/post_work/post_work_bloc.dart';
import '../../bloc/professional/professional_bloc.dart';
import '../../bloc/profile/profile_bloc.dart';
import '../../components/config.dart';
import '../../components/size_config.dart';
import '../../dao/get_user_location.dart';
import '../../global_helper/ImagePickerComponent.dart';
import '../../global_helper/dropdown.dart';
import '../../global_helper/helper_function.dart';
import '../../global_helper/loading_placeholder/home_layout.dart';
import '../../global_helper/reuse_widget.dart';
import '../../models/category_list_modal.dart';
import '../../models/dropDown_modal.dart';
import '../../models/fetch_posted_work.dart';
import '../profile/location/location_list_modal.dart';

class EditPostWorkScreen extends StatefulWidget {
  final VoidCallback refreshPageCallback;
  final FetchPostedModel fetchPostedModel;
  const EditPostWorkScreen(
      {super.key,
      required this.fetchPostedModel,
      required this.refreshPageCallback});

  @override
  State<EditPostWorkScreen> createState() => _EditPostWorkScreenState();
}

class _EditPostWorkScreenState extends State<EditPostWorkScreen> {
  late PostWorkBloc postWorkBloc;
  late ProfessionalBloc professionalBloc;
  final _formKey = GlobalKey<FormState>();
  final TextEditingController bioController = TextEditingController();
  final TextEditingController addressController = TextEditingController();
  late MultiSelectController<Language> controller;
  final langKey = languageCodeToTranslationKey[Config.languageSelected] ?? 'english';
  DropdownItemValue? _selectedWorkPlace;
  DropdownItemValue? _selectedProfession;
  String? _selectedWorkPlaceId;
  String? _selectedProfessionId;
  String? _selectedGender;
  String? _experienceLevel;
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
  String citySelected = '';
  String pincodeSelected = '';
  String localitySelected = '';
  String? _selectedWorkCityId;
  String? _selectedWorkLocalityId;

  // List<DropdownItem<Language>> items = [
  //   DropdownItem(label: 'English', value: Language(name: 'English', id: 1)),
  //   DropdownItem(label: 'Kannada', value: Language(name: 'Kannada', id: 2)),
  //   DropdownItem(label: 'Hindi', value: Language(name: 'Hindi', id: 3)),
  //   DropdownItem(label: 'Tamil', value: Language(name: 'Tamil', id: 4)),
  //   DropdownItem(label: 'Telugu', value: Language(name: 'Telugu', id: 5)),
  //   DropdownItem(label: 'Gujarati', value: Language(name: 'Gujarati', id: 6)),
  //   DropdownItem(label: 'Malayalam', value: Language(name: 'Malayalam', id: 7)),
  //   DropdownItem(label: 'Marathi', value: Language(name: 'Marathi', id: 8)),
  // ];

  void _validateForm() {
    if (_selectedProfession != null &&
        _selectedGender != null &&
        _experienceLevel != null &&
        selectedLanguage != [] &&
        bioController.text.isNotEmpty &&
        isChecked != false) {
      setState(() {
        buttonVisible = true;
      });
    }
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
      }
      if (index >= 0 && index < workImages.length) {
        workImages.removeAt(index);
      }
    });
  }

  @override
  void initState() {
    super.initState();
    postWorkBloc = BlocProvider.of<PostWorkBloc>(context);
    professionalBloc = BlocProvider.of<ProfessionalBloc>(context);
    controller = MultiSelectController<Language>();
    initialData();
  }

  void initialData() {
    _selectedProfession = DropdownItemValue(
        id: widget.fetchPostedModel.profCategoryId!,
        label: widget.fetchPostedModel.requiredProfession!);
    _selectedProfessionId = widget.fetchPostedModel.profCategoryId!;
    _selectedWorkPlaceId = widget.fetchPostedModel.workPlaceId!;
    _experienceLevel = widget.fetchPostedModel.experienceLevel!;
    _selectedGender = widget.fetchPostedModel.gender!;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      List<DropdownItem<Language>> item = knownLanguageItems;
      controller.setItems(item);
      controller.selectWhere((item) => widget.fetchPostedModel.knowLanguage!.contains(item.value.name));
    });
    selectedLanguage = convertLanguages(widget.fetchPostedModel.knowLanguage!);
    print(selectedLanguage);
    _selectedWorkPlace = DropdownItemValue(id: capitalizeFirstLetter(widget.fetchPostedModel.workPlace!),
        label: widget.fetchPostedModel.workPlaceId!);
    workImages = widget.fetchPostedModel.workImages!;
    isChecked = widget.fetchPostedModel.isProfessionalCanCall!;
    latitude = widget.fetchPostedModel.latitude!;
    longitude = widget.fetchPostedModel.longitude!;
    bioController.text = widget.fetchPostedModel.description!;
    addressSelected = widget.fetchPostedModel.location!;
    citySelected = widget.fetchPostedModel.city!;
    localitySelected = widget.fetchPostedModel.locality!;
    pincodeSelected = widget.fetchPostedModel.pincode!;
  }

  void knownLanguageUpdate() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      List<DropdownItem<Language>> item = knownLanguageItems;
      controller.setItems(item);
      controller.selectWhere((item) =>
          widget.fetchPostedModel.knowLanguage!.contains(item.value.name));
    });
    selectedLanguage = convertLanguages(widget.fetchPostedModel.knowLanguage!);
    print(selectedLanguage);

  }

  List<Language> convertLanguages(List<String> knownLanguages) {
    return List.generate(knownLanguages.length, (index) {
      return Language(
        name: knownLanguages[index],
        id: index + 1,
      );
    });
  }

  void _submitButton() {
    // if (workImages.isEmpty) {
    //   setState(() {
    //     imagesList = true;
    //   });
    // } else {}
    List<String> languageSelect =
    selectedLanguage.map((lang) => lang.name).toList();
    postWorkBloc.add(EditPostWorkEvent(
        workId: widget.fetchPostedModel.id!,
        requiredProfession: _selectedProfession!.label!,
        experienceLevel: _experienceLevel!.toLowerCase(),
        gender: _selectedGender!.toLowerCase(),
        knowLanguage: languageSelect,
        location: addressSelected,
        workPlace: _selectedWorkPlace!.label.toLowerCase(),
        workImages: workImages,
        isProfessionalCanCall: isChecked,
        latitude: latitude!,
        longitude: longitude!,
        description: bioController.text,
        city: citySelected,
      pincode: pincodeSelected,
      locality:localitySelected
    ));
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

  void _fetchCurrentLocation() async {
    setState(() {
      _isLoadingMap = true;
    });
    Position position = await _determinePosition();
    final result = await getAddress(position.latitude, position.longitude);
    setState(() {
      addressController.text = result['address'] ?? '';
      _isLoadingMap = false;
      latitude = position.latitude.toString();
      longitude = position.longitude.toString();
    });
  }

  @override
  void dispose() {
    bioController.dispose();
    addressController.dispose();
    super.dispose();
  }

  void clearData() async {
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
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
          appBar: const CustomAppBar(
              title: 'Edit Post work',
              backgroundColor: COLORS.white,
              titleColors: COLORS.neutralDark),
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
                    } else if (state is EditPostWorkSuccess) {
                      loading = false;
                      showCustomSnackBar(
                          context: context,
                          message: state.message,
                          backgroundColor: COLORS.semanticTwo);

                      widget.refreshPageCallback();
                      Navigator.pop(context, true);
                    } else if (state is EditPostWorkFailed) {
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
                        dropdownWorkPlaceItem.clear();

                        for (final category in state.dropDownItems) {
                          final translated = category.translation?.getTranslation(langKey);
                          final displayName = (translated?.isNotEmpty == true) ? translated! : category.place;

                          dropdownWorkPlaceItem.add(DropdownItemValue(id: category.id, label: displayName));

                        }

                        dropdownWorkPlaceItem.sort((a, b) => a.label.compareTo(b.label)); // Optional if needed

                        // Set selected value based on ID (more reliable than name)
                        final matchedProfession = dropdownWorkPlaceItem.firstWhere(
                              (item) => item.id == widget.fetchPostedModel.workPlaceId,
                          orElse: () => DropdownItemValue(id: '', label: ''),
                        );

                        print(matchedProfession);

                        _selectedWorkPlace = matchedProfession.id.isNotEmpty ? matchedProfession : null;

                        workPlaceLoading = false;
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
                        knownLanguageUpdate();
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
                      // setState(() {
                      //   // professionalTypesItem =
                      //   //     state.categories.map((item) => item.name).toList();
                      //   professionalTypesItem = state.categories.map((item) {
                      //     final translated = item.translation?.getTranslation(langKey);
                      //     return translated?.isNotEmpty == true ? translated! : item.name;
                      //   }).toList();
                      //   final matchedCategory = state.categories.firstWhere(
                      //         (item) => item.name == widget.fetchPostedModel.requiredProfession!,
                      //   );
                      //   final translated = matchedCategory.translation?.getTranslation(langKey);
                      //   _selectedProfession = translated?.isNotEmpty == true ? translated! : matchedCategory.name;
                      //
                      //   professionalTypesLoading = false;
                      // });
                      // setState(() {
                      //
                      //
                      //   // Build the translated list of all subcategory names
                      //   for (final category in state.categories) {
                      //     for (final subCategory in category.professionalSubCategories) {
                      //       final translated = subCategory.translation?.getTranslation(langKey);
                      //       final displayName = translated?.isNotEmpty == true ? translated! : subCategory.name;
                      //       professionalTypesItem.add(DropdownItemValue(id: subCategory.id, label: displayName));
                      //     }
                      //   }
                      //   print(widget.fetchPostedModel.requiredProfession!);
                      //   print(professionalTypesItem);
                      //
                      //   // Find the matched subcategory based on requiredProfession
                      //   ProfessionalSubCategory? matchedSubCategory;
                      //
                      //   for (final category in state.categories) {
                      //     try {
                      //       matchedSubCategory = category.professionalSubCategories.firstWhere(
                      //             (sub) {
                      //           final translated = sub.translation?.getTranslation(langKey)?.trim() ?? '';
                      //           final name = sub.name.trim();
                      //           final required = widget.fetchPostedModel.requiredProfession!.trim();
                      //           return translated == required || name == required;
                      //         },
                      //       );
                      //       break;
                      //     } catch (_) {}
                      //   }
                      //
                      //   print("Matched: ${matchedSubCategory?.toJson()}");
                      //
                      //   print(_selectedProfession);
                      //   if (matchedSubCategory != null) {
                      //     final translated = matchedSubCategory.translation?.getTranslation(langKey);
                      //     print(translated);
                      //     _selectedProfession = translated?.isNotEmpty == true
                      //         ? translated!
                      //         : matchedSubCategory.name;
                      //   } else {
                      //     _selectedProfession = '';
                      //   }
                      //
                      //   professionalTypesLoading = false;
                      // });

                      setState(() {
                        professionalTypesItem.clear();

                        for (final category in state.categories) {
                          for (final subCategory in category.professionalSubCategories) {
                            final translated = subCategory.translation?.getTranslation(langKey);
                            final displayName = (translated?.isNotEmpty == true) ? translated! : subCategory.name;

                            professionalTypesItem.add(DropdownItemValue(id: subCategory.id, label: displayName));
                          }
                        }

                        professionalTypesItem.sort((a, b) => a.label.compareTo(b.label)); // Optional if needed

                        // Set selected value based on ID (more reliable than name)
                        final matchedProfession = professionalTypesItem.firstWhere(
                              (item) => item.id == widget.fetchPostedModel.profCategoryId,
                          orElse: () => DropdownItemValue(id: '', label: ''),
                        );

                        print(matchedProfession);

                        _selectedProfession = matchedProfession.id.isNotEmpty ? matchedProfession : null;

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
                          value:  professionalTypesItem.contains(_selectedProfession)
                        ? _selectedProfession
                        : null,
                          label: 'Professional/Worker Required'.tr(),
                          hintText: 'Select Profession'.tr(),
                          items: professionalTypesItem,
                          onChanged: (value) => setState(() {
                            _selectedProfession = value;
                            _validateForm();
                          }),
                          itemLoading:professionalTypesLoading ,
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Please select your profession'.tr();
                            }
                            return null;
                          },
                        ),

                        buildDynamicRadioSelection(
                          options: [
                            {'label': 'Fresher', 'value': 'fresher'},
                            {'label': 'Experienced', 'value': 'experienced'},
                            {'label': 'Any', 'value': 'any'},
                          ],
                          onChanged: (value) => setState(() {
                            _experienceLevel = value;
                          }),
                          groupValue: _experienceLevel,
                          title: 'Experience Level'.tr(),
                        ),

                        SizedBox(height: SizeConfig.blockHeight * 1),
                        buildDynamicRadioSelection(
                          options: [
                            {'label': 'Male', 'value': 'male'},
                            {'label': 'Female', 'value': 'female'},
                          ],
                          groupValue: _selectedGender,
                          onChanged: (value) {
                            setState(() {
                              _selectedGender = value;
                            });
                          },
                          title: 'Select Gender'.tr(),
                        ),
                        SizedBox(height: SizeConfig.blockHeight * 1),
                        registerText(text: 'known_language'.tr()),
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
                              borderRadius:  SizeConfig.blockWidth * 4,
                              padding: EdgeInsets.only(
                                top: SizeConfig.blockHeight * 2.7,
                                bottom: SizeConfig.blockHeight * 2.7,
                                left: SizeConfig.blockWidth * 4,
                                right: SizeConfig.blockWidth * 3,
                              ),
                              animateSuffixIcon: true,
                              hintText: 'Select Languages'.tr(),
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
                        SizedBox(height: SizeConfig.blockHeight * 1.5),
                        registerText(text: 'Work Address'),
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
                                  onAddressSelected: (id, address, latitudeAdd,
                                      longitudeAdd, cityAdd, localityAdd, pincodeAdd,cityId,localityId) {
                                    setState(() {
                                      addressId = id;
                                      addressSelected = address;
                                      latitude = latitudeAdd;
                                      longitude = longitudeAdd;
                                      citySelected = cityAdd;
                                      localitySelected = localityAdd;
                                      pincodeSelected = pincodeAdd;
                                      _selectedWorkCityId=cityId;
                                      _selectedWorkLocalityId=localityId;
                                    });
                                  },
                                ),
                              ),
                            );
                          },  borderRadius: BorderRadius.circular(
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
                              addressSelected,
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
                        //     label: 'Work Address',
                        //     controller: addressController,
                        //     hintText: "Select work location".tr(),
                        //     validator: (value) {
                        //       if (value == null || value.isEmpty) {
                        //         setState(() => addressError = true);
                        //         return 'Please enter your address'.tr();
                        //       }
                        //       setState(() => addressError = false);
                        //       return null;
                        //     },
                        //     error: addressError,
                        //     onChanged: (value) {
                        //       _validateForm();
                        //       return null;
                        //     },
                        //     onTap: _fetchCurrentLocation,
                        //     title: 'Work Address'.tr()),


                        buildDropdownTwo(
                          value: dropdownWorkPlaceItem.contains(_selectedWorkPlace)
                              ? _selectedWorkPlace
                              : null,
                          label: 'Work Place'.tr(),
                          hintText: 'Ex : Home, Bank, etc'.tr(),
                          items: dropdownWorkPlaceItem,
                          onChanged: (value) => setState(() {
                            _selectedWorkPlace = value;
                            _validateForm();
                          }),
                          itemLoading: workPlaceLoading,
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Please select work place'.tr();
                            }
                            return null;
                          },
                        ),
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
                            },
                            title: 'Bio'.tr()),
                        MultipleImagePickerComponent(
                          onImagesSelected: _onImagesSelected,
                          error: imagesList,
                          removeImage: _removeImage,
                          defaultImages: workImages,
                            headerNeed: true,
                            filedConatinerText :'Upload your work images (Optional) \n(max 2 pictures)'
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
                                  _validateForm();
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
                            if (_formKey.currentState!.validate()) {
                              _submitButton();
                            }
                          },
                          backgroundColor: COLORS.primary,
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
