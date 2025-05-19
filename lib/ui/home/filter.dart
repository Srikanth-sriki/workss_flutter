import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:modal_bottom_sheet/modal_bottom_sheet.dart';
import 'package:multi_dropdown/multi_dropdown.dart';
import 'package:works_app/components/colors.dart';
import 'package:works_app/components/size_config.dart';
import 'package:easy_localization/easy_localization.dart';
import '../../bloc/professional/professional_bloc.dart';
import '../../bloc/profile/profile_bloc.dart';
import '../../bloc/register_account/initial_register_bloc.dart';
import '../../components/config.dart';
import '../../global_helper/dropdown.dart';
import '../../global_helper/loading_placeholder/home_layout.dart';
import '../../global_helper/reuse_widget.dart';
import '../onboarding/register_form.dart';
import '../profile/component.dart';

class SearchFilterBottomSheet extends StatefulWidget {
  final String? initialProfession;
  final String? initialCity;
  final String? initialGender;
  final String? experienceLevel;
  final List<String>? selectedLanguage;
  final bool experienceLevelVisible;
  final bool selectedLanguageVisible;

  const SearchFilterBottomSheet({
    super.key,
    this.initialProfession,
    this.initialCity,
    this.initialGender,
    this.experienceLevel,
    this.selectedLanguage = const [],
    required this.experienceLevelVisible,
    required this.selectedLanguageVisible
  });

  @override
  _SearchFilterBottomSheetState createState() =>
      _SearchFilterBottomSheetState();
}

class _SearchFilterBottomSheetState extends State<SearchFilterBottomSheet> {
  String? selectedProfession;
  String? selectedCity;
  String? selectedGender;
  String? _experienceLevel;
  late InitialRegisterBloc initialRegisterBloc;
  late ProfessionalBloc professionalBloc;
  bool cityLoading = true;
  List<String> dropdownCityItem = [];
  bool professionalTypesLoading = true;
  List<String> professionalTypesItem = [];
  late MultiSelectController<Language> controller;
  List<DropdownItem<Language>> knownLanguageItems = [];
  bool knowLanguageLoading = true;
  List<Language> selectedLanguage = [];
  late Map<String, String> translatedToProfessionalTypes;
  final langKey = languageCodeToTranslationKey[Config.languageSelected] ?? 'english';


  @override
  void initState() {
    super.initState();
    initialRegisterBloc = BlocProvider.of<InitialRegisterBloc>(context);
    professionalBloc = BlocProvider.of<ProfessionalBloc>(context);
    controller = MultiSelectController<Language>();
    print(widget.selectedLanguage);
    _fetchData();
  }

  void _fetchData() {
    selectedProfession = widget.initialProfession;
    selectedCity = widget.initialCity;
    selectedGender = widget.initialGender ?? 'Male';
    _experienceLevel = widget.experienceLevel ?? 'Any';

    WidgetsBinding.instance.addPostFrameCallback((_) {
      List<DropdownItem<Language>> item = knownLanguageItems;
      controller.setItems(item);
      controller.selectWhere((item) =>
          widget.selectedLanguage!.contains(item.value.name));
    });
    selectedLanguage = convertLanguages(widget.selectedLanguage!);

  }


  List<Language> convertLanguages(List<String> knownLanguages) {
    return List.generate(knownLanguages.length, (index) {
      return Language(
        name: knownLanguages[index],
        id: index + 1,
      );
    });
  }

