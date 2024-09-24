import 'dart:async';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:pin_code_fields/pin_code_fields.dart';
import 'package:sms_autofill/sms_autofill.dart';
import 'package:works_app/components/colors.dart';
import 'package:works_app/components/size_config.dart';
import 'package:works_app/global_helper/reuse_widget.dart';
import 'package:flutter/gestures.dart';
import 'package:works_app/main.dart';
import 'package:works_app/ui/onboarding/select_user_type.dart';

import '../../bloc/login_otp/login_otp_bloc.dart';

class OtpScreen extends StatefulWidget {
  final String mobileNumber;
  final String otpToken;
  const OtpScreen(
      {super.key, required this.mobileNumber, required this.otpToken});

  @override
  State<OtpScreen> createState() => _OtpScreenState();
}

class _OtpScreenState extends State<OtpScreen> with CodeAutoFill {
  bool buttonVisible = false;
  String otpCode = '';
  String errorMessage = '';
  final int otpLength = 6;
  Timer? countdownTimer;
  int remainingSeconds = 30;
  bool isOtpValid = true;
  late LoginOtpBloc loginOtpBloc;
  late String otpToken;
  bool loading = false;

  @override
  void initState() {
    super.initState();
    listenForCode();
    startTimer();
    loginOtpBloc = BlocProvider.of<LoginOtpBloc>(context);
    otpToken = widget.otpToken;
  }

