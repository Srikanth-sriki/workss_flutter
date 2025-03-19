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
  }

  Future<void> mapCharListEvent(
      ChartListEvent event, Emitter<ChartState> emit) async {
    try {
      emit(const ChartListLoading());
      var response = await friendsDao.fetchChartList();

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
          emit(ChartListFailed(message: "Invalid data format"));
          return;
        }

        customLog("Chat List Length: ${chatList.length}");
        if (chatList.isNotEmpty) {
          emit(ChartListSuccess(chatList: chatList));
        } else {
          emit(ChartListFailed(message: "No chats found"));
        }
      } else {
        emit(ChartListFailed(message: jsonDecoded["message"] ?? 'Error'));
      }
    } catch (error) {
      customLog("Error: $error");
      emit(ChartListFailed(message: "Something went wrong"));
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
        ChatViewGroupInfo chatViewGroupInfo ;
        chatViewGroupInfo = ChatViewGroupInfo.fromJson(jsonDecoded["data"]["chatData"]);





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
            chatViewGroupInfo:chatViewGroupInfo
        ));
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
      var response = await friendsDao.sendMessageChat(chatId: event.chatId, content: event.content, messageType: event.messageType,  fileName: event.fileName, fileUrl: event.fileUrl, fileType: event.fileType, fileSize: event.fileSize);
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
      var response =
      await friendsDao.uploadFile(imagePath: event.filePath);
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
      var response =
      await friendsDao.editGroupChat(chatId: event.chatId, picture: event.picture, name: event.name, description: event.description);
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
}
