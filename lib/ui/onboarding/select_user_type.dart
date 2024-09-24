import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:works_app/components/config.dart';
import 'package:works_app/main.dart';
import 'package:works_app/ui/onboarding/register_form.dart';
import '../../bloc/register_account/initial_register_bloc.dart';
import '../../components/colors.dart';
import '../../components/size_config.dart';
import '../../global_helper/reuse_widget.dart';
import 'package:easy_localization/easy_localization.dart';


class SelectUserType extends StatefulWidget {

  const SelectUserType({super.key, });

  @override
  State<SelectUserType> createState() => _SelectUserTypeState();
}

class _SelectUserTypeState extends State<SelectUserType> {
  bool buttonVisible = true;
  String selectedUserType = '';

  void handleUserTypeSelection(String userType) {
    setState(() {
      selectedUserType = userType;
      buttonVisible = false;
    });

  }

  void _buttonHandle() {
    if(selectedUserType != ''){

      Navigator.push(
        context,
        MaterialPageRoute(
            builder: (context) =>  MultiBlocProvider(providers: [
              BlocProvider(create: (context) => InitialRegisterBloc(),),

            ], child:  RegisterForm(mobileNumber: Config.phoneNumber ,userType:selectedUserType))),
      );
      // Navigator.push(
      //   context,
      //   MaterialPageRoute(
      //       builder: (BuildContext context) =>  RegisterForm(mobileNumber: widget.mobileNumber ,userType:selectedUserType)
      //   ),
      // );
    }

  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: customAppBar(
        onSkipPressed: () {},
        context: context,
      ),
      body: Padding(
        padding: EdgeInsets.all(SizeConfig.blockWidth * 4.5),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'select_user_type'.tr(),
              style: TextStyle(
                color: COLORS.neutralDark,
                fontSize: SizeConfig.blockWidth * 4.25,
                fontWeight: FontWeight.w500,
                fontFamily: "Poppins",
              ),
            ),
            SizedBox(height: SizeConfig.blockHeight * 0.5),
            Text(
              'secure_online_presence'.tr(),
              style: TextStyle(
                color: COLORS.neutralDarkOne,
                fontSize: SizeConfig.blockWidth * 3.25,
                fontWeight: FontWeight.w400,
                fontFamily: "Poppins",
              ),
            ),
            SizedBox(height: SizeConfig.blockHeight * 4.5),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                UserTypeCard(
                  title: 'user_type_one'.tr(),
                  imagePath: 'assets/images/login/hiring.png',
                  isSelected: selectedUserType == 'professionals',
                  onTap: () => handleUserTypeSelection('professionals'),
                  selectedImagePath: 'assets/images/login/hiring_select.png',
                ),
                UserTypeCard(
                  title: 'user_type_two'.tr(),
                  imagePath: 'assets/images/login/profession_select.png',
                  isSelected: selectedUserType == 'jobs',
                  onTap: () => handleUserTypeSelection('jobs'),
                  selectedImagePath: 'assets/images/login/profession.png',
                ),
              ],
            ),
            const Spacer(),
            customButton(
              text: 'continue'.tr(),
              onPressed: _buttonHandle,
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
    );
  }
}


class UserTypeCard extends StatelessWidget {
  final String title;
  final String imagePath;
  final bool isSelected;
  final VoidCallback onTap;
  final String selectedImagePath;

  const UserTypeCard({
    super.key,
    required this.title,
    required this.imagePath,
    required this.isSelected,
    required this.onTap,
    required this.selectedImagePath
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          border: Border.all(
            width: isSelected?SizeConfig.blockWidth * 0.4:SizeConfig.blockWidth * 0.25,
            color: isSelected ? COLORS.primary : COLORS.neutralDarkTwo,
          ),
          borderRadius: BorderRadius.all(
            Radius.circular(SizeConfig.blockWidth * 3),
          ),
        ),
        height: SizeConfig.blockHeight * 25,
        width: SizeConfig.blockWidth * 42,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Image.asset(
              isSelected?selectedImagePath:imagePath,
              width: SizeConfig.blockWidth * 6.5,
              height: SizeConfig.blockHeight * 6.5,
              fit: BoxFit.contain,
            ),
            // SizedBox(height: SizeConfig.blockHeight,),
            Text(
              title,
              style: TextStyle(
                color: isSelected ? COLORS.neutralDark : COLORS.neutralDarkOne,
                fontSize: SizeConfig.blockWidth * 3.5,
                fontWeight: FontWeight.w400,
                fontFamily: "Poppins",
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}
