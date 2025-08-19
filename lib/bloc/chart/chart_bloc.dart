import 'dart:convert';
import 'dart:io';
import 'dart:ui';

import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:meta/meta.dart';
import 'package:works_app/dao/friends_dao.dart';
import 'package:works_app/models/chat/charts_list_modal.dart';
import 'package:works_app/models/chat/chat_view_modal.dart';

import '../../components/global_handle.dart';
import '../../helper/custom_log.dart';
import '../../models/chat/blocked_chat_list.dart';
import '../../models/chat/chart_search_list.dart';
import '../../models/chat/chat_view_pro_modal.dart';
import '../../models/chat/invite_friend_modal.dart';

part 'chart_event.dart';
part 'chart_state.dart';

class ChartBloc extends Bloc<ChartEvent, ChartState> {
  late FriendsDao friendsDao;

  ChartBloc() : super(ChartInitial()) {
    friendsDao = FriendsDao();
    on<ChartListEvent>((event, emit) async {
      await mapCharListEvent(event, emit);
    });
    on<ChartGroupCreateEvent>((event, emit) async {
      await mapCreateChartGroupEvent(event, emit);
    });
    on<InviteMemberChartEvent>((event, emit) async {
      await mapInviteMemberListEvent(event, emit);
    });
    on<FetchChartViewEvent>((event, emit) async {
      await mapChatViewEvent(event, emit);
    });
    on<ChartSendMessageEvent>((event, emit) async {
      await mapChartSendMessageEvent(event, emit);
    });
    on<UploadFileEvent>((event, emit) async {
      await mapUploadFilesEvent(event, emit);
    });
    on<EditGroupChatProfileEvent>((event, emit) async {
      await mapGroupProfileEdit(event, emit);
    });
    on<FetchChartViewProfileEvent>((event, emit) async {
      await mapChatViewProfileEvent(event, emit);
    });
    on<SendInviteMemberEvent>((event, emit) async {
      await mapSendInviteMemberEvent(event, emit);
    });
    on<SendRemoveMemberEvent>((event, emit) async {
      await mapSendRemoveMemberEvent(event, emit);
    });
    on<ClearChatEvent>((event, emit) async {
      await mapClearChatEvent(event, emit);
    });
    on<ArchiveChatEvent>((event, emit) async {
      await mapArchiveChatEvent(event, emit);
    });

    on<ArchivedChartListEvent>((event, emit) async {
      await mapArchivedCharListEvent(event, emit);
    });

    on<AcceptChatEvent>((event, emit) async {
      await mapAcceptInviteChatEvent(event, emit);
    });

    on<RejectGroupChatEvent>((event, emit) async {
      await mapRejectInviteChatEvent(event, emit);
    });

    on<StartMessageEvent>((event, emit) async {
      await mapStartMessageEvent(event, emit);
    });

    on<DeleteGroupEvent>((event, emit) async {
      await mapDeleteGroupChatEvent(event, emit);
    });

    on<LeaveGroupChatEvent>((event, emit) async {
      await mapLeaveChatEvent(event, emit);
    });

    on<CancelInviteChatEvent>((event, emit) async {
      await mapCancelGroupInviteChatEvent(event, emit);
    });

    on<MarkAsAdminEvent>((event, emit) async {
      await mapMarkAsAdminEvent(event, emit);
    });

    on<UnArchiveChatEvent>((event, emit) async {
      await mapUnArchiveChatsEvent(event, emit);
    });

    on<BlocChartGroupEvent>((event, emit) async {
      await mapBlocChatGroupEvent(event, emit);
    });

    on<UnBlocChartGroupEvent>((event, emit) async {
      await mapChatUnBlockedGroupEvent(event, emit);
    });

    on<BlockedChatList>((event, emit) async {
      await mapChatBlockedListEvent(event, emit);
    });

    on<ReportChartGroupEvent>((event, emit) async {
      await mapChatReportGroupEvent(event, emit);
    });

    on<FetchChartSearchListEvent>((event, emit) async {
      await mapChartSearchListEvent(event, emit);
    });

    on<DeleteChartEvent>((event, emit) async {
      await mapDeleteChatEvent(event, emit);
    });

    on<RequestedChartListEvent>((event, emit) async {
      await mapRequestedCharListEvent(event, emit);
    });
    on<ApproveChartRequestEvent>((event, emit) async {
      await mapApproveChatRequestEvent(event, emit);
    });
    on<RejectChartRequestEvent>((event, emit) async {
      await mapRejectChatRequestEvent(event, emit);
    });
  }

