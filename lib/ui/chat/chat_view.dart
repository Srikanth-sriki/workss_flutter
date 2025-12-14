import 'dart:async';
import 'dart:io';

import 'package:audio_waveforms/audio_waveforms.dart';
import 'package:flutter_contacts/flutter_contacts.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:geolocator/geolocator.dart';
import 'package:image_picker/image_picker.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';
import 'package:modal_bottom_sheet/modal_bottom_sheet.dart';
import 'package:path_provider/path_provider.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:works_app/bloc/chart/chart_bloc.dart';
import 'package:works_app/components/colors.dart';
import 'package:works_app/components/config.dart';
import 'package:works_app/global_helper/loading_placeholder/home_layout.dart';
import 'package:works_app/ui/chat/chat_profile_view.dart';
import 'package:works_app/ui/chat/modal/delete_leave_group.dart';

import '../../bloc/friends/friends_bloc.dart';
import '../../bloc/profile/profile_bloc.dart';
import '../../bloc/register_account/initial_register_bloc.dart';
import '../../bloc/report_post_bloc.dart';
import '../../bloc/show_interested/show_interested_bloc.dart';
import '../../components/size_config.dart';
import '../../global_helper/helper_function.dart';
import '../../global_helper/popup.dart';
import '../../global_helper/reuse_widget.dart';
import '../../helper/socket_service.dart';
import '../../helper/network_helper.dart';
import '../../helper/network_error_handler.dart';
import '../../models/chat/chat_view_modal.dart';
import '../../models/chat/chat_view_pro_modal.dart';
import '../../models/chat/charts_list_modal.dart';
import '../../models/friends/friends_search_list_modal.dart';
import '../friends/friends_details.dart';
import '../profile/notification.dart';
import 'component.dart';
import 'chat_wave_form.dart';
import 'modal/report_or_block.dart';
import 'package:socket_io_client/socket_io_client.dart' as io;

class ChatViewScreen extends StatefulWidget {
  final VoidCallback refreshPageCallback;
  final String chatId;
  final bool isGroup;
  final bool isRequest;
  const ChatViewScreen(
      {super.key,
      required this.refreshPageCallback,
      required this.chatId,
      required this.isGroup,
      this.isRequest = false});

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
  late bool isRequestLocal;
  bool _sending = false;

  // Message selection state
  bool _isSelectionMode = false;
  Set<String> _selectedMessageIds = {};

  @override
  void initState() {
    super.initState();
    _isMounted = true;

    chartBloc = BlocProvider.of<ChartBloc>(context);
    initialRegisterBloc = BlocProvider.of<InitialRegisterBloc>(context);
    showInterestedBloc = BlocProvider.of<ShowInterestedBloc>(context);
    setState(() {
      isRequestLocal = widget.isRequest;
    });

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
        // Only fetch data if we don't have temporary messages being processed
        bool hasTemporaryMessages = false;
        for (var chatDate in chatView) {
          for (var message in chatDate.messages) {
            if (message.tempId != null &&
                (message.messageState == MessageState.sending ||
                    message.messageState == MessageState.sent)) {
              hasTemporaryMessages = true;
              break;
            }
          }
          if (hasTemporaryMessages) break;
        }

        if (!hasTemporaryMessages) {
          setState(() {
            _fetchData();
            print(data);
          });
        }
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
    try {
      recorderController = RecorderController()
        ..androidEncoder = AndroidEncoder.aac
        ..androidOutputFormat = AndroidOutputFormat.mpeg4
        ..iosEncoder = IosEncoder.kAudioFormatMPEG4AAC
        ..sampleRate = 44100;

      debugPrint("RecorderController initialized successfully");
    } catch (e) {
      debugPrint("Error initializing RecorderController: $e");
      _showErrorSnackBar("Audio recording not available");
    }
  }

