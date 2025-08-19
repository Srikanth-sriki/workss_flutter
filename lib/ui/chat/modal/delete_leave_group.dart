import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:works_app/components/colors.dart';
import 'package:works_app/components/size_config.dart';
import 'package:easy_localization/easy_localization.dart';
import '../../../bloc/chart/chart_bloc.dart';
import '../../../global_helper/reuse_widget.dart';

class DeleteGroupModal extends StatefulWidget {
  final String header;
  final String buttonText;
  final String chatId;

  const DeleteGroupModal(
      {super.key, required this.header, required this.buttonText,required this.chatId});

  @override
  _DeleteGroupModalState createState() => _DeleteGroupModalState();
}

class _DeleteGroupModalState extends State<DeleteGroupModal> {
  late ChartBloc chartBloc;
  @override
  void initState() {
    super.initState();
    chartBloc = BlocProvider.of<ChartBloc>(context);
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
              Container(
                margin: EdgeInsets.only(top: SizeConfig.blockHeight * 1.5),
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
                      text: widget.buttonText.tr(),
                      onPressed: () {
                        chartBloc.add(DeleteChartEvent(
                            chatId: widget.chatId,
                            onSuccess: (message) {
                              showCustomSnackBar(
                                  context: context,
                                  message: message,
                                  backgroundColor: COLORS.neutralDarkTwo);
                              Navigator.pushNamed(
                                context,
                                '/main_screen',
                                arguments: {'selectedIndex': 3},
                              );
                            },
                            onError: (message) {
                              showCustomSnackBar(
                                context: context,
                                message: message,
                              );
                            }));
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
