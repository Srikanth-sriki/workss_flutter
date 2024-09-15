import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:multi_dropdown/multi_dropdown.dart';
import 'package:works_app/components/colors.dart';
import 'package:works_app/ui/onboarding/register_form.dart';
import 'package:works_app/ui/profile/component.dart';

import '../../components/size_config.dart';
import '../../global_helper/dropdown.dart';
import '../../global_helper/reuse_widget.dart';

class PostWorkScreen extends StatefulWidget {
  const PostWorkScreen({super.key});

  @override
  State<PostWorkScreen> createState() => _PostWorkScreenState();
}

class _PostWorkScreenState extends State<PostWorkScreen> {
  final _formKey = GlobalKey<FormState>();
  final controller = MultiSelectController<Language>();

  String? _selectedCity;
  String? _selectedProfession;
  String? _selectedGender;
  String? _experienceLevel;
  List<Language> selectedLanguage = [];
  bool isChecked = false;
  bool buttonVisible = false;

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
    if (_selectedProfession != null &&
        _selectedCity != null &&
        _selectedGender != null &&
        _experienceLevel != null &&
        selectedLanguage != [] &&
        isChecked != false) {
      setState(() {
        buttonVisible = true;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: COLORS.white,
      appBar: AppBar(
        backgroundColor: COLORS.primary,
        scrolledUnderElevation: 0,
        elevation: 0,
        automaticallyImplyLeading: false,
        toolbarHeight: SizeConfig.blockHeight * 11,
        title: Column(
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
                  buildDropdown(
                    label: 'Professional/Worker Required'.tr(),
                    hintText: 'Select Profession'.tr(),
                    items: ['Technology', 'Healthcare', 'Finance', 'Education'],
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
                  ),
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
                  ),
                  SizedBox(height: SizeConfig.blockHeight * 1),
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
                        borderRadius:
                            BorderRadius.circular(SizeConfig.blockWidth * 2),
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
                      suffixIcon: Icon(
                        Icons.keyboard_arrow_down_outlined,
                        color: COLORS.accent,
                        size: SizeConfig.blockWidth * 6,
                      ),
                      backgroundColor: COLORS.white,
                      showClearIcon: true,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide:
                            const BorderSide(color: COLORS.neutralDarkTwo),
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
                  SizedBox(height: SizeConfig.blockHeight * 1.5),
                  buildDropdown(
                    label: 'Location'.tr(),
                    hintText: 'Enter Locality or City'.tr(),
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
                  SizedBox(height: SizeConfig.blockHeight * 0.5),
                  buildDropdown(
                    label: 'Work Place'.tr(),
                    hintText: 'Ex : Home, Bank, etc'.tr(),
                    items: ['Mysore', 'Bangalore', 'Mangalore', 'Mandy'],
                    onChanged: (value) => setState(() {
                      _selectedProfession = value;
                      _validateForm();
                    }),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please select work place'.tr();
                      }
                      return null;
                    },
                  ),
                  SizedBox(height: SizeConfig.blockHeight * 3),
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
                  SizedBox(height: SizeConfig.blockHeight * 2.5),
                  customButton(
                    text: 'POST WORK'.tr(),
                    onPressed: () {
                      if (_formKey.currentState!.validate()) {}
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
    );
  }
}
