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
  final bool isVerified;

  const KYCVerificationScreen({super.key, required this.isVerified});

  @override
  State<KYCVerificationScreen> createState() => _KYCVerificationScreenState();
}

class _KYCVerificationScreenState extends State<KYCVerificationScreen> {
  bool _isVerifying = false;
  bool imagesList = false;
  List<File> _selectedImages = [];
  late PostWorkBloc postWorkBloc;
  List<String> workImages = [];

  Future<void> _pickImage(ImageSource source) async {
    setState(() => _isVerifying = true);
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: source);

    if (pickedFile != null) {
      // simulate upload
      await Future.delayed(const Duration(seconds: 2));
      setState(() {
        _isVerifying = false;
      });

      // In real app: call API & update status accordingly
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Image uploaded successfully')),
      );
    } else {
      setState(() => _isVerifying = false);
    }
  }


  void _onImagesSelected(List<File> images) {
    setState(() {
      _selectedImages = images;
      if (_selectedImages.isNotEmpty) {
        postWorkBloc.add(
          UploadMultipleImageEvent(
              imagePath: _selectedImages.length > 1
                  ? _selectedImages[1]
                  : _selectedImages[0]),
        );
      }
    });
  }

  void _removeImage(int index) {
    setState(() {
      if (index >= 0 && index < _selectedImages.length) {
        _selectedImages.removeAt(index);
        if (index < workImages.length) {
          workImages.removeAt(index);
        }
      }
    });
  }

  @override
  void initState() {
    super.initState();
    postWorkBloc = BlocProvider.of<PostWorkBloc>(context);
  }

  @override
  Widget build(BuildContext context) {
    if (widget.isVerified) {
      return _buildVerifiedUI();
    } else if (_isVerifying) {
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
        titleColors: COLORS.neutralDark,textCap: false,
      ),
      body: Padding(
        padding: EdgeInsets.symmetric(
            horizontal: SizeConfig.blockWidth * 5.5,vertical: SizeConfig.blockHeight*2.5),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Image.asset("assets/images/profile/kyc_verifying.png",
              width: SizeConfig.blockWidth * 60,
              height: SizeConfig.blockWidth * 60,
            ), // Replace with your asset
            SizedBox(height: SizeConfig.blockHeight * 3),
             Text(
              "Aadhaar verification is pending!",
               style: TextStyle(
                 color: COLORS.neutralDark,
                 fontSize: SizeConfig.blockWidth * 4.25,
                 fontWeight: FontWeight.w500,
                 fontFamily: "Poppins",
               ),
              textAlign: TextAlign.center,
            ),
            // SizedBox(height: SizeConfig.blockHeight * 2),
            //  Text(
            //   "We need to take a picture of both sides of your Aadhaar card to verify your identity.",
            //   textAlign: TextAlign.center,
            //   style: TextStyle(
            //     color: COLORS.neutralDarkOne,
            //     fontSize: SizeConfig.blockWidth * 3.25,
            //     fontWeight: FontWeight.w400,
            //     fontFamily: "Poppins",
            //   ),
            // ),
            // const SizedBox(height: 30),
            // Row(
            //   mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            //   children: [
            //     OutlinedButton(
            //       onPressed: () => _pickImage(ImageSource.gallery),
            //       child: const Text("Select from Gallery"),
            //     ),
            //     ElevatedButton(
            //       onPressed: () => _pickImage(ImageSource.camera),
            //       child: const Text("Click a Picture"),
            //     ),
            //   ],
            // )
            SizedBox(height: SizeConfig.blockHeight * 2),
            MultipleImagePickerComponent(
              onImagesSelected: _onImagesSelected,
              error: imagesList,
              removeImage: _removeImage,
              defaultImages: [],
              filedConatinerText: 'We need to take a picture of both sides of \nyour Aadhaar card to verify \nyour identity.',
              headerNeed: false,

            ),
          ],
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
        titleColors: COLORS.neutralDark,textCap: false,
      ),
      body: Padding(
        padding: EdgeInsets.symmetric(
            horizontal: SizeConfig.blockWidth * 6.5,vertical: SizeConfig.blockHeight*2.5),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Image.asset("assets/images/profile/kyc_pending.png",
                width: SizeConfig.blockWidth * 60,
                height: SizeConfig.blockWidth * 60,),
              SizedBox(height: SizeConfig.blockHeight * 3),
              Text(
                "Verifying Your Identity",
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
                "We’re currently reviewing your Aadhaar card for secure verification.",
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
                onPressed: (){
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
        titleColors: COLORS.neutralDark,textCap: false,
      ),
      body: Padding(
        padding: EdgeInsets.symmetric(
            horizontal: SizeConfig.blockWidth * 6.5,vertical: SizeConfig.blockHeight*2.5),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Image.asset("assets/images/profile/kyc_success.png",   width: SizeConfig.blockWidth * 60,
              height: SizeConfig.blockWidth * 60,),
            SizedBox(height: SizeConfig.blockHeight * 3),
            Text(
              "Verification Successful",
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
              "Your Aadhaar card has been successfully verified.\nYou're all set!",
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
              onPressed: (){
                Navigator.pushNamed(
                  context,
                  '/main_screen',
                  arguments: {'selectedIndex': 1},
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
