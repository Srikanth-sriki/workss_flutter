import 'dart:convert';

import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:meta/meta.dart';
import 'package:works_app/dao/friends_dao.dart';
import 'package:works_app/models/friends/friendsRequestList.dart';
import 'package:works_app/models/friends/friends_search_list_modal.dart';
import 'package:works_app/models/friends/friends_view_modal.dart';
import 'package:works_app/models/friends/global_search_list_modal.dart';

import '../../helper/custom_log.dart';
import '../../helper/network_helper.dart';
import '../../helper/network_error_handler_global.dart';

part 'friends_event.dart';
part 'friends_state.dart';

class FriendsBloc extends Bloc<FriendsEvent, FriendsState> {
  late FriendsDao friendsDao;
  FriendsBloc() : super(FriendsInitial()) {
    friendsDao = FriendsDao();
    on<FetchFriendsListEvent>((event, emit) async {
      await mapFriendsListEvent(event, emit);
    });
    on<FetchFriendsSingleView>((event, emit) async {
      await mapFetchFriendsViewWorkEvent(event, emit);
    });
    on<FetchFriendsAddListEvent>((event, emit) async {
      await mapAddSearchFriendsListEvent(event, emit);
    });

    on<FetchFriendsRequestListEvent>((event, emit) async {
      await mapFriendsRequestListEvent(event, emit);
    });
  }

  Future<void> mapFriendsListEvent(
      FetchFriendsListEvent event, Emitter<FriendsState> emit) async {
    try {
      if (event.page == 1) {
        emit(const FriendsListLoading());
      }

      // Check network before making API call
      final hasConnection = await NetworkHelper.hasInternetConnection();
      if (!hasConnection) {
        emit(FriendsListFailed(
          message: 'No internet connection. Please check your network and try again.',
        ));
        return;
      }

      var response = await friendsDao.fetchFriendsSearchList(
          page: event.page, pageSize: event.pageSize, keyWord: event.keyWord);

      Map<String, dynamic> jsonDecoded = jsonDecode(response.body);

      if (response.statusCode == 200 && jsonDecoded['status'] == true) {
        int maxPageNumber = jsonDecoded["data"]["pagination"]["totalPages"];
        int maxPageSize = jsonDecoded["data"]["pagination"]["pageSize"];

        List<Friend> friendsList = [];
        for (var i in jsonDecoded["data"]["friends"]) {
          friendsList.add(Friend.fromJson(i));
        }

        if (event.page > 1) {
          final currentState = state;
          if (currentState is FriendsListSuccess) {
            friendsList = List.from(currentState.friendsSearchList)
              ..addAll(friendsList);
          }
        }

        emit(FriendsListSuccess(
          friendsSearchList: friendsList,
          maxPageNumber: maxPageNumber,
          maxPageSize: maxPageSize,
        ));
      } else {
        emit(FriendsListFailed(message: jsonDecoded["message"] ?? 'Error'));
        customLog('1111111111111111');
        customLog(jsonDecoded["message"]);
      }
    } catch (error) {
      customLog('Error in friends list: $error');
      // Handle network errors with user-friendly messages
      final errorMessage = GlobalNetworkErrorHandler.handleError(error);
      emit(FriendsListFailed(message: errorMessage));
    }
  }

  Future<void> mapFetchFriendsViewWorkEvent(
      FetchFriendsSingleView event, Emitter<FriendsState> emit) async {
    try {
      emit(const FetchFriendsViewLoading());
      
      // Check network before making API call
      final hasConnection = await NetworkHelper.hasInternetConnection();
      if (!hasConnection) {
        emit(const FetchFriendsViewError(
          'No internet connection. Please check your network and try again.',
        ));
        return;
      }
      
      var response = await friendsDao.fetchFriendsView(id: event.friendId);
      Map<String, dynamic> jsonDecoded = jsonDecode(response.body);
      customLog(response);
      if (response.statusCode == 200 && jsonDecoded['status'] == true) {
        FriendData friendData;
        friendData = FriendData.fromJson(jsonDecoded["data"]);
        emit(FetchFriendsViewSuccess(friendData));
      } else {
        String message = jsonDecoded["message"];
        customLog("The failure reason: $message");
        emit(FetchFriendsViewError(message));
      }
    } catch (error) {
      customLog("The error is : $error");
      // Handle network errors with user-friendly messages
      final errorMessage = GlobalNetworkErrorHandler.handleError(error);
      emit(FetchFriendsViewError(errorMessage));
    }
  }

