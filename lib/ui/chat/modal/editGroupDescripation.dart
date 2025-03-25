import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:works_app/components/colors.dart';
import 'package:works_app/components/size_config.dart';
import 'package:easy_localization/easy_localization.dart';
import '../../../bloc/chart/chart_bloc.dart';
import '../../../global_helper/reuse_widget.dart';
import '../../../models/chat/chat_view_pro_modal.dart';

class EditGroupDescriptionModal extends StatefulWidget {
  final ChatViewGroupInfo chatViewGroupInfo;
  final VoidCallback refreshPageCallback;
  const EditGroupDescriptionModal({super.key, required this.chatViewGroupInfo,required this.refreshPageCallback});

  @override
  _EditGroupDescriptionModalState createState() =>
      _EditGroupDescriptionModalState();
}

class _EditGroupDescriptionModalState extends State<EditGroupDescriptionModal> {
  final _formKey = GlobalKey<FormState>();
  late ChartBloc chartBloc;
  final TextEditingController messageController = TextEditingController();
  bool messageError = false;

  @override
  void initState() {
    super.initState();
    chartBloc = BlocProvider.of<ChartBloc>(context);
    messageController.text = widget.chatViewGroupInfo.description!;
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
          child: Form(
            key: _formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Group Description'.tr(),
                      style: TextStyle(
                        color: COLORS.neutralDark,
                        fontSize: SizeConfig.blockWidth * 4,
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
                Divider(
                  color: COLORS.neutralDarkTwo,
                  thickness: SizeConfig.blockHeight * 0.15,
                ),
                buildBioTextField(
                    label: ''.tr(),
                    controller: messageController,
                    hintText: "Enter Group Description".tr(),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        setState(() => messageError = true);
                        return 'Please enter Group Description'.tr();
                      }
                      setState(() => messageError = false);
                      return null;
                    },
                    error: messageError,
                    title: ''.tr(),
                    onChanged: (value) {},
                    maxLines: 5),
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
                        backgroundColor: COLORS.neutralDarkTwo,
                        showIcon: false,
                        width: SizeConfig.blockWidth * 42,
                        height: SizeConfig.blockHeight * 8,
                        textColor: COLORS.neutralDark,
                      ),
                      customButton(
                        text: 'SAVE'.tr(),
                        onPressed: () {
                          if (_formKey.currentState!.validate()) {
                            chartBloc.add(EditGroupChatProfileEvent(
                                picture: widget.chatViewGroupInfo.picture!,
                                name: widget.chatViewGroupInfo.name!,
                                description: messageController.text,
                                chatId: widget.chatViewGroupInfo.id!,
                              onSuccess: (message){
                                widget.refreshPageCallback();
                                Navigator.pop(context);
                              },
                              onError: (message) {
                                Navigator.pop(context);
                                showCustomSnackBar(
                                  context: context,
                                  message: message,
                                );
                              },


                            ));
                          }
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
        ),
      ),
    );
  }
}
