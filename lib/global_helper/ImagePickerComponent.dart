import 'dart:io';

import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:works_app/components/colors.dart';
import 'package:works_app/components/size_config.dart';
import 'package:works_app/ui/profile/component.dart';

class ImagePickerComponent extends StatefulWidget {
  final Function(File) onImageSelected;

  const ImagePickerComponent({Key? key, required this.onImageSelected})
      : super(key: key);

  @override
  _ImagePickerComponentState createState() => _ImagePickerComponentState();
}

class _ImagePickerComponentState extends State<ImagePickerComponent> {
  final ImagePicker _picker = ImagePicker();

  void _showPicker(context) {
    showModalBottomSheet(
      backgroundColor: COLORS.white,
      context: context,
      builder: (BuildContext context) {
        return SafeArea(
          child: Wrap(
            children: <Widget>[
              ListTile(
                leading: const Icon(
                  Icons.photo_library,
                  color: COLORS.neutralDark,
                ),
                title: Text('Gallery'.tr(),
                    style: TextStyle(
                      color: COLORS.neutralDark,
                      fontSize: SizeConfig.blockWidth * 4,
                      fontWeight: FontWeight.w500,
                      fontFamily: "Poppins",
                    )),
                onTap: () async {
                  XFile? image = await _picker.pickImage(source: ImageSource.gallery);
                  print(image);
                  if (image != null) {
                    widget.onImageSelected(File(image.path));
                  }
                  Navigator.of(context).pop();
                },
              ),
              ListTile(
                leading: const Icon(
                  Icons.photo_camera,
                  color: COLORS.neutralDark,
                ),
                title: Text(
                  'Camera'.tr(),
                  style: TextStyle(
                    color: COLORS.neutralDark,
                    fontSize: SizeConfig.blockWidth * 4,
                    fontWeight: FontWeight.w500,
                    fontFamily: "Poppins",
                  ),
                ),
                onTap: () async {
                  XFile? photo =
                      await _picker.pickImage(source: ImageSource.camera);
                  if (photo != null) {
                    widget.onImageSelected(File(photo.path));
                  }
                  Navigator.of(context).pop();
                },
              ),
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => _showPicker(context),
      child: Container(
        margin: EdgeInsets.symmetric(
          vertical: SizeConfig.blockHeight,
        ),
        width: SizeConfig.blockWidth * 32,
        height: SizeConfig.blockWidth * 32,
        decoration: BoxDecoration(
          border: Border.all(
            width: SizeConfig.blockWidth * .4,
            color: COLORS.neutralDarkTwo,
          ),
          borderRadius: BorderRadius.all(
            Radius.circular(SizeConfig.blockWidth * 3.5),
          ),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.person,
              color: COLORS.neutralDarkTwo,
              size: SizeConfig.blockWidth * 14,
            ),
          ],
        ),
      ),
    );
  }
}

class ImagePickerModal extends StatelessWidget {
  final Function(File) onImageSelected;

  const ImagePickerModal({super.key, required this.onImageSelected});

  void _showPicker(BuildContext context) {
    showModalBottomSheet(
      backgroundColor: COLORS.white,
      context: context,
      showDragHandle: true,
      builder: (BuildContext context) {
        return SafeArea(
          child: Wrap(
            children: <Widget>[
              ListTile(
                dense: true,
                contentPadding: EdgeInsets.symmetric(
                    horizontal: SizeConfig.blockWidth * 10),
                leading: Icon(
                  Icons.photo_library,
                  color: COLORS.black,
                  size: SizeConfig.blockWidth * 6,
                ),
                title: Text(
                  'Gallery'.tr(),
                  style: TextStyle(
                    color: COLORS.neutralDark,
                    fontSize: SizeConfig.blockWidth * 4,
                    fontWeight: FontWeight.w400,
                    fontFamily: "Poppins",
                  ),
                ),
                onTap: () async {
                  final pickedFile = await ImagePicker()
                      .pickImage(source: ImageSource.gallery);
                  if (pickedFile != null) {
                    onImageSelected(File(pickedFile.path));
                  }
                  Navigator.of(context).pop();
                },
              ),
              ListTile(
                dense: true,
                contentPadding: EdgeInsets.symmetric(
                    horizontal: SizeConfig.blockWidth * 10),
                leading: Icon(
                  Icons.photo_camera,
                  color: COLORS.black,
                  size: SizeConfig.blockWidth * 6,
                ),
                title: Text(
                  'Camera'.tr(),
                  style: TextStyle(
                    color: COLORS.neutralDark,
                    fontSize: SizeConfig.blockWidth * 4,
                    fontWeight: FontWeight.w400,
                    fontFamily: "Poppins",
                  ),
                ),
                onTap: () async {
                  final pickedFile =
                      await ImagePicker().pickImage(source: ImageSource.camera);
                  if (pickedFile != null) {
                    onImageSelected(File(pickedFile.path));
                  }
                  Navigator.of(context).pop();
                },
              ),
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () => _showPicker(context),
      child: Container(
        width: SizeConfig.blockWidth * 10,
        height: SizeConfig.blockWidth * 10,
        decoration: BoxDecoration(
            color: COLORS.primary,
            borderRadius: BorderRadius.only(
                topLeft: Radius.circular(SizeConfig.blockWidth * 3.5),
                bottomRight: Radius.circular(SizeConfig.blockWidth * 3.5))),
        child: Icon(
          Icons.edit,
          color: COLORS.white,
          size: SizeConfig.blockWidth * 5.5,
        ),
      ),
    );
  }
}

// class MultipleImagePickerComponent extends StatefulWidget {
//   final Function(List<File>) onImagesSelected;
//   final bool error;
//   final Function(int) removeImage;
//
//   const MultipleImagePickerComponent(
//       {super.key,
//       required this.onImagesSelected,
//       required this.error,
//       required this.removeImage});
//
//   @override
//   _MultipleImagePickerComponentState createState() =>
//       _MultipleImagePickerComponentState();
// }
//
// class _MultipleImagePickerComponentState
//     extends State<MultipleImagePickerComponent> {
//   final ImagePicker _picker = ImagePicker();
//   final List<File> _selectedImages = [];
//
//   void _showPicker(context) {
//     showModalBottomSheet(
//       backgroundColor: COLORS.white,
//       context: context,
//       showDragHandle: true,
//       builder: (BuildContext context) {
//         return SafeArea(
//           child: Wrap(
//             children: <Widget>[
//               ListTile(
//                 dense: true,
//                 contentPadding: EdgeInsets.symmetric(
//                     horizontal: SizeConfig.blockWidth * 10),
//                 leading: Icon(
//                   Icons.photo_library,
//                   color: COLORS.black,
//                   size: SizeConfig.blockWidth * 6,
//                 ),
//                 title: Text(
//                   'Gallery'.tr(),
//                   style: TextStyle(
//                     color: COLORS.neutralDark,
//                     fontWeight: FontWeight.w400,
//                     fontFamily: "Poppins",
//                     fontSize: SizeConfig.blockWidth * 4.1,
//                   ),
//                 ),
//                 onTap: () async {
//                   XFile? image =
//                       await _picker.pickImage(source: ImageSource.gallery);
//                   if (image != null && _selectedImages.length < 3) {
//                     setState(() {
//                       _selectedImages.add(File(image.path));
//                     });
//                     widget.onImagesSelected(_selectedImages);
//                   }
//                   Navigator.of(context).pop();
//                 },
//               ),
//               ListTile(
//                 dense: true,
//                 contentPadding: EdgeInsets.symmetric(
//                     horizontal: SizeConfig.blockWidth * 10),
//                 leading: Icon(
//                   Icons.photo_camera,
//                   color: COLORS.black,
//                   size: SizeConfig.blockWidth * 6,
//                 ),
//                 title: Text('Camera'.tr(),
//                     style: TextStyle(
//                       color: COLORS.neutralDark,
//                       fontWeight: FontWeight.w400,
//                       fontFamily: "Poppins",
//                       fontSize: SizeConfig.blockWidth * 4.1,
//                     )),
//                 onTap: () async {
//                   XFile? photo =
//                       await _picker.pickImage(source: ImageSource.camera);
//                   if (photo != null && _selectedImages.length < 3) {
//                     setState(() {
//                       _selectedImages.add(File(photo.path));
//                     });
//                     widget.onImagesSelected(_selectedImages);
//                   }
//                   Navigator.of(context).pop();
//                 },
//               ),
//             ],
//           ),
//         );
//       },
//     );
//   }
//
//   // void _removeImage(int index) {
//   //   setState(() {
//   //     _selectedImages.removeAt(index);
//   //     print(_selectedImages);
//   //     widget.onImagesSelected(_selectedImages);
//   //   });
//   // }
//
//   @override
//   Widget build(BuildContext context) {
//     return Column(
//       mainAxisAlignment: MainAxisAlignment.start,
//       crossAxisAlignment: CrossAxisAlignment.start,
//       children: [
//         registerText(text: 'Photos'),
//         SizedBox(
//           height: SizeConfig.blockHeight * 0.5,
//         ),
//         _selectedImages.isEmpty
//             ? Column(
//                 mainAxisAlignment: MainAxisAlignment.start,
//                 crossAxisAlignment: CrossAxisAlignment.start,
//                 children: [
//                   InkWell(
//                     onTap: () {
//                       _showPicker(context);
//                     },
//                     child: Container(
//                       width: SizeConfig.blockWidth * 100,
//                       height: SizeConfig.blockHeight * 30,
//                       decoration: BoxDecoration(
//                           border: Border.all(
//                             color: widget.error
//                                 ? COLORS.semantic
//                                 : COLORS.neutralDarkTwo,
//                             width: 1,
//                           ),
//                           borderRadius: BorderRadius.all(
//                               Radius.circular(SizeConfig.blockWidth * 3))),
//                       child: Column(
//                         mainAxisAlignment: MainAxisAlignment.center,
//                         crossAxisAlignment: CrossAxisAlignment.center,
//                         children: [
//                           Text(
//                             'Upload your work images\n(max 2 picture)',
//                             textAlign: TextAlign.center,
//                             style: TextStyle(
//                               color: COLORS.neutralDark,
//                               fontWeight: FontWeight.w400,
//                               fontFamily: "Poppins",
//                               fontSize: SizeConfig.blockWidth * 3.2,
//                             ),
//                           ),
//                           SizedBox(
//                             height: SizeConfig.blockHeight * 1.5,
//                           ),
//                           Container(
//                             width: SizeConfig.blockWidth * 45,
//                             padding: EdgeInsets.symmetric(
//                                 horizontal: SizeConfig.blockWidth * 4,
//                                 vertical: SizeConfig.blockHeight * 2),
//                             decoration: BoxDecoration(
//                               color: COLORS.primaryOne.withOpacity(0.15),
//                               borderRadius: BorderRadius.all(
//                                 Radius.circular(SizeConfig.blockWidth * 3),
//                               ),
//                             ),
//                             child: Row(
//                               mainAxisAlignment: MainAxisAlignment.center,
//                               crossAxisAlignment: CrossAxisAlignment.center,
//                               children: [
//                                 Image.asset(
//                                   'assets/images/login/upload.png',
//                                   width: SizeConfig.blockWidth * 4,
//                                   height: SizeConfig.blockWidth * 4,
//                                   color: COLORS.primary,
//                                 ),
//                                 SizedBox(width: SizeConfig.blockWidth),
//                                 Text(
//                                   'Upload Picture',
//                                   style: TextStyle(
//                                     color: COLORS.primary,
//                                     fontWeight: FontWeight.w400,
//                                     fontFamily: "Poppins",
//                                     fontSize: SizeConfig.blockWidth * 3.3,
//                                   ),
//                                 )
//                               ],
//                             ),
//                           )
//                         ],
//                       ),
//                     ),
//                   ),
//                   if (widget.error == true) ...[
//                     Padding(
//                       padding: EdgeInsets.symmetric(
//                           vertical: SizeConfig.blockHeight * 0.5,
//                           horizontal: SizeConfig.blockWidth * 2),
//                       child: Text(
//                         'Please upload picture',
//                         style: TextStyle(
//                           color: COLORS.semantic,
//                           fontWeight: FontWeight.w300,
//                           fontFamily: "Poppins",
//                           fontSize: SizeConfig.blockWidth * 3.4,
//                         ),
//                       ),
//                     )
//                   ]
//                 ],
//               )
//             : Container(
//                 decoration: BoxDecoration(
//                     border: Border.all(
//                       color: COLORS.neutralDarkTwo,
//                       width: 1,
//                     ),
//                     borderRadius: BorderRadius.all(
//                         Radius.circular(SizeConfig.blockWidth * 3))),
//                 padding: EdgeInsets.symmetric(
//                     horizontal: SizeConfig.blockWidth * 4,
//                     vertical: SizeConfig.blockHeight * 2.5),
//                 child: GridView.builder(
//                   shrinkWrap: true,
//                   itemCount: _selectedImages.length < 2
//                       ? _selectedImages.length + 1
//                       : 2,
//                   gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
//                     crossAxisCount: 2,
//                     crossAxisSpacing: 20,
//                     mainAxisSpacing: 10,
//                   ),
//                   itemBuilder: (BuildContext context, int index) {
//                     if (index == _selectedImages.length &&
//                         _selectedImages.length < 2) {
//                       return GestureDetector(
//                         onTap: () => _showPicker(context),
//                         child: Container(
//                           decoration: BoxDecoration(
//                             color: COLORS.primaryOne.withOpacity(0.5),
//                             borderRadius: BorderRadius.circular(
//                                 SizeConfig.blockWidth * 3),
//                           ),
//                           child: Icon(Icons.add_box_outlined,
//                               size: SizeConfig.blockHeight * 4,
//                               color: COLORS.black),
//                         ),
//                       );
//                     } else {
//                       return Stack(
//                         children: [
//                           Container(
//                             decoration: BoxDecoration(
//                                 borderRadius: BorderRadius.circular(
//                                     SizeConfig.blockWidth * 3),
//                                 image: DecorationImage(
//                                     image: FileImage(
//                                       _selectedImages[index],
//                                     ),
//                                     fit: BoxFit.fill)),
//                           ),
//                           Positioned(
//                             right: 0,
//                             child: GestureDetector(
//                               // onTap: () => _removeImage(index),
//                               onTap: () => widget.removeImage(index),
//                               child: Container(
//                                   padding:
//                                       EdgeInsets.all(SizeConfig.blockWidth),
//                                   decoration: BoxDecoration(
//                                       borderRadius: BorderRadius.only(
//                                         topRight: Radius.circular(
//                                             SizeConfig.blockWidth * 3),
//                                         bottomLeft: Radius.circular(
//                                             SizeConfig.blockWidth * 3),
//                                       ),
//                                       color: COLORS.neutralDarkTwo),
//                                   child: Icon(
//                                     Icons.close,
//                                     color: COLORS.black,
//                                     size: SizeConfig.blockWidth * 5,
//                                   )),
//                             ),
//                           ),
//                         ],
//                       );
//                     }
//                   },
//                 ),
//               ),
//       ],
//     );
//   }
// }

class MultipleImagePickerComponent extends StatefulWidget {
  final Function(List<File>) onImagesSelected;
  final bool error;
  final Function(int) removeImage;
  final List<String> defaultImages; // Add default image paths

  const MultipleImagePickerComponent({
    super.key,
    required this.onImagesSelected,
    required this.error,
    required this.removeImage,
    this.defaultImages = const [], // Initialize with an empty list
  });

  @override
  _MultipleImagePickerComponentState createState() =>
      _MultipleImagePickerComponentState();
}

class _MultipleImagePickerComponentState
    extends State<MultipleImagePickerComponent> {
  final ImagePicker _picker = ImagePicker();
  final List<File> _selectedImages = [];
  late List<String> _displayImages;

  @override
  void initState() {
    super.initState();

    _displayImages = List<String>.from(widget.defaultImages);
  }

  void _showPicker(BuildContext context) {
    showModalBottomSheet(
      backgroundColor: COLORS.white,
      context: context,
      showDragHandle: true,
      builder: (BuildContext context) {
        return SafeArea(
          child: Wrap(
            children: <Widget>[
              ListTile(
                dense: true,
                contentPadding: EdgeInsets.symmetric(
                    horizontal: SizeConfig.blockWidth * 10),
                leading: Icon(
                  Icons.photo_library,
                  color: COLORS.black,
                  size: SizeConfig.blockWidth * 6,
                ),
                title: Text(
                  'Gallery'.tr(),
                  style: TextStyle(
                    color: COLORS.neutralDark,
                    fontWeight: FontWeight.w400,
                    fontFamily: "Poppins",
                    fontSize: SizeConfig.blockWidth * 4.1,
                  ),
                ),
                // onTap: () async {
                //   XFile? image =
                //       await _picker.pickImage(source: ImageSource.gallery);
                //   if (image != null && _displayImages.length < 3) {
                //     setState(() {
                //       _displayImages.add(image.path);
                //     });
                //     _updateSelectedImages();
                //   }
                //   Navigator.of(context).pop();
                // },
                onTap: () async {
                  try {
                    XFile? image = await _picker.pickImage(source: ImageSource.gallery);
                    print(image!.path!);
                    if (image != null && image.path.isNotEmpty && _displayImages.length < 3) {
                      setState(() {
                        _displayImages.add(image.path);
                      });
                      _updateSelectedImages();
                    } else {
                      print('Invalid image path or selection canceled');
                    }
                    Navigator.of(context).pop();
                  } catch (e) {
                    print('Error picking image: $e');
                  }
                },
              ),
              ListTile(
                dense: true,
                contentPadding: EdgeInsets.symmetric(
                    horizontal: SizeConfig.blockWidth * 10),
                leading: Icon(
                  Icons.photo_camera,
                  color: COLORS.black,
                  size: SizeConfig.blockWidth * 6,
                ),
                title: Text(
                  'Camera'.tr(),
                  style: TextStyle(
                    color: COLORS.neutralDark,
                    fontWeight: FontWeight.w400,
                    fontFamily: "Poppins",
                    fontSize: SizeConfig.blockWidth * 4.1,
                  ),
                ),
                // onTap: () async {
                //   XFile? photo =
                //       await _picker.pickImage(source: ImageSource.camera);
                //   if (photo != null && _displayImages.length < 3) {
                //     setState(() {
                //       _displayImages.add(photo.path);
                //     });
                //     _updateSelectedImages();
                //   }
                //   Navigator.of(context).pop();
                // },

                onTap: () async {
                  try {
                    XFile? photo = await _picker.pickImage(source: ImageSource.camera);
                    print(photo!.path!);
                    if (photo != null && photo.path.isNotEmpty && _displayImages.length < 3) {
                      setState(() {
                        _displayImages.add(photo.path);
                      });
                      _updateSelectedImages();
                    } else {
                      print('Invalid image path or selection canceled');
                    }
                    Navigator.of(context).pop();
                  } catch (e) {
                    print('Error picking image: $e');
                  }
                },
              ),
            ],
          ),
        );
      },
    );
  }

  void _updateSelectedImages() {
    // Convert display images to File type and pass to parent
    List<File> files = _displayImages
        .where((path) => !widget.defaultImages.contains(path))
        .map((path) => File(path))
        .toList();
    widget.onImagesSelected(files);
  }

  void _removeImage(int index) {
    setState(() {
      _displayImages.removeAt(index);
    });
    _updateSelectedImages();
    widget.removeImage(index);
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.start,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        registerText(text: 'Photos'),
        SizedBox(
          height: SizeConfig.blockHeight * 0.5,
        ),
        _displayImages.isEmpty
            ? Column(
                children: [
                  _buildEmptyImagePicker(context),
                  if (widget.error)
                    Padding(
                      padding: EdgeInsets.symmetric(
                          vertical: SizeConfig.blockHeight * 0.5,
                          horizontal: SizeConfig.blockWidth * 2),
                      child: Text(
                        'Please upload picture',
                        style: TextStyle(
                          color: COLORS.semantic,
                          fontWeight: FontWeight.w300,
                          fontFamily: "Poppins",
                          fontSize: SizeConfig.blockWidth * 3.4,
                        ),
                      ),
                    ),
                ],
              )
            : _buildImageGrid(),
      ],
    );
  }

  Widget _buildEmptyImagePicker(BuildContext context) {
    return InkWell(
      onTap: () {
        _showPicker(context);
      },
      child: Container(
        width: SizeConfig.blockWidth * 100,
        height: SizeConfig.blockHeight * 26,
        decoration: BoxDecoration(
          border: Border.all(
            color: widget.error ? COLORS.semantic : COLORS.neutralDarkTwo,
            width: 1,
          ),
          borderRadius: BorderRadius.all(
            Radius.circular(SizeConfig.blockWidth * 3),
          ),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Text(
              'Upload your work images\n(max 2 pictures)',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: COLORS.neutralDark,
                fontWeight: FontWeight.w400,
                fontFamily: "Poppins",
                fontSize: SizeConfig.blockWidth * 3,
              ),
            ),
            SizedBox(height: SizeConfig.blockHeight * 1.5),
            _buildUploadButton(),
          ],
        ),
      ),
    );
  }

  Widget _buildUploadButton() {
    return Container(
      width: SizeConfig.blockWidth * 40,
      padding: EdgeInsets.symmetric(
          horizontal: SizeConfig.blockWidth * 4,
          vertical: SizeConfig.blockHeight*1.6),
      decoration: BoxDecoration(
        color: COLORS.primaryOne.withOpacity(0.15),
        borderRadius: BorderRadius.all(
          Radius.circular(SizeConfig.blockWidth * 2.8),
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Image.asset(
            'assets/images/login/upload.png',
            width: SizeConfig.blockWidth * 4,
            height: SizeConfig.blockWidth * 4,
            color: COLORS.primary,
          ),
          SizedBox(width: SizeConfig.blockWidth),
          Text(
            'Upload Picture',
            style: TextStyle(
              color: COLORS.primary,
              fontWeight: FontWeight.w400,
              fontFamily: "Poppins",
              fontSize: SizeConfig.blockWidth * 3.3,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildImageGrid() {
    return Container(
      decoration: BoxDecoration(
        border: Border.all(
          color: COLORS.neutralDarkTwo,
          width: 1,
        ),
        borderRadius: BorderRadius.all(
          Radius.circular(SizeConfig.blockWidth * 3),
        ),
      ),
      padding: EdgeInsets.symmetric(
        horizontal: SizeConfig.blockWidth * 4,
        vertical: SizeConfig.blockHeight * 2.5,
      ),
      child: GridView.builder(
        shrinkWrap: true,
        itemCount: _displayImages.length < 2 ? _displayImages.length + 1 : 2,
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          crossAxisSpacing: 20,
          mainAxisSpacing: 10,
        ),
        itemBuilder: (BuildContext context, int index) {
          if (index == _displayImages.length && _displayImages.length < 2) {
            return GestureDetector(
              onTap: () => _showPicker(context),
              child: Container(
                decoration: BoxDecoration(
                  color: COLORS.primaryOne.withOpacity(0.5),
                  borderRadius: BorderRadius.circular(SizeConfig.blockWidth * 3),
                ),
                child: Center(
                  child: Image.asset(
                    'assets/images/bottom_tab/add_post.png',
                    width: SizeConfig.blockWidth * 6,
                    height: SizeConfig.blockWidth * 6,
                    color: COLORS.black,
                    fit: BoxFit.contain,
                  ),
                ),
              ),
            );
          } else {
            return Stack(
              children: [
                Container(
                  decoration: BoxDecoration(
                    borderRadius:
                        BorderRadius.circular(SizeConfig.blockWidth * 3),
                    image: DecorationImage(
                      image: _displayImages[index].startsWith('http')
                          ? NetworkImage(_displayImages[index])
                          : FileImage(File(_displayImages[index]))
                              as ImageProvider,
                      fit: BoxFit.cover,
                    ),
                  ),
                ),
                Positioned(
                  right: 0,
                  child: GestureDetector(
                    onTap: () => _removeImage(index),
                    child: Container(
                        padding: EdgeInsets.all(SizeConfig.blockWidth),
                        decoration: BoxDecoration(
                            borderRadius: BorderRadius.only(
                              topRight:
                                  Radius.circular(SizeConfig.blockWidth * 3),
                              bottomLeft:
                                  Radius.circular(SizeConfig.blockWidth * 3),
                            ),
                            color: COLORS.neutralDarkTwo),
                        child: Icon(
                          Icons.close,
                          color: COLORS.black,
                          size: SizeConfig.blockWidth * 5,
                        )),
                  ),
                ),
              ],
            );
          }
        },
      ),
    );
  }
}
