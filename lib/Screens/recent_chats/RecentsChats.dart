//*************   © Copyrighted by Thinkcreative_Technologies. An Exclusive item of Envato market. Make sure you have purchased a Regular License OR Extended license for the Source Code from Envato to use this product. See the License Defination attached with source code. *********************

import 'dart:async';
import 'dart:convert';
import 'dart:core';
import 'dart:developer';
import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:collection/collection.dart';
import 'package:fiberchat/Configs/Dbkeys.dart';
import 'package:fiberchat/Configs/Dbpaths.dart';
import 'package:fiberchat/Configs/app_constants.dart';
import 'package:fiberchat/Screens/Groups/AddContactsToGroup.dart';
import 'package:fiberchat/Screens/Groups/GroupChatPage.dart';
import 'package:fiberchat/Screens/contact_screens/SmartContactsPage.dart';
import 'package:fiberchat/Screens/homepage/homepage.dart';
import 'package:fiberchat/Services/Admob/admob.dart';
import 'package:fiberchat/Services/Providers/BroadcastProvider.dart';
import 'package:fiberchat/Services/Providers/GroupChatProvider.dart';
import 'package:fiberchat/Services/Providers/Observer.dart';
import 'package:fiberchat/Services/localization/language_constants.dart';
import 'package:fiberchat/Screens/chat_screen/utils/messagedata.dart';
import 'package:fiberchat/Screens/call_history/callhistory.dart';
import 'package:fiberchat/Screens/chat_screen/chat.dart';
import 'package:fiberchat/Models/DataModel.dart';
import 'package:fiberchat/Services/Providers/user_provider.dart';
import 'package:fiberchat/Utils/alias.dart';
import 'package:fiberchat/Utils/chat_controller.dart';
import 'package:fiberchat/Utils/utils.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:scoped_model/scoped_model.dart';
import 'package:fiberchat/Utils/unawaited.dart';

class RecentChats extends StatefulWidget {
  RecentChats(
      {required this.currentUserNo,
      required this.isSecuritySetupDone,
      required this.prefs,
      required this.isPinUnPinBtnShow,
      key})
      : super(key: key);
  final String? currentUserNo;
  final SharedPreferences prefs;
  final bool isSecuritySetupDone;
  Function(bool) isPinUnPinBtnShow;

  @override
  State createState() =>
      new RecentChatsState(currentUserNo: this.currentUserNo);
}

class RecentChatsState extends State<RecentChats> {
  RecentChatsState({Key? key, this.currentUserNo}) {
    _filter.addListener(() {
      _userQuery.add(_filter.text.isEmpty ? '' : _filter.text);
    });
  }

  final TextEditingController _filter = new TextEditingController();
  bool isAuthenticating = false;

  List<StreamSubscription> unreadSubscriptions = [];
  List<StreamController> controllers = [];
  final BannerAd myBanner = BannerAd(
    adUnitId: getBannerAdUnitId()!,
    size: AdSize.banner,
    request: AdRequest(),
    listener: BannerAdListener(),
  );
  AdWidget? adWidget;

