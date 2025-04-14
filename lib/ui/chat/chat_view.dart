import 'dart:convert';
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
import 'package:loading_animation_widget/loading_animation_widget.dart';
import 'package:modal_bottom_sheet/modal_bottom_sheet.dart';
import 'package:path_provider/path_provider.dart';
import 'package:works_app/bloc/chart/chart_bloc.dart';
import 'package:works_app/components/colors.dart';
import 'package:works_app/components/config.dart';
import 'package:works_app/global_helper/loading_placeholder/home_layout.dart';
import 'package:works_app/ui/chat/chat_profile_view.dart';
import 'package:works_app/ui/chat/modal/delete_leave_group.dart';
import 'package:works_app/ui/chat/remove_friends.dart';

import '../../bloc/friends/friends_bloc.dart';
import '../../bloc/profile/profile_bloc.dart';
import '../../bloc/register_account/initial_register_bloc.dart';
import '../../bloc/report_post_bloc.dart';
import '../../bloc/show_interested/show_interested_bloc.dart';
import '../../components/size_config.dart';
import '../../global_helper/ImagePickerComponent.dart';
import '../../global_helper/helper_function.dart';
import '../../global_helper/popup.dart';
import '../../global_helper/reuse_widget.dart';
import '../../helper/socket_service.dart';
import '../../models/chat/charts_list_modal.dart';
import '../../models/chat/chat_view_modal.dart';
import '../../models/chat/chat_view_pro_modal.dart';
import '../friends/friends_details.dart';
import '../profile/notification.dart';
import 'component.dart';
import 'chat_wave_form.dart';
import 'invite_friends.dart';
import 'modal/markas_admin_modal.dart';
import 'modal/report_or_block.dart';
import 'package:socket_io_client/socket_io_client.dart' as io;

class ChatViewScreen extends StatefulWidget {
  final VoidCallback refreshPageCallback;
  final String chatId;
  final bool isGroup;
  const ChatViewScreen(
      {super.key,
      required this.refreshPageCallback,
      required this.chatId,
      required this.isGroup});

  @override
  State<ChatViewScreen> createState() => _ChatViewScreenState();
}

class _ChatViewScreenState extends State<ChatViewScreen> {
  late io.Socket socket;
  late ChartBloc chartBloc;
  late ShowInterestedBloc showInterestedBloc;
  late InitialRegisterBloc initialRegisterBloc;
  List<ChatView> chatView = [];
  List<Participant> filteredParticipants = [];
  bool isCurrentUserAdmin = false;
  ChatViewGroupInfo chatViewGroupInfo = ChatViewGroupInfo();
  final ScrollController _scrollController = ScrollController();
  final TextEditingController _messageController = TextEditingController();
  late final RecorderController recorderController;
  final ImagePicker _picker = ImagePicker();
  bool isChartViewLoading = true;
  String? path;
  String? musicFile;
  bool isRecording = false;
  bool isRecordingCompleted = false;
  bool isLoading = true;
  File? _profileImage;
  String profilePicture = '';
  late Directory appDirectory;
  int currentPage = 1;
  int pageSize = 10;
  int maxPageNumber = 1;
  bool isFetchingMore = false;
  bool textFiledChange = false;
  final String serverUrl = 'https://43.204.94.146';
  bool _isMounted = false;
  bool sentAudio = false;
  bool sentAudioSent = false;

  @override
  void initState() {
    super.initState();
    _isMounted = true;

    chartBloc = BlocProvider.of<ChartBloc>(context);
    initialRegisterBloc = BlocProvider.of<InitialRegisterBloc>(context);
    showInterestedBloc = BlocProvider.of<ShowInterestedBloc>(context);

    _getDir();
    _initialiseControllers();

    _scrollController.addListener(() {
      if (_scrollController.position.pixels ==
          _scrollController.position.maxScrollExtent) {
        _loadMoreData();
      }
    });
    socket = io.io(Config.socketUrl, <String, dynamic>{
      'transports': ['websocket'],
      'autoConnect': true,
    });

    if (!socket.connected) {
      SocketService().reconnect();
    }
    connectToSocket();
  }

