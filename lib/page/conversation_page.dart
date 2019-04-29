import 'dart:async';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:myapp/base/base_state.dart';
import 'package:myapp/database/db_api.dart';
import 'package:myapp/entity/conversation_entity.dart';
import 'package:myapp/entity/message_entity.dart';
import 'package:myapp/page/message_page.dart';
import 'package:myapp/page/more_widgets.dart';
import 'package:myapp/utils/constants.dart';
import 'package:myapp/utils/date_util.dart';
import 'package:myapp/utils/interact_vative.dart';

class ConversationPage extends StatefulWidget {
  ConversationPage({Key key, this.rootContext}) : super(key: key);
  final BuildContext rootContext;

  @override
  State<StatefulWidget> createState() {
    return new Conversation();
  }
}

class Conversation extends BaseState<ConversationPage> with WidgetsBindingObserver {
  var map = Map();
  var list = new List();
  bool isShowNoPage = false;
  Timer _refreshTimer;
  AppLifecycleState currentState = AppLifecycleState.resumed;
  GlobalKey<ScaffoldState> _key = new GlobalKey<ScaffoldState>();//TODO

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _getData();
    _startRefresh();
  }

  @override
  Widget build(BuildContext context) {
    return layout(context);
  }

  Widget layout(BuildContext context) {
    return new Scaffold(
        key: _key,
        appBar: MoreWidgets.buildAppBar(context, 'Messages'),
        body: new Stack(
          children: <Widget>[
            new Offstage(
              offstage: isShowNoPage,
              child: ListView.builder(
                  itemBuilder: (BuildContext context, int index) {
                    return _itemWidget(index);
                  },
                  itemCount: list.length),
            ),
            new Offstage(
              offstage: !isShowNoPage,
              child: MoreWidgets.buildNoDataPage(), //显示loading，则禁掉返回按钮和右滑关闭
            )
          ],
        ));
  }

  Widget _itemWidget(int index) {
    Widget res;
    ConversationEntity entity = map[list.elementAt(index).toString()];
    String timeTmp = DateUtil.getDateStrByDateTime(DateUtil.getDateTimeByMs(entity.timestamp));
    String time = DateUtil.formatDateTime(timeTmp, DateFormat.YEAR_MONTH_DAY, '/', '');

    res = MoreWidgets.conversationListViewItem(
        entity.name == null ? entity.targetUid : entity.name, 
        entity.conversationType,
        content: entity.lastMessage,
        time: time,
        unread: entity.isUnreadCount, onItemClick: (res) {
      if (entity.conversationType == Constants.CONVERSATION_SINGLE) {
        //聊天消息，跳转聊天对话页面
        Navigator.push(
            context,
            new CupertinoPageRoute<void>(
                builder: (ctx) => MessagePage(
                      title: entity.name == null ? entity.targetUid : entity.name,
                      targetUid: entity.targetUid,
                      convId: entity.id,
                    )));
      }
    });
    return res;
  }

  _getData() async {
    //display no page.
    setState(() {
      list.clear();
      map.clear();
      isShowNoPage = true;
    });
  }

  /*
  * 定时刷新
  */
  _startRefresh() {
    _refreshTimer =
        Timer.periodic(const Duration(milliseconds: 1000 * 60), _handleTime);
  }

  _handleTime(Timer timer) {
    //当APP在前台，且当前页是0（即本页），则刷新
    if (null != currentState &&
        currentState != AppLifecycleState.paused) {
      setState(() {
        print('refresh data');
      });
    }
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    // TODO: implement didChangeAppLifecycleState
    super.didChangeAppLifecycleState(state);
    //initState后，未调用，所以初始化为resume，当APP进入后台，则为onPause；APP进入前台，为resume
    currentState = state;
    if (currentState == AppLifecycleState.resumed) {
      setState(() {});
    }
  }

  @override
  void dispose() {
    // TODO: implement dispose
    if (null != _refreshTimer) {
      _refreshTimer.cancel();
    }
    super.dispose();
    WidgetsBinding.instance.removeObserver(this);
  }

  @override
  // TODO: implement wantKeepAlive
  bool get wantKeepAlive => true;

  @override
  void updateData(MessageEntity entity) {

  }
  
  @override
  void notify(Object type) {
    if (type == InteractNative.PULL_CONVERSATION) {
      list.clear();
      map.clear();

      DataBaseApi.get().getConversationEntities().then((conversations) => {
        DataBaseApi.get().getAllContactsEntities().then((contacts) {
          var contactsMap = new Map();
          contacts.forEach((contact) => contactsMap[contact.userId] = contact.userName);
          conversations.forEach((entity) {
            if (contactsMap.containsKey(entity.targetUid)) {
              entity.name = contactsMap[entity.targetUid];
            }
            list.insert(0, entity.targetUid);//TODO  group?
            map[entity.targetUid] = entity;
          });
          setState(() {
            isShowNoPage = conversations.length <= 0;
          });
      })
      });  
    }
  }
}
