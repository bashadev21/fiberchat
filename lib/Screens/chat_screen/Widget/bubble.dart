//*************   © Copyrighted by Thinkcreative_Technologies. An Exclusive item of Envato market. Make sure you have purchased a Regular License OR Extended license for the Source Code from Envato to use this product. See the License Defination attached with source code. *********************

import 'package:fiberchat/Configs/Dbkeys.dart';
import 'package:fiberchat/Configs/app_constants.dart';
import 'package:fiberchat/Screens/chat_screen/chat.dart';
import 'package:fiberchat/Services/Providers/seen_provider.dart';
import 'package:fiberchat/Services/localization/language_constants.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:fiberchat/Configs/Enum.dart';

class Bubble extends StatelessWidget {
  const Bubble({
    required this.child,
    required this.timestamp,
    required this.delivered,
    required this.isMe,
    required this.isContinuing,
    required this.messagetype,
    this.isBroadcastMssg,
    required this.isMssgDeleted,
    required this.is24hrsFormat,
    required this.isMsgStar,
    required this.mssgDoc,
    required this.refresh,
  });

  final dynamic messagetype;
  final int? timestamp;
  final Widget child;
  final dynamic delivered;
  final bool isMe, isContinuing, isMssgDeleted;
  final bool? isBroadcastMssg;
  final bool is24hrsFormat;
  final bool isMsgStar;
  final Map<String, dynamic> mssgDoc;
  final Function refresh;

  humanReadableTime() => DateFormat(is24hrsFormat == true ? 'HH:mm' : 'h:mm a')
      .format(DateTime.fromMillisecondsSinceEpoch(timestamp!));

  getSeenStatus(seen) {
    if (seen is bool) return true;
    if (seen is String) return true;
    return timestamp! <= seen;
  }

