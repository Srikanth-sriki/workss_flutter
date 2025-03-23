import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';
import 'package:lottie/lottie.dart';
import 'package:works_app/components/colors.dart';
// import 'package:shimmer/shimmer.dart';
import 'package:works_app/components/size_config.dart';
import 'package:shimmer_animation/shimmer_animation.dart';

class ShimmerJobCards extends StatelessWidget {
  const ShimmerJobCards({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Padding(
        padding: EdgeInsets.only(
            left: SizeConfig.blockWidth * 4,
            right: SizeConfig.blockWidth * 4,
            top: SizeConfig.blockWidth * 2),
        child: ListView.builder(
          shrinkWrap: true,
          // physics: NeverScrollableScrollPhysics(),
          itemCount: 4,
          itemBuilder: (context, index) {
            return Padding(
                padding: EdgeInsets.only(bottom: SizeConfig.blockWidth * 4),
                child: Shimmer(
                  color: COLORS.primary.withOpacity(0.05),
                  colorOpacity: 0.15,
                  enabled: true,
                  direction: const ShimmerDirection.fromRightToLeft(),duration: Duration(seconds: 10),
                  child: Container(
                    height: SizeConfig.blockHeight * 25,
                    width: SizeConfig.blockWidth * 100,
                    decoration: BoxDecoration(
                      color: COLORS.primaryOne.withOpacity(0.15),
                      borderRadius:
                          BorderRadius.circular(SizeConfig.blockWidth * 3.5),
                    ),
                  ),
                )

                // Shimmer.fromColors(
                //   baseColor: Colors.grey[300]!,
                //   highlightColor: Colors.grey[100]!,
                //   child: Container(
                //     height: SizeConfig.blockHeight*24,
                //     decoration: BoxDecoration(
                //       borderRadius: BorderRadius.circular(SizeConfig.blockWidth*4),
                //       color: Colors.grey,
                //     ),
                //     padding: EdgeInsets.all(SizeConfig.blockWidth*4),
                //   ),
                // ),
                );
          },
        ),
      ),
    );
  }
}



Widget globalLoadingWidget() {
  return Scaffold(
    backgroundColor: COLORS.white,
    body: Center(
      child: Container(
        height: SizeConfig.screenHeight,
        width: SizeConfig.screenWidth,
        padding: EdgeInsets.symmetric(horizontal: SizeConfig.blockWidth * 4),
        child: Center(
          child: LoadingAnimationWidget.hexagonDots(
            color: COLORS.primary,
            // secondRingColor: COLORS.semanticTwo,
            // thirdRingColor: COLORS.accent,
            size: SizeConfig.blockHeight * 7,
          ),
        ),
      ),
    ),
  );
}

Widget professionalLoading() {
  return Padding(
      padding: EdgeInsets.only(
          bottom: SizeConfig.blockWidth * 1.5,
          left: SizeConfig.blockWidth * 4,
          right: SizeConfig.blockWidth * 4,
          top: SizeConfig.blockWidth * 1.5),
      child: Shimmer(
        color: COLORS.primary.withOpacity(0.1),
        colorOpacity: 0.3,
        enabled: true,
        direction: const ShimmerDirection.fromLTRB(),
        child: Container(
          height: SizeConfig.blockHeight * 25,
          width: SizeConfig.blockWidth * 100,
          decoration: BoxDecoration(
            color: COLORS.primaryOne.withOpacity(0.25),
            borderRadius: BorderRadius.circular(SizeConfig.blockWidth * 3.5),
          ),
        ),
      ));
}

Widget categoryLoading() {
  return Padding(
      padding: EdgeInsets.only(
          bottom: SizeConfig.blockWidth * 0.5,
          top: SizeConfig.blockWidth * 0.5),
      child: Shimmer(
        color: COLORS.white,
        colorOpacity: 0.3,
        enabled: true,
        direction: const ShimmerDirection.fromLTRB(),
        child: Container(
          height: SizeConfig.blockWidth * 18,
          width: SizeConfig.blockWidth * 18,
          decoration: BoxDecoration(
            color: COLORS.primaryOne.withOpacity(0.25),
            borderRadius: BorderRadius.circular(SizeConfig.blockWidth * 9),
          ),
        ),
      ));
}

Widget dropDownLoader({
  required String hintText
}){
  return Container(
    width: SizeConfig.blockWidth*100,
    height: SizeConfig.blockHeight*7.5,
    decoration: BoxDecoration(
      borderRadius: BorderRadius.circular(SizeConfig.blockWidth*3),
      border: Border.all(color: COLORS.neutralDarkTwo,
        width: 1,),

    ),
    padding: EdgeInsets.symmetric(horizontal: SizeConfig.blockWidth*4),
    child: Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Text(
          hintText.tr(),
          style: TextStyle(
            fontWeight: FontWeight.w400,
            fontFamily: "Poppins",
            fontSize: SizeConfig.blockWidth * 3.2,
            color: COLORS.neutralDarkOne,
          ),
        ),
        LoadingAnimationWidget.discreteCircle(
          color: COLORS.accent,
          size: SizeConfig.blockWidth * 4,
        ),
      ],
    ),
  );
}

Widget emptyComponent(
    {
       String? errorText = "No data available"
    }
    ) {
  return Center(
    child: Column(
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Lottie.asset(
          'assets/images/lottie/empty.json',
          width: SizeConfig.blockWidth * 60,
          height: SizeConfig.blockWidth * 30,
          fit: BoxFit.contain,
        ),
        SizedBox(height: SizeConfig.blockHeight * 2),
        Text(
          errorText!.tr(),
          style: TextStyle(
            color: COLORS.neutralDarkOne,
            fontSize: SizeConfig.blockWidth * 3.6,
            fontWeight: FontWeight.w500,
            fontFamily: "Poppins",
          ),
        ),
      ],
    ),
  );
}


Widget friendsListLoading() {
  return   Expanded(
    child: Padding(
      padding: EdgeInsets.only(
          left: SizeConfig.blockWidth * 4,
          right: SizeConfig.blockWidth * 4,
          top: SizeConfig.blockWidth * 2),
      child: ListView.builder(
        shrinkWrap: true,
        // physics: NeverScrollableScrollPhysics(),
        itemCount: 6,
        itemBuilder: (context, index) {
          return Padding(
              padding: EdgeInsets.only(bottom: SizeConfig.blockWidth * 4),
              child: Shimmer(
                color: COLORS.primary.withOpacity(0.05),
                colorOpacity: 0.15,
                enabled: true,
                direction: const ShimmerDirection.fromRightToLeft(),duration: const Duration(seconds: 10),
                child: Container(
                  height: SizeConfig.blockHeight * 9,
                  width: SizeConfig.blockWidth * 100,
                  decoration: BoxDecoration(
                    color: COLORS.primaryOne.withOpacity(0.15),
                  ),
                ),
              )
    
            // Shimmer.fromColors(
            //   baseColor: Colors.grey[300]!,
            //   highlightColor: Colors.grey[100]!,
            //   child: Container(
            //     height: SizeConfig.blockHeight*24,
            //     decoration: BoxDecoration(
            //       borderRadius: BorderRadius.circular(SizeConfig.blockWidth*4),
            //       color: Colors.grey,
            //     ),
            //     padding: EdgeInsets.all(SizeConfig.blockWidth*4),
            //   ),
            // ),
          );
        },
      ),
    ),
  );
}