  Future<void> mapCharListEvent(
      ChartListEvent event, Emitter<ChartState> emit) async {
    try {
      emit(const ChartListLoading());

      final response = await friendsDao.fetchChartList();
      customLog("Response Body: ${response.body}");
      final jsonDecoded = jsonDecode(response.body) as Map<String, dynamic>;

      if (response.statusCode == 200 && jsonDecoded['status'] == true) {
        final data = jsonDecoded['data'];

        if (data is! List) {
          customLog("Data is not a list: $data");
          emit(ChartListFailed(message: "Invalid data format"));
          return;
        }

        final chatList = <ChatList>[];
        for (final item in data) {
          try {
            chatList.add(ChatList.fromJson(item as Map<String, dynamic>));
          } catch (e) {
            customLog("Error parsing chatList item: $e");
          }
        }

        customLog("Chat List Length: ${chatList.length}");
        // ✅ treat empty as success with []
        emit(ChartListSuccess(chatList: chatList));
      } else {
        emit(ChartListFailed(message: jsonDecoded["message"] ?? 'Error'));
      }
    } catch (e) {
      customLog("Error: $e");
      emit( ChartListFailed(message: "Something went wrong"));
    }
  }


  Future<void> mapRequestedCharListEvent(
      RequestedChartListEvent event, Emitter<ChartState> emit) async {
    try {
      emit(const RequestedChartListLoading());
      var response = await friendsDao.fetchRequestChartList();

      customLog("Response Body: ${response.body}");

      Map<String, dynamic> jsonDecoded = jsonDecode(response.body);

      if (response.statusCode == 200 && jsonDecoded['status'] == true) {
        List<ChatList> chatList = [];
        customLog("Processing Data...");

        if (jsonDecoded["data"] is List) {
          for (var i in jsonDecoded["data"]) {
            try {
              chatList.add(ChatList.fromJson(i));
            } catch (e) {
              customLog("Error parsing chatList item: $e");
            }
          }
        } else {
          customLog("Data is not a list: ${jsonDecoded["data"]}");
          emit(RequestedChartListFailed(message: "Invalid data format"));
          return;
        }

        customLog("Chat List Length: ${chatList.length}");
        if (chatList.isNotEmpty) {
          emit(RequestedChartListSuccess(chatList: chatList));
        } else {
          emit(RequestedChartListFailed(message: "No chats found"));
        }
      } else {
        emit(RequestedChartListFailed(message: jsonDecoded["message"] ?? 'Error'));
      }
    } catch (error) {
      customLog("Error: $error");
      emit(RequestedChartListFailed(message: "Something went wrong"));
    }
  }

  Future<void> mapCreateChartGroupEvent(
      ChartGroupCreateEvent event, Emitter<ChartState> emit) async {
    try {
      emit(const ChartListLoading());
      var response = await friendsDao.createGroupChat(
          picture: event.picture,
          name: event.name,
          invitedUsers: event.invitedUsers,
          type: event.type,
          description: event.description);
      Map<String, dynamic> jsonDecoded = jsonDecode(response.body);
      if (response.statusCode == 200 && jsonDecoded['status'] == true) {
        String message = jsonDecoded["message"];
        emit(ChartGroupCreateSuccess(message: message));
      } else {
        String message = jsonDecoded["message"];
        customLog("The failure reason: $message");
        emit(ChartGroupCreateFailed(message: message));
      }
    } catch (error) {
      customLog("The error is : $error");
      emit(ChartGroupCreateFailed(message: "Something Went wrong"));
    }
  }

  Future<void> mapInviteMemberListEvent(
      InviteMemberChartEvent event, Emitter<ChartState> emit) async {
    try {
      if (event.page == 1) {
        emit(const InviteMemberLoading());
      }

      var response = await friendsDao.fetchInviteMemberList(
          page: event.page,
          pageSize: event.pageSize,
          keyWord: event.keyWord,
          groupId: event.groupId);

      Map<String, dynamic> jsonDecoded = jsonDecode(response.body);

      if (response.statusCode == 200 && jsonDecoded['status'] == true) {
        int maxPageNumber = jsonDecoded["data"]["pagination"]["totalPages"];
        int maxPageSize = jsonDecoded["data"]["pagination"]["pageSize"];

        List<InviteFriend> friendsList = [];
        for (var i in jsonDecoded["data"]["friends"]) {
          friendsList.add(InviteFriend.fromJson(i));
        }

        if (event.page > 1) {
          final currentState = state;
          if (currentState is InviteMemberSuccess) {
            friendsList = List.from(currentState.inviteFriend)
              ..addAll(friendsList);
          }
        }

        emit(InviteMemberSuccess(
          inviteFriend: friendsList,
          maxPageNumber: maxPageNumber,
          maxPageSize: maxPageSize,
        ));
      } else {
        emit(InviteMemberFailed(message: jsonDecoded["message"] ?? 'Error'));
        customLog(jsonDecoded["message"]);
      }
    } catch (error) {
      emit(InviteMemberFailed(message: "Something went wrong"));
      customLog('jsonDecoded["message"]');
    }
  }

