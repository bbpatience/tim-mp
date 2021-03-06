import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:myapp/utils/functions.dart';
import 'package:myapp/utils/object_util.dart';

class DialogUtil {
  static buildToast(String str) {
    Fluttertoast.showToast(
        msg: str,
        toastLength: Toast.LENGTH_SHORT,
        gravity: ToastGravity.CENTER,
        timeInSecForIos: 1,
        backgroundColor: Colors.red[300],
        textColor: Colors.lightBlue[50]);
  }

  static buildSnakeBar(BuildContext context, String str) {
    final snackBar = new SnackBar(
        content: new Text(str),
        duration: Duration(milliseconds: 1500),
        backgroundColor: Colors.blue);
    Scaffold.of(context).showSnackBar(snackBar);
  }

  //如果context在Scaffold之前，弹不出请用这个
  static buildSnakeBarByKey(String str, GlobalKey<ScaffoldState> key) {
    final snackBar = new SnackBar(
        content: new Text(str),
        duration: Duration(milliseconds: 1500),
        backgroundColor: Colors.blue);
    key.currentState.showSnackBar(snackBar);
  }

  /*
  * 普通dialog
  */
  static showBaseDialog(BuildContext context, String content,
      {String left = 'OK',
      String right = 'Cancel',
      OnItemClick leftClick,
      OnItemClick rightClick}) {
    showDialog(
        context: context,
        barrierDismissible: true,
        builder: (BuildContext context) => new AlertDialog(
                shape: RoundedRectangleBorder(
                    side: BorderSide.none,
                    borderRadius: BorderRadius.all(Radius.circular(10))),
                contentPadding: EdgeInsets.fromLTRB(20, 10, 20, 0),
                content:
                    new Text(content, style: new TextStyle(fontSize: 20.0)),
                actions: <Widget>[
                  ObjectUtil.isEmpty(left)
                      ? SizedBox(
                          width: 0,
                          height: 15,
                        )
                      : FlatButton(
                          child: new Text(
                            left,
                            style:
                                TextStyle(color: Colors.black, fontSize: 16.0),
                          ),
                          onPressed: () {
                            Navigator.of(context).pop();
                            if (null != leftClick) {
                              leftClick(null);
                            }
                          },
                          shape: new RoundedRectangleBorder(
                              borderRadius: new BorderRadius.circular(20.0)),
                        ),
                  ObjectUtil.isEmpty(right)
                      ? SizedBox(
                          width: 0,
                          height: 15,
                        )
                      : FlatButton(
                          child: new Text(
                            right,
                            style:
                                TextStyle(color: Colors.black, fontSize: 16.0),
                          ),
                          onPressed: () {
                            Navigator.of(context).pop();
                            if (null != rightClick) {
                              rightClick(null);
                            }
                          },
                          shape: new RoundedRectangleBorder(
                              borderRadius: new BorderRadius.circular(20.0)),
                        )
                ]));
  }
}