  void startTimer() {
    countdownTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (remainingSeconds > 0) {
        setState(() {
          remainingSeconds--;
        });
      } else {
        timer.cancel();
        // setState(() {
        //   errorMessage = 'OTP expired. Please request a new OTP.';
        // });
      }
    });
  }

  @override
  void codeUpdated() {
    setState(() {
      otpCode = code ?? '';
      buttonVisible = otpCode.length == otpLength;
    });
  }

  @override
  void dispose() {
    cancel();
    countdownTimer?.cancel();
    super.dispose();
  }

  void validateOtp() {
    setState(() {
      if (otpCode.length != otpLength) {
        isOtpValid = false;
        errorMessage = 'Enter a valid 6-digit OTP'.tr();
      } else {
        isOtpValid = true;
        errorMessage = '';
        loginOtpBloc.add(VerifyOtpEvent(otp: otpCode, otpToken: otpToken));
        // Navigator.push(
        //   context,
        //   MaterialPageRoute(
        //       builder: (BuildContext context) => SelectUserType(
        //             mobileNumber: widget.mobileNumber,
        //           )),
        // );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: customAppBar(
        context: context,
        onSkipPressed: () {},
      ),
      body: SafeArea(
          child: BlocListener<LoginOtpBloc, LoginOtpState>(
        listener: (context, state) {
          if (state is LoginOtpLoading) {
            loading = true;
          }
          if (state is VerifyOtpFailed) {
            loading = false;
            isOtpValid = false;
            errorMessage = '';
            showCustomSnackBar(
              context: context,
              message: state.message,
            );
          } else if (state is VerifyOtpSuccess) {
            loading = false;
            Navigator.pop(context);
          } else if (state is ResendOtpSuccess) {
            loading = false;
            setState(() {
              otpToken = state.otpToken;
            });
            showCustomSnackBar(
              context: context,
              message: 'OTP resent successfully',
              backgroundColor: COLORS.semanticTwo
            );
          }
          setState(() {});
        },
        child: Padding(
          padding: EdgeInsets.all(SizeConfig.blockWidth * 4.5),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'otp'.tr(),
                style: TextStyle(
                  color: COLORS.neutralDark,
                  fontSize: SizeConfig.blockWidth * 4.25,
                  fontWeight: FontWeight.w500,
                  fontFamily: "Poppins",
                ),
              ),
              SizedBox(height: SizeConfig.blockHeight * 0.5),
              RichText(
                text: TextSpan(
                  children: [
                    TextSpan(
                      text: '${'otp_sub'.tr()} +91${widget.mobileNumber}. ',
                      style: TextStyle(
                        color: COLORS.neutralDarkOne,
                        fontSize: SizeConfig.blockWidth * 3.25,
                        fontWeight: FontWeight.w400,
                        fontFamily: "Poppins",
                      ),
                    ),
                    TextSpan(
                      text: 'change'.tr(),
                      style: TextStyle(
                        color: COLORS.accent,
                        fontSize: SizeConfig.blockWidth * 3.25,
                        fontWeight: FontWeight.w400,
                        fontFamily: "Poppins",
                      ),
                      recognizer: TapGestureRecognizer()
                        ..onTap = () {
                          Navigator.pop(context);
                        },
                    ),
                  ],
                ),
              ),
              SizedBox(height: SizeConfig.blockHeight * 4.5),
              PinCodeTextField(
                autoDismissKeyboard: true,
                animationCurve: Curves.easeInOut,
                autoFocus: true,
                enabled: true,
                inputFormatters: [
                  FilteringTextInputFormatter.digitsOnly,
                  LengthLimitingTextInputFormatter(6),
                ],
                keyboardType: TextInputType.phone,
                appContext: context,
                length: otpLength,
                obscureText: false,
                animationType: AnimationType.fade,
                pinTheme: PinTheme(
                  shape: PinCodeFieldShape.box,
                  borderRadius: BorderRadius.circular(5),
                  fieldHeight: SizeConfig.blockHeight * 7,
                  fieldWidth: SizeConfig.blockWidth * 12,
                  activeFillColor: Colors.white,
                  selectedFillColor: Colors.white,
                  inactiveFillColor: Colors.white,
                  activeColor: isOtpValid ? COLORS.primary : Colors.red,
                  selectedColor: isOtpValid ? COLORS.primary : Colors.red,
                  inactiveColor:
                      isOtpValid ? COLORS.neutralDarkTwo : Colors.red,
                  errorBorderColor: Colors.red, // Error state color
                ),
                animationDuration: const Duration(milliseconds: 300),
                backgroundColor: Colors.transparent,
                enableActiveFill: true,
                onCompleted: (value) {
                  setState(() {
                    otpCode = value;
                    buttonVisible = value.length == otpLength;
                  });
                },
                onChanged: (value) {
                  setState(() {
                    otpCode = value;
                    buttonVisible = value.length == otpLength;
                    isOtpValid = true;
                    if (otpCode.length == otpLength) {
                      isOtpValid = true;
                      errorMessage = "";
                    }
                  });
                },
                beforeTextPaste: (text) {
                  return true;
                },
              ),
              Row(
                mainAxisAlignment: errorMessage.isNotEmpty
                    ? MainAxisAlignment.spaceBetween
                    : MainAxisAlignment.end,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  if (errorMessage.isNotEmpty)
                    Text(
                      errorMessage,
                      style: TextStyle(
                        color: Colors.red,
                        fontSize: SizeConfig.blockWidth * 3,
                        fontWeight: FontWeight.w400,
                        fontFamily: "Poppins",
                      ),
                    ),
                  remainingSeconds == 0
                      ? TextButton(
                          onPressed: () {
                            setState(() {
                              remainingSeconds = 30;
                              startTimer();
                              errorMessage = '';
                              otpCode = '';
                              loginOtpBloc
                                  .add(ResendOtpEvent(otpToken: otpToken));
                            });
                          },
                          child: Text(
                            'resend_otp'.tr(),
                            style: TextStyle(
                              color: COLORS.neutralDark,
                              fontSize: SizeConfig.blockWidth * 3.4,
                              fontWeight: FontWeight.w500,
                              fontFamily: "Poppins",
                            ),
                          ),
                        )
                      : Text(
                          '00:${remainingSeconds.toString().padLeft(2, '0')}',
                          style: TextStyle(
                            color: COLORS.neutralDark,
                            fontSize: SizeConfig.blockWidth * 3.4,
                            fontWeight: FontWeight.w400,
                            fontFamily: "Poppins",
                          ),
                        ),
                ],
              ),
              const Spacer(),
              customButton(
                  text: 'verify'.tr(),
                  onPressed: validateOtp,
                  backgroundColor: buttonVisible
                      ? COLORS.primary
                      : COLORS.primary.withOpacity(0.4),
                  showIcon: false,
                  width: SizeConfig.blockWidth * 100,
                  height: SizeConfig.blockHeight * 8,
                  textColor: COLORS.white,
                  loading: loading),
            ],
          ),
        ),
      )),
    );
  }
}