  Future<void> mapChatViewEvent(
      FetchChartViewEvent event, Emitter<ChartState> emit) async {
    try {
      if (event.page == 1) {
        emit(const ChatViewLoading());
      }

      var response = await friendsDao.fetchChatView(
          page: event.page, pageSize: event.pageSize, chatId: event.chatId);

      Map<String, dynamic> jsonDecoded = jsonDecode(response.body);

      if (response.statusCode == 200 && jsonDecoded['status'] == true) {
        int maxPageNumber = jsonDecoded["data"]["pagination"]["totalPages"];
        int maxPageSize = jsonDecoded["data"]["pagination"]["pageSize"];
        ChatViewGroupInfo chatViewGroupInfo;
        chatViewGroupInfo =
            ChatViewGroupInfo.fromJson(jsonDecoded["data"]["chatData"]);

        List<ChatView> chatViewList = [];
        for (var i in jsonDecoded["data"]["messages"]) {
          chatViewList.add(ChatView.fromJson(i));
        }

        if (event.page > 1) {
          final currentState = state;
          if (currentState is ChatViewSuccess) {
            chatViewList = List.from(currentState.chatView)
              ..addAll(chatViewList);
          }
        }

        emit(ChatViewSuccess(
            chatView: chatViewList,
            maxPageNumber: maxPageNumber,
            maxPageSize: maxPageSize,
            chatViewGroupInfo: chatViewGroupInfo));
      } else {
        emit(ChatViewFailed(message: jsonDecoded["message"] ?? 'Error'));
        customLog(jsonDecoded["message"]);
      }
    } catch (error) {
      emit(ChatViewFailed(message: "Something went wrong"));
      customLog('jsonDecoded["message"]');
    }
  }

  Future<void> mapChartSendMessageEvent(
      ChartSendMessageEvent event, Emitter<ChartState> emit) async {
    try {
      emit(const ChartSendMessageLoading());
      var response = await friendsDao.sendMessageChat(
          chatId: event.chatId,
          content: event.content,
          messageType: event.messageType,
          fileName: event.fileName,
          fileUrl: event.fileUrl,
          fileType: event.fileType,
          fileSize: event.fileSize);
      Map<String, dynamic> jsonDecoded = jsonDecode(response.body);
      if (response.statusCode == 200 && jsonDecoded['status'] == true) {
        String message = jsonDecoded["message"];
        emit(ChartSendMessageSuccess(message: message));
      } else {
        String message = jsonDecoded["message"];
        customLog("The failure reason: $message");
        emit(ChartSendMessageFailed(message: message));
      }
    } catch (error) {
      customLog("The error is : $error");
      emit(ChartSendMessageFailed(message: "Something Went wrong"));
    }
  }

  Future<void> mapUploadFilesEvent(
      UploadFileEvent event, Emitter<ChartState> emit) async {
    try {
      emit(const UploadFileLoading());
      var response = await friendsDao.uploadFile(imagePath: event.filePath);
      Map<String, dynamic> jsonDecoded = jsonDecode(response.body);
      if (response.statusCode == 200 && jsonDecoded['status'] == true) {
        String filePath = jsonDecoded["data"];
        emit(UploadFileSuccess(filePath: filePath));
      } else if (response.statusCode == 200 && jsonDecoded['status'] == false) {
        String message = jsonDecoded["data"];
        customLog("The failure reason: $message");
        emit(UploadFileFailed(message: message));
      } else {
        String message = jsonDecoded["message"];
        emit(UploadFileFailed(message: message));
      }
    } catch (error) {
      customLog("The error of upload image is : $error");
      emit(UploadFileFailed(message: "Something Went Wrong"));
    }
  }

