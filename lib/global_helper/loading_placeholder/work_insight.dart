import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';
import 'package:works_app/components/size_config.dart';

class ShimmerInsightsScreen extends StatelessWidget {
  const ShimmerInsightsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: ListView(
        children: [
          // Top section shimmer (Profession details)
          Shimmer.fromColors(
            baseColor: Colors.grey[300]!,
            highlightColor: Colors.grey[100]!,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: double.infinity,
                  height: SizeConfig.blockHeight*25,
                  decoration: BoxDecoration(
                    color: Colors.grey,
                    borderRadius: BorderRadius.circular(SizeConfig.blockWidth*4),
                  ),
                ),
                SizedBox(height: SizeConfig.blockHeight*5,),


                Padding(
                  padding: EdgeInsets.symmetric(horizontal: SizeConfig.blockWidth*5),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Container(
                        width: SizeConfig.blockWidth* 40,
                        height:SizeConfig.blockHeight* 20,
                        decoration: BoxDecoration(
                          color: Colors.grey,
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      Container(
                        width: SizeConfig.blockWidth* 40,
                        height:SizeConfig.blockHeight* 20,
                        decoration: BoxDecoration(
                          color: Colors.grey,
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                    ],
                  ),
                ),
                SizedBox(height: SizeConfig.blockHeight*3),
                // Padding(
                //   padding: EdgeInsets.symmetric(horizontal: SizeConfig.blockWidth*5),
                //   child: Container(
                //     width: SizeConfig.blockWidth*30,
                //     height: SizeConfig.blockHeight*3,
                //     color: Colors.grey,
                //   ),
                // ),
                SizedBox(height: SizeConfig.blockHeight*3),
              ],
            ),
          ),

          // List of professionals shimmer
          ListView.builder(
            physics: NeverScrollableScrollPhysics(),
            shrinkWrap: true,
            itemCount: 3, // Number of professionals to show
            itemBuilder: (context, index) {
              return Padding(
                padding:  EdgeInsets.only(bottom: SizeConfig.blockWidth*4,left: SizeConfig.blockWidth*4,right: SizeConfig.blockWidth*4),
                child: Shimmer.fromColors(
                  baseColor: Colors.grey[300]!,
                  highlightColor: Colors.grey[100]!,
                  child:  Container(
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
        ],
      ),
    );
  }
}
