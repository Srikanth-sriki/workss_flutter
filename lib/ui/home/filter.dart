import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:modal_bottom_sheet/modal_bottom_sheet.dart';
import 'package:works_app/components/colors.dart';
import 'package:works_app/components/size_config.dart';
import 'package:easy_localization/easy_localization.dart';
import '../../bloc/professional/professional_bloc.dart';
import '../../bloc/profile/profile_bloc.dart';
import '../../bloc/register_account/initial_register_bloc.dart';
import '../../global_helper/dropdown.dart';
import '../../global_helper/loading_placeholder/home_layout.dart';
import '../../global_helper/reuse_widget.dart';
import '../profile/component.dart';

class SearchFilterBottomSheet extends StatefulWidget {
  final String? initialProfession;
  final String? initialCity;
  final String? initialGender;

  const SearchFilterBottomSheet({
    super.key,
    this.initialProfession,
    this.initialCity,
    this.initialGender,
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

  @override
  void initState() {
    super.initState();
    initialRegisterBloc = BlocProvider.of<InitialRegisterBloc>(context);
    professionalBloc = BlocProvider.of<ProfessionalBloc>(context);
    _fetchData();
  }

  void _fetchData() {
    selectedProfession = widget.initialProfession;
    selectedCity = widget.initialCity;
    selectedGender = widget.initialGender ?? 'Male';
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
                selectedProfession = value;
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
            SizedBox(height: SizeConfig.blockHeight,),
            buildGenderSelection(
              header: 'Experience Level'.tr(),
              options: [
                {'label': 'Fresher', 'value': 'Fresher'},
                {'label': 'Experienced', 'value': 'Experienced'},
                {'label': 'Any', 'value': 'Any'},
              ],
              groupValue: _experienceLevel,
              onChanged: (value) {
                setState(() {
                  _experienceLevel = value!;
                });
              },
            ),
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
                      Navigator.of(context).pop({
                        'selectedProfession': selectedProfession ?? "",
                        'selectedCity': selectedCity ?? "",
                        'selectedGender': selectedGender ?? "",
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
