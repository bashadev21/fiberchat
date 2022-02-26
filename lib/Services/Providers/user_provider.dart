//*************   © Copyrighted by Thinkcreative_Technologies. An Exclusive item of Envato market. Make sure you have purchased a Regular License OR Extended license for the Source Code from Envato to use this product. See the License Defination attached with source code. *********************

import 'dart:convert';
import 'dart:developer';
import 'dart:io';
import 'package:dio/dio.dart';
import 'package:http/http.dart' as http;
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:device_info/device_info.dart';
import 'package:fiberchat/Configs/Dbkeys.dart';
import 'package:fiberchat/Configs/Dbpaths.dart';
import 'package:fiberchat/Configs/Enum.dart';
import 'package:fiberchat/Configs/app_constants.dart';
import 'package:fiberchat/Screens/homepage/homepage.dart';
import 'package:fiberchat/Services/localization/language.dart';
import 'package:fiberchat/Services/localization/language_constants.dart';
import 'package:fiberchat/Utils/phonenumberVariantsGenerator.dart';
import 'package:fiberchat/Utils/unawaited.dart';
import 'package:fiberchat/Utils/utils.dart';
import 'package:fiberchat/main.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:fiberchat/Models/E2EE/e2ee.dart' as e2ee;

class UserProvider with ChangeNotifier {
  var currentIndex = 0;
  PageController controller =
      PageController(viewportFraction: 1, keepPage: true);

  final TextEditingController refCode = TextEditingController();
  final TextEditingController mobile = TextEditingController();
  final TextEditingController email = TextEditingController();
  final TextEditingController otp = TextEditingController();
  final TextEditingController firstname = TextEditingController();
  final TextEditingController lastname = TextEditingController();

  final FirebaseAuth firebaseAuth = FirebaseAuth.instance;
  String codeverify = "";
  final usermobile = TextEditingController();

  // final _smsCode = TextEditingController();
  final username = TextEditingController();
  final otpfield = TextEditingController();

  String? phoneCode = DEFAULT_COUNTTRYCODE_NUMBER;
  final storage = new FlutterSecureStorage();
  DeviceInfoPlugin deviceInfo = DeviceInfoPlugin();

  int _currentStep = 0;

  String? verificationId;
  bool isLoading = false;
  bool isLoading2 = true;
  bool isverficationsent = false;
  dynamic isLoggedIn = false;
  User? currentUser;
  String? deviceid;
  var mapDeviceInfo = {};
  String currentCallToken = '';
  int currentCallUID = 0;

  getCurrentCallToken() {
    return currentCallToken;
  }

  getCurrentCallUID() {
    return currentCallUID;
  }

  getRTCToken() async {

    var response = await Dio().post('https://rudr-agora-rtc-token-gen.herokuapp.com/rtctoken', 
    data: {
      // "isPublisher": false,
      "channel": "Punk Panda"
    });
    
    if (response.statusCode == 200) {

      print('RTC TOKEN RECIEVED:');
      print(response.data['token']);

      // Update Token in User Provider
      currentCallToken = response.data['token'];
      currentCallUID = response.data['uid'];
    }
    else {
      Fiberchat.toast('some error occurred');
    }
  }