  Future<void> mapGroupProfileEdit(
      EditGroupChatProfileEvent event, Emitter<ChartState> emit) async {
    try {
      emit(const EditGroupChatProfileLoading());
      var response = await friendsDao.editGroupChat(
          chatId: event.chatId,
          picture: event.picture,
          name: event.name,
          description: event.description);
      Map<String, dynamic> jsonDecoded = jsonDecode(response.body);
      if (response.statusCode == 200 && jsonDecoded['status'] == true) {
        String message = jsonDecoded["message"];
        event.onSuccess(message);
        emit(EditGroupChatProfileSuccess(message: message));
      } else if (response.statusCode == 200 && jsonDecoded['status'] == false) {
        String message = jsonDecoded["message"];
        event.onError(message);
        emit(EditGroupChatProfileFailed(message: message));
      } else {
        String message = jsonDecoded["message"];
        event.onError(message);
        emit(EditGroupChatProfileFailed(message: message));
      }
    } catch (error) {
      emit(EditGroupChatProfileFailed(message: "Something went wrong"));
    }
  }

  Future<void> mapChatViewProfileEvent(
      FetchChartViewProfileEvent event, Emitter<ChartState> emit) async {
    try {
      emit(const ChatViewProfileLoading());

      var response =
          await friendsDao.fetchChatViewProfile(chatId: event.chatId);

      Map<String, dynamic> jsonDecoded = jsonDecode(response.body);

      if (response.statusCode == 200 && jsonDecoded['status'] == true) {
        ChatViewGroupInfo chatViewGroupInfo;
        chatViewGroupInfo = ChatViewGroupInfo.fromJson(jsonDecoded["data"]);
        emit(ChatViewProfileSuccess(chatViewGroupInfo: chatViewGroupInfo));
      } else {
        emit(ChatViewProfileFailed(message: jsonDecoded["message"] ?? 'Error'));
        customLog(jsonDecoded["message"]);
      }
    } catch (error) {
      emit(ChatViewProfileFailed(message: "Something went wrong"));
      customLog('jsonDecoded["message"]');
    }
  }

  Future<void> mapSendInviteMemberEvent(
      SendInviteMemberEvent event, Emitter<ChartState> emit) async {
    try {
      emit(const SendInviteMemberLoading());
      var response = await friendsDao.inviteMemberRequest(
          chatId: event.chatId, invitedUsers: event.invitedUsers);
      Map<String, dynamic> jsonDecoded = jsonDecode(response.body);
      if (response.statusCode == 200 && jsonDecoded['status'] == true) {
        String message = jsonDecoded["message"];
        emit(SendInviteMemberSuccess(message: message));
        event.onSuccess!(message);
      } else {
        String message = jsonDecoded["message"];
        customLog("The failure reason: $message");
        emit(SendInviteMemberFailed(message: message));
        event.onError!(message);
      }
    } catch (error) {
      customLog("The error is : $error");
      emit(SendInviteMemberFailed(message: "Something Went wrong"));
      // event.onError!('Something Went wrong');
    }
  }

  Future<void> mapSendRemoveMemberEvent(
      SendRemoveMemberEvent event, Emitter<ChartState> emit) async {
    try {
      emit(const SendRemoveMemberLoading());
      var response = await friendsDao.removeMemberRequest(
          chatId: event.chatId, removedUsers: event.removeMember);
      Map<String, dynamic> jsonDecoded = jsonDecode(response.body);
      if (response.statusCode == 200 && jsonDecoded['status'] == true) {
        String message = jsonDecoded["message"];
        emit(SendRemoveMemberSuccess(message: message));
        event.onSuccess!(message);
      } else {
        String message = jsonDecoded["message"];
        customLog("The failure reason: $message");
        emit(SendRemoveMemberFailed(message: message));
        event.onError!(message);
      }
    } catch (error) {
      customLog("The error is : $error");
      emit(SendRemoveMemberFailed(message: "Something Went wrong"));
      event.onError!('Something Went wrong');
    }
  }

  Future<void> mapClearChatEvent(
      ClearChatEvent event, Emitter<ChartState> emit) async {
    try {
      emit(const ClearChatLoading());
      var response = await friendsDao.clearChatRequest(
        chatId: event.chatId,
      );
      Map<String, dynamic> jsonDecoded = jsonDecode(response.body);
      if (response.statusCode == 200 && jsonDecoded['status'] == true) {
        String message = jsonDecoded["message"];
        emit(ClearChatSuccess(message: message));
        event.onSuccess(message);
      } else {
        String message = jsonDecoded["message"];
        customLog("The failure reason: $message");
        emit(SendRemoveMemberFailed(message: message));
        event.onError(message);
      }
    } catch (error) {
      customLog("The error is : $error");
      emit(ClearChatFailed(message: "Something Went wrong"));
      event.onError('Something Went wrong"');
    }
  }

