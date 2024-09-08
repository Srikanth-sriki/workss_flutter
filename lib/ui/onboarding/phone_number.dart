// login_screen.dart
import 'dart:async';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:sms_autofill/sms_autofill.dart';
import 'package:works_app/components/colors.dart';
import 'package:works_app/components/size_config.dart';
import 'package:works_app/global_helper/reuse_widget.dart';
import 'package:works_app/ui/onboarding/otp_screen.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final TextEditingController _phoneController = TextEditingController();
  String _errorMessage = '';
  bool _hasError = false;
  bool buttonVisible = true;

  @override
  void initState() {
    super.initState();
    Future<void>.delayed(const Duration(milliseconds: 300), _autoFetchNumber);
  }

  Future<void> _autoFetchNumber() async {
    if (!mounted) return;
    try {
      final autoFill = SmsAutoFill();
      final phone = await autoFill.hint;
      if (phone == null) return;
      if (!mounted) return;

      final phoneWithoutCountryCode = phone.replaceFirst('+91', '');
      _phoneController.text = phoneWithoutCountryCode;
      RegExp regex = RegExp(r"^(?:[+0]9)?\d{10}$");
      if (regex.hasMatch(phoneWithoutCountryCode)) {}
    } on PlatformException catch (e) {
      print('Failed to get mobile number because of: ${e.message}');
    }
  }

  void _validatePhoneNumber(String value) {
    setState(() {
      RegExp regex = RegExp(r"^[0-9]{10}$");
      if (regex.hasMatch(value)) {
        _hasError = false;
        _errorMessage = '';
        buttonVisible = false;
      } else {
        _hasError = true;
        buttonVisible = true;
        _errorMessage = 'Enter a valid 10-digit phone number'.tr();
      }
    });
  }

  void _buttonVisible(String value) {
    setState(() {
      RegExp regex = RegExp(r"^[0-9]{10}$");
      if (regex.hasMatch(value)) {
        buttonVisible = false;
      } else {
        buttonVisible = true;
      }
    });
  }

  void _onGetOtpPressed() {
    _validatePhoneNumber(_phoneController.text);
    if (!_hasError) {
      Navigator.push(
        context,
        MaterialPageRoute(
            builder: (BuildContext context) => OtpScreen(
                  mobileNumber: _phoneController.text,
                )),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        FocusScopeNode currentFocus = FocusScope.of(context);
        if (!currentFocus.hasPrimaryFocus) {
          currentFocus.unfocus();
        }
      },
      child: Scaffold(
        backgroundColor: Colors.white,
        appBar: customAppBar(
          context: context,
          onSkipPressed: () {},
        ),
        body: Padding(
          padding: EdgeInsets.all(SizeConfig.blockWidth * 4.5),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'mobile_number'.tr(),
                style: TextStyle(
                  color: COLORS.neutralDark,
                  fontSize: SizeConfig.blockWidth * 4.25,
                  fontWeight: FontWeight.w500,
                  fontFamily: "Poppins",
                ),
              ),
              SizedBox(height: SizeConfig.blockHeight * 0.5),
              Text(
                'mobile_number_sub'.tr(),
                style: TextStyle(
                  color: COLORS.neutralDarkOne,
                  fontSize: SizeConfig.blockWidth * 3.25,
                  fontWeight: FontWeight.w400,
                  fontFamily: "Poppins",
                ),
              ),
              SizedBox(height: SizeConfig.blockHeight * 4.5),
              PhoneNumberInput(
                  controller: _phoneController,
                  onChanged: _validatePhoneNumber,
                  errorMessage: _errorMessage.tr(),
                  hasError: _hasError,
                  buttonVisibleChange: _buttonVisible),
              const Spacer(),
              customButton(
                text: 'mobile_number_button'.tr(),
                onPressed: _onGetOtpPressed,
                backgroundColor: buttonVisible
                    ? COLORS.primary.withOpacity(0.4)
                    : COLORS.primary,
                showIcon: false,
                width: SizeConfig.blockWidth * 100,
                height: SizeConfig.blockHeight * 8,
                textColor: COLORS.white,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class PhoneNumberInput extends StatelessWidget {
  final TextEditingController controller;
  final String errorMessage;
  final bool hasError;
  final ValueChanged<String> onChanged;
  final bool buttonVisible;
  final ValueChanged<String> buttonVisibleChange;

  const PhoneNumberInput(
      {super.key,
      required this.controller,
      required this.onChanged,
      this.errorMessage = '',
      this.hasError = false,
      this.buttonVisible = true,
      required this.buttonVisibleChange});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        normalTextField(
            hintText: "Enter your mobile number".tr(),
            maxLength: 10,
            controller: controller,
            inputType: TextInputType.phone,
            onChanged: (value) {
              buttonVisibleChange(value);
              if (value.length == 10) {
                onChanged(value);
                FocusScope.of(context).unfocus();
                buttonVisible == false;
              }
            },
            validator: (String? value) {},
            fontWeight: FontWeight.w400,
            prefix: true,
            inputFormatters: [
              FilteringTextInputFormatter.digitsOnly,
              LengthLimitingTextInputFormatter(10),
            ],
            prefixIcon: Container(
              padding: EdgeInsets.all(SizeConfig.blockWidth * 4),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    '+91',
                    style: TextStyle(
                      color: COLORS.primary,
                      fontSize: SizeConfig.blockWidth * 4.25,
                      fontWeight: FontWeight.w500,
                      fontFamily: "Poppins",
                    ),
                  ),
                  Container(
                    decoration: BoxDecoration(
                        color: COLORS.neutralDarkTwo,
                        border: Border(
                            right: BorderSide(
                                width: SizeConfig.blockWidth * 0.1,
                                color: COLORS.neutralDarkTwo))),
                    height: SizeConfig.blockHeight * 4.5,
                    width: SizeConfig.blockWidth * 0.4,
                    margin: EdgeInsets.only(left: SizeConfig.blockWidth * 3),
                  )
                ],
              ),
            ),
            errorMessage: errorMessage,
            hasError: hasError,
            autofocus: true),
      ],
    );
  }
}
