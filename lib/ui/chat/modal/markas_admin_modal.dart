import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:works_app/components/colors.dart';
import 'package:works_app/components/size_config.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:works_app/ui/chat/mark_as_admin.dart';
import '../../../bloc/chart/chart_bloc.dart';
import '../../../global_helper/reuse_widget.dart';
import '../../../models/chat/chat_view_pro_modal.dart';

class MarkasAdminModal extends StatefulWidget {
  final List<Participant> members;
  final String header;
  final String subHeader;
  final bool leaveGroup;
  final  VoidCallback onTapCalled;
   MarkasAdminModal({super.key,required this.members, required this.header,required this.subHeader,required this.leaveGroup,required this.onTapCalled});

  @override
  _MarkasAdminModalState createState() => _MarkasAdminModalState();
}

class _MarkasAdminModalState extends State<MarkasAdminModal> {
  @override
  void initState() {
    super.initState();
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
              horizontal: SizeConfig.blockWidth * 4,
              vertical: SizeConfig.blockHeight * 3),
          decoration: BoxDecoration(
              color: COLORS.white,
              borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(SizeConfig.blockWidth * 5),
                  topRight: Radius.circular(SizeConfig.blockWidth * 5))),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Text(
                widget.header.tr(),
                style: TextStyle(
                  color: COLORS.neutralDark,
                  fontSize: SizeConfig.blockWidth * 4,
                  fontWeight: FontWeight.w600,
                  fontFamily: "Poppins",
                ),
                textAlign: TextAlign.center,
              ),
              if(widget.subHeader.isNotEmpty)...[
                SizedBox(height: SizeConfig.blockHeight,),
                Text(
                  widget.subHeader.tr(),
                  style: TextStyle(
                    color: COLORS.neutralDarkOne,
                    fontSize: SizeConfig.blockWidth * 3.25,
                    fontWeight: FontWeight.w400,
                    fontFamily: "Poppins",
                  ),
                  textAlign: TextAlign.center,
                ),
              ],
              Container(
                margin: EdgeInsets.only(top: SizeConfig.blockHeight * 2),
                padding: EdgeInsets.only(
                    top: SizeConfig.blockHeight * 2.5,
                    bottom: SizeConfig.blockHeight * 1),
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
                      text: 'MARK ADMIN'.tr(),
                      onPressed: () {
                        if(widget.leaveGroup){
                          Navigator.pop(context);
                          Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (context) => MultiBlocProvider(
                                    providers: [
                                      BlocProvider(
                                          create: (context) => ChartBloc()),
                                    ],
                                    child: MarkAsAdminList(members: widget.members,),
                                  )));
                        }
                        else{
                          widget.onTapCalled();
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
    );
  }
}
