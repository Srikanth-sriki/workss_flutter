import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:modal_bottom_sheet/modal_bottom_sheet.dart';
import '../../../core/storage_service.dart';
import 'package:works_app/bloc/profile/profile_bloc.dart';
import 'package:works_app/components/colors.dart';
import 'package:works_app/components/size_config.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:works_app/ui/profile/account_delete_success.dart';

import '../../../components/local_constant.dart';
import '../../../global_helper/reuse_widget.dart';

class AccountDeleteBottomSheet extends StatefulWidget {
  const AccountDeleteBottomSheet({super.key});

  @override
  State<AccountDeleteBottomSheet> createState() => _AccountDeleteBottomSheetState();
}

class _AccountDeleteBottomSheetState extends State<AccountDeleteBottomSheet> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController messageController = TextEditingController();
  late final ProfileBloc profileBloc;

  @override
  void initState() {
    super.initState();
    profileBloc = BlocProvider.of<ProfileBloc>(context);
  }

  @override
  void dispose() {
    messageController.dispose();
    super.dispose();
  }

  void _dismissKeyboard() {
    FocusScope.of(context).unfocus();
  }

  Future<void> _handleDelete() async {
    _dismissKeyboard();

    if (!(_formKey.currentState?.validate() ?? false)) return;
    FocusScope.of(context).unfocus();

    profileBloc.add(DeleteAccount(
      reason: messageController.text.trim(),
      onSuccess: (message) async {

        // if (mounted && Navigator.of(context).canPop()) {
        //   Navigator.of(context).pop();
        // }
        await StorageService.remove(LocalConstant.accessToken);
        await StorageService.remove(LocalConstant.userId);
        await StorageService.remove(LocalConstant.profileCompleted);
        await StorageService.remove(LocalConstant.phoneNumber);
        await StorageService.remove(LocalConstant.name);
        await StorageService.setBool(LocalConstant.initialLanguage, false);
        if (!mounted) return;
        Navigator.of(context, rootNavigator: true).pushReplacement(
          MaterialPageRoute(builder: (_) => const AccountDeleteSuccess()),
        );
      },
      onError: (message) {
        if (mounted && Navigator.of(context).canPop()) {
          Navigator.of(context).pop();
        }
        if (!mounted) return;
        showCustomSnackBar(
          context: context,
          message: 'Something Went wrong',
        );
      },
    ));
  }

  @override
  Widget build(BuildContext context) {
    final scrollController = ModalScrollController.of(context);

    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: _dismissKeyboard,
      child: AnimatedPadding(
        padding: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
        duration: const Duration(milliseconds: 150),
        curve: Curves.easeOut,
        child: SafeArea(
          top: false,
          child: Material(
            color: COLORS.white,
            borderRadius: BorderRadius.only(
              topLeft: Radius.circular(SizeConfig.blockWidth * 5),
              topRight: Radius.circular(SizeConfig.blockWidth * 5),
            ),
            child: SingleChildScrollView(
              controller: scrollController,
              keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
              padding: EdgeInsets.symmetric(
                horizontal: SizeConfig.blockWidth * 5,
                vertical: SizeConfig.blockHeight * 2.5,
              ),
              child: Form(
                key: _formKey,
                autovalidateMode: AutovalidateMode.onUserInteraction,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Column(
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
                          onPressed: () {
                            _dismissKeyboard();
                            Navigator.of(context).pop();
                          },
                        ),
                      ],
                    ),
                    Divider(
                      color: COLORS.neutralDarkTwo,
                      thickness: SizeConfig.blockHeight * 0.15,
                    ),
                    SizedBox(height: SizeConfig.blockHeight * 2),
                  buildBioTextField(
                    label: 'Can you please share the reason with us'.tr(),
                    title: 'Can you please share the reason with us'.tr(),
                    controller: messageController,
                    hintText: "Write the reason".tr(),
                    maxLines: 6,
                    validator: (v) => (v == null || v.trim().isEmpty) ? 'Please enter reason'.tr() : null,
                    onChanged: (_) {},
                    error: false,
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
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          customButton(
                            text: 'CANCEL'.tr(),
                            onPressed: () {
                              _dismissKeyboard();
                              Navigator.of(context).pop();
                            },
                            backgroundColor: COLORS.primary,
                            showIcon: false,
                            width: SizeConfig.blockWidth * 42,
                            height: SizeConfig.blockHeight * 8,
                            textColor: COLORS.white,
                          ),
                          customButton(
                            text: 'DELETE'.tr(),
                            onPressed: _handleDelete,
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
          ),
        ),
      ),
    );
  }
}
