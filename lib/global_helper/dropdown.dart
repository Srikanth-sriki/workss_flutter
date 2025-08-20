import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:dropdown_button2/dropdown_button2.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';
import 'package:works_app/components/colors.dart';
import 'package:works_app/components/size_config.dart';
import 'package:works_app/global_helper/reuse_widget.dart';
import 'package:works_app/ui/profile/component.dart';

import 'helper_function.dart';

class DropdownItemValue {
  final String id;
  final String label;
  DropdownItemValue({required this.id, required this.label});
}


class CustomDropdownButtonFormField extends StatelessWidget {
  final DropdownItemValue? selectedValue;
  final List<DropdownItemValue> items;
  final ValueChanged<DropdownItemValue> onChanged;
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
      // dropdownSearchData: dropdownSearchData,
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
          .map((item) => DropdownMenuItem<DropdownItemValue>(
        value: item,
        child: Text(
          item.label,
          style: TextStyle(
            color: COLORS.accent,
            fontSize: SizeConfig.blockWidth * 3.5,
            fontWeight: FontWeight.w400,
            fontFamily: "Poppins",
          ),
        ),
      ))
          .toList(),
      // onChanged: (DropdownItemValue? newValue) {
      //   setState(() {
      //     selectedItem = newValue;
      //   });
      // },
      validator: (val) {
        if (val == null) {
          return 'Please select an option';
        }
        return null;
      },
      onChanged: (DropdownItemValue? newValue) {
        if(newValue != null){
          onChanged(newValue) ;
        }
      },

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

Widget buildDropdown(
    {required String label,
    required String hintText,
      required List<String> items,
      required void Function(String?) onChanged,
    required String? Function(String?) validator,
    String? value,
    bool? itemLoading = false,
    Color? color = COLORS.neutralDark,
    FontWeight? fontWeight = FontWeight.w500}) {
  final TextEditingController textEditingController = TextEditingController();
  List<String> filteredItems = items;

  return Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      registerText(text: label, color: color, fontWeight: fontWeight),
      DropdownButtonFormField2<String>(
        buttonStyleData: ButtonStyleData(height: SizeConfig.blockHeight * 5),
        value: value,
        isDense: true,autofocus: true,
        menuItemStyleData: MenuItemStyleData(
          height: SizeConfig.blockHeight * 6,
        ),
        decoration: InputDecoration(
            contentPadding: EdgeInsets.symmetric(
              vertical: SizeConfig.blockHeight * 1.5,
              horizontal: SizeConfig.blockWidth * 3,
            ),
            errorStyle: TextStyle(
              fontWeight: FontWeight.w400,
              fontFamily: "Poppins",
              fontSize: SizeConfig.blockWidth * 3.1,
              color: COLORS.semantic,
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
                color: COLORS.neutralDarkTwo,
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
            constraints: BoxConstraints(
                minHeight: SizeConfig.blockHeight * 8,
                maxHeight: SizeConfig.blockHeight * 15)),
        dropdownStyleData: DropdownStyleData(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(SizeConfig.blockWidth * 3),
            color: COLORS.white,
          ),
          //offset: Offset(0, SizeConfig.blockHeight * 0), // Moves dropdown below
          maxHeight: SizeConfig.blockHeight * 50, // Set a max height
        ),

        isExpanded: true,
        style: TextStyle(
          fontSize: SizeConfig.blockWidth * 3,
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
                    capitalizeEachWord(item),
                    style: TextStyle(
                      fontSize: SizeConfig.blockWidth * 3.5,
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
          icon: itemLoading!
              ? LoadingAnimationWidget.discreteCircle(
                  color: COLORS.accent,
                  size: SizeConfig.blockWidth * 4,
                )
              : Icon(
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
                hintText: '${'Search for an'.tr()} $label...',
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
                  borderRadius:
                      BorderRadius.circular(SizeConfig.blockWidth * 3),
                  borderSide: const BorderSide(
                    color: COLORS.neutralDarkOne,
                    width: 1,
                  ),
                ),
              ),
            ),
          ),
          searchMatchFn: (item, searchValue) {
            return item.value
                .toString()
                .toLowerCase()
                .contains(searchValue.toLowerCase());
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

Widget buildDropdownTwo({
  required String label,
  required String hintText,
  required List<DropdownItemValue> items,
  required void Function(DropdownItemValue) onChanged,
  required String? Function(String?) validator,
  DropdownItemValue? value,
  bool? itemLoading = false,
  Color? color = COLORS.neutralDark,
  FontWeight? fontWeight = FontWeight.w500,
}) {
  final TextEditingController textEditingController = TextEditingController();
  // List<DropdownItemValue> filteredItems = items;
  // List<DropdownItemValue> filteredItems = [...items]
  //   ..sort((a, b) => ascending
  //       ? a.label.toLowerCase().compareTo(b.label.toLowerCase())
  //       : b.label.toLowerCase().compareTo(a.label.toLowerCase()));
  List<DropdownItemValue> filteredItems = [...items]
    ..sort((a, b) =>
         a.label.toLowerCase().compareTo(b.label.toLowerCase()));



  return Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      registerText(text: label, color: color, fontWeight: fontWeight),
      DropdownButtonFormField2<DropdownItemValue>(
        buttonStyleData: ButtonStyleData(height: SizeConfig.blockHeight * 5),
        value: value,
        isDense: true,
        autofocus: true,
        menuItemStyleData: MenuItemStyleData(
          height: SizeConfig.blockHeight * 6,
        ),
        decoration: InputDecoration(
            contentPadding: EdgeInsets.symmetric(
              vertical: SizeConfig.blockHeight * 1.5,
              horizontal: SizeConfig.blockWidth * 3,
            ),
            errorStyle: TextStyle(
              fontWeight: FontWeight.w400,
              fontFamily: "Poppins",
              fontSize: SizeConfig.blockWidth * 3.1,
              color: COLORS.semantic,
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
                color: COLORS.neutralDarkTwo,
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
            constraints: BoxConstraints(
                minHeight: SizeConfig.blockHeight * 8,
                maxHeight: SizeConfig.blockHeight * 15)),
        dropdownStyleData: DropdownStyleData(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(SizeConfig.blockWidth * 3),
            color: COLORS.white,
          ),
          maxHeight: SizeConfig.blockHeight * 50,
        ),
        isExpanded: true,
        style: TextStyle(
          fontSize: SizeConfig.blockWidth * 3,
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
            .map((item) => DropdownMenuItem<DropdownItemValue>(
          value: item,
          child: Text(
            capitalizeEachWord(item.label),
            style: TextStyle(
              fontSize: SizeConfig.blockWidth * 3.5,
              color: COLORS.neutralDark,
              fontWeight: FontWeight.w400,
              fontFamily: "Poppins",
            ),
          ),
        ))
            .toList(),
        onChanged: (DropdownItemValue? selectedProfession) {
          if (selectedProfession != null) {
            onChanged(selectedProfession); // Pass the Profession object to callback
          }
        },
        validator: (selectedProfession) {
          return validator(selectedProfession?.label);
        },
        iconStyleData: IconStyleData(
          icon: itemLoading!
              ? LoadingAnimationWidget.discreteCircle(
            color: COLORS.accent,
            size: SizeConfig.blockWidth * 4,
          )
              : Icon(
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
                filteredItems = items
                    .where((item) =>
                    item.label.toLowerCase().contains(value.toLowerCase()))
                    .toList();
              },
              decoration: InputDecoration(
                isDense: true,
                contentPadding: EdgeInsets.symmetric(
                  horizontal: SizeConfig.blockWidth * 3,
                  vertical: SizeConfig.blockHeight,
                ),
                hintText: '${'Search for an'.tr()} $label...',
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
                  borderRadius:
                  BorderRadius.circular(SizeConfig.blockWidth * 3),
                  borderSide: const BorderSide(
                    color: COLORS.neutralDarkOne,
                    width: 1,
                  ),
                ),
              ),
            ),
          ),
          searchMatchFn: (item, searchValue) {
            return item.value!
                .label
                .toString()
                .toLowerCase()
                .contains(searchValue.toLowerCase());
          },
        ),
        onMenuStateChange: (isOpen) {
          if (!isOpen) {
            textEditingController.clear();
            filteredItems = items;
            // If using stateful widget, call setState here
          }
        },
      ),
      SizedBox(height: SizeConfig.blockHeight * 2),
    ],
  );
}





