import 'dart:io';

import 'package:audio_waveforms/audio_waveforms.dart';
import 'package:chat_bubbles/bubbles/bubble_normal.dart';
import 'package:chat_bubbles/bubbles/bubble_normal_audio.dart';
import 'package:chat_bubbles/bubbles/bubble_special_one.dart';
import 'package:chat_bubbles/bubbles/bubble_special_three.dart';
import 'package:chat_bubbles/bubbles/bubble_special_two.dart';
import 'package:chat_bubbles/date_chips/date_chip.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path_provider/path_provider.dart';
import 'package:works_app/components/colors.dart';
import 'package:works_app/ui/chat/chat_profile_view.dart';
import 'package:works_app/ui/chat/remove_friends.dart';

import '../../bloc/profile/profile_bloc.dart';
import '../../components/size_config.dart';
import '../../global_helper/ImagePickerComponent.dart';
import '../profile/notification.dart';
import 'component.dart';
import 'chat_wave_form.dart';
import 'invite_friends.dart';

class ChatViewScreen extends StatefulWidget {
  const ChatViewScreen({super.key});

  @override
  State<ChatViewScreen> createState() => _ChatViewScreenState();
}

class _ChatViewScreenState extends State<ChatViewScreen> {
  final TextEditingController _messageController = TextEditingController();
  late final RecorderController recorderController;
  final ImagePicker _picker = ImagePicker();
  String? path;
  String? musicFile;
  bool isRecording = false;
  bool isRecordingCompleted = false;
  bool isLoading = true;
  File? _profileImage;
  String profilePic = '';
  late Directory appDirectory;

  @override
  void initState() {
    super.initState();
    _getDir();
    _initialiseControllers();
  }

  void _getDir() async {
    appDirectory = await getApplicationDocumentsDirectory();
    path = "${appDirectory.path}/recording.m4a";
    isLoading = false;
    setState(() {});
  }

  void _initialiseControllers() {
    recorderController = RecorderController()
      ..androidEncoder = AndroidEncoder.aac
      ..androidOutputFormat = AndroidOutputFormat.mpeg4
      ..iosEncoder = IosEncoder.kAudioFormatMPEG4AAC
      ..sampleRate = 44100;
  }

  void _pickFile() async {
    FilePickerResult? result = await FilePicker.platform.pickFiles();
    if (result != null) {
      musicFile = result.files.single.path;
      setState(() {});
    } else {
      debugPrint("File not picked");
    }
  }

  @override
  void dispose() {
    recorderController.dispose();
    super.dispose();
  }

  void _startOrStopRecording() async {
    try {
      if (isRecording) {
        recorderController.reset();

        path = await recorderController.stop(false);

        if (path != null) {
          isRecordingCompleted = true;
          debugPrint(path);
          debugPrint("Recorded file size: ${File(path!).lengthSync()}");
        }
      } else {
        await recorderController.record(path: path); // Path is optional
      }
    } catch (e) {
      debugPrint(e.toString());
    } finally {
      setState(() {
        isRecording = !isRecording;
      });
    }
  }

  void _refreshWave() {
    if (isRecording) recorderController.refresh();
  }

