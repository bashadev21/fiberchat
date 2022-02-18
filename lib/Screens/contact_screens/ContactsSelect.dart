//*************   © Copyrighted by Thinkcreative_Technologies. An Exclusive item of Envato market. Make sure you have purchased a Regular License OR Extended license for the Source Code from Envato to use this product. See the License Defination attached with source code. *********************

import 'package:contacts_service/contacts_service.dart';
import 'package:fiberchat/Configs/Dbkeys.dart';
import 'package:fiberchat/Configs/Enum.dart';
import 'package:fiberchat/Configs/app_constants.dart';
import 'package:fiberchat/Screens/calling_screen/pickup_layout.dart';
import 'package:fiberchat/Services/Providers/AvailableContactsProvider.dart';
import 'package:fiberchat/Services/localization/language_constants.dart';
import 'package:fiberchat/Models/DataModel.dart';
import 'package:fiberchat/Utils/open_settings.dart';
import 'package:fiberchat/Utils/utils.dart';
import 'package:flutter/material.dart';
import 'dart:async';
import 'package:localstorage/localstorage.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:provider/provider.dart';
import 'package:scoped_model/scoped_model.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ContactsSelect extends StatefulWidget {
  const ContactsSelect({
    required this.currentUserNo,
    required this.model,
    required this.biometricEnabled,
    required this.prefs,
    required this.onSelect,
  });
  final String? currentUserNo;
  final DataModel? model;
  final SharedPreferences? prefs;
  final bool biometricEnabled;
  final Function(String? contactname, String contactphone) onSelect;

  @override
  _ContactsSelectState createState() => new _ContactsSelectState();
}

