import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:works_app/components/size_config.dart';
import 'package:works_app/ui/profile/component.dart';

import '../../components/colors.dart';
import '../../global_helper/reuse_widget.dart';
import '../onboarding/phone_number.dart';

class ContactUsScreen extends StatefulWidget {
  const ContactUsScreen({super.key});

  @override
  State<ContactUsScreen> createState() => _ContactUsScreenState();
}

class _ContactUsScreenState extends State<ContactUsScreen> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _enterName = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController bioController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();

  bool nameError = false;
  bool emailError = false;
  bool bioError = false;
  bool phoneError = false;
  String _errorMessage = '';

  @override
  void dispose() {
    _enterName.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    bioController.dispose();
    super.dispose();
  }

  void _validatePhoneNumber(String value) {
    setState(() {
      RegExp regex = RegExp(r"^[0-9]{10}$");
      if (regex.hasMatch(value)) {
        phoneError = false;
        _errorMessage = '';
      } else {
        phoneError = true;
        _errorMessage = 'Enter a valid 10-digit phone number'.tr();
      }
    });
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
        backgroundColor: COLORS.white,
        appBar: const CustomAppBar(
          title: 'Help & Support',
          backgroundColor: COLORS.white,
          titleColors: COLORS.neutralDark,
        ),
        body: SafeArea(
          child: SingleChildScrollView(
            child: Padding(
              padding: EdgeInsets.symmetric(
                vertical: SizeConfig.blockWidth * 4,
                horizontal: SizeConfig.blockHeight * 4,
              ),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    buildTextField(
                      label: 'Name',
                      controller: _enterName,
                      hintText: "Enter your name".tr(),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          setState(() => nameError = true);
                          return 'Please enter your name'.tr();
                        }
                        setState(() => nameError = false);
                        return null;
                      },
                      error: nameError,
                      title: 'name'.tr(),
                        onChanged: (value) {  }
                    ),
                    registerText(text: 'mobile_number'.tr()),
                    PhoneNumberInput(
                      controller: _phoneController,
                      onChanged: (value) {
                        setState(() {
                          RegExp regex = RegExp(r"^[0-9]{10}$");
                          phoneError = !regex.hasMatch(value);
                          _errorMessage = phoneError ? 'Enter a valid 10-digit phone number'.tr() : '';
                        });
                      },
                      errorMessage: _errorMessage,
                      validator: (value) {
                        RegExp regex = RegExp(r"^[0-9]{10}$");
                        if (value == null || !regex.hasMatch(value)) {
                          setState(() => phoneError = true);
                          return 'Enter a valid 10-digit phone number'.tr();
                        }
                        setState(() => phoneError = false);
                        return null;
                      },
                      hasError: phoneError,
                      buttonVisibleChange: _validatePhoneNumber,
                    ),

                    buildTextField(
                      label: 'Email Address',
                      controller: _emailController,
                      hintText: "Enter your email address".tr(),
                      validator: (value) {
                        if (value == null ||
                            (!RegExp(r'^[^@]+@[^@]+\.[^@]+').hasMatch(value))) {
                          setState(() => emailError = true);
                          return 'Please enter a valid email address'.tr();
                        }
                        setState(() => emailError = false);
                        return null;
                      },
                      error: emailError,
                      title: 'email'.tr(), onChanged: (value) {  },
                    ),
                    buildBioTextField(
                      label: 'Message'.tr(),
                      controller: bioController,
                      hintText: "Write a message".tr(),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          setState(() => bioError = true);
                          return 'Please enter a message'.tr();
                        }
                        setState(() => bioError = false);
                        return null;
                      },
                      error: bioError,
                      title: 'Message'.tr(),
                        onChanged: (value) {  }
                    ),
                    SizedBox(height: 20), // Add spacing to push button down
                    customButton(
                      text: 'SUBMIT'.tr(),
                      onPressed: () {
                        if (_formKey.currentState!.validate()) {
                          // Handle form submission
                        }
                      },
                      backgroundColor: COLORS.primary,
                      showIcon: false,
                      width: SizeConfig.blockWidth * 100,
                      height: SizeConfig.blockHeight * 8,
                      textColor: COLORS.white,
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
