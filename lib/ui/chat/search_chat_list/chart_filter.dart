import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:works_app/components/colors.dart';
import 'package:works_app/components/size_config.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:works_app/global_helper/dropdown.dart';
import '../../../bloc/register_account/initial_register_bloc.dart';
import '../../../global_helper/reuse_widget.dart';

class ChartSearchFilterBottomSheet extends StatefulWidget {
  final String? initialCity;
  final String? initialGender;

  const ChartSearchFilterBottomSheet({
    super.key,
    this.initialCity,
    this.initialGender,
  });

  @override
  _ChartSearchFilterBottomSheetState createState() =>
      _ChartSearchFilterBottomSheetState();
}

class _ChartSearchFilterBottomSheetState
    extends State<ChartSearchFilterBottomSheet> {
  String? selectedCity;
  String? selectedGender;
  late InitialRegisterBloc initialRegisterBloc;
  bool cityLoading = true;
  List<String> dropdownCityItem = [];
  bool citySelected = false;
  bool genderSelected = false;

  @override
  void initState() {
    super.initState();
    initialRegisterBloc = BlocProvider.of<InitialRegisterBloc>(context);
    _fetchData();
  }

  void _fetchData() {
    selectedCity = widget.initialCity;
    selectedGender = widget.initialGender ?? 'Male';
    if(selectedCity!.isNotEmpty){
      citySelected = true;
    }
    if(selectedGender!.isNotEmpty){
      genderSelected = true;
    }
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
              label: 'city'.tr(),
              hintText: 'Select city'.tr(),
              items: dropdownCityItem,
              onChanged: (value) => setState(() {
                selectedCity = value;
                citySelected = true;
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
                  : null,
                color: citySelected?COLORS.neutralDarkOne:COLORS.neutralDark,
                fontWeight: citySelected?FontWeight.w400:FontWeight.w500
            ),
            buildDynamicRadioSelection(
              options: [
                {'label': 'Male', 'value': 'male'},
                {'label': 'Female', 'value': 'female'},
              ],
              groupValue: selectedGender,
              onChanged: (value) {
                setState(() {
                  selectedGender = value!;
                  genderSelected = true;
                });
              },
              color: genderSelected?COLORS.neutralDarkOne:COLORS.neutralDark,
              fontWeight: genderSelected?FontWeight.w400:FontWeight.w500, title: 'Gender'

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