  void connectToSocket() {
    socket.on('new_message', (data) {
      if (_isMounted) {
        setState(() {
          _fetchData();
          print(data);
        });
      }
    });
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

  void _fetchData() {
    chartBloc.add(FetchChartViewEvent(
      page: currentPage,
      pageSize: pageSize,
      chatId: widget.chatId,
    ));
  }

  void _refreshPageAfterEdit() {
    chartBloc.add(FetchChartViewEvent(
      page: 1,
      pageSize: 10,
      chatId: widget.chatId,
    ));
  }

  void _loadMoreData() {
    if (!isFetchingMore && currentPage < maxPageNumber) {
      setState(() => isFetchingMore = true);
      currentPage++;
      _fetchData();
    }
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

  void _startOrStopRecording() async {
    setState(() {
      sentAudio = false;
      sentAudioSent = false;
    });
    try {
      if (isRecording) {
        recorderController.reset();

        path = await recorderController.stop(false);

        if (path != null) {
          isRecordingCompleted = true;
          debugPrint(path);
          debugPrint("Recorded file size: ${File(path!).lengthSync()}");
          chartBloc.add(UploadFileEvent(filePath: File(path!)));
          setState(() {
            sentAudioSent = true;
          });
        }
      } else {
        await recorderController.record(path: path);
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

  void onSendMessage() {
    chartBloc.add(ChartSendMessageEvent(
      chatId: widget.chatId,
      content: _messageController.text,
      messageType: _messageController.text.isEmpty ? 'media' : "text",
      fileName: _messageController.text.isEmpty ? '' : null,
      fileUrl: _messageController.text.isEmpty ? '' : null,
      fileType: _messageController.text.isEmpty ? '' : null,
      fileSize: _messageController.text.isEmpty ? '' : null,
    ));
    FocusScope.of(context).unfocus();
    _messageController.clear();
  }

  @override
  void dispose() {
    _isMounted = false;

    socket.off('new_message');
    socket.disconnect();
    recorderController.dispose();
    _messageController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: true,
      onPopInvokedWithResult: (didPop, result) {
        if (didPop) {
          widget.refreshPageCallback();
          socket.emit("close_chat", Config.id);
        }
      },
      child: Scaffold(
        backgroundColor: COLORS.white,
        resizeToAvoidBottomInset: true,
        appBar: AppBar(
          toolbarHeight: 0,
          scrolledUnderElevation: 0,
          automaticallyImplyLeading: false,
          backgroundColor: COLORS.white,
        ),
        body: MultiBlocListener(
          listeners: [
            BlocListener<ChartBloc, ChartState>(listener: (context, state) {
              if (state is ChatViewLoading && currentPage == 1) {
                setState(() {
                  //isChartViewLoading = true;
                  isFetchingMore = true;
                });
              } else if (state is ChatViewSuccess) {
                setState(() {
                  isChartViewLoading = false;
                  isFetchingMore = false;
                  maxPageNumber = state.maxPageNumber;
                  chatViewGroupInfo = state.chatViewGroupInfo;
                  filteredParticipants = chatViewGroupInfo.participants
                      .where((participant) => participant.userId != Config.id)
                      .toList();
                  isCurrentUserAdmin = chatViewGroupInfo.participants.any(
                      (participant) =>
                          participant.userId == Config.id &&
                          participant.isAdmin);

                  if (currentPage == 1) {
                    chatView = state.chatView;
                  } else {
                    for (var newChat in state.chatView) {
                      var existingChat = chatView.firstWhere(
                        (chat) => chat.date == newChat.date,
                        orElse: () =>
                            ChatView(date: newChat.date, messages: []),
                      );

                      if (existingChat.messages.isEmpty) {
                        chatView.add(newChat);
                      } else {
                        final newMessages = newChat.messages
                            .where(
                              (newMessage) => !existingChat.messages.any(
                                (existingMessage) =>
                                    existingMessage.id == newMessage.id,
                              ),
                            )
                            .toList();

                        existingChat.messages.addAll(newMessages);
                      }
                    }
                  }
                  if (sentAudioSent) {
                    sentAudio = true;
                    sentAudioSent = false;
                  } else {
                    sentAudio = false;
                    sentAudioSent = false;
                  }
                });
              } else if (state is ChatViewFailed) {
                setState(() {
                  isChartViewLoading = false;
                  isFetchingMore = false;
                });
              } else if (state is UploadFileSuccess) {
                chartBloc.add(ChartSendMessageEvent(
                  chatId: widget.chatId,
                  content: 'media',
                  messageType: 'media',
                  fileName: state.filePath.split('/').last,
                  fileUrl: state.filePath,
                  fileType: 'audio',
                  fileSize: '1mb',
                ));
                FocusScope.of(context).unfocus();
              } else if (state is UploadFileFailed) {
                setState(() {
                  isChartViewLoading = false;
                  isFetchingMore = false;
                });
              } else if (state is ChartSendMessageSuccess) {
                _fetchData();
              }
            }),
            BlocListener<InitialRegisterBloc, InitialRegisterState>(
              listener: (context, state) {
                if (state is UploadImageSuccess) {
                  setState(() {
                    profilePicture = state.filePath;

                    chartBloc.add(ChartSendMessageEvent(
                      chatId: widget.chatId,
                      content: 'media',
                      messageType: 'media',
                      fileName: profilePicture.split('/').last,
                      fileUrl: profilePicture,
                      fileType: 'image',
                      fileSize: '1mb',
                    ));
                    FocusScope.of(context).unfocus();
                  });
                } else if (state is UploadImageFailed) {
                  showCustomSnackBar(
                    context: context,
                    message: state.message,
                  );
                }
              },
            ),
          ],
          child: SafeArea(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (!isChartViewLoading) ...[
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
                                widget.refreshPageCallback();
                                socket.emit("close_chat", Config.id);
                                Navigator.pop(context);
                              },
                            ),
                            InkWell(
                              onTap: () {
                                if (widget.isGroup) {
                                  Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                          builder: (context) =>
                                              MultiBlocProvider(
                                                  providers: [
                                                    BlocProvider(
                                                      create: (context) => ChartBloc()
                                                        ..add(FetchChartViewProfileEvent(
                                                            chatId:
                                                                chatViewGroupInfo
                                                                    .id!)),
                                                    ),
                                                    BlocProvider(
                                                        create: (context) =>
                                                            InitialRegisterBloc())
                                                  ],
                                                  child: ChatProfileViewScreen(
                                                    chatViewGroupInfo:
                                                        chatViewGroupInfo,
                                                    refreshPageCallback:
                                                        _refreshPageAfterEdit,
                                                  ))));
                                } else {
                                  Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                          builder:
                                              (context) => MultiBlocProvider(
                                                    providers: [
                                                      BlocProvider(
                                                        create: (context) {
                                                          final bloc =
                                                              FriendsBloc();
                                                          bloc.add(FetchFriendsSingleView(
                                                              friendId:
                                                                  filteredParticipants[
                                                                          0]
                                                                      .userId));
                                                          return bloc;
                                                        },
                                                      ),
                                                      BlocProvider(
                                                        create: (context) =>
                                                            ShowInterestedBloc(),
                                                      ),
                                                      BlocProvider(
                                                          create: (context) =>
                                                              ReportPostBloc()),
                                                      BlocProvider(
                                                          create: (context) =>
                                                              ShowInterestedBloc()),
                                                      BlocProvider(
                                                          create: (context) =>
                                                              ChartBloc())
                                                    ],
                                                    child: FriendsDetailsScreen(
                                                      refreshPageCallback:
                                                          _refreshPageAfterEdit,
                                                      id: chatViewGroupInfo
                                                          .participants[0]
                                                          .userId,
                                                    ),
                                                  )));
                                }
                              },
                              splashColor: COLORS.white.withOpacity(0.2),
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
                                        image: chatViewGroupInfo
                                                .picture!.isNotEmpty
                                            ? DecorationImage(
                                                image: NetworkImage(
                                                  chatViewGroupInfo.picture!,
                                                ),
                                                fit: BoxFit.cover)
                                            : null,
                                        borderRadius: BorderRadius.all(
                                            Radius.circular(
                                                SizeConfig.blockWidth * 3))),
                                  ),
                                  SizedBox(width: SizeConfig.blockWidth * 2),
                                  Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      SizedBox(
                                        width: SizeConfig.blockWidth * 45,
                                        child: Text(chatViewGroupInfo.name!,
                                            style: TextStyle(
                                              color: COLORS.neutralDark,
                                              fontSize:
                                                  SizeConfig.blockWidth * 3.8,
                                              fontWeight: FontWeight.w400,
                                              fontFamily: "Poppins",
                                              overflow: TextOverflow.ellipsis,
                                            ),
                                            maxLines: 1),
                                      ),
                                      SizedBox(
                                        width: SizeConfig.blockWidth * 45,
                                        child: Text(
                                            widget.isGroup
                                                ? chatViewGroupInfo.description!
                                                : filteredParticipants[0]
                                                    .user
                                                    .professionType,
                                            style: TextStyle(
                                              color: COLORS.neutralDarkOne,
                                              fontSize:
                                                  SizeConfig.blockWidth * 3.25,
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
                        if (!widget.isGroup || isCurrentUserAdmin) ...[
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
                                    onTap: () => {
                                      Navigator.push(
                                          context,
                                          MaterialPageRoute(
                                              builder: (context) =>
                                                  MultiBlocProvider(
                                                    providers: [
                                                      BlocProvider(
                                                        create: (context) =>
                                                            ProfileBloc()
                                                              ..add(
                                                                  const FetchSettingEvent()),
                                                      ),
                                                    ],
                                                    child:
                                                        const NotificationScreen(),
                                                  )))
                                    },
                                  ),
                                  if (widget.isGroup == false) ...[
                                    BottomSheetItem(
                                      title: chatViewGroupInfo.participantsDetails?.user.isFriend != null ? 'UNFRIEND'.tr() : chatViewGroupInfo.participantsDetails?.user.friendRequestSent != null ? 'REQUEST SENT'.tr() : 'ADD FRIEND',
                                      onTap: () => {
                                        showInterestedBloc.add(UnfriendsEvent(
                                            friendId: filteredParticipants![0]
                                                .userId!,
                                            onSuccess: (message) {
                                              Navigator.pushNamed(
                                                context,
                                                '/main_screen',
                                                arguments: {'selectedIndex': 3},
                                              );
                                              showCustomSnackBar(
                                                  context: context,
                                                  message:
                                                      "Successfully unfriended!",
                                                  backgroundColor:
                                                      COLORS.semanticTwo);
                                              widget.refreshPageCallback();
                                            },
                                            onError: (message) {
                                              showCustomSnackBar(
                                                context: context,
                                                message: message,
                                              );
                                            }))
                                      },
                                    ),
                                    BottomSheetItem(
                                      title: 'Delete Chat',
                                      onTap: () => {
                                        showMaterialModalBottomSheet(
                                          enableDrag: true,
                                          expand: false,
                                          isDismissible: true,
                                          backgroundColor: COLORS.white,
                                          context: context,
                                          closeProgressThreshold: 0,
                                          duration: const Duration(seconds: 0),
                                          useRootNavigator: true,
                                          shape: const RoundedRectangleBorder(
                                            borderRadius: BorderRadius.vertical(
                                                top: Radius.circular(20)),
                                          ),
                                          builder: (context) => BlocProvider(
                                            create: (context) => ChartBloc(),
                                            child: DeleteGroupModal(
                                              buttonText: 'DELETE',
                                              header:
                                                  'Are you sure you want to \n delete the group?',
                                              chatId: chatViewGroupInfo!.id!,
                                            ),
                                          ),
                                        ),
                                      },
                                    ),
                                    BottomSheetItem(
                                      title: 'Report',
                                      onTap: () async {
                                        final result =
                                            await showMaterialModalBottomSheet(
                                                enableDrag: true,
                                                expand: false,
                                                isDismissible: true,
                                                backgroundColor: COLORS.white,
                                                closeProgressThreshold: 0,
                                                duration:
                                                    const Duration(seconds: 0),
                                                context: context,
                                                shape: RoundedRectangleBorder(
                                                  borderRadius:
                                                      BorderRadius.vertical(
                                                          top: Radius.circular(
                                                              SizeConfig
                                                                      .blockWidth *
                                                                  6)),
                                                ),
                                                builder: (context) =>
                                                    const ReportOrBlockModal(
                                                      message: '',
                                                      buttonText: "REPORT",
                                                      header: 'Report',
                                                      subText:
                                                          'Write a reason for report ',
                                                    ));

                                        if (result != null) {
                                          setState(() {
                                            chartBloc.add(ReportChartGroupEvent(
                                              reason: result['message']!,
                                              chatId: chatViewGroupInfo.id,
                                              onSuccess: (message) {
                                                showCustomSnackBar(
                                                    context: context,
                                                    message: message,
                                                    backgroundColor:
                                                        COLORS.neutralDarkOne);
                                                Navigator.pushNamed(
                                                  context,
                                                  '/main_screen',
                                                  arguments: {
                                                    'selectedIndex': 3
                                                  },
                                                );
                                              },
                                              onError: (message) {
                                                Navigator.pop(context);
                                                showCustomSnackBar(
                                                  context: context,
                                                  message: message,
                                                );
                                              },
                                            ));
                                          });
                                        }
                                      },
                                    ),
                                    BottomSheetItem(
                                      title: 'Block',
                                      onTap: () async {
                                        final result =
                                            await showMaterialModalBottomSheet(
                                                enableDrag: true,
                                                expand: false,
                                                isDismissible: true,
                                                backgroundColor: COLORS.white,
                                                closeProgressThreshold: 0,
                                                duration:
                                                    const Duration(seconds: 0),
                                                context: context,
                                                shape: RoundedRectangleBorder(
                                                  borderRadius:
                                                      BorderRadius.vertical(
                                                          top: Radius.circular(
                                                              SizeConfig
                                                                      .blockWidth *
                                                                  6)),
                                                ),
                                                builder: (context) =>
                                                    const ReportOrBlockModal(
                                                      message: '',
                                                      buttonText: "BLOCK",
                                                      header: 'Block',
                                                      subText:
                                                          'Write a reason for block ',
                                                    ));

                                        if (result != null) {
                                          setState(() {
                                            chartBloc.add(BlocChartGroupEvent(
                                              reason: result['message']!,
                                              chatId: chatViewGroupInfo.id,
                                              onSuccess: (message) {
                                                showCustomSnackBar(
                                                    context: context,
                                                    message: message,
                                                    backgroundColor:
                                                        COLORS.neutralDarkOne);
                                                Navigator.pushNamed(
                                                  context,
                                                  '/main_screen',
                                                  arguments: {
                                                    'selectedIndex': 3
                                                  },
                                                );
                                              },
                                              onError: (message) {
                                                Navigator.pop(context);
                                                showCustomSnackBar(
                                                  context: context,
                                                  message: message,
                                                );
                                              },
                                            ));
                                          });
                                        }
                                      },
                                    )
                                  ],
                                  // if (widget.isGroup && filteredParticipants[0].isAdmin) ...[
                                  //   BottomSheetItem(
                                  //     title: 'Invite Friends',
                                  //     onTap: () => {
                                  //       Navigator.push(
                                  //           context,
                                  //           MaterialPageRoute(
                                  //               builder: (context) =>
                                  //                   MultiBlocProvider(
                                  //                     providers: [
                                  //                       BlocProvider(
                                  //                         create: (context) => ChartBloc()
                                  //                           ..add(InviteMemberChartEvent(
                                  //                               page: 1,
                                  //                               pageSize: 10,
                                  //                               groupId:
                                  //                                   chatViewGroupInfo
                                  //                                       .id!,
                                  //                               keyWord: '')),
                                  //                       ),
                                  //                     ],
                                  //                     child: InviteFriendsList(
                                  //                       groupId:
                                  //                           chatViewGroupInfo.id!,
                                  //                     ),
                                  //                   )))
                                  //     },
                                  //   ),
                                  //   BottomSheetItem(
                                  //     title: 'Remove People',
                                  //     onTap: () => {
                                  //       Navigator.push(
                                  //           context,
                                  //           MaterialPageRoute(
                                  //               builder: (context) =>
                                  //                   MultiBlocProvider(
                                  //                     providers: [
                                  //                       BlocProvider(
                                  //                         create: (context) => ChartBloc()
                                  //                           ..add(FetchChartViewProfileEvent(
                                  //                               chatId:
                                  //                                   chatViewGroupInfo
                                  //                                       .id!)),
                                  //                       ),
                                  //                     ],
                                  //                     child: RemoveFriendsChat(
                                  //                         chatViewGroupInfo:
                                  //                             chatViewGroupInfo),
                                  //                   )))
                                  //     },
                                  //   ),
                                  //   BottomSheetItem(
                                  //       title: 'Share Joining Link',
                                  //       onTap: () => {}),
                                  //   if (chatViewGroupInfo.createdBy ==
                                  //       Config.id) ...[
                                  //     BottomSheetItem(
                                  //       title: 'Delete Group',
                                  //       onTap: () => {
                                  //         showMaterialModalBottomSheet(
                                  //           enableDrag: true,
                                  //           expand: false,
                                  //           isDismissible: true,
                                  //           backgroundColor: COLORS.white,
                                  //           context: context,
                                  //           closeProgressThreshold: 0,
                                  //           duration: const Duration(seconds: 0),
                                  //           useRootNavigator: true,
                                  //           shape: const RoundedRectangleBorder(
                                  //             borderRadius: BorderRadius.vertical(
                                  //                 top: Radius.circular(20)),
                                  //           ),
                                  //           builder: (context) => BlocProvider(
                                  //             create: (context) => ChartBloc(),
                                  //             child: DeleteGroupModal(
                                  //               buttonText: 'DELETE',
                                  //               header:
                                  //                   'Are you sure you want to \n delete the group?',
                                  //               chatId: chatViewGroupInfo!.id!,
                                  //             ),
                                  //           ),
                                  //         ),
                                  //       },
                                  //     )
                                  //   ],
                                  //   BottomSheetItem(
                                  //     title: 'Leave Group',
                                  //     onTap: () => {
                                  //       if (chatViewGroupInfo.createdBy ==
                                  //           Config.id)
                                  //         {
                                  //           showMaterialModalBottomSheet(
                                  //             enableDrag: true,
                                  //             expand: false,
                                  //             isDismissible: true,
                                  //             backgroundColor: COLORS.white,
                                  //             context: context,
                                  //             closeProgressThreshold: 0,
                                  //             duration:
                                  //                 const Duration(seconds: 0),
                                  //             useRootNavigator: true,
                                  //             shape: const RoundedRectangleBorder(
                                  //               borderRadius:
                                  //                   BorderRadius.vertical(
                                  //                       top: Radius.circular(20)),
                                  //             ),
                                  //             builder: (context) =>
                                  //                 MarkasAdminModal(
                                  //               members: chatViewGroupInfo
                                  //                   .participants!,
                                  //             ),
                                  //           ),
                                  //         }
                                  //       else
                                  //         {
                                  //           chartBloc.add(LeaveGroupChatEvent(
                                  //               chatId: widget.chatId,
                                  //               onSuccess: (message) {
                                  //                 showCustomSnackBar(
                                  //                     context: context,
                                  //                     message: message,
                                  //                     backgroundColor:
                                  //                         COLORS.neutralDarkTwo);
                                  //                 Navigator.pushNamed(
                                  //                   context,
                                  //                   '/main_screen',
                                  //                   arguments: {
                                  //                     'selectedIndex': 3
                                  //                   },
                                  //                 );
                                  //               },
                                  //               onError: (message) {
                                  //                 showCustomSnackBar(
                                  //                   context: context,
                                  //                   message: message,
                                  //                 );
                                  //               }))
                                  //         }
                                  //     },
                                  //   ),
                                  // ],

                                  // BottomSheetItem(
                                  //     title: 'Share Joining Link',
                                  //     onTap: () => {}),

                                  if (widget.isGroup == true &&
                                      isCurrentUserAdmin) ...[
                                    BottomSheetItem(
                                      title: 'Clear Chat',
                                      onTap: () => {
                                        showCustomAlertDialog(
                                          context: context,
                                          title: 'Are you Sure?',
                                          message: 'Do you want to clear chat',
                                          positiveButtonText: 'YES',
                                          negativeButtonText: 'NO',
                                          onPositivePressed: () {
                                            chartBloc.add(ClearChatEvent(
                                                chatId: widget.chatId,
                                                onSuccess: (message) {
                                                  showCustomSnackBar(
                                                      context: context,
                                                      message: message,
                                                      backgroundColor: COLORS
                                                          .neutralDarkTwo);
                                                  Navigator.pushNamed(
                                                    context,
                                                    '/main_screen',
                                                    arguments: {
                                                      'selectedIndex': 3
                                                    },
                                                  );
                                                },
                                                onError: (message) {
                                                  showCustomSnackBar(
                                                    context: context,
                                                    message: message,
                                                  );
                                                }));
                                          },
                                          onNegativePressed: () {
                                            Navigator.of(context).pop();
                                          },
                                        )
                                      },
                                    ),
                                    if (chatViewGroupInfo.archivedFor!
                                        .contains(Config.id)) ...[
                                      BottomSheetItem(
                                        title: 'UnArchive',
                                        onTap: () => {
                                          chartBloc.add(UnArchiveChatEvent(
                                              chatId: widget.chatId,
                                              onSuccess: (message) {
                                                showCustomSnackBar(
                                                    context: context,
                                                    message: message,
                                                    backgroundColor:
                                                        COLORS.neutralDarkTwo);
                                                Navigator.pushNamed(
                                                  context,
                                                  '/main_screen',
                                                  arguments: {
                                                    'selectedIndex': 3
                                                  },
                                                );
                                              },
                                              onError: (message) {
                                                showCustomSnackBar(
                                                  context: context,
                                                  message: message,
                                                );
                                              }))
                                        },
                                      )
                                    ] else ...[
                                      BottomSheetItem(
                                        title: 'Archive',
                                        onTap: () => {
                                          chartBloc.add(ArchiveChatEvent(
                                              chatId: widget.chatId,
                                              onSuccess: (message) {
                                                showCustomSnackBar(
                                                    context: context,
                                                    message: message,
                                                    backgroundColor:
                                                        COLORS.neutralDarkTwo);
                                                Navigator.pushNamed(
                                                  context,
                                                  '/main_screen',
                                                  arguments: {
                                                    'selectedIndex': 3
                                                  },
                                                );
                                              },
                                              onError: (message) {
                                                showCustomSnackBar(
                                                  context: context,
                                                  message: message,
                                                );
                                              }))
                                        },
                                      )
                                    ]
                                  ],
                                ],
                              );
                            },
                          )
                        ]
                      ],
                    ),
                  ),
                  Expanded(
                    child: Padding(
                        padding: EdgeInsets.only(
                          top: SizeConfig.blockHeight * 0.5,
                          right: SizeConfig.blockWidth * 1.5,
                          left: SizeConfig.blockWidth * 1.5,
                        ),
                        child: ListView.builder(
                            controller: _scrollController,
                            itemCount:
                                chatView.length + (isFetchingMore ? 1 : 0),
                            shrinkWrap: true,
                            scrollDirection: Axis.vertical,
                            reverse: true,
                            itemBuilder: (context, index) {
                              if (index == chatView.length) {
                                return isFetchingMore
                                    ? Center(
                                        child: LoadingAnimationWidget
                                            .discreteCircle(
                                          color: COLORS.primary,
                                          // secondRingColor: COLORS.semanticTwo,
                                          // thirdRingColor: COLORS.accent,
                                          size: SizeConfig.blockHeight * 3.5,
                                        ),
                                      )
                                    : const SizedBox.shrink();
                              }
                              ChatView chatDate = chatView[index];
                              return Column(
                                mainAxisAlignment: MainAxisAlignment.start,
                                crossAxisAlignment: CrossAxisAlignment.center,
                                children: [
                                  Padding(
                                    padding: EdgeInsets.only(
                                        bottom: SizeConfig.blockHeight,
                                        top: SizeConfig.blockHeight),
                                    child: Text(
                                      chatDate.date,
                                      style: TextStyle(
                                        color: COLORS.neutralDarkOne,
                                        fontSize: SizeConfig.blockWidth * 3.25,
                                        fontWeight: FontWeight.w400,
                                        fontFamily: "Poppins",
                                      ),
                                    ),
                                  ),
                                  ListView.builder(
                                    itemCount: chatDate.messages.length,
                                    shrinkWrap: true,
                                    physics: NeverScrollableScrollPhysics(),
                                    reverse: true,
                                    itemBuilder: (context, msgIndex) {
                                      Message message =
                                          chatDate.messages[msgIndex];
                                      return Column(
                                        mainAxisAlignment:
                                            MainAxisAlignment.start,
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          if (message.senderId ==
                                              Config.id) ...[
                                            SendMessage(
                                              message: message.content!,
                                              key: null,
                                              isSeenByMe: true,
                                              time: formatTime(message
                                                  .updatedAt!
                                                  .toString()),
                                              audioShow:
                                                  message.type == 'media' &&
                                                      message.messageMedia!
                                                          .isNotEmpty &&
                                                      message.messageMedia![0]
                                                              .fileType ==
                                                          "audio",
                                              textShow: message.type == 'text',
                                              imageShow:
                                                  message.type == 'media' &&
                                                      message.messageMedia!
                                                          .isNotEmpty &&
                                                      message.messageMedia![0]
                                                              .fileType ==
                                                          "image",
                                              imageUrl: message
                                                      .messageMedia!.isNotEmpty
                                                  ? message
                                                      .messageMedia![0].fileUrl!
                                                  : '',
                                              audioWidget: WaveBubble(
                                                audioUrl: message.messageMedia!
                                                        .isNotEmpty
                                                    ? message.messageMedia![0]
                                                        .fileUrl!
                                                    : '',
                                                isSender: true,
                                                downloaded: sentAudio,
                                              ),
                                            )
                                          ] else ...[
                                            if (message.sender != null) ...[
                                              ReceivedMessage(
                                                  message: message.content!,
                                                  key: null,
                                                  isSeenByMe: true,
                                                  time: formatTime(
                                                      message
                                                          .updatedAt!
                                                          .toString()),
                                                  audioShow: message.type ==
                                                          'media' &&
                                                      message.messageMedia!
                                                          .isNotEmpty &&
                                                      message.messageMedia![0]
                                                              .fileType ==
                                                          "audio",
                                                  textShow:
                                                      message.type == 'text',
                                                  imageShow: message.type ==
                                                          'media' &&
                                                      message.messageMedia!
                                                          .isNotEmpty &&
                                                      message.messageMedia![0]
                                                              .fileType ==
                                                          "image",
                                                  imageUrl: message
                                                          .messageMedia!
                                                          .isNotEmpty
                                                      ? message.messageMedia![0]
                                                          .fileUrl!
                                                      : '',
                                                  audioWidget: WaveBubble(
                                                    audioUrl: message
                                                            .messageMedia!
                                                            .isNotEmpty
                                                        ? message
                                                            .messageMedia![0]
                                                            .fileUrl!
                                                        : '',
                                                    isSender: true,
                                                  ),
                                                  sendName: message.sender!.name!)
                                            ]
                                          ],
                                        ],
                                      );
                                    },
                                  ),
                                ],
                              );
                            })),
                  )
                ] else ...[
                  SizedBox(
                    width: SizeConfig.blockWidth * 90,
                    height: SizeConfig.blockHeight * 90,
                    child: globalLoadingWidget(),
                  )
                ]
              ],
            ),
          ),
        ),
        bottomNavigationBar: Padding(
          padding: EdgeInsets.only(
            bottom: MediaQuery.of(context).viewInsets.bottom,
          ),
          child: Container(
            padding: EdgeInsets.symmetric(
              vertical: SizeConfig.blockHeight * 2,
              horizontal: SizeConfig.blockWidth * 4,
            ),
            decoration: BoxDecoration(
              border: Border(
                top: BorderSide(
                  color: COLORS.neutralDarkTwo,
                  width: SizeConfig.blockWidth * 0.25,
                ),
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
                        profilePicture = '';
                        initialRegisterBloc
                            .add(UploadImageEvent(imagePath: _profileImage!));
                      });
                    }),
                    child: Container(
                      padding: EdgeInsets.all(SizeConfig.blockWidth * 4),
                      height: SizeConfig.blockHeight * 8,
                      decoration: BoxDecoration(
                        color: COLORS.primaryOne.withOpacity(0.35),
                        borderRadius:
                            BorderRadius.circular(SizeConfig.blockWidth * 3.5),
                      ),
                      child: Icon(
                        Icons.add,
                        color: COLORS.primary,
                        size: SizeConfig.blockWidth * 6,
                      ),
                    ),
                  ),
                  SizedBox(width: SizeConfig.blockWidth * 4),
                ],
                Expanded(
                  child:
                      isRecording ? _buildRecordingUI() : _buildTextInputUI(),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTextInputUI() {
    return Container(
      height: SizeConfig.blockHeight * 8,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(SizeConfig.blockWidth * 3.25),
        color: COLORS.primaryOne.withOpacity(0.35),
        border: Border.all(
          color: COLORS.neutralDarkTwo.withOpacity(0.6),
          width: SizeConfig.blockWidth * 0.1,
        ),
      ),
      child: Row(
        children: [
          Expanded(
            child: TextField(
              controller: _messageController,
              style: TextStyle(
                color: COLORS.neutralDark,
                fontSize: SizeConfig.blockWidth * 3.25,
                fontWeight: FontWeight.w400,
                fontFamily: "Poppins",
              ),
              cursorColor: COLORS.black,
              decoration: InputDecoration(
                fillColor: COLORS.primaryOne.withOpacity(0.05),
                filled: true,
                hintText: 'Your message'.tr(),
                hintStyle: TextStyle(
                  color: COLORS.neutralDarkOne,
                  fontSize: SizeConfig.blockWidth * 3.25,
                  fontWeight: FontWeight.w400,
                  fontFamily: "Poppins",
                ),
                border: OutlineInputBorder(
                  borderRadius:
                      BorderRadius.circular(SizeConfig.blockWidth * 3.25),
                  borderSide: BorderSide.none,
                ),
              ),
              maxLines: null,
              minLines: 1,
              onChanged: (text) {
                setState(() {}); // Ensure the send button updates correctly
              },
            ),
          ),
          Padding(
            padding: EdgeInsets.only(right: SizeConfig.blockWidth * 2.5),
            child: InkWell(
              onTap: _messageController.text.isEmpty
                  ? _startOrStopRecording
                  : onSendMessage,
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
          ),
        ],
      ),
    );
  }

  Widget _buildRecordingUI() {
    return AnimatedSwitcher(
      duration: const Duration(milliseconds: 200),
      child: Container(
        width: SizeConfig.blockWidth * 90,
        height: SizeConfig.blockHeight * 8,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(SizeConfig.blockWidth * 3),
          color: COLORS.primary,
        ),
        padding: EdgeInsets.symmetric(horizontal: SizeConfig.blockWidth * 3),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            AudioWaveforms(
              enableGesture: true,
              size:
                  Size(SizeConfig.blockWidth * 70, SizeConfig.blockHeight * 8),
              recorderController: recorderController,
              waveStyle: const WaveStyle(
                waveColor: COLORS.white,
                extendWaveform: true,
                showMiddleLine: false,
                waveThickness: 1.5,
                waveCap: StrokeCap.square,
              ),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(SizeConfig.blockWidth * 3),
                color: COLORS.primary,
              ),
              padding: EdgeInsets.only(left: SizeConfig.blockWidth * 3),
            ),
            InkWell(
              onTap: _startOrStopRecording,
              borderRadius: BorderRadius.circular(SizeConfig.blockWidth * 10),
              child: Container(
                width: SizeConfig.blockWidth * 10,
                height: SizeConfig.blockWidth * 10,
                padding: EdgeInsets.all(SizeConfig.blockWidth * 2.5),
                decoration: BoxDecoration(
                  borderRadius:
                      BorderRadius.circular(SizeConfig.blockWidth * 10),
                  color: COLORS.white,
                ),
                child: Image.asset(
                  'assets/images/chat/message.png',
                  width: SizeConfig.blockWidth * 2.5,
                  height: SizeConfig.blockWidth * 2.5,
                  fit: BoxFit.fill,
                ),
              ),
            ),
          ],
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
