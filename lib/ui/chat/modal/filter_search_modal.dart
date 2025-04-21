import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:works_app/components/colors.dart';
import 'package:works_app/components/size_config.dart';

import '../../../bloc/register_account/initial_register_bloc.dart';
import '../../../global_helper/reuse_widget.dart';

class CustomFilterBottomSheet extends StatefulWidget {
  final String title;
  final bool showSearch;
  final List<String> options;
  final List<String> selectedOptions;
  final Function(List<String>) onSubmit;

  const CustomFilterBottomSheet({
    Key? key,
    required this.title,
    this.showSearch = false,
    required this.options,
    this.selectedOptions = const [],
    required this.onSubmit,
  }) : super(key: key);

  @override
  State<CustomFilterBottomSheet> createState() => _CustomFilterBottomSheetState();
}

class _CustomFilterBottomSheetState extends State<CustomFilterBottomSheet> {
  String? selectedOption;
  String searchText = '';
  late InitialRegisterBloc initialRegisterBloc;
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    initialRegisterBloc = BlocProvider.of<InitialRegisterBloc>(context);

    // Use first selected option if available
    if (widget.selectedOptions.isNotEmpty) {
      selectedOption = widget.selectedOptions.first;
    }
  }

  @override
  Widget build(BuildContext context) {
    final filteredOptions = widget.options.where((option) {
      return option.toLowerCase().contains(searchText.toLowerCase());
    }).toList();

    return Container(
      padding: EdgeInsets.all(SizeConfig.blockWidth * 5.5),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.vertical(top: Radius.circular(SizeConfig.blockWidth * 6)),
        color: COLORS.white,
      ),
      child: SafeArea(
        top: false,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              widget.title,
              style: TextStyle(
                color: COLORS.neutralDark,
                fontSize: SizeConfig.blockWidth * 4.5,
                fontWeight: FontWeight.w500,
                fontFamily: "Poppins",
              ),
            ),

            if (widget.showSearch)
              Padding(
                padding: EdgeInsets.symmetric(vertical: SizeConfig.blockHeight * 3.5),
                child: TextField(
                  controller: _searchController,
                  style: TextStyle(
                    color: COLORS.neutralDarkOne,
                    fontSize: SizeConfig.blockWidth * 3.25,
                    fontWeight: FontWeight.w400,
                    fontFamily: "Poppins",
                  ),
                  cursorColor: COLORS.black,
                  decoration: InputDecoration(
                    fillColor: COLORS.neutralDarkTwo.withOpacity(0.6),
                    filled: true,
                    hintText: 'Ex: Search'.tr(),
                    hintStyle: TextStyle(
                      color: COLORS.neutralDarkOne,
                      fontSize: SizeConfig.blockWidth * 3.25,
                      fontWeight: FontWeight.w400,
                      fontFamily: "Poppins",
                    ),
                    prefixIcon: Padding(
                      padding: EdgeInsets.all(SizeConfig.blockWidth * 4),
                      child: Image.asset(
                        'assets/images/home/search.png',
                        width: SizeConfig.blockWidth * 3.5,
                        height: SizeConfig.blockWidth * 3.5,
                        fit: BoxFit.cover,
                      ),
                    ),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(SizeConfig.blockWidth * 3.25),
                      borderSide: BorderSide(
                        color: COLORS.neutralDarkTwo.withOpacity(0.6),
                        width: SizeConfig.blockWidth * 0.1,
                      ),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(SizeConfig.blockWidth * 3.25),
                      borderSide: BorderSide(
                        color: COLORS.neutralDarkTwo.withOpacity(0.6),
                        width: SizeConfig.blockWidth * 0.1,
                      ),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(SizeConfig.blockWidth * 3.25),
                      borderSide: BorderSide(
                        color: COLORS.neutralDarkTwo.withOpacity(0.6),
                        width: SizeConfig.blockWidth * 0.1,
                      ),
                    ),
                  ),
                  onChanged: (val) => setState(() => searchText = val),
                ),
              ),

            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: filteredOptions.map((option) {
                final isSelected = selectedOption == option;
                return ChoiceChip(
                  showCheckmark: false,
                  side: BorderSide(
                    color: isSelected ? COLORS.primary : COLORS.neutralDarkTwo,
                  ),
                  label: Text(
                    option,
                    style: TextStyle(
                      color: isSelected ? COLORS.white : COLORS.neutralDark,
                      fontSize: SizeConfig.blockWidth * 3.3,
                      fontWeight: FontWeight.w400,
                      fontFamily: "Poppins",
                    ),
                  ),
                  selected: isSelected,
                  onSelected: (_) {
                    setState(() {
                      selectedOption = isSelected ? null : option;
                    });
                  },
                  selectedColor: COLORS.primary,
                  labelStyle: TextStyle(
                    color: isSelected ? COLORS.white : COLORS.neutralDark,
                  ),
                  backgroundColor: COLORS.neutralDarkTwo,
                );
              }).toList(),
            ),

             SizedBox(height: SizeConfig.blockHeight*2.5),
            Divider(
              color: COLORS.neutralDarkTwo,
              height: SizeConfig.blockHeight,
              thickness: SizeConfig.blockWidth * 0.15,
            ),
            SizedBox(height: SizeConfig.blockHeight*2.5),
            customButton(
              text: 'SUBMIT'.tr(),
              onPressed: () {
                if (selectedOption != null) {
                  widget.onSubmit([selectedOption!]); // sending single selection in list
                } else {
                  widget.onSubmit([]); // no selection
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
    );
  }
}
