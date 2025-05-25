import 'dart:io';

import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:image_picker/image_picker.dart';

import '../../bloc/post_work/post_work_bloc.dart';
import '../../components/colors.dart';
import '../../components/size_config.dart';
import '../../global_helper/ImagePickerComponent.dart';
import '../../global_helper/reuse_widget.dart';

class KYCVerificationScreen extends StatefulWidget {
  final String isVerified;

  const KYCVerificationScreen({super.key, required this.isVerified});

  @override
  State<KYCVerificationScreen> createState() => _KYCVerificationScreenState();
}

class _KYCVerificationScreenState extends State<KYCVerificationScreen> {

  bool imagesList = false;
  List<File> _selectedImages = [];
  List<String> workImages = [];
  bool loading = false;
  late PostWorkBloc postWorkBloc;

  @override
  void initState() {
    super.initState();
    postWorkBloc = BlocProvider.of<PostWorkBloc>(context);
  }

  void _onImagesSelected(List<File> images) {
    setState(() {
      _selectedImages = images;
    });

    for (final image in _selectedImages) {
      postWorkBloc.add(UploadMultipleImageEvent(imagePath: image));
    }
  }

  void _removeImage(int index) {
    setState(() {
      if (index >= 0 && index < _selectedImages.length) {
        _selectedImages.removeAt(index);
      }
      if (index < workImages.length) {
        workImages.removeAt(index);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    if (widget.isVerified == "verified") {
      return _buildVerifiedUI();
    } else if (widget.isVerified == "submitted") {
      return _buildVerifyingUI();
    } else {
      return _buildPendingUI();
    }
  }

  Widget _buildPendingUI() {
    return Scaffold(
      backgroundColor: COLORS.white,
      appBar: CustomAppBar(
        title: 'KYC Verification'.tr(),
        backgroundColor: COLORS.white,
        titleColors: COLORS.neutralDark,
        textCap: false,
      ),
      body: BlocListener<PostWorkBloc, PostWorkState>(
        listener: (context, state) {
          if (state is UploadMultipleImageSuccess) {
            FocusScope.of(context).unfocus();
            setState(() {
              workImages.add(state.filePath);
            });
          } else if (state is UploadImageFailed) {
            FocusScope.of(context).unfocus();
            setState(() => loading = false);
            showCustomSnackBar(context: context, message: state.message);
          } else if (state is KycImageAddedSuccess) {
            if (mounted) {
              showCustomSnackBar(context: context, message: state.message);
              setState(() => loading = false);
              Navigator.pushNamed(context, '/main_screen', arguments: {'selectedIndex': 0});
            }
          } else if (state is KycImageAddedFailed) {
            setState(() => loading = false);
            showCustomSnackBar(context: context, message: state.message);
          }
        },
        child: Padding(
          padding: EdgeInsets.symmetric(
              horizontal: SizeConfig.blockWidth * 5.5,
              vertical: SizeConfig.blockHeight * 2.5),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Image.asset(
                "assets/images/profile/kyc_verifying.png",
                width: SizeConfig.blockWidth * 60,
                height: SizeConfig.blockWidth * 60,
              ),
              SizedBox(height: SizeConfig.blockHeight * 3),
              Text(
                "Aadhaar verification is pending!".tr(),
                style: TextStyle(
                  color: COLORS.neutralDark,
                  fontSize: SizeConfig.blockWidth * 4.25,
                  fontWeight: FontWeight.w500,
                  fontFamily: "Poppins",
                ),
                textAlign: TextAlign.center,
              ),
              SizedBox(height: SizeConfig.blockHeight * 2),
              MultipleImagePickerComponent(
                onImagesSelected: _onImagesSelected,
                error: imagesList,
                removeImage: _removeImage,
                defaultImages: [],
                filedConatinerText:
                'We need to take a picture of both sides of \nyour Aadhaar card to verify \nyour identity.',
                headerNeed: false,
              ),
              SizedBox(height: SizeConfig.blockHeight * 4),
              customButton(
                text: 'SUBMIT'.tr(),
                onPressed: () {
                  print(workImages);
                  if (workImages.length == 2) {
                    postWorkBloc.add(PostVerifyKycImages(
                      backImg: workImages[0],
                      firstImg: workImages[1],
                    ));
                    setState(() => loading = true);
                  } else {
                    showCustomSnackBar(
                      context: context,
                      message: 'Please upload both Aadhaar images',
                    );
                  }
                },
                backgroundColor: COLORS.primary,
                showIcon: false,
                width: SizeConfig.blockWidth * 40,
                height: SizeConfig.blockHeight * 8,
                textColor: COLORS.white,
                loading: loading,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildVerifyingUI() {
    return Scaffold(
      backgroundColor: COLORS.white,
      appBar: CustomAppBar(
        title: 'KYC Verification'.tr(),
        backgroundColor: COLORS.white,
        titleColors: COLORS.neutralDark,
        textCap: false,
      ),
      body: Padding(
        padding: EdgeInsets.symmetric(
            horizontal: SizeConfig.blockWidth * 6.5,
            vertical: SizeConfig.blockHeight * 2.5),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Image.asset(
              "assets/images/profile/kyc_pending.png",
              width: SizeConfig.blockWidth * 60,
              height: SizeConfig.blockWidth * 60,
            ),
            SizedBox(height: SizeConfig.blockHeight * 3),
            Text(
              "Verifying Your Identity".tr(),
              style: TextStyle(
                color: COLORS.neutralDark,
                fontSize: SizeConfig.blockWidth * 4.25,
                fontWeight: FontWeight.w500,
                fontFamily: "Poppins",
              ),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: SizeConfig.blockHeight * 2),
            Text(
              "We’re currently reviewing your Aadhaar card for secure verification.".tr(),
              textAlign: TextAlign.center,
              style: TextStyle(
                color: COLORS.neutralDarkOne,
                fontSize: SizeConfig.blockWidth * 3.25,
                fontWeight: FontWeight.w400,
                fontFamily: "Poppins",
              ),
            ),
            SizedBox(height: SizeConfig.blockHeight * 4),
            customButton(
              text: 'OKAY'.tr(),
              onPressed: () {
                Navigator.pop(context);
              },
              backgroundColor: COLORS.primary,
              showIcon: false,
              width: SizeConfig.blockWidth * 40,
              height: SizeConfig.blockHeight * 8,
              textColor: COLORS.white,
            )
          ],
        ),
      ),
    );
  }

  Widget _buildVerifiedUI() {
    return Scaffold(
      backgroundColor: COLORS.white,
      appBar: CustomAppBar(
        title: 'KYC Verification'.tr(),
        backgroundColor: COLORS.white,
        titleColors: COLORS.neutralDark,
        textCap: false,
      ),
      body: Padding(
        padding: EdgeInsets.symmetric(
            horizontal: SizeConfig.blockWidth * 6.5,
            vertical: SizeConfig.blockHeight * 2.5),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Image.asset(
              "assets/images/profile/kyc_success.png",
              width: SizeConfig.blockWidth * 60,
              height: SizeConfig.blockWidth * 60,
            ),
            SizedBox(height: SizeConfig.blockHeight * 3),
            Text(
              "Verification Successful".tr(),
              style: TextStyle(
                color: COLORS.neutralDark,
                fontSize: SizeConfig.blockWidth * 4.25,
                fontWeight: FontWeight.w500,
                fontFamily: "Poppins",
              ),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: SizeConfig.blockHeight * 2),
            Text(
              "Your Aadhaar card has been successfully verified.\nYou're all set!".tr(),
              textAlign: TextAlign.center,
              style: TextStyle(
                color: COLORS.neutralDarkOne,
                fontSize: SizeConfig.blockWidth * 3.25,
                fontWeight: FontWeight.w400,
                fontFamily: "Poppins",
              ),
            ),
            SizedBox(height: SizeConfig.blockHeight * 4),
            customButton(
              text: 'Explore'.tr(),
              onPressed: () {
                Navigator.pushNamed(
                  context,
                  '/main_screen',
                  arguments: {'selectedIndex': 0},
                );
              },
              backgroundColor: COLORS.primary,
              showIcon: false,
              width: SizeConfig.blockWidth * 40,
              height: SizeConfig.blockHeight * 8,
              textColor: COLORS.white,
            )
          ],
        ),
      ),
    );
  }
}
