import 'dart:async';
import 'dart:io';

import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:works_app/bloc/chart/chart_bloc.dart';
import 'package:works_app/components/colors.dart';
import 'package:works_app/ui/chat/group_create_success.dart';

import '../../bloc/friends/friends_bloc.dart';
import '../../bloc/register_account/initial_register_bloc.dart';
import '../../components/size_config.dart';
import '../../global_helper/ImagePickerComponent.dart';
import '../../global_helper/loading_placeholder/home_layout.dart';
import '../../global_helper/reuse_widget.dart';
import '../../models/friends/friends_search_list_modal.dart';
import '../profile/component.dart';
import 'component.dart';

class CreateGroupScreen extends StatefulWidget {
  const CreateGroupScreen({super.key});

  @override
  State<CreateGroupScreen> createState() => _CreateGroupScreenState();
}

class _CreateGroupScreenState extends State<CreateGroupScreen> {
  final _formKey = GlobalKey<FormState>();
  late ChartBloc chartBloc;
  late FriendsBloc friendsBloc;
  late InitialRegisterBloc initialRegisterBloc;
  late String profilePicture;
  final TextEditingController groupName = TextEditingController();
  final TextEditingController groupDescription = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  final TextEditingController _searchController = TextEditingController();
  bool groupNameError = false;
  bool groupDescriptionError = false;
  bool isSubmitButtonEnabled = false;
  bool groupStepOne = false;
  bool inviteMemberListLoading = true;
  bool groupCreateLoad = false;
  File? _profileImage;
  bool isFriendsListLoad = true;
  List<Friend> friends = [];
  bool isFriendsListError = false;
  List<String> selectedFriends = [];
  Timer? _debounce;
  String searchKeyword = "";
  bool isFetchingMore = false;
  int currentPage = 1;
  int pageSize = 10;
  int maxPageNumber = 1;
  bool showSearchBar = false;
  bool selectAll = false;
  List<Map<String, dynamic>> selectedItems = [];
  String? _selectedGroupType = 'private';
  bool profileSelected = false;
  bool nameSelected = false;
  bool descriptionSelected = false;

  @override
  void initState() {
    super.initState();
    friendsBloc = BlocProvider.of<FriendsBloc>(context);
    chartBloc = BlocProvider.of<ChartBloc>(context);
    profilePicture = "";
    initialRegisterBloc = BlocProvider.of<InitialRegisterBloc>(context);
    _scrollController.addListener(() {
      if (_scrollController.position.pixels ==
              _scrollController.position.maxScrollExtent &&
          !isFetchingMore &&
          currentPage < maxPageNumber) {
        _loadMoreData();
      }
    });
  }

  void _onSearchChanged(String keyword) {
    if (_debounce?.isActive ?? false) _debounce?.cancel();
    _debounce = Timer(const Duration(milliseconds: 500), () {
      setState(() {
        searchKeyword = keyword;
        currentPage = 1;
      });
      _fetchData();
    });
  }

  void _fetchData({bool isNewFetch = false}) {
    if (isNewFetch) {
      friends.clear();
      currentPage = 1;
    }

    friendsBloc.add(FetchFriendsListEvent(
      page: currentPage,
      pageSize: pageSize,
      keyWord: searchKeyword,
    ));
  }

  void _loadMoreData() {
    setState(() {
      isFetchingMore = true;
      currentPage++;
    });
    _fetchData();
  }

  void _toggleSelectAll(bool value) {
    setState(() {
      selectAll = value;
      for (var item in selectedItems) {
        item["selected"] = value;
      }
      print(selectedItems);
    });
  }

  void _updateSelectedItemsList() {
    selectedItems = friends
        .map((friend) => {"id": friend.friends.id, "selected": false})
        .toList();
  }

  @override
  void dispose() {
    _scrollController.dispose();
    _searchController.dispose();
    _debounce?.cancel();
    super.dispose();
  }

  void fetchInviteList() {
    //chartBloc.add(InviteMemberChartEvent(page: page, pageSize: pageSize, groupId: groupId, keyWord: keyWord))
  }

  void _validateForm() {
    if (groupName.text.isNotEmpty && groupDescription.text.isNotEmpty) {
      setState(() {
        isSubmitButtonEnabled = true;
      });
    }
  }

  void toggleSelection(String friendId) {
    setState(() {
      if (selectedFriends.contains(friendId)) {
        selectedFriends.remove(friendId);
      } else {
        selectedFriends.add(friendId);
      }
    });
  }