class _ContactsSelectState extends State<ContactsSelect>
    with AutomaticKeepAliveClientMixin {
  Map<String?, String?>? contacts;
  Map<String?, String?> _filtered = new Map<String, String>();
  String _query = "";

  @override
  bool get wantKeepAlive => true;

  final TextEditingController _filter = new TextEditingController();

  @override
  void dispose() {
    super.dispose();
    _filter.dispose();
  }

  loading() {
    return Stack(children: [
      Container(
        child: Center(
            child: CircularProgressIndicator(
          valueColor: AlwaysStoppedAnimation<Color>(fiberchatBlue),
        )),
      )
    ]);
  }

  @override
  initState() {
    super.initState();
     getContacts();
    // WidgetsBinding.instance!.addPostFrameCallback((timeStamp) {
      WidgetsBinding.instance!.addPostFrameCallback((timeStamp) {
        setInitial(context);
      });
    // });


  }
  setInitial(BuildContext context) {
    final AvailableContactsProvider contactsProvider =
    Provider.of<AvailableContactsProvider>(context, listen: false);
    contactsProvider.setIsLoading(true);
    _appBarTitle = new Text(
      getTranslated(context, 'selectsinglecontact'),
      style: TextStyle(
        fontSize: 18.0,
        fontWeight: FontWeight.w600,
        color:
        DESIGN_TYPE == Themetype.whatsapp ? fiberchatWhite : fiberchatBlack,
      ),
    );
    Future.delayed(const Duration(milliseconds: 500), () {
      setStateIfMounted(() {
        _filtered = contactsProvider.filtered!;
      });

      contactsProvider.setIsLoading(false);
    });

    _filter.addListener(() {
      if (_filter.text.isEmpty) {
        setState(() async {
          _query = "";
          this._filtered = await getContacts(refresh: true);
        });
      } else {
        setState(() {
          _query = _filter.text;
          this._filtered =
              Map.fromEntries(this.contacts!.entries.where((MapEntry contact) {
                return contact.value
                    .toLowerCase()
                    .trim()
                    .contains(new RegExp(r'' + _query.toLowerCase().trim() + ''));
              }));
        });
      }
    });
  }
  void setStateIfMounted(f) {
    if (mounted) setState(f);
  }

  String? getNormalizedNumber(String number) {
    if (number.isEmpty) {
      return null;
    }

    return number.replaceAll(new RegExp('[^0-9+]'), '');
  }

  _isHidden(String? phoneNo) {
    Map<String, dynamic> _currentUser = widget.model!.currentUser!;
    return _currentUser[Dbkeys.hidden] != null &&
        _currentUser[Dbkeys.hidden].contains(phoneNo);
  }

  Future<Map<String?, String?>> getContacts({bool refresh = false}) async {
    Completer<Map<String?, String?>> completer =
        new Completer<Map<String?, String?>>();

    LocalStorage storage = LocalStorage(Dbkeys.cachedContacts);

    Map<String?, String?> _cachedContacts = {};

    completer.future.then((c) {
      c.removeWhere((key, val) => _isHidden(key));
      if (mounted) {
        setState(() {
          this.contacts = this._filtered = c;
        });
      }
    });

    Fiberchat.checkAndRequestPermission(Permission.contacts).then((res) {
      if (res) {
        storage.ready.then((ready) async {
          if (ready) {
            String? getNormalizedNumber(String? number) {
              if (number == null) return null;
              return number.replaceAll(new RegExp('[^0-9+]'), '');
            }

            ContactsService.getContacts(withThumbnails: false)
                .then((Iterable<Contact> contacts) async {
              contacts.where((c) => c.phones!.isNotEmpty).forEach((Contact p) {
                if (p.displayName != null && p.phones!.isNotEmpty) {
                  List<String?> numbers = p.phones!
                      .map((number) {
                        String? _phone = getNormalizedNumber(number.value);

                        return _phone;
                      })
                      .toList()
                      .where((s) => s != null)
                      .toList();

                  numbers.forEach((number) {
                    _cachedContacts[number] = p.displayName;
                    setState(() {});
                  });
                  setState(() {});
                }
              });

              // await storage.setItem(Dbkeys.cachedContacts, _cachedContacts);
              completer.complete(_cachedContacts);
            });
          }
          // }
        });
      } else {
        Fiberchat.showRationale(getTranslated(context, 'perm_contact'));
        Navigator.pushReplacement(context,
            new MaterialPageRoute(builder: (context) => OpenSettings()));
      }
    }).catchError((onError) {
      Fiberchat.showRationale('Error occured: $onError');
    });

    return completer.future;
  }

  Widget _appBarTitle = Text('');
  Icon _searchIcon = new Icon(
    Icons.search,
    color: DESIGN_TYPE == Themetype.whatsapp ? fiberchatWhite : fiberchatBlack,
  );
  void _searchPressed() {
    setState(() {
      if (this._searchIcon.icon == Icons.search) {
        this._searchIcon = new Icon(
          Icons.close,
          color: DESIGN_TYPE == Themetype.whatsapp
              ? fiberchatWhite
              : fiberchatBlack,
        );
        this._appBarTitle = new TextField(
          textCapitalization: TextCapitalization.sentences,
          autofocus: true,
          style: TextStyle(
            color: DESIGN_TYPE == Themetype.whatsapp
                ? fiberchatWhite
                : fiberchatBlack,
            fontSize: 18.5,
            fontWeight: FontWeight.w600,
          ),
          controller: _filter,
          decoration: new InputDecoration(
              labelStyle: TextStyle(
                color: DESIGN_TYPE == Themetype.whatsapp
                    ? fiberchatWhite
                    : fiberchatBlack,
              ),
              hintText: getTranslated(context, 'search'),
              hintStyle: TextStyle(
                fontSize: 18.5,
                color: DESIGN_TYPE == Themetype.whatsapp
                    ? fiberchatWhite.withOpacity(0.7)
                    : fiberchatGrey,
              )),
        );
      } else {
        this._searchIcon = new Icon(
          Icons.search,
          color: DESIGN_TYPE == Themetype.whatsapp
              ? fiberchatWhite
              : fiberchatBlack,
        );
        this._appBarTitle = new Text(
          getTranslated(context, 'searchcontact'),
          style: TextStyle(
            fontSize: 18.5,
            color: DESIGN_TYPE == Themetype.whatsapp
                ? fiberchatWhite
                : fiberchatBlack,
          ),
        );

        _filter.clear();
      }
    });
    setState(() {});
  }
  @override
  Widget build(BuildContext context) {
    super.build(context);

    return PickupLayout(
        scaffold: Fiberchat.getNTPWrappedWidget(ScopedModel<DataModel>(
            model: widget.model!,
            child: ScopedModelDescendant<DataModel>(
                builder: (context, child, model) {
              return Consumer<AvailableContactsProvider>(
                  builder: (context, contactsProvider, _child) => Scaffold(
                      backgroundColor: fiberchatWhite,
                      appBar: AppBar(

                        leading: IconButton(
                          onPressed: () {
                            Navigator.of(context).pop();
                          },
                          icon: Icon(
                            Icons.keyboard_arrow_left,
                            size: 30,
                            color: DESIGN_TYPE == Themetype.whatsapp
                                ? fiberchatWhite
                                : fiberchatBlack,
                          ),
                        ),
                        backgroundColor: DESIGN_TYPE == Themetype.whatsapp
                            ? fiberchatDeepGreen
                            : fiberchatWhite,
                        centerTitle: false,
                        title: _appBarTitle,
                        actions: <Widget>[
                          IconButton(
                            icon: _searchIcon,
                            onPressed: _searchPressed,
                          )
                        ],
                      ),
                      body: contacts == null
                          ? loading()
                          : RefreshIndicator(
                              onRefresh: () {
                                return getContacts(refresh: true);
                              },
                              child: _filtered.isEmpty
                                  ? ListView(children: [
                                      Padding(
                                          padding: EdgeInsets.only(
                                              top: MediaQuery.of(context)
                                                      .size
                                                      .height /
                                                  2.5),
                                          child: Center(
                                            child: Text(
                                                getTranslated(
                                                    context, 'nosearchresult'),
                                                textAlign: TextAlign.center,
                                                style: TextStyle(
                                                  fontSize: 18,
                                                  color: fiberchatBlack,
                                                )),
                                          ))
                                    ])
                                  : ListView.builder(
                                      padding: EdgeInsets.all(10),
                                      itemCount: _filtered.length,
                                      itemBuilder: (context, idx) {
                                        MapEntry user =
                                            _filtered.entries.elementAt(idx);
                                        String phone = user.key;
                                        return FutureBuilder(
                                            future: contactsProvider
                                                .getUserDoc(phone),
                                            builder: (BuildContext context,
                                                AsyncSnapshot snapshot) {
                                              if (snapshot.hasData) {
                                                var userDoc =
                                                    snapshot.data!.data();
                                                return ListTile(
                                                  leading: CircleAvatar(
                                                      backgroundColor:
                                                          fiberchatgreen,
                                                      radius: 22.5,
                                                      child: Text(
                                                        Fiberchat.getInitials(
                                                            userDoc[Dbkeys
                                                                .nickname]),
                                                        style: TextStyle(
                                                            color:
                                                                fiberchatWhite),
                                                      )),
                                                  title: Text(
                                                      userDoc[Dbkeys.nickname],
                                                      style: TextStyle(
                                                          color:
                                                              fiberchatBlack)),
                                                  subtitle: Text(phone,
                                                      style: TextStyle(
                                                          color:
                                                              fiberchatGrey)),
                                                  contentPadding:
                                                      EdgeInsets.symmetric(
                                                          horizontal: 10.0,
                                                          vertical: 0.0),
                                                  onTap: () {
                                                    Navigator.of(context).pop();
                                                    widget.onSelect(
                                                        user.value, phone);
                                                  },
                                                );
                                              }
                                              return ListTile(
                                                leading: CircleAvatar(
                                                    backgroundColor:
                                                        fiberchatgreen,
                                                    radius: 22.5,
                                                    child: Text(
                                                      Fiberchat.getInitials(
                                                          user.value),
                                                      style: TextStyle(
                                                          color:
                                                              fiberchatWhite),
                                                    )),
                                                title: Text(user.value,
                                                    style: TextStyle(
                                                        color: fiberchatBlack)),
                                                subtitle: Text(phone,
                                                    style: TextStyle(
                                                        color: fiberchatGrey)),
                                                contentPadding:
                                                    EdgeInsets.symmetric(
                                                        horizontal: 10.0,
                                                        vertical: 0.0),
                                                onTap: () {
                                                  Navigator.of(context).pop();
                                                  widget.onSelect(
                                                      user.value, phone);
                                                },
                                              );
                                            });
                                      },
                                    ))));
            }))));
  }
}