  Future<void> mapArchiveChatEvent(
      ArchiveChatEvent event, Emitter<ChartState> emit) async {
    try {
      emit(const ClearChatLoading());
      var response = await friendsDao.archiveChatRequest(
        chatId: event.chatId,
      );
      Map<String, dynamic> jsonDecoded = jsonDecode(response.body);
      if (response.statusCode == 200 && jsonDecoded['status'] == true) {
        String message = jsonDecoded["message"];
        emit(ArchiveChatSuccess(message: message));
        event.onSuccess(message);
      } else {
        String message = jsonDecoded["message"];
        customLog("The failure reason: $message");
        emit(ArchiveChatFailed(message: message));
        event.onError(message);
      }
    } catch (error) {
      customLog("The error is : $error");
      emit(ArchiveChatFailed(message: "Something Went wrong"));
      event.onError('Something Went wrong"');
    }
  }

  Future<void> mapLeaveChatEvent(
      LeaveGroupChatEvent event, Emitter<ChartState> emit) async {
    try {
      emit(const LeaveChatLoading());
      var response = await friendsDao.leaveChatRequest(
        chatId: event.chatId,
      );
      Map<String, dynamic> jsonDecoded = jsonDecode(response.body);
      if (response.statusCode == 200 && jsonDecoded['status'] == true) {
        String message = jsonDecoded["message"];
        emit(LeaveChatSuccess(message: message));
        event.onSuccess(message);
      } else {
        String message = jsonDecoded["message"];
        customLog("The failure reason: $message");
        emit(LeaveChatFailed(message: message));
        event.onError(message);
      }
    } catch (error) {
      customLog("The error is : $error");
      emit(LeaveChatFailed(message: "Something Went wrong"));
      event.onError('Something Went wrong"');
    }
  }

  Future<void> mapArchivedCharListEvent(
      ArchivedChartListEvent event, Emitter<ChartState> emit) async {
    try {
      emit(const ArchivedChartListLoading());
      var response = await friendsDao.fetchArchivedChartList();
      Map<String, dynamic> jsonDecoded = jsonDecode(response.body);

      if (response.statusCode == 200 && jsonDecoded['status'] == true) {
        List<ChatList> chatList = [];

        if (jsonDecoded["data"] is List) {
          for (var i in jsonDecoded["data"]) {
            try {
              chatList.add(ChatList.fromJson(i));
            } catch (e) {
              customLog("Error parsing chatList item: $e");
            }
          }
        } else {
          emit(ArchivedChartListFailed(message: "Invalid data format"));
          return;
        }

        if (chatList.isNotEmpty) {
          emit(ArchivedChartListSuccess(chatList: chatList));
        } else {
          emit(ArchivedChartListFailed(message: "No chats found"));
        }
      } else {
        emit(ArchivedChartListFailed(
            message: jsonDecoded["message"] ?? 'Error'));
      }
    } catch (error) {
      customLog("Error: $error");
      emit(ArchivedChartListFailed(message: "Something went wrong"));
    }
  }

  Future<void> mapAcceptInviteChatEvent(
      AcceptChatEvent event, Emitter<ChartState> emit) async {
    try {
      emit(const AcceptInviteChatLoading());
      var response = await friendsDao.acceptInviteGroup(
        chatId: event.chatId,
      );
      Map<String, dynamic> jsonDecoded = jsonDecode(response.body);
      if (response.statusCode == 200 && jsonDecoded['status'] == true) {
        String message = jsonDecoded["message"];
        emit(AcceptInviteChatSuccess(message: message));
        event.onSuccess(message);
      } else {
        String message = jsonDecoded["message"];
        customLog("The failure reason: $message");
        emit(AcceptInviteChatFailed(message: message));
        event.onError(message);
      }
    } catch (error) {
      customLog("The error is : $error");
      emit(AcceptInviteChatFailed(message: "Something Went wrong"));
      event.onError('Something Went wrong"');
    }
  }