  void _submitButton() {
    List<String> selectedUserIds = selectedItems
        .where((user) => user["selected"] == true)
        .map((user) => user["id"] as String)
        .toList();

    setState(() {
      if (selectAll) {
        selectedFriends = selectedUserIds;
      }
    });
    chartBloc.add(ChartGroupCreateEvent(
        picture: profilePicture,
        name: groupName.text,
        description: groupDescription.text,
        invitedUsers: selectedFriends,type: _selectedGroupType!));
  }

  void checkSelectedId() {
    List<String> selectedUserIds = selectedItems
        .where((user) => user["selected"] == true)
        .map((user) => user["id"] as String)
        .toList();
    if (selectedUserIds.isEmpty) {
      setState(() {
        selectAll = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: COLORS.white,
      appBar: AppBar(
        backgroundColor: COLORS.primary,
        scrolledUnderElevation: 0,
        elevation: 0,
        automaticallyImplyLeading: false,
        toolbarHeight: SizeConfig.blockHeight * 11,
        title: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    InkWell(
                        onTap: () {
                          Navigator.of(context).pop();
                        },
                        child: Icon(
                          Icons.arrow_back_ios,
                          color: COLORS.white,
                          size: SizeConfig.blockWidth * 4,
                        )),
                    SizedBox(
                      width: SizeConfig.blockWidth * 2.5,
                    ),
                    Text(
                      'Create Group'.tr(),
                      style: TextStyle(
                        color: COLORS.white,
                        fontSize: SizeConfig.blockWidth * 4.6,
                        fontWeight: FontWeight.w400,
                        fontFamily: "Poppins",
                      ),
                    ),
                  ],
                ),
                Container(
                  padding: EdgeInsets.symmetric(
                      horizontal: SizeConfig.blockWidth * 2.5,
                      vertical: SizeConfig.blockHeight),
                  decoration: BoxDecoration(
                      color: COLORS.primaryOne.withOpacity(0.5),
                      borderRadius:
                          BorderRadius.circular(SizeConfig.blockWidth * 2.5)),
                  child: Text(
                    groupStepOne ? 'Step 2'.tr() : 'Step 1'.tr(),
                    style: TextStyle(
                      color: COLORS.white,
                      fontSize: SizeConfig.blockWidth * 3,
                      fontWeight: FontWeight.w400,
                      fontFamily: "Poppins",
                    ),
                  ),
                )
              ],
            ),
            Padding(
              padding:
                  EdgeInsets.symmetric(horizontal: SizeConfig.blockWidth * 7),
              child: Text(
                'Build your own work network'.tr(),
                style: TextStyle(
                  color: COLORS.primaryOne,
                  fontSize: SizeConfig.blockWidth * 3.5,
                  fontWeight: FontWeight.w400,
                  fontFamily: "Poppins",
                ),
              ),
            ),
          ],
        ),
      ),
      body: MultiBlocListener(
        listeners: [
          BlocListener<FriendsBloc, FriendsState>(
            listener: (context, state) {
              if (state is FriendsListLoading) {
                setState(() {
                  isFriendsListLoad = true;
                  isFriendsListError = false;
                });
              } else if (state is FriendsListSuccess) {
                setState(() {
                  friends = state.friendsSearchList;
                  isFriendsListLoad = false;
                  isFriendsListError = false;
                  _updateSelectedItemsList();
                });
              } else if (state is FriendsListFailed) {
                setState(() {
                  isFriendsListLoad = false;
                  isFriendsListError = true;
                });
              }
            },
          ),
          BlocListener<ChartBloc, ChartState>(
            listener: (context, state) {
              // if (state is InviteMemberLoading) {
              //   setState(() {
              //     inviteMemberListLoading = true;
              //   });
              // }
              // if (state is InviteMemberSuccess) {
              //   setState(() {
              //     inviteMemberListLoading = false;
              //   });
              // } else if (state is InviteMemberFailed) {
              //   setState(() {
              //     inviteMemberListLoading = false;
              //   });
              // } else
              if (state is ChartListLoading) {
                setState(() {
                  groupCreateLoad = true;
                });
              } else if (state is ChartGroupCreateSuccess) {
                setState(() {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (BuildContext context) =>
                          const GroupCreateSuccess(),
                    ),
                  );
                  groupCreateLoad = false;
                });
              } else if (state is ChartGroupCreateFailed) {
                setState(() {
                  groupCreateLoad = false;
                  showCustomSnackBar(
                    context: context,
                    message: state.message,
                  );
                });
              }
            },
          ),
          BlocListener<InitialRegisterBloc, InitialRegisterState>(
            listener: (context, state) {
              if (state is UploadImageSuccess) {
                profilePicture = state.filePath;
                profileSelected = true;
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
            child: groupStepOne != true
                ? SingleChildScrollView(
                    child: Container(
                    width: SizeConfig.screenWidth,
                    padding: EdgeInsets.all(SizeConfig.blockWidth * 4.5),
                    child: Form(
                        key: _formKey,
                        child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisAlignment: MainAxisAlignment.start,
                            children: [
                              _buildProfilePicture(),
                              _buildTextField(
                                  label: 'Group Name',
                                  controller: groupName,
                                  hintText: "Enter group name".tr(),
                                  validator: (value) {
                                    if (value == null || value.isEmpty) {
                                      setState(() => groupNameError = true);
                                      return 'Please enter group name'.tr();
                                    }
                                    setState(() => groupNameError = false);
                                    return null;
                                  },
                                  error: groupNameError,
                                  onChanged: (value) {
                                    _validateForm();
                                    if (value!.isNotEmpty) {
                                      setState(() {
                                        nameSelected = true;
                                      });
                                    } else {
                                      setState(() {
                                        nameSelected = false;
                                      });
                                    }
                                  },
                                  title: 'Group Name'.tr(),
                                  color: nameSelected
                                      ? COLORS.neutralDarkOne
                                      : COLORS.neutralDark,
                                  fontWeight: nameSelected
                                      ? FontWeight.w400
                                      : FontWeight.w500),
                              buildDynamicRadioSelection(
                                  title: 'Gender'.tr(),
                                  options: [
                                    {'label': 'Private', 'value': 'private'},
                                    {'label': 'Public', 'value': 'public'}
                                  ],
                                  onChanged: (value) {
                                    setState(() {
                                      _selectedGroupType = value;
                                      _validateForm();
                                    });
                                  },
                                  groupValue: _selectedGroupType,
                                  color: COLORS.neutralDarkOne ,fontWeight:  FontWeight.w400
                              ),
                              SizedBox(height: SizeConfig.blockHeight * 1),
                              _buildBioTextField(
                                  label: 'Group Description'.tr(),
                                  controller: groupDescription,
                                  hintText: "Write group description here".tr(),
                                  validator: (value) {
                                    if (value == null || value.isEmpty) {
                                      setState(
                                          () => groupDescriptionError = true);
                                      return 'Please enter description'.tr();
                                    }
                                    setState(
                                        () => groupDescriptionError = false);
                                    return null;
                                  },
                                  error: groupDescriptionError,
                                  onChanged: (value) {
                                    _validateForm();
                                    if (value!.isNotEmpty) {
                                      setState(() {
                                        descriptionSelected = true;
                                      });
                                    } else {
                                      setState(() {
                                        descriptionSelected = false;
                                      });
                                    }
                                  },
                                  title: 'Group Description'.tr(),
                                  color: descriptionSelected
                                      ? COLORS.neutralDarkOne
                                      : COLORS.neutralDark,
                                  fontWeight: descriptionSelected
                                      ? FontWeight.w400
                                      : FontWeight.w500
                              ),
                            ])),
                  ))
                : Container(
                    width: SizeConfig.screenWidth,
                    padding: EdgeInsets.all(SizeConfig.blockWidth * 4.5),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            Row(
                              crossAxisAlignment: CrossAxisAlignment.center,
                              mainAxisAlignment: MainAxisAlignment.start,
                              children: [
                                Checkbox(
                                    side: BorderSide(
                                        color: COLORS.neutralDarkOne,
                                        width: SizeConfig.blockWidth * 0.5),
                                    checkColor: COLORS.white,
                                    activeColor: COLORS.primary,
                                    value: selectAll,
                                    onChanged: (value) {
                                      _toggleSelectAll(value ?? false);
                                      selectedFriends = [];
                                    }),
                                Text(
                                  'Select Friends',
                                  style: TextStyle(
                                    color: COLORS.neutralDarkOne,
                                    fontSize: SizeConfig.blockWidth * 3.8,
                                    fontWeight: FontWeight.w400,
                                    fontFamily: "Poppins",
                                  ),
                                ),
                              ],
                            ),
                            IconButton(
                              icon: Icon(
                                showSearchBar ? Icons.close : Icons.search,
                                color: COLORS.neutralDarkOne,
                                size: SizeConfig.blockHeight * 3.5,
                              ),
                              onPressed: () {
                                setState(() {
                                  _searchController.clear();
                                  showSearchBar = !showSearchBar;
                                  if (!showSearchBar) {
                                    setState(() {
                                      searchKeyword = '';
                                      currentPage = 1;
                                      _fetchData(isNewFetch: true);
                                    });
                                  }
                                });
                              },
                            ),
                          ],
                        ),
                        if (showSearchBar)
                          TextField(
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
                              focusColor:
                                  COLORS.neutralDarkTwo.withOpacity(0.6),
                              filled: true,
                              hintText: 'Ex: Search'.tr(),
                              hintStyle: TextStyle(
                                color: COLORS.neutralDarkOne,
                                fontSize: SizeConfig.blockWidth * 3.25,
                                fontWeight: FontWeight.w400,
                                fontFamily: "Poppins",
                              ),
                              prefixIcon: Icon(
                                Icons.search,
                                color: COLORS.neutralDarkOne,
                                size: SizeConfig.blockWidth * 5,
                              ),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(
                                    SizeConfig.blockWidth * 3.25),
                                borderSide: BorderSide(
                                    color:
                                        COLORS.neutralDarkTwo.withOpacity(0.6),
                                    width: SizeConfig.blockWidth * 0.1),
                              ),
                              focusedBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(
                                    SizeConfig.blockWidth * 3.25),
                                borderSide: BorderSide(
                                    color:
                                        COLORS.neutralDarkTwo.withOpacity(0.6),
                                    width: SizeConfig.blockWidth * 0.1),
                              ),
                              enabledBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(
                                    SizeConfig.blockWidth * 3.25),
                                borderSide: BorderSide(
                                    color:
                                        COLORS.neutralDarkTwo.withOpacity(0.6),
                                    width: SizeConfig.blockWidth * 0.1),
                              ),
                            ),
                            onChanged: _onSearchChanged,
                          ),
                        SizedBox(
                          height: SizeConfig.blockHeight * 2.5,
                        ),
                        if (isFriendsListLoad) ...[
                          Expanded(child: globalLoadingWidget())
                        ] else if (!isFriendsListLoad &&
                            friends.isNotEmpty) ...[
                          Expanded(
                            child: ListView.builder(
                                controller: _scrollController,
                                itemCount:
                                    friends.length + (isFetchingMore ? 1 : 0),
                                shrinkWrap: true,
                                scrollDirection: Axis.vertical,
                                itemBuilder: (context, index) {
                                  final friend = friends[index].friends;
                                  final isSelected =
                                      selectedFriends.contains(friend.id);
                                  if (index < friends.length) {
                                    return Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.start,
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        if (selectAll) ...[
                                          Checkbox(
                                            side: BorderSide(
                                              color: COLORS.neutralDarkOne,
                                              width:
                                                  SizeConfig.blockWidth * 0.5,
                                            ),
                                            checkColor: COLORS.white,
                                            activeColor: COLORS.primary,
                                            value: selectedItems[index]
                                                ["selected"],
                                            onChanged: (bool? value) {
                                              setState(() {
                                                selectedItems[index]
                                                        ["selected"] =
                                                    value ?? false;
                                                checkSelectedId();
                                              });
                                            },
                                          )
                                        ],
                                        createGroupInviteCard(
                                            image: friend.profilePic,
                                            name: friend.name,
                                            disc: friend.bio,
                                            added: isSelected,
                                            onTapCard: () =>
                                                toggleSelection(friend.id),
                                            checkSelected: selectAll),
                                      ],
                                    );
                                  } else if (isFetchingMore) {
                                    return Center(
                                        child: SizedBox(
                                            height: SizeConfig.blockHeight * 3,
                                            width: SizeConfig.blockHeight * 3,
                                            child: CircularProgressIndicator(
                                              color: COLORS.primary,
                                              strokeWidth:
                                                  SizeConfig.blockWidth * 0.8,
                                            )));
                                  } else {
                                    return const SizedBox.shrink();
                                  }
                                }),
                          )
                        ] else if (friends.isEmpty) ...[
                          SizedBox(
                            height: SizeConfig.blockHeight * 60,
                            child: emptyComponent(),
                          )
                        ],
                      ],
                    ),
                  )),
      ),
      bottomNavigationBar: Container(
        padding: EdgeInsets.symmetric(vertical: SizeConfig.blockHeight * 2),
        decoration: BoxDecoration(
          border: Border(
              top: BorderSide(
                  color: COLORS.neutralDarkTwo,
                  width: SizeConfig.blockWidth * 0.3)),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            if (groupStepOne != true) ...[
              customButton(
                text: 'CANCEL'.tr(),
                onPressed: () {
                  Navigator.pop(context);
                },
                backgroundColor: COLORS.neutralDarkTwo,
                showIcon: false,
                width: SizeConfig.blockWidth * 42,
                height: SizeConfig.blockHeight * 8,
                textColor: COLORS.black,
              ),
              customButton(
                text: 'NEXT'.tr(),
                onPressed: () {
                  if (_formKey.currentState!.validate()) {
                    setState(() {
                      groupStepOne = true;
                    });
                  }
                },
                backgroundColor: isSubmitButtonEnabled
                    ? COLORS.primary
                    : COLORS.primary.withOpacity(0.4),
                showIcon: false,
                width: SizeConfig.blockWidth * 42,
                height: SizeConfig.blockHeight * 8,
                textColor: COLORS.white,
              )
            ] else ...[
              customButton(
                text: 'BACK'.tr(),
                onPressed: () {
                  setState(() {
                    groupStepOne = false;
                  });
                },
                backgroundColor: COLORS.neutralDarkTwo,
                showIcon: false,
                width: SizeConfig.blockWidth * 42,
                height: SizeConfig.blockHeight * 8,
                textColor: COLORS.black,
              ),
              customButton(
                text: 'CREATE'.tr(),
                onPressed: () {
                  _submitButton();
                },
                backgroundColor: isSubmitButtonEnabled
                    ? COLORS.primary
                    : COLORS.primary.withOpacity(0.4),
                showIcon: false,
                width: SizeConfig.blockWidth * 42,
                height: SizeConfig.blockHeight * 8,
                textColor: COLORS.white,
              )
            ]
          ],
        ),
      ),
    );
  }

  Widget _buildProfilePicture() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.start,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        registerText(text: 'Group Picture'.tr(),color: profileSelected ? COLORS.neutralDarkOne : COLORS.neutralDark,
    fontWeight: profileSelected ? FontWeight.w400 : FontWeight.w500),
        _profileImage == null
            ? ImagePickerComponent(
                onImageSelected: (File image) {
                  setState(() {
                    _profileImage = image;
                    initialRegisterBloc
                        .add(UploadImageEvent(imagePath: _profileImage!));
                  });
                },
              )
            : Stack(
                children: [
                  Container(
                    height: SizeConfig.blockWidth * 32,
                    width: SizeConfig.blockWidth * 34,
                    decoration: BoxDecoration(
                        border: Border.all(
                          color: COLORS.primary,
                          width: 1.2,
                        ),
                        image: DecorationImage(
                          image: FileImage(
                            File(_profileImage!.path),
                          ),
                          fit: BoxFit.fill,
                        ),
                        borderRadius:
                            BorderRadius.circular(SizeConfig.blockWidth * 3.5)),
                  ),
                  Positioned(
                    bottom: 0,
                    right: 0,
                    child: ImagePickerModal(
                      onImageSelected: (File image) {
                        setState(() {
                          _profileImage = image;
                        });
                      },
                    ),
                  )
                ],
              ),
        SizedBox(height: SizeConfig.blockHeight * 3),
      ],
    );
  }

  Widget _buildTextField(
      {required String label,
      required TextEditingController controller,
      required String hintText,
      required String? Function(String?) validator,
      required String? Function(String?) onChanged,
      required bool error,
      required String title, Color? color = COLORS.neutralDark,
        FontWeight? fontWeight = FontWeight.w500,}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        registerText(text: title, color: color, fontWeight: fontWeight),
        normalTextField(
          hintText: hintText,
          controller: controller,
          inputType: TextInputType.text,
          onChanged: onChanged,
          validator: validator,
          fontWeight: FontWeight.w400,
          prefix: false,
          errorMessage: '',
          hasError: error,
        ),
      ],
    );
  }

  Widget _buildBioTextField(
      {required String label,
      required TextEditingController controller,
      required String hintText,
      required String? Function(String?) validator,
      required String? Function(String?) onChanged,
      required bool error,
      required String title,Color? color = COLORS.neutralDark,
        FontWeight? fontWeight = FontWeight.w500,}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        registerText(text: title, color: color, fontWeight: fontWeight),
        normalTextField(
            hintText: hintText,
            controller: controller,
            inputType: TextInputType.text,
            onChanged: onChanged,
            validator: validator,
            fontWeight: FontWeight.w400,
            prefix: false,
            errorMessage: '',
            hasError: error,
            maxLines: 6),
      ],
    );
  }
}
