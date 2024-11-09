import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:modal_bottom_sheet/modal_bottom_sheet.dart';
import 'package:works_app/components/colors.dart';
import 'package:works_app/components/size_config.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:works_app/ui/profile/logout_success.dart';

import '../../../bloc/authentication/authentication_bloc.dart';
import '../../../bloc/profile/profile_bloc.dart';
import '../../../components/global_handle.dart';
import '../../../global_helper/reuse_widget.dart';
import '../location/location_list.dart';

class AddressSuccessBottomSheet extends StatefulWidget {
  final String? routePage;
  const AddressSuccessBottomSheet({super.key,required this.routePage});

  @override
  _AddressSuccessBottomSheetState createState() =>
      _AddressSuccessBottomSheetState();
}

class _AddressSuccessBottomSheetState extends State<AddressSuccessBottomSheet> {
  final TextEditingController messageController = TextEditingController();

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
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          SizedBox(
            height: SizeConfig.blockHeight * 3,
          ),
          Image.asset(
            'assets/images/profile/success.png',
            height: SizeConfig.blockWidth * 15,
            width: SizeConfig.blockWidth * 15,
            fit: BoxFit.contain,
          ),
          SizedBox(
            height: SizeConfig.blockHeight * 3.5,
          ),
          Text(
            "Address Saved Successfully!".tr(),
            style: TextStyle(
              color: COLORS.neutralDark,
              fontSize: SizeConfig.blockWidth * 3.8,
              fontWeight: FontWeight.w600,
              fontFamily: "Poppins",
            ),
          ),
          SizedBox(height: SizeConfig.blockHeight),
          Text(
            "Your address is saved securely for quick \naccess in future transactions."
                .tr(),
            style: TextStyle(
              color: COLORS.neutralDarkOne,
              fontSize: SizeConfig.blockWidth * 3.4,
              fontWeight: FontWeight.w400,
              fontFamily: "Poppins",
            ),
            textAlign: TextAlign.center,
          ),
          Container(
            margin: EdgeInsets.only(top: SizeConfig.blockHeight * 2.5),
            padding: EdgeInsets.only(
                top: SizeConfig.blockHeight * 2.5,
                bottom: SizeConfig.blockHeight * 1),
            child: customButton(
              text: 'Okay'.tr(),
              onPressed: () {
                if(widget.routePage == 'modal'){
                  Navigator.pop(context);
                  Navigator.pop(context);
                }
                else{
                  Navigator.pop(context);
                  Navigator.pop(context);
                  Navigator.pop(context);

                  Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) => MultiBlocProvider(
                            providers: [
                              BlocProvider(
                                  create: (context) => ProfileBloc()
                                    ..add(const AddressLocationListEvent())),
                            ],
                            child: const LocationListScreen(),
                          )));
                }

              },
              backgroundColor: COLORS.primary,
              showIcon: false,
              width: SizeConfig.blockWidth * 100,
              height: SizeConfig.blockHeight * 8,
              textColor: COLORS.white,
            ),
          ),
        ],
      ),
    );
  }
}
