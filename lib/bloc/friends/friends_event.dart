part of 'friends_bloc.dart';

@immutable
sealed class FriendsEvent extends Equatable {
  const FriendsEvent();
  @override
  List<Object> get props => [];
}

class FetchFriendsListEvent extends FriendsEvent {
  int page;
  int pageSize;
  String keyWord;
  FetchFriendsListEvent({
    required this.page,
    required this.pageSize,
    required this.keyWord,
  });
  @override
  List<Object> get props => [page, pageSize, keyWord];
}

class FetchFriendsSingleView extends FriendsEvent {
  final String friendId;

  const FetchFriendsSingleView({required this.friendId});

  @override
  List<Object> get props => [friendId];
}



class FetchFriendsAddListEvent extends FriendsEvent {
  int page;
  int pageSize;
  String keyWord;
  FetchFriendsAddListEvent({
    required this.page,
    required this.pageSize,
    required this.keyWord,
  });
  @override
  List<Object> get props => [page, pageSize, keyWord];
}