  Future<void> mapAddSearchFriendsListEvent(
      FetchFriendsAddListEvent event, Emitter<FriendsState> emit) async {
    try {
      if (event.page == 1) {
        emit(const FriendsListLoading());
      }
      var response = await friendsDao.fetchAddFriendsChatSearchList(
          page: event.page, pageSize: event.pageSize, keyWord: event.keyWord,
        city: event.city ?? "",gender: event.gender??""
      );

      Map<String, dynamic> jsonDecoded = jsonDecode(response.body);

      if (response.statusCode == 200 && jsonDecoded['status'] == true) {
        int maxPageNumber = jsonDecoded["data"]["pagination"]["totalPages"];
        int maxPageSize = jsonDecoded["data"]["pagination"]["pageSize"];

        List<SearchFriendLists> searchFriendLists = [];
        for (var i in jsonDecoded["data"]["users"]) {
          searchFriendLists.add(SearchFriendLists.fromJson(i));
        }

        if (event.page > 1) {
          final currentState = state;
          if (currentState is FriendsListSuccess) {
            searchFriendLists = List.from(currentState.friendsSearchList)
              ..addAll(searchFriendLists);
          }
        }

        emit(FriendsAddListSuccess(
          searchFriendLists: searchFriendLists,
          maxPageNumber: maxPageNumber,
          maxPageSize: maxPageSize,
        ));
      } else {
        emit(FriendsAddListFailed(message: jsonDecoded["message"] ?? 'Error'));
        customLog(jsonDecoded["message"]);
      }
    } catch (error) {
      emit(FriendsAddListFailed(message: "Something went wrong"));
    }
  }

  Future<void> mapFriendsRequestListEvent(
      FetchFriendsRequestListEvent event, Emitter<FriendsState> emit) async {
    try {
      if (event.page == 1) {
        emit(const FriendsListLoading());
      }

      var response = await friendsDao.fetchFriendsRequestList(
          page: event.page, pageSize: event.pageSize, keyWord: event.keyWord);

      Map<String, dynamic> jsonDecoded = jsonDecode(response.body);
      print('object');

      if (response.statusCode == 200 && jsonDecoded['status'] == true) {
        print('object1111111111111');
        int maxPageNumber = jsonDecoded["data"]["pagination"]["totalPages"];
        int maxPageSize = jsonDecoded["data"]["pagination"]["pageSize"];
        print('object1233333333333333333333322222222222222222222111');
        List<RequestFriendsList> friendsList = [];
        for (var i in jsonDecoded["data"]["friendRequests"]) {
          friendsList.add(RequestFriendsList.fromJson(i));
        }
        print('object1222222222222222222222111');
        if (event.page > 1) {
          final currentState = state;
          if (currentState is FriendsRequestListSuccess) {
            friendsList = List.from(currentState.friendsSearchList)
              ..addAll(friendsList);
          }
        }

        emit(FriendsRequestListSuccess(
          friendsSearchList: friendsList,
          maxPageNumber: maxPageNumber,
          maxPageSize: maxPageSize,
        ));
      } else {
        emit(FriendsRequestListFailed(
            message: jsonDecoded["message"] ?? 'Error'));
        customLog(jsonDecoded["message"]);
      }
    } catch (error) {
      emit(FriendsRequestListFailed(message: "Something went wrong"));
      customLog('jsonDecoded["message"]');
    }
  }
}
