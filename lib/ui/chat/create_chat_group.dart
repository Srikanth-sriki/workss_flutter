import 'dart:io';

import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:works_app/components/colors.dart';
import 'package:works_app/ui/chat/group_create_success.dart';

import '../../components/size_config.dart';
import '../../global_helper/ImagePickerComponent.dart';
import '../../global_helper/reuse_widget.dart';
import '../profile/component.dart';
import 'component.dart';

class CreateGroupScreen extends StatefulWidget {
  const CreateGroupScreen({super.key});

  @override
  State<CreateGroupScreen> createState() => _CreateGroupScreenState();
}

class _CreateGroupScreenState extends State<CreateGroupScreen> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController groupName = TextEditingController();
  final TextEditingController groupDescription = TextEditingController();
  bool groupNameError = false;
  bool groupDescriptionError = false;
  bool isSubmitButtonEnabled = false;
  bool groupStepOne = false;
  File? _profileImage;

  void _validateForm() {
    if (groupName.text.isNotEmpty && groupDescription.text.isNotEmpty) {
      setState(() {
        isSubmitButtonEnabled = true;
      });
    }
  }

  void _submitButton() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (BuildContext context) => GroupCreateSuccess(),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: COLORS.white,
      appBar: AppBar(
        backgroundColor: COLORS.primary,
        scrolledUnderElevation: 0,
        elevation: 0,
        automaticallyImplyLeading: false,
        toolbarHeight: SizeConfig.blockHeight * 11,
        title: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    InkWell(
                        onTap: () {
                          Navigator.of(context).pop();
                        },
                        child: Icon(
                          Icons.arrow_back_ios,
                          color: COLORS.white,
                          size: SizeConfig.blockWidth * 4,
                        )),
                    SizedBox(
                      width: SizeConfig.blockWidth * 2.5,
                    ),
                    Text(
                      'Create Group'.tr(),
                      style: TextStyle(
                        color: COLORS.white,
                        fontSize: SizeConfig.blockWidth * 4.6,
                        fontWeight: FontWeight.w400,
                        fontFamily: "Poppins",
                      ),
                    ),
                  ],
                ),
                Container(
                  padding: EdgeInsets.symmetric(
                      horizontal: SizeConfig.blockWidth * 2.5,
                      vertical: SizeConfig.blockHeight),
                  decoration: BoxDecoration(
                      color: COLORS.primaryOne.withOpacity(0.5),
                      borderRadius:
                          BorderRadius.circular(SizeConfig.blockWidth * 2.5)),
                  child: Text(
                    groupStepOne ? 'Step 2'.tr() : 'Step 1'.tr(),
                    style: TextStyle(
                      color: COLORS.white,
                      fontSize: SizeConfig.blockWidth * 3,
                      fontWeight: FontWeight.w400,
                      fontFamily: "Poppins",
                    ),
                  ),
                )
              ],
            ),
            Padding(
              padding:
                  EdgeInsets.symmetric(horizontal: SizeConfig.blockWidth * 7),
              child: Text(
                'Build your own work network'.tr(),
                style: TextStyle(
                  color: COLORS.primaryOne,
                  fontSize: SizeConfig.blockWidth * 3.5,
                  fontWeight: FontWeight.w400,
                  fontFamily: "Poppins",
                ),
              ),
            ),
          ],
        ),
      ),
      body: SafeArea(
          child: groupStepOne != true
              ? SingleChildScrollView(
                  child: Container(
                  width: SizeConfig.screenWidth,
                  padding: EdgeInsets.all(SizeConfig.blockWidth * 4.5),
                  child: Form(
                      key: _formKey,
                      child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisAlignment: MainAxisAlignment.start,
                          children: [
                            _buildProfilePicture(),
                            _buildTextField(
                                label: 'Group Name',
                                controller: groupName,
                                hintText: "Enter group name".tr(),
                                validator: (value) {
                                  if (value == null || value.isEmpty) {
                                    setState(() => groupNameError = true);
                                    return 'Please enter group name'.tr();
                                  }
                                  setState(() => groupNameError = false);
                                  return null;
                                },
                                error: groupNameError,
                                onChanged: (value) {
                                  _validateForm();
                                },
                                title: 'Group Name'.tr()),
                            _buildBioTextField(
                                label: 'Group Description'.tr(),
                                controller: groupDescription,
                                hintText: "Write group description here".tr(),
                                validator: (value) {
                                  if (value == null || value.isEmpty) {
                                    setState(
                                        () => groupDescriptionError = true);
                                    return 'Please enter description'.tr();
                                  }
                                  setState(() => groupDescriptionError = false);
                                  return null;
                                },
                                error: groupDescriptionError,
                                onChanged: (value) {
                                  _validateForm();
                                },
                                title: 'Group Description'.tr()),
                          ])),
                ))
              : Container(
                  width: SizeConfig.screenWidth,
                  padding: EdgeInsets.all(SizeConfig.blockWidth * 4.5),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Text(
                            'Select Friends',
                            style: TextStyle(
                              color: COLORS.neutralDarkOne,
                              fontSize: SizeConfig.blockWidth * 3.8,
                              fontWeight: FontWeight.w400,
                              fontFamily: "Poppins",
                            ),
                          ),
                          InkWell(
                            onTap: () {
                              setState(() {});
                            },
                            child: Icon(
                              Icons.search,
                              color: COLORS.neutralDarkOne,
                              size: SizeConfig.blockWidth * 6,
                            ),
                          ),
                        ],
                      ),
                      SizedBox(
                        height: SizeConfig.blockHeight * 1.5,
                      ),
                      Expanded(
                        child: ListView.builder(
                            itemCount: 5,
                            shrinkWrap: true,
                            scrollDirection: Axis.vertical,
                            itemBuilder: (context, index) {
                              return createGroupInviteCard(
                                image: 'assets/images/home/dumy1.png',
                                name: 'Julia Vandervort-Will',
                                onTapCard: () {},
                                added: index % 2 == 0 ? true : false,
                                disc: 'Mathematics Tutor'
                              );
                            }),
                      )
                    ],
                  ),
                )),
      bottomNavigationBar: Container(
        padding: EdgeInsets.symmetric(vertical: SizeConfig.blockHeight * 2),
        decoration: BoxDecoration(
          border: Border(
              top: BorderSide(
                  color: COLORS.neutralDarkTwo,
                  width: SizeConfig.blockWidth * 0.3)),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            if (groupStepOne != true) ...[
              customButton(
                text: 'CANCEL'.tr(),
                onPressed: () {
                  Navigator.pop(context);
                },
                backgroundColor: COLORS.neutralDarkTwo,
                showIcon: false,
                width: SizeConfig.blockWidth * 42,
                height: SizeConfig.blockHeight * 8,
                textColor: COLORS.black,
              ),
              customButton(
                text: 'NEXT'.tr(),
                onPressed: () {
                  if (_formKey.currentState!.validate()) {
                    setState(() {
                      groupStepOne = true;
                    });
                  }
                },
                backgroundColor: isSubmitButtonEnabled
                    ? COLORS.primary
                    : COLORS.primary.withOpacity(0.4),
                showIcon: false,
                width: SizeConfig.blockWidth * 42,
                height: SizeConfig.blockHeight * 8,
                textColor: COLORS.white,
              )
            ] else ...[
              customButton(
                text: 'BACK'.tr(),
                onPressed: () {
                  setState(() {
                    groupStepOne = false;
                  });
                },
                backgroundColor: COLORS.neutralDarkTwo,
                showIcon: false,
                width: SizeConfig.blockWidth * 42,
                height: SizeConfig.blockHeight * 8,
                textColor: COLORS.black,
              ),
              customButton(
                text: 'CREATE'.tr(),
                onPressed: () {
                  _submitButton();
                },
                backgroundColor: isSubmitButtonEnabled
                    ? COLORS.primary
                    : COLORS.primary.withOpacity(0.4),
                showIcon: false,
                width: SizeConfig.blockWidth * 42,
                height: SizeConfig.blockHeight * 8,
                textColor: COLORS.white,
              )
            ]
          ],
        ),
      ),
    );
  }

  Widget _buildProfilePicture() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.start,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        registerText(text: 'Group Picture'.tr()),
        _profileImage == null
            ? ImagePickerComponent(
                onImageSelected: (File image) {
                  setState(() {
                    print(image);
                    _profileImage = image;
                  });
                },
              )
            : Stack(
                children: [
                  Container(
                    height: SizeConfig.blockWidth * 32,
                    width: SizeConfig.blockWidth * 34,
                    decoration: BoxDecoration(
                        border: Border.all(
                          color: COLORS.primary,
                          width: 1.2,
                        ),
                        image: DecorationImage(
                          image: FileImage(
                            File(_profileImage!.path),
                          ),
                          fit: BoxFit.fill,
                        ),
                        borderRadius:
                            BorderRadius.circular(SizeConfig.blockWidth * 3.5)),
                  ),
                  Positioned(
                    bottom: 0,
                    right: 0,
                    child: ImagePickerModal(
                      onImageSelected: (File image) {
                        setState(() {
                          _profileImage = image;
                        });
                      },
                    ),
                  )
                ],
              ),
        SizedBox(height: SizeConfig.blockHeight * 3),
      ],
    );
  }

  Widget _buildTextField(
      {required String label,
      required TextEditingController controller,
      required String hintText,
      required String? Function(String?) validator,
      required String? Function(String?) onChanged,
      required bool error,
      required String title}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        registerText(text: title),
        normalTextField(
          hintText: hintText,
          controller: controller,
          inputType: TextInputType.text,
          onChanged: onChanged,
          validator: validator,
          fontWeight: FontWeight.w400,
          prefix: false,
          errorMessage: '',
          hasError: error,
        ),
      ],
    );
  }

  Widget _buildBioTextField(
      {required String label,
      required TextEditingController controller,
      required String hintText,
      required String? Function(String?) validator,
      required String? Function(String?) onChanged,
      required bool error,
      required String title}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        registerText(text: title),
        normalTextField(
            hintText: hintText,
            controller: controller,
            inputType: TextInputType.text,
            onChanged: onChanged,
            validator: validator,
            fontWeight: FontWeight.w400,
            prefix: false,
            errorMessage: '',
            hasError: error,
            maxLines: 6),
      ],
    );
  }
}
