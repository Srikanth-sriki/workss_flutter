import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:works_app/bloc/profile/profile_bloc.dart';
import 'package:works_app/models/faq_model.dart';

import '../../components/colors.dart';
import '../../components/size_config.dart';
import '../../global_helper/reuse_widget.dart';

class FaqScreen extends StatefulWidget {
  const FaqScreen({super.key});

  @override
  State<FaqScreen> createState() => _FaqScreenState();
}

class _FaqScreenState extends State<FaqScreen> {
  late ProfileBloc profileBloc;
  late List<FaqModelList> faqModelListModal = [];
  bool loading = true;
  bool error = false;

  @override
  void initState() {
    super.initState();
    profileBloc = BlocProvider.of<ProfileBloc>(context);
    profileBloc.add(FetchFaqEvent());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: COLORS.white,
      appBar: const CustomAppBar(
        title: 'FAQs',
        backgroundColor: COLORS.white,
        titleColors: COLORS.neutralDark,
      ),
      body: BlocListener<ProfileBloc, ProfileState>(
        listener: (context, state) {
          if (state is ProfileLoading) {
            setState(() {
              loading = true;
              error = false;
            });
          } else if (state is FetchFaqSuccess) {
            setState(() {
              loading = false;
              error = false;
              faqModelListModal = state.faqList;
            });
          } else if (state is FetchFaqFailed) {
            setState(() {
              loading = false;
              error = true;
            });
          }
        },
        child: Builder(builder: (context) {
          if (loading) {
            return const Center(child: CircularProgressIndicator());
          } else if (error) {
            return Center(child: Text('Failed to load FAQs.'));
          } else if (!loading && !error) {
            if (faqModelListModal.isEmpty) {
              return Center(child: Text('No FAQs available.'));
            }
            return SafeArea(
              child: Padding(
                padding: EdgeInsets.symmetric(
                  vertical: SizeConfig.blockHeight * 1,
                  horizontal: SizeConfig.blockWidth * 6,
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.start,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    SizedBox(
                      height: SizeConfig.blockHeight * 60,
                      child: ListView.builder(
                        padding: EdgeInsets.zero,
                        shrinkWrap: true,
                        itemCount: faqModelListModal.length,
                        physics: const AlwaysScrollableScrollPhysics(),
                        itemBuilder: (context, index) {
                          return FaqItem(
                            question: faqModelListModal[index].question ?? '',
                            answer: faqModelListModal[index].answer ?? '',
                            isExpanded: index == 0, // First one expanded by default
                          );
                        },
                      ),
                    ),
                    Spacer(),
                    Image.asset(
                      'assets/images/profile/faq.png',
                      height: SizeConfig.blockWidth * 15,
                      width: SizeConfig.blockWidth * 15,
                      fit: BoxFit.contain,
                    ),
                    SizedBox(height: SizeConfig.blockHeight * 2),
                    Text(
                      'Have further questions? Let \nus know.',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: COLORS.neutralDark,
                        fontSize: SizeConfig.blockWidth * 3.8,
                        fontWeight: FontWeight.w500,
                        fontFamily: "Poppins",
                      ),
                    ),
                    SizedBox(height: SizeConfig.blockHeight * 4),
                    customButton(
                      text: 'MAIL US'.tr(),
                      onPressed: () {},
                      backgroundColor: COLORS.primary,
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
          return Container();
        }),
      ),
    );
  }
}

class FaqItem extends StatefulWidget {
  final String question;
  final String answer;
  final bool isExpanded;

  const FaqItem({
    required this.question,
    required this.answer,
    this.isExpanded = false,
    super.key,
  });

  @override
  State<FaqItem> createState() => _FaqItemState();
}

class _FaqItemState extends State<FaqItem> {
  late bool _isExpanded;

  @override
  void initState() {
    super.initState();
    _isExpanded = widget.isExpanded;
  }

  @override
  Widget build(BuildContext context) {
    return ExpansionTile(
      tilePadding: EdgeInsets.zero,
      childrenPadding: EdgeInsets.zero,
      iconColor: COLORS.black,
      shape: const Border(
        bottom: BorderSide(color: COLORS.neutralDarkTwo, width: 0.8),
      ),
      title: Text(
        widget.question,
        style: TextStyle(
          color: COLORS.neutralDark,
          fontSize: SizeConfig.blockWidth * 3.8,
          fontWeight: FontWeight.w500,
          fontFamily: "Poppins",
        ),
      ),
      trailing: Icon(_isExpanded ? Icons.close : Icons.add),
      initiallyExpanded: _isExpanded,
      onExpansionChanged: (expanded) {
        setState(() {
          _isExpanded = expanded;
        });
      },
      children: [
        Padding(
          padding: EdgeInsets.only(bottom: SizeConfig.blockHeight * 1.5),
          child: Text(
            widget.answer,
            style: TextStyle(
              color: COLORS.neutralDarkOne,
              fontSize: SizeConfig.blockWidth * 3.4,
              fontWeight: FontWeight.w400,
              fontFamily: "Poppins",
            ),
          ),
        ),
      ],
    );
  }
}
