import 'package:flutter/material.dart';

class DynamicGridExample extends StatelessWidget {
  final List<String> imageUrls;  // Your image URLs or assets

  DynamicGridExample({Key? key, required this.imageUrls}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GridView.builder(
      shrinkWrap: true,
      physics: NeverScrollableScrollPhysics(), // Prevent scrolling within the grid
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: imageUrls.length == 1 ? 1 : 2,  // Full width if one image, 2 columns otherwise
        mainAxisSpacing: 10.0,
        crossAxisSpacing: 10.0,
        childAspectRatio: imageUrls.length == 1 ? 2.0 : 1.0, // Adjust aspect ratio for single image
      ),
      itemCount: imageUrls.length,
      itemBuilder: (context, index) {
        return imageUrls.length == 1
            ? SizedBox(
          height: 200,  // Custom height for single image
          child: Image.network(
            imageUrls[index],
            fit: BoxFit.cover,
          ),
        )
            : Image.network(
          imageUrls[index],
          fit: BoxFit.cover,
        );
      },
    );
  }
}
