import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:modal_bottom_sheet/modal_bottom_sheet.dart';
import 'package:works_app/components/colors.dart';
import 'package:works_app/components/size_config.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:works_app/ui/profile/logout_success.dart';

import '../../../bloc/profile/profile_bloc.dart';
import '../../../components/global_handle.dart';
import '../../../global_helper/reuse_widget.dart';

class AddressListDeleteBottomSheet extends StatefulWidget {
  final String addressId;
  final VoidCallback refreshPageCallback;

  const AddressListDeleteBottomSheet({required this.addressId,  required this.refreshPageCallback,super.key});

  @override
  _AddressListDeleteBottomSheetState createState() => _AddressListDeleteBottomSheetState();
}

class _AddressListDeleteBottomSheetState extends State<AddressListDeleteBottomSheet> {
  late ProfileBloc profileBloc;

  @override
  void initState() {
    super.initState();
    profileBloc = BlocProvider.of<ProfileBloc>(context); // Access the ProfileBloc instance
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: SizeConfig.blockHeight * 45,
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
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          SizedBox(height: SizeConfig.blockHeight * 3.5),
          Image.asset(
            'assets/images/profile/delete_2d.png',
            height: SizeConfig.blockWidth * 15,
            width: SizeConfig.blockWidth * 15,
            fit: BoxFit.contain,
          ),
          SizedBox(height: SizeConfig.blockHeight * 3),
          Padding(
            padding: EdgeInsets.symmetric(vertical: SizeConfig.blockHeight * 0.5),
            child: Text(
              "Are you sure you want to \ndelete this address?".tr(),
              style: TextStyle(
                color: COLORS.neutralDark,
                fontSize: SizeConfig.blockWidth * 3.8,
                fontWeight: FontWeight.w600,
                fontFamily: "Poppins",
              ),
              textAlign: TextAlign.center,
            ),
          ),
          Text(
            "This action cannot be undone.".tr(),
            style: TextStyle(
              color: COLORS.neutralDarkOne,
              fontSize: SizeConfig.blockWidth * 3.4,
              fontWeight: FontWeight.w400,
              fontFamily: "Poppins",
            ),
            textAlign: TextAlign.center,
          ),
          SizedBox(height: SizeConfig.blockHeight * 2),
          Container(
            padding: EdgeInsets.only(
              top: SizeConfig.blockHeight * 2.5,
              bottom: SizeConfig.blockHeight * 1,
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                customButton(
                  text: 'CANCEL'.tr(),
                  onPressed: () {
                    Navigator.pop(context);
                  },
                  backgroundColor: COLORS.primary,
                  showIcon: false,
                  width: SizeConfig.blockWidth * 40,
                  height: SizeConfig.blockHeight * 8,
                  textColor: COLORS.white,
                ),
                customButton(
                  text: 'DELETE'.tr(),
                  onPressed: () {
                    profileBloc.add(
                      AddressLocationIdDelete(
                        id: widget.addressId, // Use the passed address ID
                        onSuccess: () {
                          Navigator.pop(context); // Close the bottom sheet
                          showCustomSnackBar(
                            context: context,
                            message: "Address deleted successfully",
                            backgroundColor: COLORS.semanticTwo,
                          );
                          widget.refreshPageCallback();
                        },
                        onError: () {
                          showCustomSnackBar(
                            context: context,
                            message: "Something went wrong",
                          );
                        },
                      ),
                    );
                  },
                  backgroundColor: COLORS.semantic,
                  showIcon: false,
                  width: SizeConfig.blockWidth * 40,
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