  void _onMessageChanged(String keyword) {}
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: COLORS.white,
      resizeToAvoidBottomInset: true,
      appBar: AppBar(
        toolbarHeight: 0,
        scrolledUnderElevation: 0,
        automaticallyImplyLeading: false,
        backgroundColor: COLORS.white,
      ),
      body: SafeArea(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: EdgeInsets.symmetric(
                  horizontal: SizeConfig.blockWidth * 2.5,
                  vertical: SizeConfig.blockHeight * 1.5),
              decoration: BoxDecoration(
                  border: Border(
                      bottom: BorderSide(
                          color: COLORS.neutralDarkTwo,
                          width: SizeConfig.blockHeight * 0.15))),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.start,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      IconButton(
                        icon: Icon(Icons.arrow_back_ios,
                            color: COLORS.black,
                            size: SizeConfig.blockWidth * 4.5),
                        onPressed: () {
                          Navigator.pop(context);
                        },
                      ),
                      InkWell(
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (BuildContext context) =>
                                  const ChatProfileViewScreen(),
                            ),
                          );
                        },
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.start,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Container(
                              width: SizeConfig.blockWidth * 12,
                              height: SizeConfig.blockWidth * 12,
                              decoration: BoxDecoration(
                                  border: Border.all(
                                    color: COLORS.primary,
                                    width: SizeConfig.blockWidth * 0.3,
                                  ),
                                  image: const DecorationImage(
                                      image: NetworkImage(
                                        'https://via.placeholder.com/150',
                                      ),
                                      fit: BoxFit.cover),
                                  borderRadius: BorderRadius.all(
                                      Radius.circular(
                                          SizeConfig.blockWidth * 3))),
                            ),
                            SizedBox(width: SizeConfig.blockWidth * 2),
                            Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                SizedBox(
                                  width: SizeConfig.blockWidth * 45,
                                  child: Text('Angie',
                                      style: TextStyle(
                                        color: COLORS.neutralDark,
                                        fontSize: SizeConfig.blockWidth * 3.8,
                                        fontWeight: FontWeight.w400,
                                        fontFamily: "Poppins",
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                      maxLines: 1),
                                ),
                                SizedBox(
                                  width: SizeConfig.blockWidth * 45,
                                  child: Text('Lorem ipsum dolor sit',
                                      style: TextStyle(
                                        color: COLORS.neutralDarkOne,
                                        fontSize: SizeConfig.blockWidth * 3.25,
                                        fontWeight: FontWeight.w400,
                                        fontFamily: "Poppins",
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                      maxLines: 1),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  IconButton(
                    icon: Icon(
                      Icons.more_vert,
                      color: COLORS.black,
                      size: SizeConfig.blockWidth * 6.5,
                    ),
                    onPressed: () {
                      showDynamicBottomSheet(
                        context,
                        'Chat Options',
                        [
                          BottomSheetItem(
                            title: 'Mute Notification',
                            onTap: () => {},
                          ),
                          BottomSheetItem(
                            title: 'Unfriend',
                            onTap: () => {},
                          ),
                          BottomSheetItem(
                            title: 'Invite Friends',
                            onTap: () => {
                              Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) =>
                                        const InviteFriendsList(),
                                  ))
                            },
                          ),
                          BottomSheetItem(
                            title: 'Remove People',
                            onTap: () => {
                              Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) =>
                                        const RemoveFriendsChat(),
                                  ))
                            },
                          ),
                          BottomSheetItem(
                              title: 'Share Joining Link', onTap: () => {}),
                          BottomSheetItem(
                            title: 'Archive',
                            onTap: () => {},
                          ),
                          BottomSheetItem(
                            title: 'Mute Notification',
                            onTap: () => print('Add Friends clicked'),
                          ),
                          BottomSheetItem(
                            title: 'Leave Group',
                            onTap: () => print('Turn-Off Notification clicked'),
                          ),
                          BottomSheetItem(
                            title: 'Clear Chat',
                            onTap: () => print('Add Friends clicked'),
                          ),
                          BottomSheetItem(
                            title: 'Report or Block',
                            onTap: () => print('Add Friends clicked'),
                          ),
                        ],
                      );
                    },
                  ),
                ],
              ),
            ),
            Expanded(
              child: SingleChildScrollView(
                child: Padding(
                  padding: EdgeInsets.only(
                    top: SizeConfig.blockHeight * 2,
                    right: SizeConfig.blockWidth * 1.5,
                    left: SizeConfig.blockWidth * 1.5,
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.start,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // if (isRecordingCompleted)
                      //   WaveBubble(
                      //     path: path,
                      //     isSender: true,
                      //     appDirectory: appDirectory,
                      //   ),
                      // if (musicFile != null)
                      //   WaveBubble(
                      //     path: musicFile,
                      //     isSender: true,
                      //     appDirectory: appDirectory,
                      //   ),

                      SentMessage(
                        message: "Hello this is cool",
                        key: null,
                        isSentByMe: true,
                        time: '2:20pm',
                        audioShow: false,
                        textShow: false,
                        imageShow: true,
                        imageUrl: 'https://via.placeholder.com/150',
                      ),
                      ReceivedMessage(
                        message:
                            "I am great how are you doing. It while when we talked.",
                        isSentByMe: true,
                        imageUrl: 'https://via.placeholder.com/150',
                        time: '2:30pm',
                        sendName: 'By Laurence Kilback',
                        audioShow: true,
                        textShow: false,
                        imageShow: false,
                        audioWidget: isRecordingCompleted
                            ? WaveBubble(
                                path: path,
                                isSender: true,
                                appDirectory: appDirectory,
                              )
                            : null,
                      ),
                      SentMessage(
                        message: "How are you",
                        key: null,
                        isSentByMe: false,
                        time: '3:20pm',
                        audioShow: false,
                        textShow: true,
                        imageShow: false,
                        imageUrl: 'https://via.placeholder.com/150',
                      ),
                      SentMessage(
                        message: "How are you",
                        imageUrl: 'https://via.placeholder.com/150',
                        key: null,
                        isSentByMe: true,
                        time: '3:20pm',
                        audioShow: true,
                        textShow: false,
                        imageShow: false,
                        audioWidget: isRecordingCompleted
                            ? WaveBubble(
                                path: path,
                                isSender: true,
                                appDirectory: appDirectory,
                              )
                            : null,
                      ),
                    ],
                  ),
                ),
              ),
            )
          ],
        ),
      ),
      bottomNavigationBar: Padding(
        padding: EdgeInsets.only(
          bottom: MediaQuery.of(context).viewInsets.bottom,
        ),
        child: Container(
          padding: EdgeInsets.symmetric(
              vertical: SizeConfig.blockHeight * 2,
              horizontal: SizeConfig.blockWidth * 4),
          decoration: BoxDecoration(
            border: Border(
              top: BorderSide(
                  color: COLORS.neutralDarkTwo,
                  width: SizeConfig.blockWidth * 0.25),
            ),
            color: COLORS.white,
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              if (!isRecording) ...[
                InkWell(
                  onTap: () => _showPicker(context, (File image) {
                    setState(() {
                      _profileImage = image;
                      profilePic = '';
                    });
                  }),
                  child: Container(
                    padding: EdgeInsets.all(SizeConfig.blockWidth * 4),
                    height: SizeConfig.blockHeight * 8.5,
                    decoration: BoxDecoration(
                        color: COLORS.primaryOne.withOpacity(0.35),
                        borderRadius:
                            BorderRadius.circular(SizeConfig.blockWidth * 3.5)),
                    child: Icon(
                      Icons.add,
                      color: COLORS.primary,
                      size: SizeConfig.blockWidth * 6,
                    ),
                  ),
                ),
                SizedBox(
                  width: SizeConfig.blockWidth * 4,
                )
              ],
              Expanded(
                  child: isRecording
                      ? AnimatedSwitcher(
                          duration: const Duration(milliseconds: 200),
                          child: Container(
                            width: SizeConfig.blockWidth * 90,
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(
                                  SizeConfig.blockWidth * 3),
                              color: COLORS.primary,
                            ),
                            padding: EdgeInsets.symmetric(
                                horizontal: SizeConfig.blockWidth * 3),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: [
                                AudioWaveforms(
                                  enableGesture: true,
                                  size: Size(SizeConfig.blockWidth * 70,
                                      SizeConfig.blockHeight * 8),
                                  recorderController: recorderController,
                                  waveStyle: const WaveStyle(
                                      waveColor: COLORS.white,
                                      extendWaveform: true,
                                      showMiddleLine: false,
                                      waveThickness: 1.5,
                                      waveCap: StrokeCap.square),
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(
                                        SizeConfig.blockWidth * 3),
                                    color: COLORS.primary,
                                  ),
                                  padding: EdgeInsets.only(
                                      left: SizeConfig.blockWidth * 3),
                                  //                   margin:  EdgeInsets.symmetric(
                                  // horizontal: SizeConfig.blockWidth*3),
                                ),
                                InkWell(
                                  onTap: _startOrStopRecording,
                                  child: Container(
                                    width: SizeConfig.blockWidth * 10,
                                    height: SizeConfig.blockWidth * 10,
                                    padding: EdgeInsets.all(
                                        SizeConfig.blockWidth * 2.5),
                                    decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(
                                          SizeConfig.blockWidth * 10),
                                      color: COLORS.white,
                                    ),
                                    child: Image.asset(
                                      'assets/images/chat/message.png',
                                      width: SizeConfig.blockWidth * 2.5,
                                      height: SizeConfig.blockWidth * 2.5,
                                      fit: BoxFit.fill,
                                    ),
                                  ),
                                )
                              ],
                            ),
                          ),
                        )
                      : Container(
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(
                                SizeConfig.blockWidth * 3.25),
                            color: COLORS.primaryOne.withOpacity(0.35),
                            border: Border.all(
                              color: COLORS.neutralDarkTwo.withOpacity(0.6),
                              width: SizeConfig.blockWidth * 0.1,
                            ),
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              Expanded(
                                child: TextField(
                                  controller: _messageController,
                                  style: TextStyle(
                                    color: COLORS.neutralDarkOne,
                                    fontSize: SizeConfig.blockWidth * 3.25,
                                    fontWeight: FontWeight.w400,
                                    fontFamily: "Poppins",
                                  ),
                                  // autofocus: true,
                                  cursorColor: COLORS.black,
                                  decoration: InputDecoration(
                                    fillColor:
                                        COLORS.primaryOne.withOpacity(0.05),
                                    focusColor:
                                        COLORS.primaryOne.withOpacity(0.05),
                                    filled: true,
                                    hintText: 'Your message'.tr(),
                                    hintStyle: TextStyle(
                                      color: COLORS.neutralDarkOne,
                                      fontSize: SizeConfig.blockWidth * 3.25,
                                      fontWeight: FontWeight.w400,
                                      fontFamily: "Poppins",
                                    ),
                                    border: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(
                                          SizeConfig.blockWidth * 3.25),
                                      borderSide: BorderSide(
                                        color:
                                            COLORS.primaryOne.withOpacity(0.1),
                                        width: 0,
                                      ),
                                    ),
                                    focusedBorder: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(
                                          SizeConfig.blockWidth * 3.25),
                                      borderSide: BorderSide(
                                        color:
                                            COLORS.primaryOne.withOpacity(0.1),
                                        width: 0,
                                      ),
                                    ),
                                    enabledBorder: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(
                                          SizeConfig.blockWidth * 3.25),
                                      borderSide: BorderSide(
                                        color:
                                            COLORS.primaryOne.withOpacity(0.1),
                                        width: 0,
                                      ),
                                    ),
                                  ),
                                  maxLines:
                                      null, // Allow the field to grow with multiple lines
                                  minLines: 1, // Start with 1 line
                                  expands:
                                      false, // Don't make it fill all available space, but grow as needed
                                  onChanged: _onMessageChanged,
                                ),
                              ),
                              Padding(
                                padding: EdgeInsets.only(
                                    right: SizeConfig.blockWidth * 2.5),
                                child: InkWell(
                                  onTap: _messageController.text.isEmpty
                                      ? _startOrStopRecording
                                      : _refreshWave,
                                  child: _messageController.text.isEmpty
                                      ? Image.asset(
                                          'assets/images/chat/message.png',
                                          width: SizeConfig.blockWidth * 5,
                                          height: SizeConfig.blockWidth * 5,
                                        )
                                      : Icon(
                                          Icons.send,
                                          color: COLORS.primary,
                                          size: SizeConfig.blockWidth * 5,
                                        ),
                                ),
                              )
                            ],
                          ),
                        )),
            ],
          ),
        ),
      ),
    );
  }

  void _showPicker(context, onImageSelected) {
    showModalBottomSheet(
      backgroundColor: COLORS.white,
      context: context,
      builder: (BuildContext context) {
        return Container(
            decoration: BoxDecoration(
                color: COLORS.white,
                borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(SizeConfig.blockWidth * 5),
                    topRight: Radius.circular(SizeConfig.blockWidth * 5))),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                SizedBox(height: SizeConfig.blockHeight),
                Padding(
                  padding: EdgeInsets.symmetric(
                      horizontal: SizeConfig.blockWidth * 5,
                      vertical: SizeConfig.blockHeight),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Select Media'.tr(),
                        style: TextStyle(
                          color: COLORS.primaryTwo,
                          fontSize: SizeConfig.blockWidth * 4.25,
                          fontWeight: FontWeight.w500,
                          fontFamily: "Poppins",
                        ),
                      ),
                      IconButton(
                        icon: Icon(
                          Icons.close,
                          color: COLORS.neutralDark,
                          size: SizeConfig.blockWidth * 6.5,
                        ),
                        onPressed: () => Navigator.of(context).pop(),
                      ),
                    ],
                  ),
                ),
                const Divider(
                  color: COLORS.neutralDarkTwo,
                ),
                SizedBox(
                  height: SizeConfig.blockHeight * 3,
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    InkWell(
                      onTap: () async {
                        XFile? photo =
                            await _picker.pickImage(source: ImageSource.camera);
                        if (photo != null) {
                          onImageSelected(File(photo.path));
                        }
                        Navigator.of(context).pop();
                      },
                      child: Container(
                        alignment: Alignment.center,
                        decoration: BoxDecoration(
                          border: Border.all(
                              color: COLORS.primary,
                              width: SizeConfig.blockWidth * 0.15),
                          borderRadius:
                              BorderRadius.circular(SizeConfig.blockWidth * 3),
                          color: COLORS.primaryOne.withOpacity(0.5),
                        ),
                        width: SizeConfig.blockWidth * 30,
                        height: SizeConfig.blockWidth * 30,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.photo_camera_outlined,
                              color: COLORS.primary,
                              size: SizeConfig.blockWidth * 6.5,
                            ),
                            SizedBox(
                              width: SizeConfig.blockWidth * 1.5,
                            ),
                            Text(
                              'Camera'.tr(),
                              style: TextStyle(
                                color: COLORS.neutralDark,
                                fontSize: SizeConfig.blockWidth * 3.8,
                                fontWeight: FontWeight.w400,
                                fontFamily: "Poppins",
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    InkWell(
                      onTap: () async {
                        XFile? image = await _picker.pickImage(
                            source: ImageSource.gallery);
                        print(image);
                        if (image != null) {
                          onImageSelected(File(image.path));
                        }
                        Navigator.of(context).pop();
                      },
                      child: Container(
                        alignment: Alignment.center,
                        decoration: BoxDecoration(
                          border: Border.all(
                              color: COLORS.primary,
                              width: SizeConfig.blockWidth * 0.15),
                          borderRadius:
                              BorderRadius.circular(SizeConfig.blockWidth * 3),
                          color: COLORS.primaryOne.withOpacity(0.5),
                        ),
                        width: SizeConfig.blockWidth * 30,
                        height: SizeConfig.blockWidth * 30,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.photo_library_outlined,
                              color: COLORS.primary,
                              size: SizeConfig.blockWidth * 6.5,
                            ),
                            SizedBox(
                              width: SizeConfig.blockWidth * 1.5,
                            ),
                            Text('Gallery'.tr(),
                                style: TextStyle(
                                  color: COLORS.neutralDark,
                                  fontSize: SizeConfig.blockWidth * 3.8,
                                  fontWeight: FontWeight.w400,
                                  fontFamily: "Poppins",
                                )),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
                SizedBox(height: SizeConfig.blockHeight * 3),
              ],
            ));
      },
    );
  }
}
