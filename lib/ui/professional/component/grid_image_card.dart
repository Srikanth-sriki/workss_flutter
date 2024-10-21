import 'package:flutter/material.dart';
import 'package:works_app/components/size_config.dart';

class DynamicGridExample extends StatelessWidget {
  final List<String> imageUrls; // Your image URLs or assets

  const DynamicGridExample({super.key, required this.imageUrls});

  @override
  Widget build(BuildContext context) {
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        mainAxisSpacing: 10.0,
        crossAxisSpacing: 10.0,
        childAspectRatio: 1.0,
      ),
      itemCount: imageUrls.length < 2 ? imageUrls.length : 2,
      itemBuilder: (context, index) {
        return Container(
          decoration: BoxDecoration(
              borderRadius: BorderRadius.all(
                Radius.circular(SizeConfig.blockWidth * 4),
              ),
              image: DecorationImage(
                  image: NetworkImage(imageUrls[index]), fit: BoxFit.cover)),
        );
      },
    );
  }
}


class DynamicWorkListImage extends StatelessWidget {
  final List<String> imageUrls;

  const DynamicWorkListImage({super.key, required this.imageUrls});

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: imageUrls.length < 2 ? imageUrls.length : 2,
      itemBuilder: (context, index) {
        return Padding(
          padding:  EdgeInsets.symmetric(vertical: SizeConfig.blockHeight),
          child: Container(
            height: SizeConfig.blockHeight*45,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(SizeConfig.blockWidth*4),
              image: DecorationImage(
                image: NetworkImage(imageUrls[index]),
                fit: BoxFit.cover,
              ),
            ),
          ),
        );
      },
    );
  }
}

