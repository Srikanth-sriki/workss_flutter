import 'package:flutter/material.dart';
import 'package:dropdown_button2/dropdown_button2.dart';
import 'package:works_app/components/colors.dart';
import 'package:works_app/components/size_config.dart';

class CustomDropdownButtonFormField extends StatelessWidget {
  final String? selectedValue;
  final List<String> items;
  final ValueChanged<String?> onChanged;
  final String hintText;
  final double iconSize;
  final Color iconColor;
  final bool isExpanded;

  const CustomDropdownButtonFormField({
    Key? key,
    required this.selectedValue,
    required this.items,
    required this.onChanged,
    this.hintText = 'Select an option',
    this.iconSize = 24.0,
    this.iconColor = Colors.blue,
    this.isExpanded = true,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return DropdownButtonFormField2(
      value: selectedValue,
      decoration:  InputDecoration(
        contentPadding: EdgeInsets.fromLTRB(0, SizeConfig.blockHeight * 2, 0, SizeConfig.blockHeight * 2),
        border: InputBorder.none,
        enabledBorder: InputBorder.none,
        focusedBorder: InputBorder.none,
        errorBorder: InputBorder.none,
        disabledBorder: InputBorder.none,
      ),
      isExpanded: isExpanded,
      iconStyleData: IconStyleData(
        icon: Icon(
          Icons.keyboard_arrow_down_outlined,
          color: COLORS.accent,
          size: SizeConfig.blockWidth * 6,
        ),
      ),
      hint: Text(
        hintText,
        style: TextStyle( color: COLORS.accent,
          fontSize: SizeConfig.blockWidth * 3.5,
          fontWeight: FontWeight.w400,
          fontFamily: "Poppins",),
      ),
      items: items.map((item) => DropdownMenuItem<String>(
        value: item,
        child: Text(
          item,
          style:  TextStyle(
            color: COLORS.accent,
            fontSize: SizeConfig.blockWidth * 3.5,
            fontWeight: FontWeight.w400,
            fontFamily: "Poppins",
          ),
        ),
      )).toList(),
      validator: (value) {
        if (value == null || value.isEmpty) {
          return 'Please select an option';
        }
        return null;
      },
      onChanged: onChanged,
      dropdownStyleData: DropdownStyleData(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(SizeConfig.blockWidth * 3),
          color: COLORS.white,
        ),
        offset: const Offset(0, -4),
      ),
    );
  }
}
