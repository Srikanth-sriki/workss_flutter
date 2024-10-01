import 'package:flutter/material.dart';
import 'package:modal_bottom_sheet/modal_bottom_sheet.dart';
import 'package:works_app/components/colors.dart';
import 'package:works_app/components/size_config.dart';
import 'package:easy_localization/easy_localization.dart';
import '../../global_helper/dropdown.dart';
import '../../global_helper/reuse_widget.dart';


class SearchFilterBottomSheet extends StatefulWidget {
  const SearchFilterBottomSheet({super.key});

  @override
  _SearchFilterBottomSheetState createState() =>
      _SearchFilterBottomSheetState();
}

class _SearchFilterBottomSheetState extends State<SearchFilterBottomSheet> {
  String? selectedProfession;
  String? selectedCity;
  String selectedGender = '';

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(
          horizontal: SizeConfig.blockWidth * 5,
          vertical: SizeConfig.blockHeight * 2.5),
      decoration: BoxDecoration(
          color: COLORS.white,
          borderRadius: BorderRadius.only(
              topLeft: Radius.circular(SizeConfig.blockWidth * 5),
              topRight: Radius.circular(SizeConfig.blockWidth * 5))),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Search & Filter',
                style: TextStyle(
                  color: COLORS.neutralDark,
                  fontSize: SizeConfig.blockWidth * 4.5,
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
            hintText: 'Select your Profession'.tr(),
            items: [
              'Technology',
              'Healthcare',
              'Finance',
              'Education',
              'Teacher',
              'Engineer',
              'Doctor'
            ],
            onChanged: (value) => setState(() {
              selectedProfession = value;
            }),
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Please select your profession'.tr();
              }
              return null;
            },
          ),
          buildDropdown(
            label: 'city'.tr(),
            hintText: 'Select your city'.tr(),
            items: ['Mysore', 'Bangalore', 'Mangalore', 'Mandy'],
            onChanged: (value) => setState(() {
              selectedCity = value;
            }),
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Please select your city'.tr();
              }
              return null;
            },
          ),
          buildGenderSelection(
            groupValue: selectedGender,
            onChanged: (value) {
              setState(() {
                selectedGender = value!;
              });
            },
          ),
          Container(
            margin: EdgeInsets.only(top: SizeConfig.blockHeight * 1.5),
            padding: EdgeInsets.only(
                top: SizeConfig.blockHeight * 2.5,
                bottom: SizeConfig.blockHeight * 1),
            decoration: const BoxDecoration(
                border: Border(
                    top: BorderSide(color: COLORS.neutralDarkOne, width: 0.1))),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                customButton(
                  text: 'CLEAR'.tr(),
                  onPressed: () {
                    setState(() {
                      selectedProfession = null;
                      selectedCity = null;
                      selectedGender = 'Male';
                    });
                    Navigator.pop(context);
                  },
                  backgroundColor: COLORS.neutralDarkTwo,
                  showIcon: false,
                  width: SizeConfig.blockWidth * 42,
                  height: SizeConfig.blockHeight * 8,
                  textColor: COLORS.black,
                ),
                // customButton(
                //   text: 'FILTER'.tr(),
                //   onPressed: () {
                //     Navigator.of(context).pop();
                //     // if (_formKey.currentState!.validate()) {
                //     //   _submitButton();
                //     // }
                //   },
                //   backgroundColor: COLORS.primary,
                //   showIcon: false,
                //   width: SizeConfig.blockWidth * 42,
                //   height: SizeConfig.blockHeight * 8,
                //   textColor: COLORS.white,
                // )
                customButton(
                  text: 'FILTER'.tr(),
                  onPressed: () {
                    Navigator.of(context).pop({
                      'selectedProfession': selectedProfession??"",
                      'selectedCity': selectedCity??"",
                      'selectedGender': selectedGender??"",
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
    );
  }
}
