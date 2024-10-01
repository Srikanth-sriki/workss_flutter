import 'package:flutter/material.dart';
import 'package:dropdown_button2/dropdown_button2.dart';
import 'package:works_app/components/colors.dart';
import 'package:works_app/components/size_config.dart';
import 'package:works_app/global_helper/reuse_widget.dart';
import 'package:works_app/ui/profile/component.dart';

class CustomDropdownButtonFormField extends StatelessWidget {
  final String? selectedValue;
  final List<String> items;
  final ValueChanged<String?> onChanged;
  final String hintText;
  final double iconSize;
  final Color iconColor;
  final bool isExpanded;
  final DropdownSearchData<String>? dropdownSearchData;

  const CustomDropdownButtonFormField(
      {super.key,
      required this.selectedValue,
      required this.items,
      required this.onChanged,
      this.hintText = 'Select an option',
      this.iconSize = 24.0,
      this.iconColor = Colors.blue,
      this.isExpanded = true,
      this.dropdownSearchData});

  @override
  Widget build(BuildContext context) {
    return DropdownButtonFormField2(
      dropdownSearchData: dropdownSearchData,
      value: selectedValue,
      decoration: InputDecoration(
        contentPadding: EdgeInsets.fromLTRB(
            0, SizeConfig.blockHeight * 2, 0, SizeConfig.blockHeight * 2),
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
        style: TextStyle(
          color: COLORS.accent,
          fontSize: SizeConfig.blockWidth * 3.5,
          fontWeight: FontWeight.w400,
          fontFamily: "Poppins",
        ),
      ),
      items: items
          .map((item) => DropdownMenuItem<String>(
                value: item,
                child: Text(
                  item,
                  style: TextStyle(
                    color: COLORS.accent,
                    fontSize: SizeConfig.blockWidth * 3.5,
                    fontWeight: FontWeight.w400,
                    fontFamily: "Poppins",
                  ),
                ),
              ))
          .toList(),
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

Widget buildDropdown({
  required String label,
  required String hintText,
  required List<String> items,
  required void Function(String?) onChanged,
  required String? Function(String?) validator,
  String?value,
}) {
  final TextEditingController textEditingController = TextEditingController();
  List<String> filteredItems = items;

  return Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      registerText(text: label),
      DropdownButtonFormField2<String>(
        value: value,
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
          maxHeight: SizeConfig.blockHeight*40
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
            color: COLORS.neutralDarkOne,
          ),
        ),
        items: filteredItems
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
        dropdownSearchData: DropdownSearchData(
          searchController: textEditingController,
          searchInnerWidgetHeight: SizeConfig.blockHeight * 7,
          searchInnerWidget: Container(
            height: SizeConfig.blockHeight * 7,
            margin: EdgeInsets.only(top: SizeConfig.blockHeight * 2),
            padding:
            EdgeInsets.symmetric(horizontal: SizeConfig.blockWidth * 3),
            child: TextFormField(
              expands: true,
              maxLines: null,
              controller: textEditingController,
              onChanged: (value) {
                // Update filteredItems based on search query
                filteredItems = items
                    .where((item) =>
                    item.toLowerCase().contains(value.toLowerCase()))
                    .toList();
              },
              decoration: InputDecoration(
                isDense: true,
                contentPadding: EdgeInsets.symmetric(
                  horizontal: SizeConfig.blockWidth * 3,
                  vertical: SizeConfig.blockHeight,
                ),
                hintText: 'Search for an $label...',
                hintStyle: TextStyle(
                  fontWeight: FontWeight.w400,
                  fontFamily: "Poppins",
                  fontSize: SizeConfig.blockWidth * 3.2,
                  color: COLORS.neutralDark,
                ),
                border: OutlineInputBorder(
                  borderRadius:
                  BorderRadius.circular(SizeConfig.blockWidth * 3),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius:
                  BorderRadius.circular(SizeConfig.blockWidth * 3),
                  borderSide: const BorderSide(
                    color: COLORS.primary,
                    width: 1,
                  ),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(SizeConfig.blockWidth * 3),
                  borderSide: const BorderSide(
                    color: COLORS.neutralDarkOne,
                    width: 1,
                  ),
                ),
              ),
            ),
          ),
          searchMatchFn: (item, searchValue) {
            return item.value.toString().toLowerCase().contains(searchValue.toLowerCase());
          },
        ),
        onMenuStateChange: (isOpen) {
          if (!isOpen) {
            textEditingController.clear();
            filteredItems = items; // Reset the list when dropdown closes
          }
        },
      ),
      SizedBox(height: SizeConfig.blockHeight * 2),
    ],
  );
}

