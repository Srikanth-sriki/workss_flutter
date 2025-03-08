part of 'friends_bloc.dart';

@immutable
sealed class FriendsState extends Equatable{
  const FriendsState();
  @override
  List<Object> get props => [];
}

final class FriendsInitial extends FriendsState {}


class FriendsListLoading extends FriendsState {
  const FriendsListLoading();
  @override
  List<Object> get props => [];
}

class FriendsListFailed extends FriendsState {
  String message;

  FriendsListFailed({required this.message});
  @override
  List<Object> get props => [message];
}

class FriendsListSuccess extends FriendsState {
  List<Friend> friendsSearchList = [];
  int maxPageNumber;
  int maxPageSize;

  FriendsListSuccess(
      {required this.friendsSearchList,
        required this.maxPageNumber,
        required this.maxPageSize});
  @override
  List<Object> get props => [friendsSearchList,maxPageSize,maxPageNumber];
}

class FetchFriendsViewLoading extends FriendsState {
  const FetchFriendsViewLoading();
  @override
  List<Object> get props => [];
}


class FetchFriendsViewSuccess extends FriendsState {
  final FriendData friendData;

  const FetchFriendsViewSuccess(this.friendData);

  @override
  List<Object> get props => [FriendData];
}

class FetchFriendsViewError extends FriendsState {
  final String message;

  const FetchFriendsViewError(this.message);

  @override
  List<Object> get props => [message];
}



class FriendsAddListFailed extends FriendsState {
  String message;

  FriendsAddListFailed({required this.message});
  @override
  List<Object> get props => [message];
}

class FriendsAddListSuccess extends FriendsState {
  List<SearchFriendLists> searchFriendLists = [];
  int maxPageNumber;
  int maxPageSize;

  FriendsAddListSuccess(
      {required this.searchFriendLists,
        required this.maxPageNumber,
        required this.maxPageSize});
  @override
  List<Object> get props => [searchFriendLists,maxPageSize,maxPageNumber];
}


class FriendsRequestListFailed extends FriendsState {
  String message;

  FriendsRequestListFailed({required this.message});
  @override
  List<Object> get props => [message];
}

class FriendsRequestListSuccess extends FriendsState {
  List<RequestFriendsList> friendsSearchList = [];
  int maxPageNumber;
  int maxPageSize;

  FriendsRequestListSuccess(
      {required this.friendsSearchList,
        required this.maxPageNumber,
        required this.maxPageSize});
  @override
  List<Object> get props => [friendsSearchList,maxPageSize,maxPageNumber];
}