  Future<void> mapRejectInviteChatEvent(
      RejectGroupChatEvent event, Emitter<ChartState> emit) async {
    try {
      emit(const RejectInviteChatLoading());
      var response = await friendsDao.rejectInviteGroup(
        chatId: event.chatId,
      );
      Map<String, dynamic> jsonDecoded = jsonDecode(response.body);
      if (response.statusCode == 200 && jsonDecoded['status'] == true) {
        String message = jsonDecoded["message"];
        emit(RejectInviteChatSuccess(message: message));
        event.onSuccess(message);
      } else {
        String message = jsonDecoded["message"];
        customLog("The failure reason: $message");
        emit(RejectInviteChatFailed(message: message));
        event.onError(message);
      }
    } catch (error) {
      customLog("The error is : $error");
      emit(RejectInviteChatFailed(message: "Something Went wrong"));
      event.onError('Something Went wrong"');
    }
  }

  Future<void> mapStartMessageEvent(
      StartMessageEvent event, Emitter<ChartState> emit) async {
    try {
      emit(const RejectInviteChatLoading());
      var response = await friendsDao.sendChatMessage(
        chatId: event.chatId,
      );
      Map<String, dynamic> jsonDecoded = jsonDecode(response.body);
      if (response.statusCode == 200 && jsonDecoded['status'] == true) {
        String chatId = jsonDecoded["data"]["id"];
        emit(StartMessageSuccess(chatId: chatId));
        event.onSuccess(chatId);
      } else {
        String message = jsonDecoded["message"];
        customLog("The failure reason: $message");
        emit(StartMessageChatFailed(message: message));
        event.onError(message);
      }
    } catch (error) {
      customLog("The error is : $error");
      emit(StartMessageChatFailed(message: "Something Went wrong"));
      event.onError('Something Went wrong"');
    }
  }

  Future<void> mapDeleteGroupChatEvent(
      DeleteGroupEvent event, Emitter<ChartState> emit) async {
    try {
      //emit(const RejectInviteChatLoading());
      var response = await friendsDao.deleteGroupChart(
        chatId: event.chatId,
      );
      Map<String, dynamic> jsonDecoded = jsonDecode(response.body);
      if (response.statusCode == 200 && jsonDecoded['status'] == true) {
        String message = jsonDecoded["message"];
        emit(DeleteGroupChatSuccess(message: message));
        event.onSuccess(message);
      } else {
        String message = jsonDecoded["message"];
        customLog("The failure reason: $message");
        emit(DeleteGroupChatFailed(message: message));
        event.onError(message);
      }
    } catch (error) {
      customLog("The error is : $error");
      emit(DeleteGroupChatFailed(message: "Something Went wrong"));
      event.onError('Something Went wrong"');
    }
  }

  Future<void> mapCancelGroupInviteChatEvent(
      CancelInviteChatEvent event, Emitter<ChartState> emit) async {
    try {
      emit(const CancelInviteChatLoading());
      var response = await friendsDao.cancelInviteGroupChart(
        id: event.id,
      );
      Map<String, dynamic> jsonDecoded = jsonDecode(response.body);
      if (response.statusCode == 200 && jsonDecoded['status'] == true) {
        String message = jsonDecoded["message"];
        emit(CancelInviteSuccess(message: message));
        event.onSuccess(message);
      } else {
        String message = jsonDecoded["message"];
        customLog("The failure reason: $message");
        emit(CancelInviteChatFailed(message: message));
        event.onError(message);
      }
    } catch (error) {
      customLog("The error is : $error");
      emit(CancelInviteChatFailed(message: "Something Went wrong"));
      event.onError('Something Went wrong"');
    }
  }

  Future<void> mapMarkAsAdminEvent(
      MarkAsAdminEvent event, Emitter<ChartState> emit) async {
    try {
      emit(const MarkAsAdminLoading());
      var response = await friendsDao.markAsAdminRequest(
          chatId: event.chatId, userIds: event.users);
      Map<String, dynamic> jsonDecoded = jsonDecode(response.body);
      if (response.statusCode == 200 && jsonDecoded['status'] == true) {
        String message = jsonDecoded["message"];
        emit(MarkAsAdminSuccess(message: message));
        event.onSuccess!(message);
      } else {
        String message = jsonDecoded["message"];
        customLog("The failure reason: $message");
        emit(MarkAsAdminFailed(message: message));
        event.onError!(message);
      }
    } catch (error) {
      customLog("The error is : $error");
      emit(MarkAsAdminFailed(message: "Something Went wrong"));
      event.onError!('Something Went wrong"');
    }
  }

