import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:modal_bottom_sheet/modal_bottom_sheet.dart';
import 'package:works_app/bloc/profile/profile_bloc.dart';
import 'package:works_app/components/colors.dart';
import 'package:works_app/components/size_config.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:works_app/ui/profile/account_delete_success.dart';

import '../../../bloc/authentication/authentication_bloc.dart';
import '../../../components/global_handle.dart';
import '../../../global_helper/reuse_widget.dart';

class AccountDeleteBottomSheet extends StatefulWidget {
  const AccountDeleteBottomSheet({super.key});

  @override
  _AccountDeleteBottomSheetState createState() =>
      _AccountDeleteBottomSheetState();
}

class _AccountDeleteBottomSheetState extends State<AccountDeleteBottomSheet> {
  final TextEditingController messageController = TextEditingController();
  late ProfileBloc profileBloc;

  bool messageError = false;
  @override
  void initState() {
    super.initState();
    profileBloc = BlocProvider.of<ProfileBloc>(context);
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Padding(
        padding: EdgeInsets.only(
          bottom: MediaQuery.of(context)
              .viewInsets
              .bottom, // Ensure padding for keyboard
        ),
        child: Container(
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
                  Column(
                    mainAxisAlignment: MainAxisAlignment.start,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Are you sure?'.tr(),
                        style: TextStyle(
                          color: COLORS.neutralDark,
                          fontSize: SizeConfig.blockWidth * 4,
                          fontWeight: FontWeight.w500,
                          fontFamily: "Poppins",
                        ),
                      ),
                      Text(
                        'Do you want to delete your account'.tr(),
                        style: TextStyle(
                          color: COLORS.neutralDarkOne,
                          fontSize: SizeConfig.blockWidth * 3.4,
                          fontWeight: FontWeight.w400,
                          fontFamily: "Poppins",
                        ),
                      ),
                    ],
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
              Divider(
                color: COLORS.neutralDarkTwo,
                thickness: SizeConfig.blockHeight * 0.15,
              ),
              SizedBox(
                height: SizeConfig.blockHeight * 2,
              ),
              buildBioTextField(
                label: 'Can you please share the reason with us'.tr(),
                controller: messageController,
                hintText: "Write the reason".tr(),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    setState(() => messageError = true);
                    return 'Please enter a message'.tr();
                  }
                  setState(() => messageError = false);
                  return null;
                },
                error: messageError,
                title: 'Message'.tr(),
                onChanged: (value) {},
              ),
              Container(
                margin: EdgeInsets.only(top: SizeConfig.blockHeight * 1.5),
                padding: EdgeInsets.only(
                    top: SizeConfig.blockHeight * 2.5,
                    bottom: SizeConfig.blockHeight * 1),
                decoration: const BoxDecoration(
                    border: Border(
                        top: BorderSide(
                            color: COLORS.neutralDarkOne, width: 0.1))),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    customButton(
                      text: 'CANCEL'.tr(),
                      onPressed: () {
                        setState(() {});
                        Navigator.pop(context);
                      },
                      backgroundColor: COLORS.primary,
                      showIcon: false,
                      width: SizeConfig.blockWidth * 42,
                      height: SizeConfig.blockHeight * 8,
                      textColor: COLORS.white,
                    ),
                    customButton(
                      text: 'DELETE'.tr(),
                      onPressed: () {
                         profileBloc.add(DeleteAccount(onSuccess: (){
                           GlobalBlocClass.authenticationBloc?.add(const AuthenticationLogoutEvent());
                           Navigator.pushAndRemoveUntil(
                             context,
                             MaterialPageRoute(
                               builder: (context) => const AccountDeleteSuccess(),
                             ),
                                 (Route<dynamic> route) => false,
                           );
                         }, onError: (){
                           showCustomSnackBar(
                             context: context,
                             message: 'Something Went wrong',
                           );
                         }, reason: messageController.text));


                      },
                      backgroundColor: COLORS.semantic,
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
      ),
    );
  }
}