  setdeviceinfo() async {
    if (Platform.isAndroid == true) {
      AndroidDeviceInfo androidInfo = await deviceInfo.androidInfo;

      deviceid = androidInfo.id + androidInfo.androidId;
      mapDeviceInfo = {
        Dbkeys.deviceInfoMODEL: androidInfo.model,
        Dbkeys.deviceInfoOS: 'android',
        Dbkeys.deviceInfoISPHYSICAL: androidInfo.isPhysicalDevice,
        Dbkeys.deviceInfoDEVICEID: androidInfo.id,
        Dbkeys.deviceInfoOSID: androidInfo.androidId,
        Dbkeys.deviceInfoOSVERSION: androidInfo.version.baseOS,
        Dbkeys.deviceInfoMANUFACTURER: androidInfo.manufacturer,
        Dbkeys.deviceInfoLOGINTIMESTAMP: DateTime.now(),
      };
      notifyListeners();
    } else if (Platform.isIOS == true) {
      IosDeviceInfo iosInfo = await deviceInfo.iosInfo;

      deviceid = iosInfo.systemName + iosInfo.model + iosInfo.systemVersion;
      mapDeviceInfo = {
        Dbkeys.deviceInfoMODEL: iosInfo.model,
        Dbkeys.deviceInfoOS: 'ios',
        Dbkeys.deviceInfoISPHYSICAL: iosInfo.isPhysicalDevice,
        Dbkeys.deviceInfoDEVICEID: iosInfo.identifierForVendor,
        Dbkeys.deviceInfoOSID: iosInfo.name,
        Dbkeys.deviceInfoOSVERSION: iosInfo.name,
        Dbkeys.deviceInfoMANUFACTURER: iosInfo.name,
        Dbkeys.deviceInfoLOGINTIMESTAMP: DateTime.now(),
      };
      notifyListeners();
    }
  }

  Language? seletedlanguage;

  Future<void> verifyPhoneNumber(context, isaccountapprovalbyadminneeded,
      accountApprovalMessage, prefs, issecutitysetupdone) async {
    isLoading = true;
    final PhoneVerificationCompleted verificationCompleted =
        (AuthCredential phoneAuthCredential) {
      handleSignIn(
        context,
        isaccountapprovalbyadminneeded,
        accountApprovalMessage,
        prefs,
        issecutitysetupdone,
        authCredential: phoneAuthCredential,
      );
    };

    final PhoneVerificationFailed verificationFailed =
        (FirebaseAuthException authException) {
      isLoading = false;
      isLoading2 = false;
      _currentStep = 0;
      usermobile.clear();
      // codeverify = '';
      isverficationsent = false;
      notifyListeners();
      print(
          'Authentication failed -ERROR: ${authException.message}. Try again later.');

      Fiberchat.toast('Authentication failed - ${authException.message}');
    };

    final PhoneCodeSent codeSent =
        (String verificationId, [int? forceResendingToken]) async {
          this.verificationId = verificationId;
      isLoading = false;
      isLoading2 = false;
      isverficationsent = true;
      notifyListeners();
      controller.animateToPage(2,
          duration: Duration(milliseconds: 500), curve: Curves.ease);

    };

    final PhoneCodeAutoRetrievalTimeout codeAutoRetrievalTimeout =
        (String verificationId) {
      isLoading = false;
      isLoading2 = false;
      isverficationsent = false;
      notifyListeners();

      // this.verificationId = verificationId;
    };
log("(phoneCode! + usermobile.text).trim()  ==>  ${(phoneCode! + usermobile.text).trim()}");
    await firebaseAuth.verifyPhoneNumber(
        phoneNumber: (phoneCode! + usermobile.text).trim(),
        timeout: const Duration(seconds: 60),
        verificationCompleted: verificationCompleted,
        verificationFailed: verificationFailed,
        codeSent: codeSent,
        codeAutoRetrievalTimeout: codeAutoRetrievalTimeout);
  }