  Future<void> mapUnArchiveChatsEvent(
      UnArchiveChatEvent event, Emitter<ChartState> emit) async {
    try {
      var response =
          await friendsDao.unArchiveChatRequest(chatId: event.chatId);
      Map<String, dynamic> jsonDecoded = jsonDecode(response.body);
      if (response.statusCode == 200 && jsonDecoded['status'] == true) {
        String message = jsonDecoded["message"];
        emit(UnArchiveChatSuccess(message: message));
        event.onSuccess(message);
      } else {
        String message = jsonDecoded["message"];
        customLog("The failure reason: $message");
        emit(UnArchiveChatFailed(message: message));
        event.onError(message);
      }
    } catch (error) {
      customLog("The error is : $error");
      emit(UnArchiveChatFailed(message: "Something Went wrong"));
      event.onError('Something Went wrong"');
    }
  }

  Future<void> mapBlocChatGroupEvent(
      BlocChartGroupEvent event, Emitter<ChartState> emit) async {
    try {
      var response = await friendsDao.blockGroupChat(
          chatId: event.chatId, reason: event.reason);
      Map<String, dynamic> jsonDecoded = jsonDecode(response.body);
      if (response.statusCode == 200 && jsonDecoded['status'] == true) {
        String message = jsonDecoded["message"];
        event.onSuccess(message);
        emit(GroupBlocChatSuccess(message: message));
      } else if (response.statusCode == 200 && jsonDecoded['status'] == false) {
        String message = jsonDecoded["message"];
        event.onError(message);
        emit(GroupBlocChatFailed(message: message));
      } else {
        String message = jsonDecoded["message"];
        event.onError(message);
        emit(GroupBlocChatFailed(message: message));
      }
    } catch (error) {
      emit(GroupBlocChatFailed(message: "Something went wrong"));
    }
  }

  Future<void> mapChatUnBlockedGroupEvent(
      UnBlocChartGroupEvent event, Emitter<ChartState> emit) async {
    try {
      var response = await friendsDao.unReportGroupChat(
        chatId: event.chatId,
      );
      Map<String, dynamic> jsonDecoded = jsonDecode(response.body);
      if (response.statusCode == 200 && jsonDecoded['status'] == true) {
        String message = jsonDecoded["message"];
        event.onSuccess(message);
        emit(GroupUnBlocChatSuccess(message: message));
      } else if (response.statusCode == 200 && jsonDecoded['status'] == false) {
        String message = jsonDecoded["message"];
        event.onError(message);
        emit(GroupUnBlocChatFailed(message: message));
      } else {
        String message = jsonDecoded["message"];
        event.onError(message);
        emit(GroupUnBlocChatFailed(message: message));
      }
    } catch (error) {
      emit(GroupUnBlocChatFailed(message: "Something went wrong"));
    }
  }


  Future<void> mapChatReportGroupEvent(
      ReportChartGroupEvent event, Emitter<ChartState> emit) async {
    try {
      var response = await friendsDao.reportGroupChat(
        chatId: event.chatId,
        reason: event.reason
      );
      Map<String, dynamic> jsonDecoded = jsonDecode(response.body);
      if (response.statusCode == 200 && jsonDecoded['status'] == true) {
        String message = jsonDecoded["message"];
        event.onSuccess(message);
        emit(ReportChatSuccess(message: message));
      } else if (response.statusCode == 200 && jsonDecoded['status'] == false) {
        String message = jsonDecoded["message"];
        event.onError(message);
        emit(ReportChatFailed(message: message));
      } else {
        String message = jsonDecoded["message"];
        event.onError(message);
        emit(ReportChatFailed(message: message));
      }
    } catch (error) {
      emit(ReportChatFailed(message: "Something went wrong"));
    }
  }

  Future<void> mapChatBlockedListEvent(
      BlockedChatList event, Emitter<ChartState> emit) async {
    try {
      emit(const GroupUnBlocChatLoading());

      var response = await friendsDao.blockedUserListChat();

      Map<String, dynamic> jsonDecoded = jsonDecode(response.body);



      if (response.statusCode == 200 && jsonDecoded['status'] == true) {
        List<ChatList> chatList = [];

        if (jsonDecoded["data"] is List) {
          for (var i in jsonDecoded["data"]) {
            try {
              chatList.add(ChatList.fromJson(i));
            } catch (e) {
              customLog("Error parsing chatList item: $e");
            }
          }
        } else {
          emit(ChatBlockedListFalied(message: "Invalid data format"));
          return;
        }

        if (chatList.isNotEmpty) {
          emit(ChatBlockedListSuccess(chatBlockedList: chatList));
        } else {
          emit(ChatBlockedListFalied(message: "No chats found"));
        }
      } else {
        emit(ChatBlockedListFalied(
            message: jsonDecoded["message"] ?? 'Error'));
      }
    } catch (error) {
      emit(ChatBlockedListFalied(message: "Something went wrong"));
      customLog('jsonDecoded["message"]');
    }
  }


