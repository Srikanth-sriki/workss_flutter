import 'dart:io';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:multi_dropdown/multi_dropdown.dart';
import 'package:works_app/components/colors.dart';
import 'package:works_app/ui/onboarding/register_form.dart';
import 'package:works_app/ui/post_work/post_work_success.dart';
import 'package:works_app/ui/profile/component.dart';
import 'package:geolocator/geolocator.dart';
import '../../bloc/post_work/post_work_bloc.dart';
import '../../components/size_config.dart';
import '../../dao/get_user_location.dart';
import '../../global_helper/ImagePickerComponent.dart';
import '../../global_helper/dropdown.dart';
import '../../global_helper/helper_function.dart';
import '../../global_helper/reuse_widget.dart';
import '../../models/fetch_posted_work.dart';

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
  final _formKey = GlobalKey<FormState>();
  final TextEditingController bioController = TextEditingController();
  final TextEditingController addressController = TextEditingController();
  late MultiSelectController<Language> controller;
  String? _selectedWorkPlace;
  String? _selectedProfession;
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

  List<DropdownItem<Language>> items = [
    DropdownItem(label: 'English', value: Language(name: 'English', id: 1)),
    DropdownItem(label: 'Kannada', value: Language(name: 'Kannada', id: 2)),
    DropdownItem(label: 'Hindi', value: Language(name: 'Hindi', id: 3)),
    DropdownItem(label: 'Tamil', value: Language(name: 'Tamil', id: 4)),
    DropdownItem(label: 'Telugu', value: Language(name: 'Telugu', id: 5)),
    DropdownItem(label: 'Gujarati', value: Language(name: 'Gujarati', id: 6)),
    DropdownItem(label: 'Malayalam', value: Language(name: 'Malayalam', id: 7)),
    DropdownItem(label: 'Marathi', value: Language(name: 'Marathi', id: 8)),
  ];



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
    controller = MultiSelectController<Language>();
    initialData();
  }

  void initialData() {
    _selectedProfession = widget.fetchPostedModel.requiredProfession!;
    _experienceLevel = widget.fetchPostedModel.experienceLevel!;
    _selectedGender = widget.fetchPostedModel.gender!;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      List<DropdownItem<Language>> item = items;
      controller.setItems(item);
      controller.selectWhere((item) =>
          widget.fetchPostedModel.knowLanguage!.contains(item.value.name));
    });
    selectedLanguage = convertLanguages(widget.fetchPostedModel.knowLanguage!);
    _selectedWorkPlace =
        capitalizeFirstLetter(widget.fetchPostedModel.workPlace!);
    workImages = widget.fetchPostedModel.workImages!;
    isChecked = widget.fetchPostedModel.isProfessionalCanCall!;
    latitude = widget.fetchPostedModel.latitude!;
    longitude = widget.fetchPostedModel.longitude!;
    bioController.text = widget.fetchPostedModel.description!;
    addressController.text = widget.fetchPostedModel.location!;
  }

  List<Language> convertLanguages(List<String> knownLanguages) {
    return List.generate(knownLanguages.length, (index) {
      return Language(
        name: knownLanguages[index],
        id: index + 1, // Assigning a dynamic ID starting from 1
      );
    });
  }

  void _submitButton() {
    if (workImages.isEmpty) {
      setState(() {
        imagesList = true;
      });
    } else {
      List<String> languageSelect = selectedLanguage.map((lang) => lang.name).toList();
      postWorkBloc.add(EditPostWorkEvent(
          workId: widget.fetchPostedModel.id!,
          requiredProfession: _selectedProfession!,
          experienceLevel: _experienceLevel!.toLowerCase(),
          gender: _selectedGender!.toLowerCase(),
          knowLanguage: languageSelect,
          location: addressController.text,
          workPlace: _selectedWorkPlace!.toLowerCase(),
          workImages: workImages,
          isProfessionalCanCall: isChecked,
          latitude: latitude!,
          longitude: longitude!,
          description: bioController.text));
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
        return false;
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
            child: BlocListener<PostWorkBloc, PostWorkState>(
              listener: (context, state) {
                if (state is PostWorkLoading) {
                  loading = true;
                } else if (state is UploadMultipleImageSuccess) {
                  loading = false;
                  workImages.add(state.filePath);
                } else if (state is UploadImageFailed) {
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
                }
                setState(() {});
              },
              child: SingleChildScrollView(
                child: Container(
                  width: SizeConfig.screenWidth,
                  padding: EdgeInsets.all(SizeConfig.blockWidth * 4.5),
                  child: Form(
                    key: _formKey,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        buildDropdown(
                          value: _selectedProfession,
                          label: 'Professional/Worker Required'.tr(),
                          hintText: 'Select Profession'.tr(),
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

                        //SizedBox(height: SizeConfig.blockHeight * 1),
                        buildGenderSelection(
                          groupValue: _selectedGender,
                          onChanged: (value) {
                            setState(() {
                              _selectedGender = value;
                            });
                          },
                        ),
                        SizedBox(height: SizeConfig.blockHeight * 1),
                        registerText(text: 'known_language'.tr()),
                        MultiDropdown<Language>(
                          items: items,
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
                              backgroundColor: COLORS.primary.withOpacity(0.05),
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
                            padding:EdgeInsets.only(
                              top: SizeConfig.blockHeight * 2.2,
                              bottom: SizeConfig.blockHeight * 2.2,
                              left: SizeConfig.blockWidth * 4,
                              right: SizeConfig.blockWidth * 3,
                            ) ,
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
                        ),
                        SizedBox(height: SizeConfig.blockHeight * 1.5),
                        _buildTextField(
                            label: 'Work Address',
                            controller: addressController,
                            hintText: "Select work location".tr(),
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                setState(() => addressError = true);
                                return 'Please enter your address'.tr();
                              }
                              setState(() => addressError = false);
                              return null;
                            },
                            error: addressError,
                            onChanged: (value) {
                              _validateForm();
                              return null;
                            },
                            onTap: _fetchCurrentLocation,
                            title: 'Work Address'.tr()),
                        buildDropdown(
                          value: _selectedWorkPlace,
                          label: 'Work Place'.tr(),
                          hintText: 'Ex : Home, Bank, etc'.tr(),
                          items: ['Office', 'Home'],
                          onChanged: (value) => setState(() {
                            _selectedWorkPlace = value;
                            _validateForm();
                          }),
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