  Future<void> _fetchData() async {
    // Check network before fetching
    final hasConnection = await NetworkHelper.hasInternetConnection();
    if (!hasConnection) {
      if (_isMounted) {
        NetworkErrorHandler.showNetworkErrorSnackBar(
          context,
          'No internet connection. Please check your network settings.',
        );
      }
      return;
    }

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

  Future<void> _loadMoreData() async {
    if (!isFetchingMore && currentPage < maxPageNumber) {
      // Check network before loading more
      final hasConnection = await NetworkHelper.hasInternetConnection();
      if (!hasConnection) {
        if (_isMounted) {
          NetworkErrorHandler.showNetworkErrorSnackBar(
            context,
            'No internet connection. Cannot load more messages.',
          );
        }
        return;
      }

      setState(() => isFetchingMore = true);
      currentPage++;
      _fetchData();
    }
  }

  void _startOrStopRecording() async {
    setState(() {
      sentAudio = false;
      sentAudioSent = false;
    });

    // Check network before stopping recording (to upload)
    if (isRecording) {
      final hasConnection = await NetworkHelper.hasInternetConnection();
      if (!hasConnection) {
        NetworkErrorHandler.showNetworkErrorSnackBar(
          context,
          'No internet connection. Cannot send audio message.',
        );
        setState(() {
          isRecording = false;
        });
        return;
      }
    }

    try {
      if (isRecording) {
        // Stop recording with timeout
        try {
          path = await recorderController.stop(false).timeout(
            Duration(seconds: 5),
            onTimeout: () {
              debugPrint("Recording stop timeout");
              return null;
            },
          );
        } catch (e) {
          debugPrint("Error stopping recorder: $e");
          _showErrorSnackBar("Failed to stop recording");
          return;
        }

        if (path != null && path!.isNotEmpty) {
          final recordedFile = File(path!);

          // Check if file exists and has content
          if (await recordedFile.exists()) {
            final fileSize = await recordedFile.length();
            debugPrint("Recorded file size: $fileSize bytes");

            if (fileSize > 0) {
              isRecordingCompleted = true;
              chartBloc.add(UploadFileEvent(filePath: recordedFile));
              setState(() {
                sentAudioSent = true;
              });
            } else {
              debugPrint("Recorded file is empty");
              _showErrorSnackBar("Recording failed - empty file");
            }
          } else {
            debugPrint("Recorded file does not exist");
            _showErrorSnackBar("Recording failed - file not created");
          }
        } else {
          debugPrint("Recording path is null or empty");
          _showErrorSnackBar("Recording failed - no file path");
        }
      } else {
        // Check if recording is available before starting
        final isAvailable = await _isRecordingAvailable();
        if (!isAvailable) {
          _showErrorSnackBar("Audio recording is not available on this device");
          return;
        }

        // Start recording with error handling
        try {
          final dir = await getApplicationDocumentsDirectory();
          path =
              '${dir.path}/recording_${DateTime.now().millisecondsSinceEpoch}.m4a';

          await recorderController.record(path: path).timeout(
            Duration(seconds: 10),
            onTimeout: () {
              debugPrint("Recording start timeout");
              throw Exception("Recording start timeout");
            },
          );
          debugPrint("Started recording to: $path");
        } catch (e) {
          debugPrint("Error starting recording: $e");
          _showErrorSnackBar("Failed to start recording. Please try again.");
          return;
        }
      }
    } catch (e) {
      debugPrint("Recording error: ${e.toString()}");
      _showErrorSnackBar("Recording error: ${e.toString()}");
    } finally {
      setState(() {
        isRecording = !isRecording;
      });
    }
  }

  void _showErrorSnackBar(String message) {
    if (_isMounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(message),
          backgroundColor: Colors.black12,
          duration: Duration(seconds: 3),
        ),
      );
    }
  }

  Future<bool> _isRecordingAvailable() async {
    try {
      // Test if we can initialize the recorder
      final testController = RecorderController()
        ..androidEncoder = AndroidEncoder.aac
        ..androidOutputFormat = AndroidOutputFormat.mpeg4
        ..iosEncoder = IosEncoder.kAudioFormatMPEG4AAC
        ..sampleRate = 44100;

      // Dispose the test controller
      testController.dispose();
      return true;
    } catch (e) {
      debugPrint("Recording not available: $e");
      return false;
    }
  }

  // void _startOrStopRecording() async {
  //   setState(() {
  //     sentAudio = false;
  //     sentAudioSent = false;
  //   });
  //
  //   try {
  //     if (isRecording) {
  //       recorderController.reset();
  //
  //       path = await recorderController.stop(false);
  //
  //       if (path != null) {
  //         isRecordingCompleted = true;
  //         final recordedFile = File(path!);
  //         int size = recordedFile.lengthSync();
  //         debugPrint("Original size: $size bytes");
  //
  //         File fileToUpload = recordedFile;
  //         if (size > 1 * 1024 * 1024) {
  //           final compressed = await compressAudio(recordedFile);
  //           if (compressed != null) {
  //             fileToUpload = compressed;
  //           }
  //         }
  //
  //         chartBloc.add(UploadFileEvent(filePath: fileToUpload));
  //
  //         setState(() {
  //           sentAudioSent = true;
  //         });
  //       }
  //     } else {
  //       final dir = await getTemporaryDirectory();
  //       path = '${dir.path}/recorded_${DateTime.now().millisecondsSinceEpoch}.aac';
  //       await recorderController.record(path: path);
  //     }
  //   } catch (e) {
  //     debugPrint(e.toString());
  //   } finally {
  //     setState(() {
  //       isRecording = !isRecording;
  //     });
  //   }
  // }

  void _retryMessage(Message message) {
    if (message.tempId != null) {
      // Retry sending the message
      setState(() {
        message.messageState = MessageState.sending;
        message.isUploading = true;
      });

      if (message.type == 'text') {
        chartBloc.add(ChartSendMessageEvent(
          chatId: widget.chatId,
          content: message.content,
          messageType: 'text',
          fileName: null,
          fileUrl: null,
          fileType: null,
          fileSize: null,
        ));
      } else if (message.type == 'media') {
        // Handle media retry
        if (message.messageMedia.isNotEmpty) {
          final media = message.messageMedia[0];
          if (media.fileType == 'audio') {
            // Retry audio upload
            chartBloc.add(UploadFileEvent(filePath: File(media.fileUrl)));
          } else if (media.fileType == 'image') {
            // Retry image upload
            initialRegisterBloc
                .add(UploadImageEvent(imagePath: File(media.fileUrl)));
          }
        }
      }
    }
  }

  void _addMessageWithAnimation(Message message) {
    setState(() {
      if (chatView.isNotEmpty) {
        chatView[0].messages.insert(0, message);
      }
    });
  }

  void _cleanupTemporaryMessages() {
    setState(() {
      for (var chatDate in chatView) {
        chatDate.messages.removeWhere((message) =>
            message.tempId != null &&
            message.messageState == MessageState.sent);
      }
    });
  }

  Future<void> onSendMessage() async {
    if (_sending) return;

    // Check network before sending
    final hasConnection = await NetworkHelper.hasInternetConnection();
    if (!hasConnection) {
      NetworkErrorHandler.showNetworkErrorSnackBar(
        context,
        'No internet connection. Please check your network settings.',
      );
      return;
    }

    _sending = true;

    try {
      final tempId = DateTime.now().millisecondsSinceEpoch.toString();
      final messageContent = _messageController.text;

      // Create a temporary message with sending state
      final tempMessage = Message(
        id: tempId,
        chatId: widget.chatId,
        senderId: Config.id,
        content: messageContent,
        type: 'text',
        deletedFor: [],
        messageMedia: [],
        messageState: MessageState.sending,
        isUploading: false,
        tempId: tempId,
      );

      // Add temporary message to the list with animation
      _addMessageWithAnimation(tempMessage);

      // Add timeout to handle stuck messages
      Future.delayed(Duration(seconds: 10), () {
        if (_isMounted) {
          setState(() {
            for (var chatDate in chatView) {
              for (var message in chatDate.messages) {
                if (message.tempId == tempId &&
                    message.messageState == MessageState.sending) {
                  message.messageState = MessageState.failed;
                  message.isUploading = false;
                }
              }
            }
          });
        }
      });

      chartBloc.add(ChartSendMessageEvent(
        chatId: widget.chatId,
        content: messageContent,
        messageType: 'text',
        fileName: null,
        fileUrl: null,
        fileType: null,
        fileSize: null,
      ));
      FocusScope.of(context).unfocus();
      _messageController.clear();
    } catch (e) {
      if (NetworkHelper.isNetworkError(e)) {
        NetworkErrorHandler.showNetworkErrorSnackBar(
          context,
          NetworkHelper.getNetworkErrorMessage(e),
        );
      }
    } finally {
      _sending = false;
    }
  }

  @override
  void dispose() {
    _isMounted = false;

    // socket.off('new_message');
    // socket.disconnect();
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
                try {
                  final tempId =
                      DateTime.now().millisecondsSinceEpoch.toString();

                  // Create temporary message for audio
                  final tempMessage = Message(
                    id: tempId,
                    chatId: widget.chatId,
                    senderId: Config.id,
                    content: 'media',
                    type: 'media',
                    deletedFor: [],
                    messageMedia: [
                      MessageMedia(
                        id: tempId,
                        messageId: tempId,
                        fileName: state.filePath.split('/').last,
                        fileUrl: state.filePath,
                        fileType: 'audio',
                        fileSize: '1mb',
                      ),
                    ],
                    messageState: MessageState.sending,
                    isUploading: true,
                    tempId: tempId,
                  );

                  // Add temporary message to the list with animation
                  _addMessageWithAnimation(tempMessage);

                  // Add timeout to handle stuck audio messages
                  Future.delayed(Duration(seconds: 15), () {
                    if (_isMounted) {
                      setState(() {
                        for (var chatDate in chatView) {
                          for (var message in chatDate.messages) {
                            if (message.tempId == tempId &&
                                message.messageState == MessageState.sending) {
                              message.messageState = MessageState.failed;
                              message.isUploading = false;
                            }
                          }
                        }
                      });
                    }
                  });

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
                } catch (e) {
                  debugPrint("Error handling UploadFileSuccess: $e");
                  _showErrorSnackBar("Error processing audio upload");
                }
              } else if (state is UploadFileFailed) {
                // Update any uploading audio messages to failed state
                setState(() {
                  for (var chatDate in chatView) {
                    for (var message in chatDate.messages) {
                      if (message.tempId != null &&
                          message.messageState == MessageState.sending &&
                          message.type == 'media' &&
                          message.messageMedia.isNotEmpty &&
                          message.messageMedia[0].fileType == 'audio') {
                        message.messageState = MessageState.failed;
                        message.isUploading = false;
                      }
                    }
                  }
                });

                // Show network error if applicable
                if (state.message != null) {
                  final errorMessage = state.message!;
                  if (NetworkHelper.isNetworkError(errorMessage) ||
                      errorMessage.toLowerCase().contains('network') ||
                      errorMessage.toLowerCase().contains('internet') ||
                      errorMessage.toLowerCase().contains('connection')) {
                    NetworkErrorHandler.showNetworkErrorSnackBar(
                      context,
                      NetworkHelper.getNetworkErrorMessage(errorMessage),
                    );
                  } else {
                    _showErrorSnackBar(errorMessage);
                  }
                }
              } else if (state is ChartSendMessageSuccess) {
                // Update message state to sent
                setState(() {
                  for (var chatDate in chatView) {
                    for (var message in chatDate.messages) {
                      if (message.tempId != null &&
                          message.messageState == MessageState.sending) {
                        message.messageState = MessageState.sent;
                        message.isUploading = false;
                        // Message ID will be updated when we fetch new data
                      }
                    }
                  }
                });

                // Clean up temporary messages after a short delay
                Future.microtask(() {
                  if (_isMounted) {
                    _cleanupTemporaryMessages();
                    _fetchData();
                  }
                });
              } else if (state is ChartSendMessageFailed) {
                // Update message state to failed
                setState(() {
                  for (var chatDate in chatView) {
                    for (var message in chatDate.messages) {
                      if (message.tempId != null &&
                          (message.messageState == MessageState.sending ||
                              message.messageState == MessageState.sent)) {
                        message.messageState = MessageState.failed;
                        message.isUploading = false;
                      }
                    }
                  }
                });

                // Show network error if applicable
                if (state.message != null) {
                  final errorMessage = state.message!;
                  if (NetworkHelper.isNetworkError(errorMessage) ||
                      errorMessage.toLowerCase().contains('network') ||
                      errorMessage.toLowerCase().contains('internet') ||
                      errorMessage.toLowerCase().contains('connection')) {
                    NetworkErrorHandler.showNetworkErrorSnackBar(
                      context,
                      NetworkHelper.getNetworkErrorMessage(errorMessage),
                    );
                  } else {
                    _showErrorSnackBar(errorMessage);
                  }
                }
              } else if (state is ChatViewFailed) {
                // Handle network errors in chat view fetch
                if (state.message != null) {
                  final errorMessage = state.message!;
                  if (NetworkHelper.isNetworkError(errorMessage) ||
                      errorMessage.toLowerCase().contains('network') ||
                      errorMessage.toLowerCase().contains('internet') ||
                      errorMessage.toLowerCase().contains('connection')) {
                    NetworkErrorHandler.showNetworkErrorSnackBar(
                      context,
                      NetworkHelper.getNetworkErrorMessage(errorMessage),
                    );
                  }
                }
              }
            }),
            BlocListener<InitialRegisterBloc, InitialRegisterState>(
              listener: (context, state) {
                if (state is UploadImageSuccess) {
                  try {
                    final tempId =
                        DateTime.now().millisecondsSinceEpoch.toString();

                    // Create temporary message for image
                    final tempMessage = Message(
                      id: tempId,
                      chatId: widget.chatId,
                      senderId: Config.id,
                      content: 'media',
                      type: 'media',
                      deletedFor: [],
                      messageMedia: [
                        MessageMedia(
                          id: tempId,
                          messageId: tempId,
                          fileName: state.filePath.split('/').last,
                          fileUrl: state.filePath,
                          fileType: 'image',
                          fileSize: '1mb',
                        ),
                      ],
                      messageState: MessageState.sending,
                      isUploading: true,
                      tempId: tempId,
                    );

                    // Add temporary message to the list with animation
                    setState(() {
                      profilePicture = state.filePath;
                    });
                    _addMessageWithAnimation(tempMessage);

                    // Add timeout to handle stuck image messages
                    Future.delayed(Duration(seconds: 15), () {
                      if (_isMounted) {
                        setState(() {
                          for (var chatDate in chatView) {
                            for (var message in chatDate.messages) {
                              if (message.tempId == tempId &&
                                  message.messageState ==
                                      MessageState.sending) {
                                message.messageState = MessageState.failed;
                                message.isUploading = false;
                              }
                            }
                          }
                        });
                      }
                    });

                    chartBloc.add(ChartSendMessageEvent(
                      chatId: widget.chatId,
                      content: 'media',
                      messageType: 'media',
                      fileName: state.filePath.split('/').last,
                      fileUrl: state.filePath,
                      fileType: 'image',
                      fileSize: '1mb',
                    ));
                    FocusScope.of(context).unfocus();
                  } catch (e) {
                    debugPrint("Error handling UploadImageSuccess: $e");
                    _showErrorSnackBar("Error processing image upload");
                  }
                } else if (state is UploadImageFailed) {
                  // Update any uploading image messages to failed state
                  setState(() {
                    for (var chatDate in chatView) {
                      for (var message in chatDate.messages) {
                        if (message.tempId != null &&
                            message.messageState == MessageState.sending &&
                            message.type == 'media' &&
                            message.messageMedia.isNotEmpty &&
                            message.messageMedia[0].fileType == 'image') {
                          message.messageState = MessageState.failed;
                          message.isUploading = false;
                        }
                      }
                    }
                  });

                  // Show network error if applicable
                  if (state.message != null) {
                    final errorMessage = state.message!;
                    if (NetworkHelper.isNetworkError(errorMessage) ||
                        errorMessage.toLowerCase().contains('network') ||
                        errorMessage.toLowerCase().contains('internet') ||
                        errorMessage.toLowerCase().contains('connection')) {
                      NetworkErrorHandler.showNetworkErrorSnackBar(
                        context,
                        NetworkHelper.getNetworkErrorMessage(errorMessage),
                      );
                    } else {
                      showCustomSnackBar(
                        context: context,
                        message: errorMessage,
                      );
                    }
                  }
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
                    child: _isSelectionMode
                        ? _buildSelectionAppBar()
                        : Row(
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
                                                        child:
                                                            ChatProfileViewScreen(
                                                          chatViewGroupInfo:
                                                              chatViewGroupInfo,
                                                          refreshPageCallback:
                                                              _refreshPageAfterEdit,
                                                        ))));
                                      } else {
                                        Navigator.push(
                                            context,
                                            MaterialPageRoute(
                                                builder: (context) =>
                                                    MultiBlocProvider(
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
                                                      child:
                                                          FriendsDetailsScreen(
                                                        refreshPageCallback:
                                                            _refreshPageAfterEdit,
                                                        id: filteredParticipants
                                                                .isNotEmpty
                                                            ? filteredParticipants[
                                                                    0]
                                                                .userId
                                                            : chatViewGroupInfo
                                                                .participants[0]
                                                                .userId,
                                                      ),
                                                    )));
                                      }
                                    },
                                    splashColor: COLORS.white.withOpacity(0.2),
                                    child: Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.start,
                                      crossAxisAlignment:
                                          CrossAxisAlignment.center,
                                      children: [
                                        Container(
                                          width: SizeConfig.blockWidth * 12,
                                          height: SizeConfig.blockWidth * 12,
                                          decoration: BoxDecoration(
                                              border: Border.all(
                                                color: COLORS.primary,
                                                width:
                                                    SizeConfig.blockWidth * 0.3,
                                              ),
                                              image: (chatViewGroupInfo.picture
                                                          ?.isNotEmpty ??
                                                      false)
                                                  ? DecorationImage(
                                                      image: NetworkImage(
                                                        chatViewGroupInfo
                                                            .picture!,
                                                      ),
                                                      fit: BoxFit.cover)
                                                  : null,
                                              borderRadius: BorderRadius.all(
                                                  Radius.circular(
                                                      SizeConfig.blockWidth *
                                                          6))),
                                        ),
                                        SizedBox(
                                            width: SizeConfig.blockWidth * 2),
                                        Column(
                                          mainAxisAlignment:
                                              MainAxisAlignment.center,
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            SizedBox(
                                              width: SizeConfig.blockWidth * 45,
                                              child: Text(
                                                  chatViewGroupInfo.name!,
                                                  style: TextStyle(
                                                    color: COLORS.neutralDark,
                                                    fontSize:
                                                        SizeConfig.blockWidth *
                                                            3.8,
                                                    fontWeight: FontWeight.w400,
                                                    fontFamily: "Poppins",
                                                    overflow:
                                                        TextOverflow.ellipsis,
                                                  ),
                                                  maxLines: 1),
                                            ),
                                            if (widget.isGroup
                                                ? (chatViewGroupInfo.description
                                                        ?.isNotEmpty ??
                                                    false)
                                                : (filteredParticipants
                                                        .isNotEmpty &&
                                                    filteredParticipants[0]
                                                        .user
                                                        .professionType
                                                        .isNotEmpty))
                                              SizedBox(
                                                width:
                                                    SizeConfig.blockWidth * 45,
                                                child: Text(
                                                    widget.isGroup
                                                        ? chatViewGroupInfo
                                                            .description!
                                                        : filteredParticipants
                                                                .isNotEmpty
                                                            ? filteredParticipants[
                                                                    0]
                                                                .user
                                                                .professionType
                                                            : '',
                                                    style: TextStyle(
                                                      color:
                                                          COLORS.neutralDarkOne,
                                                      fontSize: SizeConfig
                                                              .blockWidth *
                                                          3.25,
                                                      fontWeight:
                                                          FontWeight.w400,
                                                      fontFamily: "Poppins",
                                                      overflow:
                                                          TextOverflow.ellipsis,
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
                                        if (widget.isGroup == false &&
                                            filteredParticipants
                                                .isNotEmpty) ...[
                                          BottomSheetItem(
                                            title: filteredParticipants[0]
                                                        .user
                                                        .isFriend !=
                                                    null
                                                ? 'Unfriend'.tr()
                                                : filteredParticipants[0]
                                                            .user
                                                            .friendRequestSent !=
                                                        null
                                                    ? 'Request Sent'.tr()
                                                    : 'Add Friend',
                                            onTap: () => {
                                              if (filteredParticipants[0]
                                                      .user
                                                      .isFriend !=
                                                  null)
                                                {
                                                  showInterestedBloc.add(
                                                      UnfriendsEvent(
                                                          friendId:
                                                              filteredParticipants![
                                                                      0]
                                                                  .userId!,
                                                          onSuccess: (message) {
                                                            Navigator.pushNamed(
                                                              context,
                                                              '/main_screen',
                                                              arguments: {
                                                                'selectedIndex':
                                                                    3
                                                              },
                                                            );
                                                            showCustomSnackBar(
                                                                context:
                                                                    context,
                                                                message:
                                                                    "Successfully unfriended!",
                                                                backgroundColor:
                                                                    COLORS
                                                                        .semanticTwo);
                                                            widget
                                                                .refreshPageCallback();
                                                          },
                                                          onError: (message) {
                                                            showCustomSnackBar(
                                                              context: context,
                                                              message: message,
                                                            );
                                                          }))
                                                }
                                              else if (filteredParticipants[0]
                                                      .user
                                                      .friendRequestSent !=
                                                  null)
                                                {
                                                  showInterestedBloc.add(
                                                      UnSendFriendEvent(
                                                          userId:
                                                              filteredParticipants![
                                                                      0]
                                                                  .userId!,
                                                          onSuccess: (message) {
                                                            setState(() {
                                                              filteredParticipants[
                                                                          0]
                                                                      .user
                                                                      .isFriend =
                                                                  null;
                                                              filteredParticipants[
                                                                          0]
                                                                      .user
                                                                      .friendRequestSent =
                                                                  null;
                                                              Navigator
                                                                  .pushNamed(
                                                                context,
                                                                '/main_screen',
                                                                arguments: {
                                                                  'selectedIndex':
                                                                      3
                                                                },
                                                              );
                                                              showCustomSnackBar(
                                                                  context:
                                                                      context,
                                                                  message:
                                                                      message,
                                                                  backgroundColor:
                                                                      COLORS
                                                                          .semanticTwo);
                                                              widget
                                                                  .refreshPageCallback();
                                                            });
                                                          },
                                                          onError: (message) {
                                                            showCustomSnackBar(
                                                              context: context,
                                                              message: message,
                                                            );
                                                          }))
                                                }
                                              else
                                                {
                                                  showInterestedBloc.add(
                                                      AddFriendEvent(
                                                          userId:
                                                              filteredParticipants![
                                                                      0]
                                                                  .userId!,
                                                          onSuccess: (message) {
                                                            widget
                                                                .refreshPageCallback();
                                                            setState(() {
                                                              filteredParticipants[
                                                                          0]
                                                                      .user
                                                                      .friendRequestSent =
                                                                  FriendRequestSent(
                                                                id: filteredParticipants[
                                                                        0]
                                                                    .user
                                                                    .id,
                                                              );
                                                              Navigator
                                                                  .pushNamed(
                                                                context,
                                                                '/main_screen',
                                                                arguments: {
                                                                  'selectedIndex':
                                                                      3
                                                                },
                                                              );
                                                              showCustomSnackBar(
                                                                  context:
                                                                      context,
                                                                  message:
                                                                      message,
                                                                  backgroundColor:
                                                                      COLORS
                                                                          .semanticTwo);
                                                              widget
                                                                  .refreshPageCallback();
                                                            });
                                                          },
                                                          onError: (message) {
                                                            showCustomSnackBar(
                                                              context: context,
                                                              message: message,
                                                            );
                                                          }))
                                                }
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
                                                duration:
                                                    const Duration(seconds: 0),
                                                useRootNavigator: true,
                                                shape:
                                                    const RoundedRectangleBorder(
                                                  borderRadius:
                                                      BorderRadius.vertical(
                                                          top: Radius.circular(
                                                              20)),
                                                ),
                                                builder: (context) =>
                                                    BlocProvider(
                                                  create: (context) =>
                                                      ChartBloc(),
                                                  child: DeleteGroupModal(
                                                    buttonText: 'DELETE',
                                                    header:
                                                        'Are you sure you want to \n delete the chat?',
                                                    chatId:
                                                        chatViewGroupInfo!.id!,
                                                    isGroup: chatViewGroupInfo!
                                                        .isGroup,
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
                                                      backgroundColor:
                                                          COLORS.white,
                                                      closeProgressThreshold: 0,
                                                      duration: const Duration(
                                                          seconds: 0),
                                                      context: context,
                                                      shape:
                                                          RoundedRectangleBorder(
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
                                                            buttonText:
                                                                "REPORT",
                                                            header: 'Report',
                                                            subText:
                                                                'Write a reason for report ',
                                                          ));

                                              if (result != null) {
                                                setState(() {
                                                  chartBloc.add(
                                                      ReportChartGroupEvent(
                                                    reason: result['message']!,
                                                    chatId:
                                                        chatViewGroupInfo.id,
                                                    onSuccess: (message) {
                                                      showCustomSnackBar(
                                                          context: context,
                                                          message: message,
                                                          backgroundColor: COLORS
                                                              .neutralDarkOne);
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
                                                      backgroundColor:
                                                          COLORS.white,
                                                      closeProgressThreshold: 0,
                                                      duration: const Duration(
                                                          seconds: 0),
                                                      context: context,
                                                      shape:
                                                          RoundedRectangleBorder(
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
                                                  chartBloc
                                                      .add(BlocChartGroupEvent(
                                                    reason: result['message']!,
                                                    chatId:
                                                        chatViewGroupInfo.id,
                                                    onSuccess: (message) {
                                                      showCustomSnackBar(
                                                          context: context,
                                                          message: message,
                                                          backgroundColor: COLORS
                                                              .neutralDarkOne);
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
                                                message:
                                                    'Do you want to clear chat',
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
                                                chartBloc
                                                    .add(UnArchiveChatEvent(
                                                        chatId: widget.chatId,
                                                        onSuccess: (message) {
                                                          showCustomSnackBar(
                                                              context: context,
                                                              message: message,
                                                              backgroundColor:
                                                                  COLORS
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
                          right: _isSelectionMode
                              ? SizeConfig.blockWidth * 1.5
                              : SizeConfig.blockWidth * 1.5,
                          left: _isSelectionMode
                              ? SizeConfig.blockWidth * 1.5
                              : SizeConfig.blockWidth * 1.5,
                        ),
                        child: ListView.builder(
                            controller: _scrollController,
                            reverse: true,
                            itemCount:
                                chatView.length + (isFetchingMore ? 1 : 0),
                            itemBuilder: (context, index) {
                              if (index == chatView.length) {
                                return isFetchingMore
                                    ? Center(
                                        child: LoadingAnimationWidget
                                            .discreteCircle(
                                          color: COLORS.primary,
                                          size: SizeConfig.blockHeight * 3.5,
                                        ),
                                      )
                                    : const SizedBox.shrink();
                              }
                              ChatView chatDate = chatView[index];
                              return _buildDateSection(chatDate);
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
            child: isRequestLocal
                ? Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'New Chat? You Decide!',
                        style: TextStyle(
                          color: COLORS.neutralDark,
                          fontSize: SizeConfig.blockWidth * 3.6,
                          fontWeight: FontWeight.w500,
                          fontFamily: "Poppins",
                        ),
                      ),
                      SizedBox(
                        height: SizeConfig.blockHeight,
                      ),
                      Text(
                        'Review and respond to chat requests securely.',
                        style: TextStyle(
                          color: COLORS.neutralDarkOne,
                          fontSize: SizeConfig.blockWidth * 3.3,
                          fontWeight: FontWeight.w400,
                          fontFamily: "Poppins",
                        ),
                        softWrap: true,
                      ),
                      SizedBox(
                        height: SizeConfig.blockHeight,
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          customButton(
                            text: 'Reject'.tr(),
                            onPressed: () {
                              chartBloc.add(RejectChartRequestEvent(
                                  chatId: chatViewGroupInfo.id,
                                  onSuccess: (message) {
                                    setState(() {
                                      isRequestLocal = false;
                                    });
                                    showCustomSnackBar(
                                        context: context,
                                        message: message,
                                        backgroundColor: COLORS.neutralDarkOne);
                                    Navigator.pushNamed(
                                      context,
                                      '/main_screen',
                                      arguments: {'selectedIndex': 3},
                                    );
                                  },
                                  onError: (message) {
                                    showCustomSnackBar(
                                      context: context,
                                      message: message,
                                    );
                                  }));
                            },
                            backgroundColor: COLORS.neutralDarkTwo,
                            showIcon: false,
                            width: SizeConfig.blockWidth * 44,
                            height: SizeConfig.blockHeight * 8,
                            textColor: COLORS.neutralDark,
                          ),
                          customButton(
                            text: 'Accept'.tr(),
                            onPressed: () {
                              chartBloc.add(ApproveChartRequestEvent(
                                  chatId: chatViewGroupInfo.id,
                                  onSuccess: (message) {
                                    setState(() {
                                      isRequestLocal = false;
                                    });
                                  },
                                  onError: (message) {
                                    showCustomSnackBar(
                                      context: context,
                                      message: message,
                                    );
                                  }));
                            },
                            backgroundColor: COLORS.primary,
                            showIcon: false,
                            width: SizeConfig.blockWidth * 44,
                            height: SizeConfig.blockHeight * 8,
                            textColor: COLORS.white,
                          ),
                        ],
                      ),
                    ],
                  )
                : Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      if (!isRecording) ...[
                        InkWell(
                          onTap: () => _showPicker(context, (File image) {
                            setState(() {
                              _profileImage = image;
                              profilePicture = '';
                              initialRegisterBloc.add(
                                  UploadImageEvent(imagePath: _profileImage!));
                            });
                          }),
                          child: Container(
                            padding: EdgeInsets.all(SizeConfig.blockWidth * 4),
                            height: SizeConfig.blockHeight * 8,
                            decoration: BoxDecoration(
                              color: COLORS.primaryOne.withOpacity(0.35),
                              borderRadius: BorderRadius.circular(
                                  SizeConfig.blockWidth * 3.5),
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
                        child: isRecording
                            ? _buildRecordingUI()
                            : _buildTextInputUI(),
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
      constraints: BoxConstraints(
        minHeight: SizeConfig.blockHeight * 8,
        maxHeight: SizeConfig.blockHeight * 18, // Max 5 lines approximately
      ),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(SizeConfig.blockWidth * 3.25),
        color: COLORS.primaryOne.withOpacity(0.35),
        border: Border.all(
          color: COLORS.neutralDarkTwo.withOpacity(0.6),
          width: SizeConfig.blockWidth * 0.1,
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Expanded(
            child: Padding(
              padding: EdgeInsets.symmetric(
                vertical: SizeConfig.blockHeight * 1.5,
                horizontal: SizeConfig.blockWidth * 3,
              ),
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
                  fillColor: Colors.transparent,
                  filled: false,
                  hintText: 'Your message'.tr(),
                  hintStyle: TextStyle(
                    color: COLORS.neutralDarkOne,
                    fontSize: SizeConfig.blockWidth * 3.25,
                    fontWeight: FontWeight.w400,
                    fontFamily: "Poppins",
                  ),
                  border: InputBorder.none,
                  contentPadding: EdgeInsets.zero,
                  isDense: true,
                ),
                maxLines: null,
                minLines: 1,
                textInputAction: TextInputAction.newline,
                onChanged: (text) {
                  setState(() {}); // Ensure the send button updates correctly
                },
              ),
            ),
          ),
          Padding(
            padding: EdgeInsets.only(
              right: SizeConfig.blockWidth * 2.5,
              // bottom: SizeConfig.blockHeight * 1.5,
            ),
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

  Widget _buildDateSection(ChatView chatDate) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.start,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Padding(
          padding: EdgeInsets.only(
              bottom: SizeConfig.blockHeight, top: SizeConfig.blockHeight),
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
            Message message = chatDate.messages[msgIndex];
            String _safeTime(Message m) {
              final ts = m.updatedAt;
              return ts != null
                  ? formatTime(ts.toString())
                  : formatTime(DateTime.now().toString());
            }

            // Check if message is seen by comparing updatedAt with receiverLastSeen
            bool _isMessageSeen(Message m) {
              // If message is still sending or failed, it's not seen
              if (m.messageState == MessageState.sending ||
                  m.messageState == MessageState.failed) {
                return false;
              }

              // If receiverLastSeen is null, message is not seen
              if (chatViewGroupInfo.reciverLastSeen == null) {
                return false;
              }

              // If message updatedAt is null, message is not seen
              if (m.updatedAt == null) {
                return false;
              }

              // Message is seen if updatedAt is less than or equal to receiverLastSeen
              return m.updatedAt!
                      .isBefore(chatViewGroupInfo.reciverLastSeen!) ||
                  m.updatedAt!
                      .isAtSameMomentAs(chatViewGroupInfo.reciverLastSeen!);
            }

            final isSelected = _selectedMessageIds.contains(message.id);

            return GestureDetector(
              onLongPress: () {
                if (!_isSelectionMode) {
                  setState(() {
                    _isSelectionMode = true;
                    _selectedMessageIds.add(message.id);
                  });
                }
              },
              onTap: () {
                if (_isSelectionMode) {
                  setState(() {
                    if (isSelected) {
                      _selectedMessageIds.remove(message.id);
                    } else {
                      _selectedMessageIds.add(message.id);
                    }
                    if (_selectedMessageIds.isEmpty) {
                      _isSelectionMode = false;
                    }
                  });
                }
              },
              child: LayoutBuilder(
                builder: (context, constraints) {
                  return ClipRect(
                    child: Container(
                      width: constraints.maxWidth,
                      constraints: BoxConstraints(
                        maxWidth: constraints.maxWidth,
                      ),
                      decoration: _isSelectionMode && isSelected
                          ? BoxDecoration(
                              color: COLORS.primary.withOpacity(0.15),
                              borderRadius: BorderRadius.circular(
                                  SizeConfig.blockWidth * 2),
                            )
                          : null,
                      margin: _isSelectionMode && isSelected
                          ? EdgeInsets.symmetric(
                              vertical: SizeConfig.blockHeight * 0.5,
                            )
                          : EdgeInsets.zero,
                      child: message.senderId == Config.id
                          ? SendMessage(
                              message: message.content!,
                              key: null,
                              isSeenByMe: _isMessageSeen(message),
                              time: _safeTime(message),
                              audioShow: message.type == 'media' &&
                                  message.messageMedia!.isNotEmpty &&
                                  message.messageMedia![0].fileType == "audio",
                              textShow: message.type == 'text',
                              imageShow: message.type == 'media' &&
                                  message.messageMedia!.isNotEmpty &&
                                  message.messageMedia![0].fileType == "image",
                              imageUrl: message.messageMedia!.isNotEmpty
                                  ? message.messageMedia![0].fileUrl!
                                  : '',
                              messageState: message.messageState,
                              isUploading: message.isUploading,
                              onRetry: () => _retryMessage(message),
                              customTextWidget:
                                  _formatMessageWithLinks(message.content!),
                              audioWidget: WaveBubble(
                                audioUrl: message.messageMedia!.isNotEmpty
                                    ? message.messageMedia![0].fileUrl!
                                    : '',
                                isSender: true,
                                downloaded: sentAudio,
                                messageState: message.messageState,
                                isUploading: message.isUploading,
                                onRetry: () => _retryMessage(message),
                              ),
                            )
                          : (message.sender != null
                              ? ReceivedMessage(
                                  message: message.content!,
                                  key: null,
                                  isSeenByMe: true,
                                  time:
                                      formatTime(message.updatedAt!.toString()),
                                  audioShow: message.type == 'media' &&
                                      message.messageMedia!.isNotEmpty &&
                                      message.messageMedia![0].fileType ==
                                          "audio",
                                  textShow: message.type == 'text',
                                  imageShow: message.type == 'media' &&
                                      message.messageMedia!.isNotEmpty &&
                                      message.messageMedia![0].fileType ==
                                          "image",
                                  imageUrl: message.messageMedia!.isNotEmpty
                                      ? message.messageMedia![0].fileUrl!
                                      : '',
                                  customTextWidget:
                                      _formatMessageWithLinks(message.content!),
                                  audioWidget: WaveBubble(
                                    audioUrl: message.messageMedia!.isNotEmpty
                                        ? message.messageMedia![0].fileUrl!
                                        : '',
                                    isSender: true,
                                  ),
                                  sendName: widget.isGroup == true
                                      ? message.sender!.name!
                                      : "")
                              : const SizedBox.shrink()),
                    ),
                  );
                },
              ),
            );
          },
        ),
      ],
    );
  }

  Widget _buildSelectionAppBar() {
    return Container(
      color: COLORS.white,
      padding: EdgeInsets.only(
        // top: MediaQuery.of(context).padding.top,
        bottom: SizeConfig.blockHeight * 0.1,
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Row(
            children: [
              IconButton(
                icon: Icon(
                  Icons.arrow_back_ios_new_sharp,
                  color: COLORS.neutralDark,
                  size: SizeConfig.blockWidth * 4.5,
                ),
                onPressed: () {
                  setState(() {
                    _isSelectionMode = false;
                    _selectedMessageIds.clear();
                  });
                },
              ),
              SizedBox(width: SizeConfig.blockWidth * 1),
              Text(
                'Selected ${_selectedMessageIds.length}',
                style: TextStyle(
                  color: COLORS.primary,
                  fontSize: SizeConfig.blockWidth * 3.8,
                  fontWeight: FontWeight.w400,
                  fontFamily: "Poppins",
                ),
              ),
            ],
          ),
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Copy button (only for text messages)
              // Copy button: Only show if ALL selected messages are text messages
              if (_hasOnlyTextMessages())
                IconButton(
                  icon: Image.asset(
                    'assets/images/chat/copy.png',
                    width: SizeConfig.blockWidth * 4.5,
                    height: SizeConfig.blockWidth * 4.5,
                    fit: BoxFit.fill,
                  ),
                  onPressed: _copySelectedMessages,
                  padding: EdgeInsets.all(SizeConfig.blockWidth * 2),
                  constraints: BoxConstraints(),
                ),
              // Forward button
              IconButton(
                icon: Image.asset(
                  'assets/images/chat/forward.png',
                  width: SizeConfig.blockWidth * 4.5,
                  height: SizeConfig.blockWidth * 4.5,
                  fit: BoxFit.fill,
                ),
                onPressed: _forwardSelectedMessages,
                padding: EdgeInsets.all(SizeConfig.blockWidth * 2),
                constraints: BoxConstraints(),
              ),
            ],
          ),
        ],
      ),
    );
  }

  bool _hasOnlyTextMessages() {
    // Only return true if ALL selected messages are text messages
    // If any selected message is media (audio/image), return false
    if (_selectedMessageIds.isEmpty) return false;

    bool hasAtLeastOneText = false;

    for (var chatDate in chatView) {
      for (var message in chatDate.messages) {
        if (_selectedMessageIds.contains(message.id)) {
          // If any selected message is media (not text), return false
          if (message.type != 'text') {
            return false;
          }
          // Check if text message has valid content
          if (message.content != null && message.content!.isNotEmpty) {
            hasAtLeastOneText = true;
          } else {
            // Empty or null text message, don't allow copy
            return false;
          }
        }
      }
    }

    return hasAtLeastOneText; // All selected messages are text with content
  }

  void _copySelectedMessages() {
    // Only copy text messages, ignore media messages
    final textMessages = <String>[];
    for (var chatDate in chatView) {
      for (var message in chatDate.messages) {
        if (_selectedMessageIds.contains(message.id) &&
            message.type == 'text' &&
            message.content != null &&
            message.content!.isNotEmpty) {
          textMessages.add(message.content!);
        }
      }
    }

    if (textMessages.isNotEmpty) {
      final textToCopy = textMessages.join('\n');
      Clipboard.setData(ClipboardData(text: textToCopy));
      showCustomSnackBar(
        context: context,
        message: 'Message${textMessages.length > 1 ? 's' : ''} copied',
        backgroundColor: COLORS.semanticTwo,
      );
      setState(() {
        _isSelectionMode = false;
        _selectedMessageIds.clear();
      });
    } else {
      // This shouldn't happen if button visibility is correct, but add safeguard
      showCustomSnackBar(
        context: context,
        message: 'No text messages to copy',
        backgroundColor: COLORS.neutralDarkOne,
      );
    }
  }

  void _forwardSelectedMessages() {
    if (_selectedMessageIds.isEmpty) return;

    // Get selected messages
    final selectedMessages = <Message>[];
    for (var chatDate in chatView) {
      for (var message in chatDate.messages) {
        if (_selectedMessageIds.contains(message.id)) {
          selectedMessages.add(message);
        }
      }
    }

    if (selectedMessages.isEmpty) return;

    // Navigate to chat selection screen for forwarding
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => MultiBlocProvider(
          providers: [
            BlocProvider(
              create: (context) => FriendsBloc()
                ..add(
                    FetchFriendsListEvent(page: 1, pageSize: 10, keyWord: '')),
            ),
            BlocProvider(
              create: (context) => ChartBloc()..add(const ChartListEvent()),
            ),
          ],
          child: _ForwardChatSelectionScreen(
            messagesToForward: selectedMessages,
            onForwardComplete: () {
              setState(() {
                _isSelectionMode = false;
                _selectedMessageIds.clear();
              });
            },
          ),
        ),
      ),
    );
  }

  // Helper method to get current location
  Future<Position?> _getCurrentLocation() async {
    try {
      // Check if location services are enabled
      bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        _showErrorSnackBar("Location services are disabled");
        return null;
      }

      // Check location permissions
      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) {
          _showErrorSnackBar("Location permissions are denied");
          return null;
        }
      }

      if (permission == LocationPermission.deniedForever) {
        _showErrorSnackBar("Location permissions are permanently denied");
        return null;
      }

      // Get current position
      Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );
      return position;
    } catch (e) {
      debugPrint("Error getting location: $e");
      _showErrorSnackBar("Error getting location: $e");
      return null;
    }
  }

  // Helper method to share current location
  Future<void> _shareCurrentLocation() async {
    // Check network before sharing location
    final hasConnection = await NetworkHelper.hasInternetConnection();
    if (!hasConnection) {
      NetworkErrorHandler.showNetworkErrorSnackBar(
        context,
        'No internet connection. Cannot share location.',
      );
      return;
    }

    try {
      final position = await _getCurrentLocation();
      if (position != null) {
        final tempId = DateTime.now().millisecondsSinceEpoch.toString();

        final googleMapsUrl =
            'https://www.google.com/maps?q=${position.latitude},${position.longitude}';

        // Create location message as text with clickable link
        final locationMessage = Message(
          id: tempId,
          chatId: widget.chatId,
          senderId: Config.id,
          content: googleMapsUrl,
          type: 'text',
          deletedFor: [],
          messageMedia: [],
          messageState: MessageState.sending,
          isUploading: false,
          tempId: tempId,
        );

        // Add location message to chat
        _addMessageWithAnimation(locationMessage);

        // Send location as text message
        chartBloc.add(ChartSendMessageEvent(
          chatId: widget.chatId,
          content: googleMapsUrl,
          messageType: 'text',
          fileName: null,
          fileUrl: null,
          fileType: null,
          fileSize: null,
        ));

        FocusScope.of(context).unfocus();
      }
    } catch (e) {
      debugPrint("Error sharing location: $e");
      _showErrorSnackBar("Error sharing location: $e");
    }
  }

  // Helper method to get contacts
  Future<void> _getContacts() async {
    try {
      // Check contacts permission
      bool permission = await FlutterContacts.requestPermission();
      if (!permission) {
        _showErrorSnackBar("Contacts permission denied");
        return;
      }

      // Get contacts
      List<Contact> contacts = await FlutterContacts.getContacts(
        withProperties: true,
        withPhoto: false,
      );

      // Show contacts picker
      _showContactsPicker(contacts);
    } catch (e) {
      debugPrint("Error getting contacts: $e");
      _showErrorSnackBar("Error getting contacts: $e");
    }
  }

  // Helper method to show contacts picker
  void _showContactsPicker(List<Contact> contacts) {
    showModalBottomSheet(
      backgroundColor: COLORS.white,
      context: context,
      isScrollControlled: true,
      builder: (BuildContext context) {
        return Container(
          height: MediaQuery.of(context).size.height * 0.7,
          decoration: BoxDecoration(
            color: COLORS.white,
            borderRadius: BorderRadius.only(
              topLeft: Radius.circular(SizeConfig.blockWidth * 5),
              topRight: Radius.circular(SizeConfig.blockWidth * 5),
            ),
          ),
          child: Column(
            children: [
              // Header
              Padding(
                padding: EdgeInsets.symmetric(
                  horizontal: SizeConfig.blockWidth * 5,
                  vertical: SizeConfig.blockHeight,
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Select Contact'.tr(),
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
              const Divider(color: COLORS.neutralDarkTwo),

              // Contacts list
              Expanded(
                child: ListView.builder(
                  itemCount: contacts.length,
                  itemBuilder: (context, index) {
                    final contact = contacts[index];
                    return ListTile(
                      leading: CircleAvatar(
                        backgroundColor: COLORS.primary,
                        child: Text(
                          contact.displayName.isNotEmpty
                              ? contact.displayName[0].toUpperCase()
                              : '?',
                          style: TextStyle(
                            color: COLORS.white,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      title: Text(
                        contact.displayName.isNotEmpty
                            ? contact.displayName
                            : 'Unknown',
                        style: TextStyle(
                          color: COLORS.neutralDark,
                          fontSize: SizeConfig.blockWidth * 3.8,
                          fontWeight: FontWeight.w500,
                          fontFamily: "Poppins",
                        ),
                      ),
                      subtitle: contact.phones.isNotEmpty
                          ? Text(
                              contact.phones.first.number,
                              style: TextStyle(
                                color: COLORS.neutralDarkOne,
                                fontSize: SizeConfig.blockWidth * 3.3,
                                fontFamily: "Poppins",
                              ),
                            )
                          : null,
                      onTap: () {
                        _shareContact(contact);
                        Navigator.of(context).pop();
                      },
                    );
                  },
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  // Helper method to share contact
  void _shareContact(Contact contact) {
    try {
      final tempId = DateTime.now().millisecondsSinceEpoch.toString();
      final phoneNumber =
          contact.phones.isNotEmpty ? contact.phones.first.number : '';

      // Create contact message
      final contactMessage = Message(
        id: tempId,
        chatId: widget.chatId,
        senderId: Config.id,
        content:
            'Name: ${contact.displayName.isNotEmpty ? contact.displayName : 'Unknown'}\nPhone: ${phoneNumber}',
        type: 'text',
        deletedFor: [],
        messageMedia: [],
        messageState: MessageState.sending,
        isUploading: false,
        tempId: tempId,
      );

      // Add contact message to chat
      _addMessageWithAnimation(contactMessage);

      // Send contact as text message
      chartBloc.add(ChartSendMessageEvent(
        chatId: widget.chatId,
        content:
            'Name: ${contact.displayName.isNotEmpty ? contact.displayName : 'Unknown'}\nPhone: ${phoneNumber}',
        messageType: 'text',
        fileName: null,
        fileUrl: null,
        fileType: null,
        fileSize: null,
      ));

      FocusScope.of(context).unfocus();
    } catch (e) {
      debugPrint("Error sharing contact: $e");
      _showErrorSnackBar("Error sharing contact: $e");
    }
  }

  // Helper method to detect and format links in text
  Widget _formatMessageWithLinks(String text) {
    // Check if text contains phone number (contact format: "Name: ...\nPhone: ...")
    if (text.contains('Phone:')) {
      final lines = text.split('\n');
      String? nameLine;
      String? phoneLine;

      for (var line in lines) {
        if (line.trim().startsWith('Name:')) {
          nameLine = line.trim();
        } else if (line.trim().startsWith('Phone:')) {
          phoneLine = line.trim();
        }
      }

      if (phoneLine != null) {
        // Extract phone number after "Phone:"
        final phoneMatch = RegExp(r'Phone:\s*(.+)').firstMatch(phoneLine);
        if (phoneMatch != null) {
          final phoneNumber = phoneMatch.group(1)!.trim();
          return RichText(
            text: TextSpan(
              children: [
                if (nameLine != null) ...[
                  TextSpan(
                    text: nameLine.replaceFirst('Name:', '').trim(),
                    style: TextStyle(
                      color: COLORS.neutralDark,
                      fontSize: SizeConfig.blockWidth * 3.8,
                      fontWeight: FontWeight.w400,
                      fontFamily: "Poppins",
                    ),
                  ),
                  TextSpan(text: '\n'),
                ],
                TextSpan(
                  text: phoneNumber,
                  style: TextStyle(
                    color: COLORS.primary,
                    fontSize: SizeConfig.blockWidth * 3.5,
                    fontWeight: FontWeight.w500,
                    fontFamily: "Poppins",
                  ),
                  recognizer: TapGestureRecognizer()
                    ..onTap = () async {
                      // Clean phone number (remove spaces, dashes, etc.)
                      final cleanPhone =
                          phoneNumber.replaceAll(RegExp(r'[\s\-\(\)]'), '');
                      final uri = Uri.parse('tel:$cleanPhone');
                      if (await canLaunchUrl(uri)) {
                        await launchUrl(uri);
                      } else {
                        _showErrorSnackBar("Cannot make phone call");
                      }
                    },
                ),
              ],
            ),
          );
        }
      }
    }

    // Check if text contains URL (location links like Google Maps)
    final urlRegex = RegExp(
      r'https?://[^\s]+|www\.[^\s]+',
      caseSensitive: false,
    );
    final urlMatch = urlRegex.firstMatch(text);

    if (urlMatch != null) {
      final url = urlMatch.group(0)!;
      // Ensure URL has protocol
      final fullUrl = url.startsWith('http') ? url : 'https://$url';

      return RichText(
        text: TextSpan(
          children: [
            TextSpan(
              text: text,
              style: TextStyle(
                color: COLORS.primary,
                fontSize: SizeConfig.blockWidth * 3.5,
                fontWeight: FontWeight.w500,
                fontFamily: "Poppins",
              ),
              recognizer: TapGestureRecognizer()
                ..onTap = () async {
                  try {
                    final uri = Uri.parse(fullUrl);
                    if (await canLaunchUrl(uri)) {
                      await launchUrl(uri,
                          mode: LaunchMode.externalApplication);
                    } else {
                      _showErrorSnackBar("Cannot open map");
                    }
                  } catch (e) {
                    debugPrint("Error opening URL: $e");
                    _showErrorSnackBar("Invalid URL");
                  }
                },
            ),
          ],
        ),
      );
    }

    // Regular text message
    return Text(
      text,
      style: TextStyle(
        color: COLORS.neutralDark,
        fontSize: SizeConfig.blockWidth * 3.8,
        fontWeight: FontWeight.w400,
        fontFamily: "Poppins",
      ),
    );
  }

  void _showPicker(BuildContext context, Function(File) onImageSelected) {
    showModalBottomSheet(
      backgroundColor: COLORS.white,
      context: context,
      builder: (BuildContext context) {
        return Container(
          decoration: BoxDecoration(
            color: COLORS.white,
            borderRadius: BorderRadius.only(
              topLeft: Radius.circular(SizeConfig.blockWidth * 5),
              topRight: Radius.circular(SizeConfig.blockWidth * 5),
            ),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              SizedBox(height: SizeConfig.blockHeight),
              Padding(
                padding: EdgeInsets.symmetric(
                  horizontal: SizeConfig.blockWidth * 4.5,
                  vertical: SizeConfig.blockHeight * 0.5,
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Select Media'.tr(),
                      style: TextStyle(
                        color: COLORS.primaryTwo,
                        fontSize: SizeConfig.blockWidth * 4.25,
                        fontWeight: FontWeight.w400,
                        fontFamily: "Poppins",
                      ),
                    ),
                    IconButton(
                      icon: Icon(
                        Icons.close,
                        color: COLORS.neutralDark,
                        size: SizeConfig.blockWidth * 4.5,
                      ),
                      onPressed: () => Navigator.of(context).pop(),
                    ),
                  ],
                ),
              ),
              const Divider(color: COLORS.neutralDarkTwo),
              SizedBox(height: SizeConfig.blockHeight * 3),
              Padding(
                padding:
                    EdgeInsets.symmetric(horizontal: SizeConfig.blockWidth * 4),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    // Camera
                    InkWell(
                      onTap: () async {
                        final XFile? photo =
                            await _picker.pickImage(source: ImageSource.camera);
                        if (photo != null) onImageSelected(File(photo.path));
                        Navigator.of(context).pop();
                      },
                      child: Column(
                        children: [
                          Container(
                            width: SizeConfig.blockWidth * 18,
                            height: SizeConfig.blockWidth * 18,
                            decoration: BoxDecoration(
                              color: COLORS.primaryOne.withOpacity(0.3),
                              shape: BoxShape.circle,
                            ),
                            alignment: Alignment.center,
                            child: Image.asset(
                              'assets/images/profile/camera_icon.png',
                              width: SizeConfig.blockWidth * 6.0,
                              height: SizeConfig.blockWidth * 6.0,
                              color: COLORS.primary,
                            ),
                          ),
                          SizedBox(height: SizeConfig.blockHeight * 1.2),
                          Text(
                            'Camera'.tr(),
                            style: TextStyle(
                              color: COLORS.neutralDark,
                              fontSize: SizeConfig.blockWidth * 3.25,
                              fontWeight: FontWeight.w400,
                              fontFamily: "Poppins",
                            ),
                          ),
                        ],
                      ),
                    ),

                    // Gallery
                    InkWell(
                      onTap: () async {
                        final XFile? image = await _picker.pickImage(
                            source: ImageSource.gallery);
                        if (image != null) onImageSelected(File(image.path));
                        Navigator.of(context).pop();
                      },
                      child: Column(
                        children: [
                          Container(
                            width: SizeConfig.blockWidth * 18,
                            height: SizeConfig.blockWidth * 18,
                            decoration: BoxDecoration(
                              color: COLORS.accent.withOpacity(0.1),
                              shape: BoxShape.circle,
                            ),
                            alignment: Alignment.center,
                            child: Image.asset(
                              'assets/images/profile/gallery_icon.png',
                              width: SizeConfig.blockWidth * 6.0,
                              height: SizeConfig.blockWidth * 6.0,
                              color: COLORS.accent,
                            ),
                          ),
                          SizedBox(height: SizeConfig.blockHeight * 1.2),
                          Text(
                            'Gallery'.tr(),
                            style: TextStyle(
                              color: COLORS.neutralDark,
                              fontSize: SizeConfig.blockWidth * 3.25,
                              fontWeight: FontWeight.w400,
                              fontFamily: "Poppins",
                            ),
                          ),
                        ],
                      ),
                    ),

                    // Location
                    InkWell(
                      onTap: () async {
                        Navigator.of(context).pop();
                        await _shareCurrentLocation();
                      },
                      child: Column(
                        children: [
                          Container(
                            width: SizeConfig.blockWidth * 18,
                            height: SizeConfig.blockWidth * 18,
                            decoration: BoxDecoration(
                              color: COLORS.semanticTwo.withOpacity(0.1),
                              shape: BoxShape.circle,
                            ),
                            alignment: Alignment.center,
                            child: Image.asset(
                              'assets/images/chat/map.png',
                              width: SizeConfig.blockWidth * 6.0,
                              height: SizeConfig.blockWidth * 6.0,
                            ),
                          ),
                          SizedBox(height: SizeConfig.blockHeight * 1.2),
                          Text(
                            'Location'.tr(),
                            style: TextStyle(
                              color: COLORS.neutralDark,
                              fontSize: SizeConfig.blockWidth * 3.25,
                              fontWeight: FontWeight.w400,
                              fontFamily: "Poppins",
                            ),
                          ),
                        ],
                      ),
                    ),

                    // Contact
                    InkWell(
                      onTap: () async {
                        Navigator.of(context).pop();
                        await _getContacts();
                      },
                      child: Column(
                        children: [
                          Container(
                            width: SizeConfig.blockWidth * 18,
                            height: SizeConfig.blockWidth * 18,
                            decoration: BoxDecoration(
                              color: COLORS.semanticOne.withOpacity(0.1),
                              shape: BoxShape.circle,
                            ),
                            alignment: Alignment.center,
                            child: Image.asset(
                              'assets/images/chat/contact.png',
                              width: SizeConfig.blockWidth * 6.0,
                              height: SizeConfig.blockWidth * 6.0,
                            ),
                          ),
                          SizedBox(height: SizeConfig.blockHeight * 1.2),
                          Text(
                            'Contact'.tr(),
                            style: TextStyle(
                              color: COLORS.neutralDark,
                              fontSize: SizeConfig.blockWidth * 3.25,
                              fontWeight: FontWeight.w400,
                              fontFamily: "Poppins",
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              SizedBox(height: SizeConfig.blockHeight * 8),
            ],
          ),
        );
      },
    );
  }
}

// Forward Chat Selection Screen
class _ForwardChatSelectionScreen extends StatefulWidget {
  final List<Message> messagesToForward;
  final VoidCallback onForwardComplete;

  const _ForwardChatSelectionScreen({
    required this.messagesToForward,
    required this.onForwardComplete,
  });

  @override
  State<_ForwardChatSelectionScreen> createState() =>
      _ForwardChatSelectionScreenState();
}

class _ForwardChatSelectionScreenState
    extends State<_ForwardChatSelectionScreen> {
  late FriendsBloc friendsBloc;
  late ChartBloc chartBloc;
  List<Friend> _friends = [];
  List<ChatList> _chats = [];
  List<Friend> _filteredFriends = [];
  List<ChatList> _filteredChats = [];
  Set<String> _selectedChatIds = {};
  Map<String, String> _friendIdToChatId =
      {}; // Map userId to chatId for existing chats
  final TextEditingController _searchController = TextEditingController();
  Timer? _debounce;
  String _searchKeyword = '';

  @override
  void initState() {
    super.initState();
    friendsBloc = BlocProvider.of<FriendsBloc>(context);
    chartBloc = BlocProvider.of<ChartBloc>(context);
    _searchController.addListener(_onSearchChanged);
  }

  @override
  void dispose() {
    _searchController.dispose();
    _debounce?.cancel();
    super.dispose();
  }

  void _onSearchChanged() {
    if (_debounce?.isActive ?? false) _debounce?.cancel();
    _debounce = Timer(const Duration(milliseconds: 300), () {
      setState(() {
        _searchKeyword = _searchController.text.toLowerCase().trim();
        _filterResults();
      });
    });
  }

  void _filterResults() {
    if (_searchKeyword.isEmpty) {
      _filteredFriends = _friends;
      _filteredChats = _chats.where((chat) => chat.isGroup == true).toList();
    } else {
      _filteredFriends = _friends.where((friend) {
        final name = friend.friends.name.toLowerCase();
        return name.contains(_searchKeyword);
      }).toList();

      _filteredChats = _chats.where((chat) {
        if (chat.isGroup != true) return false;
        final name = (chat.name ?? '').toLowerCase();
        return name.contains(_searchKeyword);
      }).toList();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: COLORS.white,
      appBar: AppBar(
        title: Text(
          'Forward to...',
          style: TextStyle(
            color: COLORS.white,
            fontSize: SizeConfig.blockWidth * 4.5,
            fontWeight: FontWeight.w500,
            fontFamily: "Poppins",
          ),
        ),
        backgroundColor: COLORS.primary,
        iconTheme: IconThemeData(color: COLORS.white),
        actions: [
          if (_selectedChatIds.isNotEmpty)
            Padding(
              padding:
                  EdgeInsets.symmetric(horizontal: SizeConfig.blockWidth * 2),
              child: Center(
                child: TextButton(
                  onPressed: _forwardMessages,
                  child: Text(
                    'Forward',
                    style: TextStyle(
                      color: COLORS.white,
                      fontSize: SizeConfig.blockWidth * 4,
                      fontWeight: FontWeight.w500,
                      fontFamily: "Poppins",
                    ),
                  ),
                ),
              ),
            ),
        ],
      ),
      body: Column(
        children: [
          Padding(
            padding: EdgeInsets.only(
                left: SizeConfig.blockWidth * 4.5,
                top: SizeConfig.blockHeight * 1,
                right: SizeConfig.blockWidth * 4.5,
                bottom: SizeConfig.blockHeight * 0.5),
            child: TextField(
              controller: _searchController,
              style: TextStyle(
                color: COLORS.neutralDarkOne,
                fontSize: SizeConfig.blockWidth * 3.25,
                fontWeight: FontWeight.w400,
                fontFamily: "Poppins",
              ),
              cursorColor: COLORS.black,
              decoration: InputDecoration(
                fillColor: COLORS.neutralDarkTwo.withOpacity(0.6),
                focusColor: COLORS.neutralDarkTwo.withOpacity(0.6),
                filled: true,
                hintText: 'Search by name'.tr(),
                hintStyle: TextStyle(
                  color: COLORS.neutralDarkOne,
                  fontSize: SizeConfig.blockWidth * 3.25,
                  fontWeight: FontWeight.w400,
                  fontFamily: "Poppins",
                ),
                prefixIcon: Padding(
                  padding: EdgeInsets.all(SizeConfig.blockWidth * 4),
                  child: Image.asset(
                    'assets/images/home/search.png',
                    width: SizeConfig.blockWidth * 3.5,
                    height: SizeConfig.blockWidth * 3.5,
                    fit: BoxFit.cover,
                  ),
                ),
                border: OutlineInputBorder(
                  borderRadius:
                      BorderRadius.circular(SizeConfig.blockWidth * 3.25),
                  borderSide: BorderSide(
                      color: COLORS.neutralDarkTwo.withOpacity(0.6),
                      width: SizeConfig.blockWidth * 0.1),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius:
                      BorderRadius.circular(SizeConfig.blockWidth * 3.25),
                  borderSide: BorderSide(
                      color: COLORS.neutralDarkTwo.withOpacity(0.6),
                      width: SizeConfig.blockWidth * 0.1),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius:
                      BorderRadius.circular(SizeConfig.blockWidth * 3.25),
                  borderSide: BorderSide(
                      color: COLORS.neutralDarkTwo.withOpacity(0.6),
                      width: SizeConfig.blockWidth * 0.1),
                ),
              ),
              onChanged: (value) {
                setState(() {}); // Trigger rebuild to show/hide clear button
              },
            ),
          ),
          const Divider(
            color: COLORS.neutralDarkTwo,
          ),
          Expanded(
            child: MultiBlocListener(
              listeners: [
                BlocListener<FriendsBloc, FriendsState>(
                  listener: (context, state) {
                    if (state is FriendsListSuccess) {
                      setState(() {
                        _friends = state.friendsSearchList;
                        _filterResults();
                      });
                    }
                  },
                ),
                BlocListener<ChartBloc, ChartState>(
                  listener: (context, state) {
                    if (state is ChartListSuccess) {
                      setState(() {
                        _chats = state.chatList;
                        // Build map of friend userId to chatId for existing individual chats
                        _friendIdToChatId.clear();
                        for (var chat in _chats) {
                          if (chat.isGroup == false &&
                              chat.chatId != null &&
                              chat.chatId!.isNotEmpty) {
                            // For individual chats, we need to match by checking if friend's userId matches
                            // This will be used when forwarding to check if chat already exists
                          }
                        }
                        _filterResults();
                      });
                    } else if (state is StartMessageChatFailed) {
                      // Error handled in callback
                    }
                  },
                ),
              ],
              child: _filteredFriends.isEmpty &&
                      _filteredChats.isEmpty &&
                      _searchKeyword.isNotEmpty
                  ? Center(
                      child: Padding(
                        padding: EdgeInsets.all(SizeConfig.blockWidth * 10),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.search_off,
                              size: SizeConfig.blockWidth * 15,
                              color: COLORS.neutralDarkOne,
                            ),
                            SizedBox(height: SizeConfig.blockHeight * 2),
                            Text(
                              'No results found',
                              style: TextStyle(
                                color: COLORS.neutralDarkOne,
                                fontSize: SizeConfig.blockWidth * 4,
                                fontWeight: FontWeight.w400,
                                fontFamily: "Poppins",
                              ),
                            ),
                          ],
                        ),
                      ),
                    )
                  : ListView(
                      padding: EdgeInsets.symmetric(
                        horizontal: SizeConfig.blockWidth * 4.5,
                        vertical: SizeConfig.blockHeight * 1,
                      ),
                      children: [
                        // Friends section
                        if (_filteredFriends.isNotEmpty) ...[
                          if (_searchKeyword.isEmpty)
                            Padding(
                              padding: EdgeInsets.only(
                                bottom: SizeConfig.blockHeight * 1,
                                top: SizeConfig.blockHeight * 0.5,
                              ),
                              child: Text(
                                'Chats'.tr(),
                                style: TextStyle(
                                  color: COLORS.neutralDarkOne,
                                  fontSize: SizeConfig.blockWidth * 3.5,
                                  fontWeight: FontWeight.w500,
                                  fontFamily: "Poppins",
                                ),
                              ),
                            ),
                          ..._filteredFriends.map((friend) {
                            final friendData = friend.friends;
                            if (friendData.id.isEmpty)
                              return const SizedBox.shrink();
                            final userId =
                                friendData.id; // This is userId, not chatId
                            final isSelected =
                                _selectedChatIds.contains(userId);
                            return InkWell(
                              onTap: () {
                                setState(() {
                                  if (isSelected) {
                                    _selectedChatIds.remove(userId);
                                  } else {
                                    _selectedChatIds.add(userId);
                                  }
                                });
                              },
                              splashColor: COLORS.primary.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(
                                  SizeConfig.blockWidth * 3.5),
                              child: Container(
                                padding: EdgeInsets.symmetric(
                                  horizontal: SizeConfig.blockWidth * 4,
                                  vertical: SizeConfig.blockHeight * 1.5,
                                ),
                                margin: EdgeInsets.only(
                                    bottom: SizeConfig.blockHeight * 1),
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(
                                      SizeConfig.blockWidth * 3.5),
                                  color: COLORS.primaryOne.withOpacity(0.1),
                                ),
                                child: Row(
                                  children: [
                                    Container(
                                      width: SizeConfig.blockWidth * 14,
                                      height: SizeConfig.blockWidth * 14,
                                      decoration: BoxDecoration(
                                        image: friendData.profilePic.isNotEmpty
                                            ? DecorationImage(
                                                image: NetworkImage(
                                                    friendData.profilePic),
                                                fit: BoxFit.cover,
                                              )
                                            : null,
                                        color: friendData.profilePic.isEmpty
                                            ? COLORS.neutralDarkTwo
                                            : null,
                                        borderRadius: BorderRadius.circular(
                                            SizeConfig.blockWidth * 7),
                                      ),
                                      child: friendData.profilePic.isEmpty
                                          ? Icon(
                                              Icons.person,
                                              color: COLORS.neutralDarkOne,
                                              size: SizeConfig.blockWidth * 7,
                                            )
                                          : null,
                                    ),
                                    SizedBox(width: SizeConfig.blockWidth * 3),
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            friendData.name,
                                            style: TextStyle(
                                              color: COLORS.neutralDark,
                                              fontSize:
                                                  SizeConfig.blockWidth * 3.8,
                                              fontWeight: FontWeight.w400,
                                              fontFamily: "Poppins",
                                            ),
                                            maxLines: 1,
                                            overflow: TextOverflow.ellipsis,
                                          ),
                                          if (friendData
                                              .professionType.isNotEmpty) ...[
                                            SizedBox(
                                                height: SizeConfig.blockHeight *
                                                    0.3),
                                            Text(
                                              friendData.professionType,
                                              style: TextStyle(
                                                color: COLORS.neutralDarkOne,
                                                fontSize:
                                                    SizeConfig.blockWidth * 3.2,
                                                fontWeight: FontWeight.w400,
                                                fontFamily: "Poppins",
                                              ),
                                              maxLines: 1,
                                              overflow: TextOverflow.ellipsis,
                                            ),
                                          ],
                                        ],
                                      ),
                                    ),
                                    Checkbox(
                                      value: isSelected,
                                      onChanged: (value) {
                                        setState(() {
                                          if (value == true) {
                                            _selectedChatIds.add(userId);
                                          } else {
                                            _selectedChatIds.remove(userId);
                                          }
                                        });
                                      },
                                      activeColor: COLORS.primary,
                                      side: BorderSide(
                                        color: COLORS.neutralDarkOne,
                                        width: SizeConfig.blockWidth * 0.4,
                                        style: BorderStyle.solid,
                                        strokeAlign:
                                            BorderSide.strokeAlignCenter,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            );
                          }),
                        ],
                        // Groups section
                        if (_filteredChats.isNotEmpty) ...[
                          if (_searchKeyword.isEmpty)
                            Padding(
                              padding: EdgeInsets.only(
                                bottom: SizeConfig.blockHeight * 1,
                                top: SizeConfig.blockHeight * 1,
                              ),
                              child: Text(
                                'Groups'.tr(),
                                style: TextStyle(
                                  color: COLORS.neutralDarkOne,
                                  fontSize: SizeConfig.blockWidth * 3.5,
                                  fontWeight: FontWeight.w500,
                                  fontFamily: "Poppins",
                                ),
                              ),
                            ),
                          ..._filteredChats.map((chat) {
                            final chatId = chat.chatId ?? '';
                            if (chatId.isEmpty) return const SizedBox.shrink();
                            final isSelected =
                                _selectedChatIds.contains(chatId);
                            return InkWell(
                              onTap: () {
                                setState(() {
                                  if (isSelected) {
                                    _selectedChatIds.remove(chatId);
                                  } else {
                                    _selectedChatIds.add(chatId);
                                  }
                                });
                              },
                              splashColor: COLORS.primary.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(
                                  SizeConfig.blockWidth * 3.5),
                              child: Container(
                                padding: EdgeInsets.symmetric(
                                  horizontal: SizeConfig.blockWidth * 4,
                                  vertical: SizeConfig.blockHeight * 1.5,
                                ),
                                margin: EdgeInsets.only(
                                    bottom: SizeConfig.blockHeight * 1),
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(
                                      SizeConfig.blockWidth * 3.5),
                                  color: COLORS.primaryOne.withOpacity(0.1),
                                ),
                                child: Row(
                                  children: [
                                    Container(
                                      width: SizeConfig.blockWidth * 14,
                                      height: SizeConfig.blockWidth * 14,
                                      decoration: BoxDecoration(
                                        image: (chat.picture?.isNotEmpty ??
                                                false)
                                            ? DecorationImage(
                                                image:
                                                    NetworkImage(chat.picture!),
                                                fit: BoxFit.cover,
                                              )
                                            : null,
                                        color: (chat.picture?.isEmpty ?? true)
                                            ? COLORS.neutralDarkTwo
                                            : null,
                                        borderRadius: BorderRadius.circular(
                                            SizeConfig.blockWidth * 7),
                                      ),
                                      child: (chat.picture?.isEmpty ?? true)
                                          ? Icon(
                                              Icons.group,
                                              color: COLORS.neutralDarkOne,
                                              size: SizeConfig.blockWidth * 7,
                                            )
                                          : null,
                                    ),
                                    SizedBox(width: SizeConfig.blockWidth * 3),
                                    Expanded(
                                      child: Text(
                                        chat.name ?? 'Group',
                                        style: TextStyle(
                                          color: COLORS.neutralDark,
                                          fontSize: SizeConfig.blockWidth * 3.8,
                                          fontWeight: FontWeight.w400,
                                          fontFamily: "Poppins",
                                        ),
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                    ),
                                    Checkbox(
                                      value: isSelected,
                                      onChanged: (value) {
                                        setState(() {
                                          if (value == true) {
                                            _selectedChatIds.add(chatId);
                                          } else {
                                            _selectedChatIds.remove(chatId);
                                          }
                                        });
                                      },
                                      activeColor: COLORS.primary,
                                      side: BorderSide(
                                        color: COLORS.neutralDarkOne,
                                        width: SizeConfig.blockWidth * 0.4,
                                        style: BorderStyle.solid,
                                        strokeAlign:
                                            BorderSide.strokeAlignCenter,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            );
                          }),
                        ],
                      ],
                    ),
            ),
          ),
        ],
      ),
    );
  }

  void _forwardMessages() {
    if (_selectedChatIds.isEmpty) return;

    // Separate friends (userId) from groups/existing chats (chatId)
    final friendUserIds = <String>[];
    final existingChatIds = <String>[];

    // Get all existing chatIds from _chats
    final existingChatIdsSet = _chats
        .where((chat) => chat.chatId != null && chat.chatId!.isNotEmpty)
        .map((chat) => chat.chatId!)
        .toSet();

    for (var selectedId in _selectedChatIds) {
      if (existingChatIdsSet.contains(selectedId)) {
        // It's an existing chat (group or individual)
        existingChatIds.add(selectedId);
      } else {
        // It's a friend userId, need to create chat first
        friendUserIds.add(selectedId);
      }
    }

    // Forward to existing chats immediately
    for (var chatId in existingChatIds) {
      _forwardToChatId(chatId);
    }

    // For friends, create chat first, then forward (handled in listener)
    if (friendUserIds.isNotEmpty) {
      // Create chats for friends one by one
      _createChatAndForward(friendUserIds, 0);
    } else {
      // All were existing chats, show success message
      showCustomSnackBar(
        context: context,
        message:
            'Message${widget.messagesToForward.length > 1 ? 's' : ''} forwarded',
        backgroundColor: COLORS.semanticTwo,
      );
      Navigator.pop(context);
      widget.onForwardComplete();
    }
  }

  void _createChatAndForward(List<String> userIds, int index) {
    if (index >= userIds.length) {
      // All chats created, show success message
      showCustomSnackBar(
        context: context,
        message:
            'Message${widget.messagesToForward.length > 1 ? 's' : ''} forwarded',
        backgroundColor: COLORS.semanticTwo,
      );
      Navigator.pop(context);
      widget.onForwardComplete();
      return;
    }

    final userId = userIds[index];
    // Create chat for this friend
    chartBloc.add(StartMessageEvent(
      chatId: userId, // This is actually userId for StartMessageEvent
      onSuccess: (chatId) {
        // Forward messages to the created chat
        _forwardToChatId(chatId);
        // Create next chat
        _createChatAndForward(userIds, index + 1);
      },
      onError: (message) {
        showCustomSnackBar(
          context: context,
          message: 'Failed to create chat: $message',
          backgroundColor: COLORS.neutralDarkOne,
        );
        // Continue with next friend even if this one failed
        _createChatAndForward(userIds, index + 1);
      },
    ));
  }

  void _forwardToChatId(String chatId) {
    // Forward all messages to the given chatId
    for (var message in widget.messagesToForward) {
      if (message.type == 'text') {
        chartBloc.add(ChartSendMessageEvent(
          chatId: chatId,
          content: message.content,
          messageType: 'text',
          fileName: null,
          fileUrl: null,
          fileType: null,
          fileSize: null,
        ));
      } else if (message.type == 'media' && message.messageMedia.isNotEmpty) {
        final media = message.messageMedia[0];
        chartBloc.add(ChartSendMessageEvent(
          chatId: chatId,
          content: 'media',
          messageType: 'media',
          fileName: media.fileName,
          fileUrl: media.fileUrl,
          fileType: media.fileType,
          fileSize: media.fileSize,
        ));
      }
    }
  }
}
