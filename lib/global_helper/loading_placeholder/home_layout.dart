import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';
import 'package:works_app/components/size_config.dart';

class ShimmerJobCards extends StatelessWidget {
  const ShimmerJobCards({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Padding(
        padding:  EdgeInsets.symmetric(horizontal:SizeConfig.blockWidth*4, vertical: SizeConfig.blockWidth*4),
        child: ListView.builder(
          shrinkWrap: true,
          // physics: NeverScrollableScrollPhysics(),
          itemCount: 4,
          itemBuilder: (context, index) {
            return Padding(
              padding:  EdgeInsets.only(bottom: SizeConfig.blockWidth*4),
              child: Shimmer.fromColors(
                baseColor: Colors.grey[300]!,
                highlightColor: Colors.grey[100]!,
                child: Container(
                  height: SizeConfig.blockHeight*24,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(SizeConfig.blockWidth*4),
                    color: Colors.grey,
                  ),
                  padding: EdgeInsets.all(SizeConfig.blockWidth*4),
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}