  void knownLanguageUpdate() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      List<DropdownItem<Language>> item = knownLanguageItems;
      controller.setItems(item);
      controller.selectWhere((item) =>
          widget.selectedLanguage!.contains(item.value.name));
    });
    selectedLanguage = convertLanguages(widget.selectedLanguage!);

  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: SizeConfig.blockWidth * 5,
        vertical: SizeConfig.blockHeight * 2.5,
      ),
      decoration: BoxDecoration(
        color: COLORS.white,
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(SizeConfig.blockWidth * 5),
          topRight: Radius.circular(SizeConfig.blockWidth * 5),
        ),
      ),
      child: MultiBlocListener(
        listeners: [
          BlocListener<InitialRegisterBloc, InitialRegisterState>(
            listener: (context, state) {
              if (state is FetchCityLoading) {
                setState(() {
                  cityLoading = true;
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
              }
              if (state is FetchKnownLanguageSuccess) {
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
                setState(() {
                  // professionalTypesItem =
                  //     state.categories.map((item) => item.name).toList();
                  professionalTypesItem = state.categories.map((item) {
                    final translated = item.translation?.getTranslation(langKey);
                    return translated?.isNotEmpty == true ? translated! : item.name;
                  }).toList();
                  professionalTypesLoading = false;
                });
                setState(() {
                  translatedToProfessionalTypes = {};
                  professionalTypesItem = [];

                  for (final category in state.categories) {
                    for (final subCategory in category.professionalSubCategories) {
                      final translated = subCategory.translation?.getTranslation(langKey) ?? subCategory.name;
                      translatedToProfessionalTypes[translated] = subCategory.name;
                      professionalTypesItem.add(translated);
                    }
                  }
                  professionalTypesItem.sort((a, b) => a.compareTo(b));
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
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Search & Filter'.tr(),
                  style: TextStyle(
                    color: COLORS.neutralDark,
                    fontSize: SizeConfig.blockWidth * 4.25,
                    fontWeight: FontWeight.w500,
                    fontFamily: "Poppins",
                  ),
                ),
                IconButton(
                  icon: Icon(
                    Icons.close,
                    color: COLORS.black,
                    size: SizeConfig.blockWidth * 5,
                  ),
                  onPressed: () => Navigator.of(context).pop(),
                ),
              ],
            ),
            SizedBox(
              height: SizeConfig.blockHeight,
            ),
            buildDropdown(
              label: 'profession_type'.tr(),
              hintText: 'Select profession type.'.tr(),
              items: professionalTypesItem,
              onChanged: (value) => setState(() {
                selectedProfession =
                    translatedToProfessionalTypes[value] ??
                        value;
              }),
              itemLoading: professionalTypesLoading,
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Please select your profession'.tr();
                }
                return null;
              },
              value: selectedProfession != null &&
                  professionalTypesItem.contains(selectedProfession)
                  ? selectedProfession
                  : null, // Ensure value is valid
            ),
            buildDropdown(
              label: 'city'.tr(),
              hintText: 'Select city'.tr(),
              items: dropdownCityItem,
              onChanged: (value) => setState(() {
                selectedCity = value;
              }),
              itemLoading: cityLoading,
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Please select your city'.tr();
                }
                return null;
              },
              value: selectedCity != null &&
                  dropdownCityItem.contains(selectedCity)
                  ? selectedCity
                  : null, // Ensure value is valid
            ),
            if(widget.selectedLanguageVisible)...[
              registerText(text: 'known_language'.tr(),),
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
                    borderRadius: SizeConfig.blockWidth*4,
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
                    setState(() {});

                  },
                ),
                SizedBox(height: SizeConfig.blockHeight*2,)
              ],
              if (knowLanguageLoading) ...[
                dropDownLoader(hintText: 'Select Languages')
              ]
            ],
            buildGenderSelection(
              options: [
                {'label': 'Male', 'value': 'male'},
                {'label': 'Female', 'value': 'female'},
              ],
              groupValue: selectedGender,
              onChanged: (value) {
                setState(() {
                  selectedGender = value!;
                });
              },
            ),
            if(widget.experienceLevelVisible)...[
              SizedBox(height: SizeConfig.blockHeight,),
              buildGenderSelection(
                header: 'Experience Level'.tr(),
                options: [
                  {'label': 'Fresher', 'value': 'fresher'},
                  {'label': 'Experienced', 'value': 'experienced'},
                  {'label': 'Any', 'value': 'any'},
                ],
                groupValue: _experienceLevel,
                onChanged: (value) {
                  setState(() {
                    _experienceLevel = value!;
                  });
                },
              )
            ],

            Container(
              margin: EdgeInsets.only(top: SizeConfig.blockHeight * 1.5),
              padding: EdgeInsets.only(
                top: SizeConfig.blockHeight * 2.5,
                bottom: SizeConfig.blockHeight * 1,
              ),
              decoration: const BoxDecoration(
                border: Border(
                  top: BorderSide(color: COLORS.neutralDarkOne, width: 0.1),
                ),
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  customButton(
                    text: 'CLEAR'.tr(),
                    onPressed: () {
                      Navigator.of(context).pop({
                        'selectedProfession': "",
                        'selectedCity': "",
                        'selectedGender': "",
                        "_experienceLevel":"",
                        'selectedLanguage':[""]
                      });
                    },
                    backgroundColor: COLORS.neutralDarkTwo,
                    showIcon: false,
                    width: SizeConfig.blockWidth * 42,
                    height: SizeConfig.blockHeight * 8,
                    textColor: COLORS.black,
                  ),
                  customButton(
                    text: 'FILTER'.tr(),
                    onPressed: () {
                      List<String> languageSelect =
                      selectedLanguage.map((lang) => lang.name).toList();
                      print(languageSelect);
                      Navigator.of(context).pop({
                        'selectedProfession': selectedProfession ?? "",
                        'selectedCity': selectedCity ?? "",
                        'selectedGender': selectedGender ?? "",
                        '_experienceLevel':_experienceLevel ??"",
                        'selectedLanguage':languageSelect,
                      });
                    },
                    backgroundColor: COLORS.primary,
                    showIcon: false,
                    width: SizeConfig.blockWidth * 42,
                    height: SizeConfig.blockHeight * 8,
                    textColor: COLORS.white,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