  @override
  void initState() {
    super.initState();
    Fiberchat.internetLookUp();
    print("RecentChatsState  ==>  RecentChatsState");
    WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
      final observer = Provider.of<Observer>(this.context, listen: false);
      if (IsBannerAdShow == true && observer.isadmobshow == true) {
        myBanner.load();
        adWidget = AdWidget(ad: myBanner);
        setState(() {});
      }
    });
  }

  getuid(BuildContext context) {
    final UserProvider userProvider =
        Provider.of<UserProvider>(context, listen: false);
    userProvider.getUserDetails(currentUserNo);
  }

  void cancelUnreadSubscriptions() {
    unreadSubscriptions.forEach((subscription) {
      subscription.cancel();
    });
  }

  DataModel? _cachedModel;
  bool showHidden = false, biometricEnabled = false;

  String? currentUserNo;

  bool isLoading = false;

  Widget buildItem(BuildContext context, Map<String, dynamic> user) {
    String userKey = user["key"].toString();
    if (user[Dbkeys.phone] == currentUserNo) {
      return Container(width: 0, height: 0);
    } else {
      return StreamBuilder(
        stream: getUnread(user).asBroadcastStream(),
        builder: (context, AsyncSnapshot<MessageData> unreadData) {
          int unread = unreadData.hasData &&
                  unreadData.data!.snapshot.docs.isNotEmpty
              ? unreadData.data!.snapshot.docs
                  .where((t) => t[Dbkeys.timestamp] > unreadData.data!.lastSeen)
                  .length
              : 0;
          return Theme(
              data: ThemeData(
                  splashColor: fiberchatBlue,
                  highlightColor: Colors.transparent),
              child: Column(
                children: [
                  ListTile(
                    contentPadding: EdgeInsets.fromLTRB(20, 8, 20, 8),
                    onLongPress: () {
                      selectedUser.add(userKey);
                      setState(() {});
                      widget.isPinUnPinBtnShow(selectedUser.isNotEmpty);
                      // unawaited(showDialog(
                      //     context: context,
                      //     builder: (context) {
                      //       return AliasForm(user, _cachedModel);
                      //     }));
                    },
                    leading: Stack(
                      alignment: Alignment.bottomRight,
                      children: [
                        customCircleAvatar(url: user['photoUrl'], radius: 22),
                        if (selectedUser.contains(userKey))
                          Container(
                            padding: EdgeInsets.all(2),
                            decoration: BoxDecoration(
                              color: Colors.blue,
                              shape: BoxShape.circle,
                            ),
                            child: Icon(
                              Icons.check,
                              color: Colors.white,
                              size: 15,
                            ),
                          )
                      ],
                    ),
                    title: Row(
                      children: [
                        Expanded(
                          child: Text(
                            Fiberchat.getNickname(user)!,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                              color: fiberchatBlack,
                              fontSize: 16,
                            ),
                          ),
                        ),
                        unread != 0
                            ? Container(
                                child: Text(unread.toString(),
                                    style: TextStyle(
                                        fontSize: 14,
                                        color: Colors.white,
                                        fontWeight: FontWeight.bold)),
                                padding: const EdgeInsets.all(7.0),
                                decoration: new BoxDecoration(
                                  shape: BoxShape.circle,
                                  color: user[Dbkeys.lastSeen] == true
                                      ? Colors.green[400]
                                      : Colors.blue[400],
                                ),
                              )
                            : user[Dbkeys.lastSeen] == true
                                ? Container(
                                    child: Container(width: 0, height: 0),
                                    padding: const EdgeInsets.all(7.0),
                                    decoration: new BoxDecoration(
                                        shape: BoxShape.circle,
                                        color: Colors.green[400]),
                                  )
                                : SizedBox(
                                    height: 0,
                                    width: 0,
                                  ),
                      ],
                    ),
                    onTap: () {
                      if (selectedUser.isNotEmpty) {
                        _userSelectUnSelect(userKey: userKey);
                        return;
                      }
                      if (_cachedModel!.currentUser![Dbkeys.locked] != null &&
                          _cachedModel!.currentUser![Dbkeys.locked]
                              .contains(user[Dbkeys.phone])) {
                        if (widget.prefs.getString(Dbkeys.isPINsetDone) !=
                                currentUserNo ||
                            widget.prefs.getString(Dbkeys.isPINsetDone) ==
                                null) {
                          ChatController.unlockChat(
                              currentUserNo, user[Dbkeys.phone] as String?);
                          Navigator.push(
                              context,
                              new MaterialPageRoute(
                                  builder: (context) => new ChatScreen(
                                      isSharingIntentForwarded: false,
                                      prefs: widget.prefs,
                                      unread: unread,
                                      model: _cachedModel!,
                                      currentUserNo: currentUserNo,
                                      peerNo: user[Dbkeys.phone] as String?)));
                        } else {
                          NavigatorState state = Navigator.of(context);
                          ChatController.authenticate(_cachedModel!,
                              getTranslated(context, 'auth_neededchat'),
                              state: state,
                              shouldPop: false,
                              type: Fiberchat.getAuthenticationType(
                                  biometricEnabled, _cachedModel),
                              prefs: widget.prefs, onSuccess: () {
                            state.pushReplacement(new MaterialPageRoute(
                                builder: (context) => new ChatScreen(
                                    isSharingIntentForwarded: false,
                                    prefs: widget.prefs,
                                    unread: unread,
                                    model: _cachedModel!,
                                    currentUserNo: currentUserNo,
                                    peerNo: user[Dbkeys.phone] as String?)));
                          });
                        }
                      } else {
                        Navigator.push(
                            context,
                            new MaterialPageRoute(
                                builder: (context) => new ChatScreen(
                                    isSharingIntentForwarded: false,
                                    prefs: widget.prefs,
                                    unread: unread,
                                    model: _cachedModel!,
                                    currentUserNo: currentUserNo,
                                    peerNo: user[Dbkeys.phone] as String?)));
                      }
                    },
                    subtitle: (user[Dbkeys.isPin] ?? false)
                        ? Row(
                            mainAxisAlignment: MainAxisAlignment.end,
                            children: [
                              if (user[Dbkeys.isPin] ?? false)
                               _chatPin(),
                            ],
                          )
                        : null,
                  ),
                  Divider(
                    height: 0,
                  ),
                ],
              ));
        },
      );
    }
  }

  void _userSelectUnSelect({String? userKey}) {
    if (userKey == null) {
      return;
    }
    if (selectedUser.contains(userKey)) {
      selectedUser.remove(userKey);
    } else {
      selectedUser.add(userKey);
    }
    setState(() {});
    widget.isPinUnPinBtnShow(selectedUser.isNotEmpty);
  }

  Stream<MessageData> getUnread(Map<String, dynamic> user) {
    String chatId = Fiberchat.getChatId(currentUserNo, user[Dbkeys.phone]);
    var controller = StreamController<MessageData>.broadcast();
    unreadSubscriptions.add(FirebaseFirestore.instance
        .collection(DbPaths.collectionmessages)
        .doc(chatId)
        .snapshots()
        .listen((doc) {
      if (doc[currentUserNo!] != null && doc[currentUserNo!] is int) {
        unreadSubscriptions.add(FirebaseFirestore.instance
            .collection(DbPaths.collectionmessages)
            .doc(chatId)
            .collection(chatId)
            .snapshots()
            .listen((snapshot) {
          controller.add(
              MessageData(snapshot: snapshot, lastSeen: doc[currentUserNo!]));
        }));
      }
    }));
    controllers.add(controller);
    return controller.stream;
  }

  _isHidden(phoneNo) {
    Map<String, dynamic> _currentUser = _cachedModel!.currentUser!;
    return _currentUser[Dbkeys.hidden] != null &&
        _currentUser[Dbkeys.hidden].contains(phoneNo);
  }

  StreamController<String> _userQuery =
      new StreamController<String>.broadcast();

  List<Map<String, dynamic>> _streamDocSnap = [];

  _chats(Map<String?, Map<String, dynamic>?> _userData,
      Map<String, dynamic>? currentUser) {
    return Consumer<List<GroupModel>>(
        builder: (context, groupList, _child) => Consumer<List<BroadcastModel>>(
                builder: (context, broadcastList, _child) {
              _streamDocSnap.clear();

              Map.from(_userData).forEach((key, value) {
                if ((value).containsKey(Dbkeys.chatStatus)) {
                  value["key"] = key;
                  if (!pinUserList.contains(key)) {
                    value[Dbkeys.isPin] = false;
                    value[Dbkeys.priorityIndex] =
                        ((_userData.keys.length + 20) * 200);
                  } else {
                    value[Dbkeys.priorityIndex] =
                        pinUserList.indexOf(key.toString());
                    value[Dbkeys.isPin] = true;
                  }
                  _streamDocSnap.add(value as Map<String, dynamic>);
                }
              });
              Map<String?, int?> _lastSpokenAt = _cachedModel!.lastSpokenAt;
              List<Map<String, dynamic>> filtered =
                  List.from(<Map<String, dynamic>>[]);
              groupList.forEach((element) {
                log("message groupList ==>   ${element.docmap}");
                element.docmap["key"] = element.docmap["id"];
                if (pinUserList.contains(element.docmap["id"])) {
                  element.docmap[Dbkeys.priorityIndex] =
                      pinUserList.indexOf(element.docmap["id"]);
                  element.docmap[Dbkeys.isPin] = true;
                } else {
                  element.docmap[Dbkeys.priorityIndex] =
                      ((_userData.keys.length + 20) * 200);
                  element.docmap[Dbkeys.isPin] = false;
                }
                _streamDocSnap.add(element.docmap);
              });
              broadcastList.forEach((element) {
                element.docmap["key"] = element.docmap["id"];
                if (pinUserList.contains(element.docmap["id"])) {
                  element.docmap[Dbkeys.priorityIndex] =
                      pinUserList.indexOf(element.docmap["id"]);
                  element.docmap[Dbkeys.isPin] = true;
                } else {
                  element.docmap[Dbkeys.priorityIndex] =
                      ((_userData.keys.length + 20) * 200);
                  element.docmap[Dbkeys.isPin] = false;
                }
                _streamDocSnap.add(element.docmap);
              });
              _streamDocSnap.sort((a, b) {
                int aTimestamp = a.containsKey(Dbkeys.groupISTYPINGUSERID)
                    ? a[Dbkeys.groupLATESTMESSAGETIME]
                    : a.containsKey(Dbkeys.broadcastBLACKLISTED)
                        ? a[Dbkeys.broadcastLATESTMESSAGETIME]
                        : _lastSpokenAt[a[Dbkeys.phone]] ?? 0;
                int bTimestamp = b.containsKey(Dbkeys.groupISTYPINGUSERID)
                    ? b[Dbkeys.groupLATESTMESSAGETIME]
                    : b.containsKey(Dbkeys.broadcastBLACKLISTED)
                        ? b[Dbkeys.broadcastLATESTMESSAGETIME]
                        : _lastSpokenAt[b[Dbkeys.phone]] ?? 0;
                return bTimestamp - aTimestamp;
              });

              List<Map<String, dynamic>> tempData = [];
//               tempData.addAll(_streamDocSnap);
              _streamDocSnap.sort((a, b) {
                log(" aTimestamp  ==>  ${a} \n\n\n\n\n ${b} ");

                int aTimestamp = a[Dbkeys.priorityIndex];
                int bTimestamp = b[Dbkeys.priorityIndex];
                return aTimestamp.compareTo(bTimestamp);
              });

              if (!showHidden) {
                _streamDocSnap.removeWhere((_user) =>
                    !_user.containsKey(Dbkeys.groupISTYPINGUSERID) &&
                    !_user.containsKey(Dbkeys.broadcastBLACKLISTED) &&
                    _isHidden(_user[Dbkeys.phone]));
              }

              return ListView(
                physics: const BouncingScrollPhysics(
                    parent: AlwaysScrollableScrollPhysics()),
                shrinkWrap: true,
                children: [
                  Container(
                      child: _streamDocSnap.isNotEmpty
                          ? StreamBuilder(
                              stream: _userQuery.stream.asBroadcastStream(),
                              builder: (context, snapshot) {
                                if (_filter.text.isNotEmpty ||
                                    snapshot.hasData) {
                                  filtered = this._streamDocSnap.where((user) {
                                    return user[Dbkeys.nickname]
                                        .toLowerCase()
                                        .trim()
                                        .contains(new RegExp(r'' +
                                            _filter.text.toLowerCase().trim() +
                                            ''));
                                  }).toList();
                                  if (filtered.isNotEmpty)
                                    return ListView.builder(
                                      physics: AlwaysScrollableScrollPhysics(),
                                      shrinkWrap: true,
                                      padding: EdgeInsets.all(10.0),
                                      itemBuilder: (context, index) {
                                        return buildItem(
                                            context, filtered.elementAt(index));
                                      },
                                      itemCount: filtered.length,
                                    );
                                  else
                                    return ListView(
                                        physics:
                                            AlwaysScrollableScrollPhysics(),
                                        shrinkWrap: true,
                                        children: [
                                          Padding(
                                              padding: EdgeInsets.only(
                                                  top: MediaQuery.of(context)
                                                          .size
                                                          .height /
                                                      3.5),
                                              child: Center(
                                                child: Text(
                                                    getTranslated(context,
                                                        'nosearchresult'),
                                                    textAlign: TextAlign.center,
                                                    style: TextStyle(
                                                      fontSize: 18,
                                                      color: fiberchatGrey,
                                                    )),
                                              ))
                                        ]);
                                }
                                return ListView.builder(
                                  physics: NeverScrollableScrollPhysics(),
                                  shrinkWrap: true,
                                  padding: EdgeInsets.fromLTRB(0, 10, 0, 120),
                                  itemBuilder: (context, index) {
                                    if (_streamDocSnap[index].containsKey(
                                        Dbkeys.groupISTYPINGUSERID)) {
                                      ///----- Build Group Chat Tile ----
                                      String groupKey = _streamDocSnap[index]
                                              ["key"]
                                          .toString();

                                      return Theme(
                                          data: ThemeData(
                                              splashColor: fiberchatBlue,
                                              highlightColor:
                                                  Colors.transparent),
                                          child: Column(
                                            children: [
                                              ListTile(
                                                contentPadding:
                                                    EdgeInsets.fromLTRB(
                                                        20, 0, 20, 0),
                                                leading: Stack(
                                                  alignment:
                                                      Alignment.bottomRight,
                                                  children: [
                                                    customCircleAvatarGroup(
                                                        url: _streamDocSnap[
                                                                index][
                                                            Dbkeys
                                                                .groupPHOTOURL],
                                                        radius: 22),
                                                    if (selectedUser
                                                        .contains(groupKey))
                                                      Container(
                                                        padding:
                                                            EdgeInsets.all(2),
                                                        decoration:
                                                            BoxDecoration(
                                                          color: Colors.blue,
                                                          shape:
                                                              BoxShape.circle,
                                                        ),
                                                        child: Icon(
                                                          Icons.check,
                                                          color: Colors.white,
                                                          size: 15,
                                                        ),
                                                      )
                                                  ],
                                                ),
                                                title: Row(
                                                  children: [
                                                    Expanded(
                                                      child: Text(
                                                        _streamDocSnap[index]
                                                            [Dbkeys.groupNAME],
                                                        maxLines: 1,
                                                        overflow:
                                                            TextOverflow.ellipsis,
                                                        style: TextStyle(
                                                          color: fiberchatBlack,
                                                          fontSize: 16,
                                                        ),
                                                      ),
                                                    ),
                                                    StreamBuilder(
                                                      stream: FirebaseFirestore
                                                          .instance
                                                          .collection(DbPaths
                                                          .collectiongroups)
                                                          .doc(_streamDocSnap[index]
                                                      [Dbkeys.groupID])
                                                          .collection(DbPaths
                                                          .collectiongroupChats)
                                                          .where(
                                                          Dbkeys.groupmsgTIME,
                                                          isGreaterThan:
                                                          _streamDocSnap[
                                                          index][
                                                          widget
                                                              .currentUserNo])
                                                          .snapshots(),
                                                      builder:
                                                          (BuildContext context,
                                                          AsyncSnapshot<
                                                              QuerySnapshot<
                                                                  dynamic>>
                                                          snapshot) {
                                                        if (snapshot
                                                            .connectionState ==
                                                            ConnectionState
                                                                .waiting) {
                                                          return SizedBox(
                                                            height: 0,
                                                            width: 0,
                                                          );
                                                        } else if (snapshot
                                                            .hasData &&
                                                            snapshot.data!.docs
                                                                .length >
                                                                0) {
                                                          return Container(
                                                            child: Text(
                                                                '${snapshot.data!.docs.length}',
                                                                style: TextStyle(
                                                                    fontSize: 14,
                                                                    color: Colors
                                                                        .white,
                                                                    fontWeight:
                                                                    FontWeight
                                                                        .bold)),
                                                            padding:
                                                            const EdgeInsets
                                                                .all(7.0),
                                                            decoration:
                                                            new BoxDecoration(
                                                              shape:
                                                              BoxShape.circle,
                                                              color:
                                                              Colors.blue[400],
                                                            ),
                                                          );
                                                        }
                                                        return SizedBox(
                                                          height: 0,
                                                          width: 0,
                                                        );
                                                      },
                                                    ),
                                                  ],
                                                ),
                                                subtitle: Row(
                                                  children: [
                                                    Expanded(
                                                      child: Text(
                                                        '${_streamDocSnap[index][Dbkeys.groupMEMBERSLIST].length} ${getTranslated(context, 'participants')}',
                                                        style: TextStyle(
                                                          color: fiberchatGrey,
                                                          fontSize: 14,
                                                        ),
                                                      ),
                                                    ),
                                                    if (_streamDocSnap[index][Dbkeys.isPin] ?? false)
                                                      _chatPin(),
                                                  ],
                                                ),
                                                onLongPress: () {
                                                  _userSelectUnSelect(
                                                      userKey: groupKey);
                                                  setState(() {});
                                                  widget.isPinUnPinBtnShow(
                                                      selectedUser.isNotEmpty);
                                                },
                                                onTap: () {
                                                  if (selectedUser.isNotEmpty) {
                                                    _userSelectUnSelect(
                                                        userKey: groupKey);
                                                    return;
                                                  }
                                                  Navigator.push(
                                                      context,
                                                      new MaterialPageRoute(
                                                          builder: (context) => new GroupChatPage(
                                                              isSharingIntentForwarded:
                                                                  false,
                                                              model:
                                                                  _cachedModel!,
                                                              prefs:
                                                                  widget.prefs,
                                                              joinedTime:
                                                                  _streamDocSnap[
                                                                          index]
                                                                      [
                                                                      '${widget.currentUserNo}-joinedOn'],
                                                              currentUserno: widget
                                                                  .currentUserNo!,
                                                              groupID:
                                                                  _streamDocSnap[
                                                                          index]
                                                                      [Dbkeys
                                                                          .groupID])));
                                                },
                                              ),
                                              Divider(
                                                height: 0,
                                              ),
                                            ],
                                          ));
                                    } else {
                                      return buildItem(context,
                                          _streamDocSnap.elementAt(index));
                                    }
                                  },
                                  itemCount: _streamDocSnap.length,
                                );
                              })
                          : ListView(
                              physics: NeverScrollableScrollPhysics(),
                              shrinkWrap: true,
                              padding: EdgeInsets.all(0),
                              children: [
                                  Padding(
                                      padding: EdgeInsets.only(
                                          top: MediaQuery.of(context)
                                                  .size
                                                  .height /
                                              3.5),
                                      child: Center(
                                        child: Padding(
                                            padding: EdgeInsets.all(30.0),
                                            child: Text(
                                                groupList.length != 0
                                                    ? ''
                                                    : getTranslated(
                                                        context, 'startchat'),
                                                textAlign: TextAlign.center,
                                                style: TextStyle(
                                                  fontSize: 16,
                                                  height: 1.59,
                                                  color: fiberchatGrey,
                                                ))),
                                      ))
                                ])),
                ],
              );
            }));
  }

  Widget buildGroupitem() {
    return Text(
      Dbkeys.groupNAME,
      maxLines: 1,
      overflow: TextOverflow.ellipsis,
    );
  }

  DataModel? getModel() {
    _cachedModel ??= DataModel(currentUserNo);
    return _cachedModel;
  }

  @override
  void dispose() {
    super.dispose();

    if (IsBannerAdShow == true) {
      myBanner.dispose();
    }
  }

  @override
  Widget build(BuildContext context) {
    final observer = Provider.of<Observer>(this.context, listen: false);
    return Fiberchat.getNTPWrappedWidget(ScopedModel<DataModel>(
      model: getModel()!,
      child:
          ScopedModelDescendant<DataModel>(builder: (context, child, _model) {
        _cachedModel = _model;
        return Scaffold(
          bottomSheet: IsBannerAdShow == true &&
                  observer.isadmobshow == true &&
                  adWidget != null
              ? Container(
                  height: 60,
                  margin: EdgeInsets.only(
                      bottom: Platform.isIOS == true ? 25.0 : 5, top: 0),
                  child: Center(child: adWidget),
                )
              : SizedBox(
                  height: 0,
                ),
          backgroundColor: fiberchatWhite,
          floatingActionButton: Padding(
            padding: EdgeInsets.only(
                bottom: IsBannerAdShow == true && observer.isadmobshow == true
                    ? 60
                    : 0),
            child: FloatingActionButton(
              backgroundColor: fiberchatLightGreen,
              child: Icon(
                Icons.chat,
                size: 30.0,
              ),
              onPressed: () {
                Navigator.push(
                    context,
                    new MaterialPageRoute(
                        builder: (context) => new SmartContactsPage(
                            onTapCreateGroup: () {
                              if (observer.isAllowCreatingGroups == false) {
                                Fiberchat.showRationale(
                                    getTranslated(this.context, 'disabled'));
                              } else {
                                Navigator.pushReplacement(
                                    context,
                                    MaterialPageRoute(
                                        builder: (context) =>
                                            AddContactsToGroup(
                                              currentUserNo:
                                                  widget.currentUserNo,
                                              model: _cachedModel,
                                              biometricEnabled: false,
                                              prefs: widget.prefs,
                                              isAddingWhileCreatingGroup: true,
                                            )));
                              }
                            },
                            prefs: widget.prefs,
                            biometricEnabled: biometricEnabled,
                            currentUserNo: currentUserNo!,
                            model: _cachedModel!)));
              },
            ),
          ),
          body: RefreshIndicator(
            onRefresh: () {
              isAuthenticating = !isAuthenticating;
              setState(() {
                showHidden = !showHidden;
              });
              return Future.value(true);
            },
            child: _chats(_model.userData, _model.currentUser),
          ),
        );
      }),
    ));
  }

  Widget _chatPin(){
    return Image.asset(
      "assets/images/chatPin.png",
      width: 15,
      height: 15,
      color: Colors.grey,
    );
  }
}