// Widget buildDropdown2({
//   required String label,
//   required String hintText,
//   required List<Map<String, String>> items, // <-- updated
//   required void Function(String?) onChanged,
//   required String? Function(String?) validator,
//   String? value,
//   bool? itemLoading = false,
//   Color? color = COLORS.neutralDark,
//   FontWeight? fontWeight = FontWeight.w500,
// }) {
//   final TextEditingController textEditingController = TextEditingController();
//   List<Map<String, String>> filteredItems = List.from(items);
//
//   return Column(
//     crossAxisAlignment: CrossAxisAlignment.start,
//     children: [
//       registerText(text: label, color: color, fontWeight: fontWeight),
//       DropdownButtonFormField2<String>(
//         value: value,
//         isDense: true,
//         autofocus: true,
//         buttonStyleData: ButtonStyleData(height: SizeConfig.blockHeight * 5),
//         menuItemStyleData: MenuItemStyleData(
//           height: SizeConfig.blockHeight * 6,
//         ),
//         decoration: InputDecoration(
//           contentPadding: EdgeInsets.symmetric(
//             vertical: SizeConfig.blockHeight * 1.5,
//             horizontal: SizeConfig.blockWidth * 3,
//           ),
//           errorStyle: TextStyle(
//             fontWeight: FontWeight.w400,
//             fontFamily: "Poppins",
//             fontSize: SizeConfig.blockWidth * 3.1,
//             color: COLORS.semantic,
//           ),
//           enabledBorder: OutlineInputBorder(
//             borderRadius: BorderRadius.circular(SizeConfig.blockWidth * 3),
//             borderSide: const BorderSide(
//               color: COLORS.neutralDarkTwo,
//               width: 1,
//             ),
//           ),
//           focusedBorder: OutlineInputBorder(
//             borderRadius: BorderRadius.circular(SizeConfig.blockWidth * 3),
//             borderSide: const BorderSide(
//               color: COLORS.primary,
//               width: 1,
//             ),
//           ),
//           errorBorder: OutlineInputBorder(
//             borderRadius: BorderRadius.circular(SizeConfig.blockWidth * 3),
//             borderSide: const BorderSide(
//               color: COLORS.semantic,
//               width: 1,
//             ),
//           ),
//           focusedErrorBorder: OutlineInputBorder(
//             borderRadius: BorderRadius.circular(SizeConfig.blockWidth * 3),
//             borderSide: const BorderSide(
//               color: COLORS.semantic,
//               width: 1.5,
//             ),
//           ),
//           constraints: BoxConstraints(
//             minHeight: SizeConfig.blockHeight * 8,
//             maxHeight: SizeConfig.blockHeight * 15,
//           ),
//         ),
//         dropdownStyleData: DropdownStyleData(
//           decoration: BoxDecoration(
//             borderRadius: BorderRadius.circular(SizeConfig.blockWidth * 3),
//             color: COLORS.white,
//           ),
//           maxHeight: SizeConfig.blockHeight * 50,
//         ),
//         isExpanded: true,
//         style: TextStyle(
//           fontSize: SizeConfig.blockWidth * 3,
//           color: COLORS.neutralDark,
//           fontWeight: FontWeight.w400,
//           fontFamily: "Poppins",
//         ),
//         hint: Text(
//           hintText,
//           style: TextStyle(
//             fontWeight: FontWeight.w400,
//             fontFamily: "Poppins",
//             fontSize: SizeConfig.blockWidth * 3.2,
//             color: COLORS.neutralDarkOne,
//           ),
//         ),
//         items: filteredItems.map((item) {
//           return DropdownMenuItem<String>(
//             value: item['id'],
//             child: Text(
//               capitalizeEachWord(item['name'] ?? ''),
//               style: TextStyle(
//                 fontSize: SizeConfig.blockWidth * 3.5,
//                 color: COLORS.neutralDark,
//                 fontWeight: FontWeight.w400,
//                 fontFamily: "Poppins",
//               ),
//             ),
//           );
//         }).toList(),
//         onChanged: onChanged,
//         validator: validator,
//         iconStyleData: IconStyleData(
//           icon: itemLoading!
//               ? LoadingAnimationWidget.discreteCircle(
//             color: COLORS.accent,
//             size: SizeConfig.blockWidth * 4,
//           )
//               : Icon(
//             Icons.keyboard_arrow_down_outlined,
//             color: COLORS.accent,
//             size: SizeConfig.blockWidth * 6,
//           ),
//         ),
//         dropdownSearchData: DropdownSearchData(
//           searchController: textEditingController,
//           searchInnerWidgetHeight: SizeConfig.blockHeight * 7,
//           searchInnerWidget: Container(
//             height: SizeConfig.blockHeight * 7,
//             margin: EdgeInsets.only(top: SizeConfig.blockHeight * 2),
//             padding: EdgeInsets.symmetric(horizontal: SizeConfig.blockWidth * 3),
//             child: TextFormField(
//               expands: true,
//               maxLines: null,
//               controller: textEditingController,
//               onChanged: (searchText) {
//                 filteredItems = items
//                     .where((item) =>
//                     item['name']!
//                         .toLowerCase()
//                         .contains(searchText.toLowerCase()))
//                     .toList();
//               },
//               decoration: InputDecoration(
//                 isDense: true,
//                 contentPadding: EdgeInsets.symmetric(
//                   horizontal: SizeConfig.blockWidth * 3,
//                   vertical: SizeConfig.blockHeight,
//                 ),
//                 hintText: 'Search for an $label...',
//                 hintStyle: TextStyle(
//                   fontWeight: FontWeight.w400,
//                   fontFamily: "Poppins",
//                   fontSize: SizeConfig.blockWidth * 3.2,
//                   color: COLORS.neutralDark,
//                 ),
//                 border: OutlineInputBorder(
//                   borderRadius: BorderRadius.circular(SizeConfig.blockWidth * 3),
//                 ),
//                 focusedBorder: OutlineInputBorder(
//                   borderRadius: BorderRadius.circular(SizeConfig.blockWidth * 3),
//                   borderSide: const BorderSide(
//                     color: COLORS.primary,
//                     width: 1,
//                   ),
//                 ),
//                 enabledBorder: OutlineInputBorder(
//                   borderRadius: BorderRadius.circular(SizeConfig.blockWidth * 3),
//                   borderSide: const BorderSide(
//                     color: COLORS.neutralDarkOne,
//                     width: 1,
//                   ),
//                 ),
//               ),
//             ),
//           ),
//           searchMatchFn: (item, searchValue) {
//             return item.value
//                 .toString()
//                 .toLowerCase()
//                 .contains(searchValue.toLowerCase());
//           },
//         ),
//         onMenuStateChange: (isOpen) {
//           if (!isOpen) {
//             textEditingController.clear();
//             filteredItems = List.from(items); // Reset
//           }
//         },
//       ),
//       SizedBox(height: SizeConfig.blockHeight * 2),
//     ],
//   );
// }