  subscribeToNotification(String currentUserNo, bool isFreshNewAccount) async {
    await FirebaseMessaging.instance
        .subscribeToTopic(
            '${currentUserNo.replaceFirst(new RegExp(r'\+'), '')}')
        .catchError((err) {
      print('ERROR SUBSCRIBING NOTIFICATION' + err.toString());
    });
    await FirebaseMessaging.instance
        .subscribeToTopic(Dbkeys.topicUSERS)
        .catchError((err) {
      print('ERROR SUBSCRIBING NOTIFICATION' + err.toString());
    });
    await FirebaseMessaging.instance
        .subscribeToTopic(Platform.isAndroid
            ? Dbkeys.topicUSERSandroid
            : Platform.isIOS
                ? Dbkeys.topicUSERSios
                : Dbkeys.topicUSERSweb)
        .catchError((err) {
      print('ERROR SUBSCRIBING NOTIFICATION' + err.toString());
    });

    if (isFreshNewAccount == false) {
      await FirebaseFirestore.instance
          .collection(DbPaths.collectiongroups)
          .where(Dbkeys.groupMEMBERSLIST, arrayContains: currentUserNo)
          .get()
          .then((query) async {
        if (query.docs.length > 0) {
          query.docs.forEach((doc) async {
            await FirebaseMessaging.instance
                .subscribeToTopic(
                    "GROUP${doc[Dbkeys.groupID].replaceAll(RegExp('-'), '').substring(1, doc[Dbkeys.groupID].replaceAll(RegExp('-'), '').toString().length)}")
                .catchError((err) {
              print('ERROR SUBSCRIBING NOTIFICATION' + err.toString());
            });
          });
        }
      });
    }
  }

  Future checkInvitation() async {
    var url = Uri.parse(
        'http://www.pandasapi.com/panda_chat/api/check_ref_code?ref_code=${refCode.text}');

    var response = await http.get(
      url,
    );

    var jsonBody = response.body;
    var data = json.decode(jsonBody);
    if (response.statusCode == 200) {
      if (data['status'] == 'SUCCESS') {
        controller.animateToPage(1,
            duration: Duration(milliseconds: 500), curve: Curves.ease);
      } else {
        Fiberchat.toast(data['msg']);
      }
      notifyListeners();
    } else {
      notifyListeners();
    }
  }

