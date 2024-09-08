import 'dart:io';
import 'package:dropdown_button2/dropdown_button2.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:works_app/ui/onboarding/login_success.dart';
import 'package:works_app/ui/onboarding/phone_number.dart';
import '../../components/colors.dart';
import '../../components/size_config.dart';
import '../../global_helper/ImagePickerComponent.dart';
import '../../global_helper/dropdown.dart';
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
  final controller = MultiSelectController<Language>();

  String? selectedYears;
  String? selectedCharges;
  String? _selectedCity;
  String? _selectedProfession;
  bool buttonVisible = true;
  bool nameError = false;
  bool emailError = false;
  bool bioError = false;
  bool yearError = false;
  bool chargeError = false;
  File? _profileImage;
  String? selectedValue;
  String? _selectedGender;
  String? selectedExperence = 'Year';
  String? selectedCharge = 'PerDay';
  List<Language> selectedLanguage = [];
  bool isSubmitButtonEnabled = false;

  var items = [
    DropdownItem(label: 'English', value: Language(name: 'English', id: 1)),
    DropdownItem(label: 'Spanish', value: Language(name: 'Spanish', id: 2)),
    DropdownItem(label: 'French', value: Language(name: 'French', id: 3)),
    DropdownItem(label: 'German', value: Language(name: 'German', id: 4)),
    DropdownItem(label: 'Chinese', value: Language(name: 'Chinese', id: 5)),
    DropdownItem(label: 'Japanese', value: Language(name: 'Japanese', id: 6)),
    DropdownItem(label: 'Korean', value: Language(name: 'Korean', id: 7)),
    DropdownItem(label: 'Hindi', value: Language(name: 'Hindi', id: 8)),
  ];

  void _validateForm() {
    print(isSubmitButtonEnabled);

    if (widget.userType != 'jobs' &&
        _enterName.text.isNotEmpty &&
        _selectedCity != null &&
        bioController.text.isNotEmpty &&
        _selectedCity!.isNotEmpty) {
      setState(() {
        isSubmitButtonEnabled = true;
      });
    }
    if (widget.userType == 'jobs' &&
        _enterName.text.isNotEmpty &&
        _selectedCity != null &&
        _selectedCity!.isNotEmpty &&
        _selectedProfession != null &&
        _selectedProfession!.isNotEmpty &&
        experienceController.text.isNotEmpty &&
        chargesController.text.isNotEmpty &&
        _selectedGender != null &&
        bioController.text.isNotEmpty &&
        selectedLanguage != []) {
      setState(() {
        isSubmitButtonEnabled = true;
      });
    }
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
    } else {
      if (isSubmitButtonEnabled == true) {
        Navigator.push(
          context,
          MaterialPageRoute(
              builder: (BuildContext context) => const LoginSuccess()),
        );
      } else {
        _validateForm();
      }
    }
  }

  @override
  void dispose() {
    _enterName.dispose();
    _emailController.dispose();
    experienceController.dispose();
    chargesController.dispose();
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
          context: context,
          onSkipPressed: () {},
        ),
        body: SafeArea(
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
                          },
                          title: 'name'.tr()),
                      _buildMobileNumber(),
                      _buildTextField(
                          label: 'Email Address',
                          controller: _emailController,
                          hintText: "Enter your email address (Optional)".tr(),
                          validator: (value) {
                            if (value != null &&
                                value.isNotEmpty &&
                                !RegExp(r'^[^@]+@[^@]+\.[^@]+')
                                    .hasMatch(value)) {
                              return 'Please enter a valid email address'.tr();
                            }
                            return null;
                          },
                          error: emailError,
                          onChanged: (value) {
                            _validateForm();
                          },
                          title: 'email'.tr()),
                      _buildDropdown(
                        label: 'city'.tr(),
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
                      if (widget.userType == 'jobs') ...[
                        SizedBox(height: SizeConfig.blockHeight),
                        _buildDropdown(
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
                      if (widget.userType == 'jobs') ...[
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
                            suffix: true,
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
                      if (widget.userType == 'jobs') ...[
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
                                            width: SizeConfig.blockWidth * 0.1,
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
                                  items: const [' Hours', 'PerDay', 'Month'],
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
                      if (widget.userType == 'jobs') ...[
                        SizedBox(height: SizeConfig.blockHeight * 0.5),
                        _buildGenderSelection(),
                      ],
                      if (widget.userType == 'jobs') ...[
                        SizedBox(height: SizeConfig.blockHeight * 2),
                        registerText(text: 'known_language'.tr()),
                        MultiDropdown<Language>(
                          items: items,
                          controller: controller,
                          enabled: true,
                          searchEnabled: false,
                          closeOnBackButton: true,
                          chipDecoration: ChipDecoration(
                              backgroundColor: COLORS.primary.withOpacity(0.1),
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
                            if (value == null || value.isEmpty) {
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
                          },
                          title: 'Bio'.tr()),
                    ],
                  ),
                )),
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
        registerText(text: 'profile_picture'.tr()),
        _profileImage == null
            ? ImagePickerComponent(
                onImageSelected: (File image) {
                  setState(() {
                    _profileImage = image;
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
                          width: SizeConfig.blockWidth * 0.5,
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

  Widget _buildDropdown({
    required String label,
    required String hintText,
    required List<String> items,
    required void Function(String?) onChanged,
    required String? Function(String?) validator,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        registerText(text: label),
        DropdownButtonFormField2<String>(
          isDense: true,
          decoration: InputDecoration(
            contentPadding: EdgeInsets.symmetric(
              vertical: SizeConfig.blockHeight * 1.5,
              horizontal: SizeConfig.blockWidth * 3,
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(SizeConfig.blockWidth * 3),
              borderSide: const BorderSide(
                color: COLORS.neutralDarkTwo,
                width: 1,
              ),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(SizeConfig.blockWidth * 3),
              borderSide: const BorderSide(
                color: COLORS.primary,
                width: 1,
              ),
            ),
            errorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(SizeConfig.blockWidth * 3),
              borderSide: const BorderSide(
                color: COLORS.semantic,
                width: 1,
              ),
            ),
            focusedErrorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(SizeConfig.blockWidth * 3),
              borderSide: const BorderSide(
                color: COLORS.semantic,
                width: 1.5,
              ),
            ),
          ),
          dropdownStyleData: DropdownStyleData(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(SizeConfig.blockWidth * 3),
              color: COLORS.white,
            ),
            offset: const Offset(0, -4),
          ),
          isExpanded: true,
          style: TextStyle(
            fontSize: SizeConfig.blockWidth * 3.5,
            color: COLORS.neutralDark,
            fontWeight: FontWeight.w400,
            fontFamily: "Poppins",
          ),
          hint: Text(
            hintText,
            style: TextStyle(
              fontWeight: FontWeight.w400,
              fontFamily: "Poppins",
              fontSize: SizeConfig.blockWidth * 3.2,
              color: COLORS.neutralDark,
            ),
          ),
          items: items
              .map((item) => DropdownMenuItem<String>(
                    value: item,
                    child: Text(
                      item,
                      style: TextStyle(
                        fontSize: SizeConfig.blockWidth * 3.8,
                        color: COLORS.neutralDark,
                        fontWeight: FontWeight.w400,
                        fontFamily: "Poppins",
                      ),
                    ),
                  ))
              .toList(),
          onChanged: onChanged,
          validator: validator,
          iconStyleData: IconStyleData(
            icon: Icon(
              Icons.keyboard_arrow_down_outlined,
              color: COLORS.accent,
              size: SizeConfig.blockWidth * 6,
            ),
          ),
        ),
        SizedBox(height: SizeConfig.blockHeight * 2),
      ],
    );
  }

  Widget _buildGenderSelection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        registerText(text: 'select_gender'.tr()),
        Row(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                Radio<String>(
                  value: 'Male',
                  groupValue: _selectedGender,
                  onChanged: (value) {
                    setState(() {
                      _selectedGender = value;
                    });
                  },
                  materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                  fillColor: const WidgetStatePropertyAll(COLORS.primary),
                ),
                Text(
                  'Male'.tr(),
                  style: TextStyle(
                    color: COLORS.neutralDark,
                    fontSize: SizeConfig.blockWidth * 3.8,
                    fontWeight: FontWeight.w400,
                    fontFamily: "Poppins",
                  ),
                ),
              ],
            ),
            SizedBox(width: SizeConfig.blockWidth * 5),
            Row(
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                Radio<String>(
                  value: 'Female',
                  groupValue: _selectedGender,
                  onChanged: (value) {
                    setState(() {
                      _selectedGender = value;
                    });
                  },
                  materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                  fillColor: const WidgetStatePropertyAll(COLORS.primary),
                ),
                Text(
                  'Female'.tr(),
                  style: TextStyle(
                    color: COLORS.neutralDark,
                    fontSize: SizeConfig.blockWidth * 3.8,
                    fontWeight: FontWeight.w400,
                    fontFamily: "Poppins",
                  ),
                ),
              ],
            ),
          ],
        ),
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
            maxLines: 8),
      ],
    );
  }
}