  Future<void> mapChartSearchListEvent(
      FetchChartSearchListEvent event, Emitter<ChartState> emit) async {
    try {
      if (event.page == 1) {
        emit(const chartListSearchLoading());
      }

      var response = await friendsDao.fetchChatSearchList(
          page: event.page, pageSize: event.pageSize, keyWord: event.keyWord);

      Map<String, dynamic> jsonDecoded = jsonDecode(response.body);
      print('object');

      if (response.statusCode == 200 && jsonDecoded['status'] == true) {
        int maxPageNumber = jsonDecoded["data"]["pagination"]["totalPages"];
        int maxPageSize = jsonDecoded["data"]["pagination"]["pageSize"];
        List<ChartSearchList> chartSearchList = [];
        for (var i in jsonDecoded["data"]["groups"]) {
          chartSearchList.add(ChartSearchList.fromJson(i));
        }
        if (event.page > 1) {
          final currentState = state;
          if (currentState is chartListSearchSuccess) {
            chartSearchList = List.from(currentState.chartSearchList)
              ..addAll(chartSearchList);
          }
        }
        customLog(chartSearchList.length);

        emit(chartListSearchSuccess(
        chartSearchList: chartSearchList,
          maxPageNumber: maxPageNumber,
          maxPageSize: maxPageSize,
        ));
      } else {
        emit(chartListSearchFailed(
            message: jsonDecoded["message"] ?? 'Error'));
        customLog(jsonDecoded["message"]);
      }
    } catch (error) {
      emit(chartListSearchFailed(message: "Something went wrong"));
      customLog('jsonDecoded["message"]');
    }
  }


  Future<void> mapDeleteChatEvent(
      DeleteChartEvent event, Emitter<ChartState> emit) async {
    try {
      //emit(const RejectInviteChatLoading());
      var response = await friendsDao.deleteChart(
        chatId: event.chatId,
      );
      Map<String, dynamic> jsonDecoded = jsonDecode(response.body);
      if (response.statusCode == 200 && jsonDecoded['status'] == true) {
        String message = jsonDecoded["message"];
        emit(DeleteChatSuccess(message: message));
        event.onSuccess(message);
      } else {
        String message = jsonDecoded["message"];
        customLog("The failure reason: $message");
        emit(DeleteChatFailed(message: message));
        event.onError(message);
      }
    } catch (error) {
      customLog("The error is : $error");
      emit(DeleteChatFailed(message: "Something Went wrong"));
      event.onError('Something Went wrong"');
    }
  }


  Future<void> mapApproveChatRequestEvent(
      ApproveChartRequestEvent event, Emitter<ChartState> emit) async {
    try {
      var response = await friendsDao.approveChartRequest(
        chatId: event.chatId,
      );
      Map<String, dynamic> jsonDecoded = jsonDecode(response.body);
      if (response.statusCode == 200 && jsonDecoded['status'] == true) {
        String message = jsonDecoded["message"];
        emit(ApproveChartRequestSuccess(message: message));
        event.onSuccess(message);
      } else {
        String message = jsonDecoded["message"];
        customLog("The failure reason: $message");
        emit(ApproveChartRequestFailed(message: message));
        event.onError(message);
      }
    } catch (error) {
      customLog("The error is : $error");
      emit(ApproveChartRequestFailed(message: "Something Went wrong"));
      event.onError('Something Went wrong"');
    }
  }


  Future<void> mapRejectChatRequestEvent(
      RejectChartRequestEvent event, Emitter<ChartState> emit) async {
    try {
      //emit(const RejectInviteChatLoading());
      var response = await friendsDao.rejectChartRequest(
        chatId: event.chatId,
      );
      Map<String, dynamic> jsonDecoded = jsonDecode(response.body);
      if (response.statusCode == 200 && jsonDecoded['status'] == true) {
        String message = jsonDecoded["message"];
        emit(RejectChartRequestSuccess(message: message));
        event.onSuccess(message);
      } else {
        String message = jsonDecoded["message"];
        customLog("The failure reason: $message");
        emit(RejectChartRequestFailed(message: message));
        event.onError(message);
      }
    } catch (error) {
      customLog("The error is : $error");
      emit(RejectChartRequestFailed(message: "Something Went wrong"));
      event.onError('Something Went wrong"');
    }
  }


}