  Future<Null> handleSignIn(context, isaccountapprovalbyadminneeded,
      accountApprovalMessage, prefs, issecutitysetupdone,
      {AuthCredential? authCredential}) async {
    // if (isLoading == false) {
    //   isLoading = true;
    //   notifyListeners();
    // }

    var phoneNo = (phoneCode! + usermobile.text).trim();

    AuthCredential credential;
    print(
        "verificationId ==>   $verificationId \n\n$codeverify \n\n $authCredential");
    await firebaseAuth.signOut();
    if (authCredential == null)
      credential = PhoneAuthProvider.credential(
        verificationId: verificationId!,
        smsCode: codeverify,
      );
    else
      credential = authCredential;
    UserCredential firebaseUser;
    firebaseUser = await firebaseAuth
        .signInWithCredential(credential)
        .catchError((err) async {
          log("error  ==>  $err");
      if (err == null) {
      } else {
        if (err.toString().contains('return a value') ||
            err.toString().contains('null') ||
            err == null ||
            err.toString().contains('return') ||
            err.toString().contains('closure') ||
            err.toString().contains('Closure') ||
            err.toString().contains('arguments')) {
        } else {
          Fiberchat.toast(getTranslated(context, 'makesureotp'));

          _currentStep = 0;
          usermobile.clear();
          // codeverify = '';
          isLoading = false;
          isLoading2 = false;
          notifyListeners();
        }
      }
    });
    // return;
    // ignore: unnecessary_null_comparison
    if (firebaseUser != null) {
      // Check is already sign up
      final QuerySnapshot result = await FirebaseFirestore.instance
          .collection(DbPaths.collectionusers)
          .where(Dbkeys.id, isEqualTo: firebaseUser.user!.uid)
          .get();
      final List documents = result.docs;
      final pair = await e2ee.X25519().generateKeyPair();

      if (documents.isEmpty) {
        await storage.write(
            key: Dbkeys.privateKey, value: pair.secretKey.toBase64());
        // Update data to server if new user
        await FirebaseFirestore.instance
            .collection(DbPaths.collectionusers)
            .doc(phoneNo)
            .set({
          Dbkeys.publicKey: pair.publicKey.toBase64(),
          Dbkeys.privateKey: pair.secretKey.toBase64(),
          Dbkeys.countryCode: phoneCode,
          Dbkeys.nickname: username.text.trim(),
          Dbkeys.photoUrl: firebaseUser.user!.photoURL ?? '',
          Dbkeys.id: firebaseUser.user!.uid,
          Dbkeys.phone: phoneNo,
          Dbkeys.phoneRaw: usermobile.text,
          Dbkeys.authenticationType: AuthenticationType.passcode.index,
          Dbkeys.aboutMe: '',
          //---Additional fields added for Admin app compatible----
          Dbkeys.accountstatus: isaccountapprovalbyadminneeded == true
              ? Dbkeys.sTATUSpending
              : Dbkeys.sTATUSallowed,
          Dbkeys.actionmessage: accountApprovalMessage,
          Dbkeys.lastLogin: DateTime.now().millisecondsSinceEpoch,
          Dbkeys.joinedOn: DateTime.now().millisecondsSinceEpoch,
          Dbkeys.searchKey: username.text.trim().substring(0, 1).toUpperCase(),
          Dbkeys.videoCallMade: 0,
          Dbkeys.videoCallRecieved: 0,
          Dbkeys.audioCallMade: 0,
          Dbkeys.groupsCreated: 0,
          Dbkeys.blockeduserslist: [],
          Dbkeys.audioCallRecieved: 0,
          Dbkeys.mssgSent: 0,
          Dbkeys.deviceDetails: mapDeviceInfo,
          Dbkeys.currentDeviceID: deviceid,
          Dbkeys.phonenumbervariants: phoneNumberVariantsList(
              countrycode: phoneCode, phonenumber: usermobile.text)
        }, SetOptions(merge: true));
        currentUser = firebaseUser.user;
        await FirebaseFirestore.instance
            .collection(DbPaths.collectiondashboard)
            .doc(DbPaths.docuserscount)
            .set(
                isaccountapprovalbyadminneeded == false
                    ? {
                        Dbkeys.totalapprovedusers: FieldValue.increment(1),
                      }
                    : {
                        Dbkeys.totalpendingusers: FieldValue.increment(1),
                      },
                SetOptions(merge: true));

        await FirebaseFirestore.instance
            .collection(DbPaths.collectioncountrywiseData)
            .doc(phoneCode)
            .set({
          Dbkeys.totalusers: FieldValue.increment(1),
        }, SetOptions(merge: true));

        await FirebaseFirestore.instance
            .collection(DbPaths.collectionnotifications)
            .doc(DbPaths.adminnotifications)
            .update({
          Dbkeys.nOTIFICATIONxxaction: 'PUSH',
          Dbkeys.nOTIFICATIONxxdesc: isaccountapprovalbyadminneeded == true
              ? '${username.text.trim()} has Joined $Appname. APPROVE the user account. You can view the user profile from All Users List.'
              : '${username.text.trim()} has Joined $Appname. You can view the user profile from All Users List.',
          Dbkeys.nOTIFICATIONxxtitle: 'New User Joined',
          Dbkeys.nOTIFICATIONxximageurl: null,
          Dbkeys.nOTIFICATIONxxlastupdate: DateTime.now(),
          'list': FieldValue.arrayUnion([
            {
              Dbkeys.docid: DateTime.now().millisecondsSinceEpoch.toString(),
              Dbkeys.nOTIFICATIONxxdesc: isaccountapprovalbyadminneeded == true
                  ? '${username.text.trim()} has Joined $Appname. APPROVE the user account. You can view the user profile from All Users List.'
                  : '${username.text.trim()} has Joined $Appname. You can view the user profile from All Users List.',
              Dbkeys.nOTIFICATIONxxtitle: 'New User Joined',
              Dbkeys.nOTIFICATIONxximageurl: null,
              Dbkeys.nOTIFICATIONxxlastupdate: DateTime.now(),
              Dbkeys.nOTIFICATIONxxauthor: currentUser!.uid + 'XXX' + 'userapp',
            }
          ])
        });

        // Write data to local
        await prefs.setString(Dbkeys.id, currentUser!.uid);
        await prefs.setString(Dbkeys.nickname, username.text.trim());
        await prefs.setString(Dbkeys.photoUrl, currentUser!.photoURL ?? '');
        await prefs.setString(Dbkeys.phone, phoneNo);
        await prefs.setString(Dbkeys.countryCode, phoneCode!);
        String? fcmToken = await FirebaseMessaging.instance.getToken();

        await FirebaseFirestore.instance
            .collection(DbPaths.collectionusers)
            .doc(phoneNo)
            .set({
          Dbkeys.notificationTokens: [fcmToken]
        }, SetOptions(merge: true));
        unawaited(prefs.setBool(Dbkeys.isTokenGenerated, true));

        // unawaited(Navigator.pushReplacement(
        //     this.context,
        //     MaterialPageRoute(
        //         builder: (context) => Security(
        //               phoneNo,
        //               prefs: widget.prefs,
        //               setPasscode: true,
        //               onSuccess: (newContext) async {
        unawaited(Navigator.pushReplacement(
            context,
            MaterialPageRoute(
                builder: (newContext) => Homepage(
                      currentUserNo: phoneNo,
                      isSecuritySetupDone: true,
                      prefs: prefs,
                    ))));
        await prefs.setString(Dbkeys.isSecuritySetupDone, phoneNo);
        await subscribeToNotification(documents[0][Dbkeys.phone], true);

        //   },
        //   title: getTranslated(this.context, 'authh'),
        // ))));
      } else {
        await storage.write(
            key: Dbkeys.privateKey, value: documents[0][Dbkeys.privateKey]);
        String? fcmToken = await FirebaseMessaging.instance.getToken();

        // await FirebaseFirestore.instance
        //     .collection(DbPaths.collectionusers)
        //     .doc(currentUserNo)
        //     .set({
        //   Dbkeys.notificationTokens: [fcmToken],
        //   Dbkeys.deviceDetails: mapDeviceInfo,
        //   Dbkeys.currentDeviceID: deviceid,
        //   // Dbkeys.phonenumbervariants: phoneNumberVariantsList(
        //   //     countrycode: userDoc[Dbkeys.countryCode],
        //   //     phonenumber: userDoc[Dbkeys.phoneRaw])
        // }, SetOptions(merge: true));
        // unawaited(widget.prefs.setBool(Dbkeys.isTokenGenerated, true));
        await FirebaseFirestore.instance
            .collection(DbPaths.collectionusers)
            .doc(phoneNo)
            .update(
              !documents[0].data().containsKey(Dbkeys.deviceDetails)
                  ? {
                      Dbkeys.authenticationType:
                          AuthenticationType.passcode.index,
                      Dbkeys.accountstatus:
                          isaccountapprovalbyadminneeded == true
                              ? Dbkeys.sTATUSpending
                              : Dbkeys.sTATUSallowed,
                      Dbkeys.actionmessage: accountApprovalMessage,
                      Dbkeys.lastLogin: DateTime.now().millisecondsSinceEpoch,
                      Dbkeys.joinedOn:
                          documents[0].data()![Dbkeys.lastSeen] != true
                              ? documents[0].data()![Dbkeys.lastSeen]
                              : DateTime.now().millisecondsSinceEpoch,
                      Dbkeys.nickname: username.text.trim(),
                      Dbkeys.searchKey:
                          username.text.trim().substring(0, 1).toUpperCase(),
                      Dbkeys.videoCallMade: 0,
                      Dbkeys.videoCallRecieved: 0,
                      Dbkeys.audioCallMade: 0,
                      Dbkeys.audioCallRecieved: 0,
                      Dbkeys.mssgSent: 0,
                      Dbkeys.deviceDetails: mapDeviceInfo,
                      Dbkeys.currentDeviceID: deviceid,
                      Dbkeys.phonenumbervariants: phoneNumberVariantsList(
                          countrycode: documents[0][Dbkeys.countryCode],
                          phonenumber: documents[0][Dbkeys.phoneRaw]),
                      Dbkeys.notificationTokens: [fcmToken],
                    }
                  : {
                      Dbkeys.searchKey:
                          username.text.trim().substring(0, 1).toUpperCase(),
                      Dbkeys.nickname: username.text.trim(),
                      Dbkeys.authenticationType:
                          AuthenticationType.passcode.index,
                      Dbkeys.lastLogin: DateTime.now().millisecondsSinceEpoch,
                      Dbkeys.deviceDetails: mapDeviceInfo,
                      Dbkeys.currentDeviceID: deviceid,
                      Dbkeys.phonenumbervariants: phoneNumberVariantsList(
                          countrycode: documents[0][Dbkeys.countryCode],
                          phonenumber: documents[0][Dbkeys.phoneRaw]),
                      Dbkeys.notificationTokens: [fcmToken],
                    },
            );
        // Write data to local
        await prefs.setString(Dbkeys.id, documents[0][Dbkeys.id]);
        await prefs.setString(Dbkeys.nickname, username.text.trim());
        await prefs.setString(
            Dbkeys.photoUrl, documents[0][Dbkeys.photoUrl] ?? '');
        await prefs.setString(
            Dbkeys.aboutMe, documents[0][Dbkeys.aboutMe] ?? '');
        await prefs.setString(Dbkeys.phone, documents[0][Dbkeys.phone]);

        if (issecutitysetupdone == false ||
            // ignore: unnecessary_null_comparison
            issecutitysetupdone == null) {
          // unawaited(Navigator.pushReplacement(
          //     this.context,
          //     MaterialPageRoute(
          // builder: (context) => Security(
          //               phoneNo,
          //               prefs: widget.prefs,
          //               setPasscode: true,
          //               onSuccess: (newContext) async {
          unawaited(Navigator.pushReplacement(
              context,
              MaterialPageRoute(
                  builder: (newContext) => Homepage(
                        currentUserNo: phoneNo,
                        isSecuritySetupDone: true,
                        prefs: prefs,
                      ))));
          await prefs.setString(Dbkeys.isSecuritySetupDone, phoneNo);
          await subscribeToNotification(phoneNo, false);

          //   },
          //   title: getTranslated(this.context, 'authh'),
          // ))));
        } else {
          unawaited(Navigator.pushReplacement(context,
              new MaterialPageRoute(builder: (context) => FiberchatWrapper())));
          Fiberchat.toast(getTranslated(context, 'welcomeback'));
          await subscribeToNotification(documents[0][Dbkeys.phone], false);
        }
      }
    } else {
      Fiberchat.toast(getTranslated(context, 'failedlogin'));
    }
  }

  UserModel? _user;

  UserModel? get getUser => _user;

  getUserDetails(String? phone) async {
    DocumentSnapshot documentSnapshot = await FirebaseFirestore.instance
        .collection(DbPaths.collectionusers)
        .doc(phone)
        .get();

    _user = UserModel.fromMap(documentSnapshot.data() as Map<String, dynamic>);
    notifyListeners();
  }
}

class UserModel {
  String? uid;
  String? name;
  String? phone;
  String? username;
  String? status;
  int? state;
  String? profilePhoto;

  UserModel({
    this.uid,
    this.name,
    this.phone,
    this.username,
    this.status,
    this.state,
    this.profilePhoto,
  });

  Map toMap(UserModel user) {
    var data = Map<String, dynamic>();
    data['id'] = user.uid;
    data['nickname'] = user.name;
    data['phone'] = user.phone;
    data["photoUrl"] = user.profilePhoto;
    return data;
  }

  // Named constructor
  UserModel.fromMap(Map<String, dynamic> mapData) {
    this.uid = mapData['id'];
    this.name = mapData['nickname'];
    this.phone = mapData['phone'];
    this.profilePhoto = mapData['photoUrl'];
  }
}