  @override
  Widget build(BuildContext context) {
    final bool seen = getSeenStatus(SeenProvider.of(context).value);
    final bg = isMe ? fiberchatteagreen : fiberchatWhite;
    final align = isMe ? CrossAxisAlignment.end : CrossAxisAlignment.start;
    dynamic icon = delivered is bool && delivered
        ? (seen ? Icons.done_all : Icons.done)
        : Icons.access_time;
    final color = isMe
        ? fiberchatBlack.withOpacity(0.5)
        : fiberchatBlack.withOpacity(0.5);
    icon = Icon(icon, size: 14.0, color: seen ? Colors.lightBlue : color);
    if (delivered is Future) {
      icon = FutureBuilder(
          future: delivered,
          builder: (context, res) {
            switch (res.connectionState) {
              case ConnectionState.done:
                return Icon((seen ? Icons.done_all : Icons.done),
                    size: 13.0, color: seen ? Colors.lightBlue : color);
              case ConnectionState.none:
              case ConnectionState.active:
              case ConnectionState.waiting:
              default:
                return Icon(Icons.access_time,
                    size: 13.0, color: seen ? Colors.lightBlue : color);
            }
          });
    }
    dynamic radius = isMe
        ? BorderRadius.only(
            topLeft: Radius.circular(5.0),
            bottomLeft: Radius.circular(5.0),
            bottomRight: Radius.circular(10.0),
          )
        : BorderRadius.only(
            topRight: Radius.circular(5.0),
            bottomLeft: Radius.circular(10.0),
            bottomRight: Radius.circular(5.0),
          );
    dynamic margin = const EdgeInsets.only(top: 20.0, bottom: 1.5);
    if (isContinuing) {
      radius = BorderRadius.all(Radius.circular(5.0));
      margin = const EdgeInsets.all(1.9);
    }

    return SingleChildScrollView(
        child: Column(
      crossAxisAlignment: align,
      children: <Widget>[
        Row(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            if (align == CrossAxisAlignment.start) _selectedMessage(),
            Container(
              margin: margin,
              padding: const EdgeInsets.all(8.0),
              constraints: BoxConstraints(
                  maxWidth: MediaQuery.of(context).size.width * 0.67),
              decoration: BoxDecoration(
                color: bg,
                borderRadius: radius,
              ),
              child: Stack(
                children: <Widget>[
                  isMssgDeleted == true
                      ? deletedMessageWidget(
                          isMe, isBroadcastMssg, context, is24hrsFormat)
                      : Padding(
                          padding: this.messagetype == null ||
                                  this.messagetype == MessageType.location ||
                                  this.messagetype == MessageType.image ||
                                  this.messagetype == MessageType.text
                              ? child is Container ||
                                      mssgDoc.containsKey(Dbkeys.isReply) ==
                                          true
                                  ? mssgDoc[Dbkeys.isReply] == true ||
                                          child is Container
                                      ? EdgeInsets.fromLTRB(0, 0, 0, 17)
                                      : EdgeInsets.only(
                                          right: (this.messagetype ==
                                                      MessageType.location
                                                  ? 0
                                                  : isMe
                                                      ? isBroadcastMssg ==
                                                                  null ||
                                                              isBroadcastMssg ==
                                                                  false
                                                          ? is24hrsFormat
                                                              ? 45
                                                              : 65
                                                          : is24hrsFormat
                                                              ? 62
                                                              : 81.0
                                                      : isBroadcastMssg ==
                                                                  null ||
                                                              isBroadcastMssg ==
                                                                  false
                                                          ? is24hrsFormat
                                                              ? 33
                                                              : 48
                                                          : is24hrsFormat
                                                              ? 48
                                                              : 60.0) +
                                              (isMsgStar ? 20 : 0))
                                  : EdgeInsets.only(
                                      right: (this.messagetype ==
                                                  MessageType.location
                                              ? 0
                                              : isMe
                                                  ? isBroadcastMssg == null ||
                                                          isBroadcastMssg ==
                                                              false
                                                      ? is24hrsFormat
                                                          ? 45
                                                          : 65
                                                      : is24hrsFormat
                                                          ? 62
                                                          : 81.0
                                                  : isBroadcastMssg == null ||
                                                          isBroadcastMssg ==
                                                              false
                                                      ? is24hrsFormat
                                                          ? 33
                                                          : 48
                                                      : is24hrsFormat
                                                          ? 48
                                                          : 60.0) +
                                          (isMsgStar ? 0 : 0))
                              : child is Container
                                  ? EdgeInsets.all(0.0)
                                  : EdgeInsets.only(right: 5.0, bottom: 20),
                          child: child),
                  Positioned(
                    bottom: 0.0,
                    right: 0.0,
                    child: Row(
                        children: <Widget>[
                      isBroadcastMssg == null || isBroadcastMssg == false
                          ? Container(
                              height: 0,
                              width: 0,
                            )
                          : Padding(
                              padding: EdgeInsets.fromLTRB(3, 0, 3, 0),
                              child: Icon(
                                Icons.campaign,
                                size: 14.3,
                                color: color,
                              ),
                            ),
                      if (isMsgStar)
                        Icon(
                          Icons.star,
                          size: 18,
                        ),
                      Text(humanReadableTime().toString() + (isMe ? ' ' : ''),
                          style: TextStyle(
                            color: color,
                            fontSize: 10.0,
                          )),
                      isMe ? icon : SizedBox()
                      // ignore: unnecessary_null_comparison
                    ].where((o) => o != null).toList()),
                  ),
                ],
              ),
            ),
            if (align == CrossAxisAlignment.end) _selectedMessage()
          ],
        )
      ],
    ));
  }

  Widget _selectedMessage() {
    if (selectedMessageDocs.isNotEmpty) {
      return InkWell(
      onTap: (){
        if(selectedMessageDocs.contains(mssgDoc)){
          selectedMessageDocs.remove(mssgDoc);
        }else{
          selectedMessageDocs.add(mssgDoc);
        }
        refresh();
      },
        child: Padding(
          padding: EdgeInsets.only(left: 5, right: 5, bottom: 5),
          child: !selectedMessageDocs.contains(mssgDoc)
              ? Container(
                  width: 24,
                  height: 24,
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(color: Colors.blue, width: 2)))
              : Icon(
                Icons.check_circle,
                size: 24,
                color: Colors.blue,
              ),
        ),
      );
    } else {
      return SizedBox(width: 0, height: 0);
    }
  }
}

Widget deletedMessageWidget(bool isMe, bool? isBroadcastMssg,
    BuildContext context, bool is24hrsFormat) {
  return Padding(
    padding: EdgeInsets.only(
        right: isMe
            ? isBroadcastMssg == null || isBroadcastMssg == false
                ? is24hrsFormat
                    ? 48
                    : 60
                : is24hrsFormat
                    ? 73
                    : 81
            : isBroadcastMssg == null || isBroadcastMssg == false
                ? is24hrsFormat
                    ? 38
                    : 55
                : is24hrsFormat
                    ? 48
                    : 50),
    child: Text(
      getTranslated(context, 'msgdeleted'),
      textAlign: isMe ? TextAlign.right : TextAlign.left,
      style: TextStyle(
          fontSize: 15.0, fontStyle: FontStyle.italic, color: Colors.black45),
    ),
  );
}
