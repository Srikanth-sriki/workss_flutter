import 'dart:io';

import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:works_app/components/colors.dart';
import 'package:works_app/components/size_config.dart';

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
                  XFile? image =
                      await _picker.pickImage(source: ImageSource.gallery);
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
      context: context,
      builder: (BuildContext context) {
        return SafeArea(
          child: Wrap(
            children: <Widget>[
              ListTile(
                leading: const Icon(Icons.photo_library),
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
                leading: const Icon(Icons.photo_camera),
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
