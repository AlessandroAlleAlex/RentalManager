import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart'; // IOS的Cupertino控件库
import 'package:flutter/foundation.dart'; //一个用于识别操作系统的工具库，其内的defaultTargetPlatform值可帮助我们识别操作系统
import '../globals.dart' as globals;

String NAME = "Team Cowculator";

final ThemeData kIOSTheme = new ThemeData(
  primarySwatch: Colors.orange,
  primaryColor: Colors.grey[100],
  primaryColorBrightness: Brightness.light,
);


final ThemeData kDefaultTheme = new ThemeData(
    primarySwatch: Colors.purple, accentColor: Colors.orangeAccent[400]);

class ThirdTab extends StatelessWidget {

  @override
  Widget build(BuildContext context) {
    return new MaterialApp(
        title: "Help",

        theme: defaultTargetPlatform == TargetPlatform.iOS
            ? kIOSTheme
            : kDefaultTheme,
        home: new ChatScreen());
  }
}

// 聊天页面的主界面
class ChatScreen extends StatefulWidget {
  @override
  State createState() => new ChatScreenState();
}

// 单个聊天的界面无状态
class ChatMessage extends StatelessWidget {
  final String text;
  final AnimationController animationController;
  ChatMessage({this.text, this.animationController});

  @override
  Widget build(BuildContext context) {
    return new SizeTransition(
        sizeFactor: new CurvedAnimation(
            parent: animationController, curve: Curves.easeInOut),
        axisAlignment: 0.0,
        child: new Container(
          margin: const EdgeInsets.symmetric(vertical: 10.0),
          child: new Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              new Container(
                  margin: const EdgeInsets.only(right: 16.0),
                  child: new CircleAvatar(child: new Text(NAME[0]))),
              new Expanded(
                  child: new Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      new Text(NAME, style: Theme.of(context).textTheme.subhead),
                      new Container(
                          margin: const EdgeInsets.only(top: 5.0),
                          child: new Text(text))
                    ],
                  ))
            ],
          ),
        ));
  }
}


class ChatScreenState extends State<ChatScreen> with TickerProviderStateMixin {

  final List<ChatMessage> chatMessages = <ChatMessage>[];

  final TextEditingController textEditingController =
  new TextEditingController();
  bool _isComposing = false;


  void handleSubmitted(String text) {
    textEditingController.clear();
    setState(() {
      _isComposing = false;
    });
    ChatMessage chatMessage = new ChatMessage(
        text: text,
        animationController: new AnimationController(
            duration: new Duration(milliseconds: 2000), vsync: this));
    setState(() {
      chatMessages.insert(0, chatMessage);
    });
    chatMessage.animationController.forward();
  }


  Widget _fixTextWeight() {
    return new Container(
        margin: const EdgeInsets.symmetric(horizontal: 8.0),
        child: new Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: <Widget>[

            new Flexible(
                child: new TextField(
                    controller: textEditingController,
                    onChanged: (String text) {
                      setState(() {

                        _isComposing = text.length > 0;
                      });
                    },
                    decoration: new InputDecoration.collapsed(
                        hintText: "Need Help?  Send a message to us"),
                    onSubmitted: handleSubmitted)),
            new Container(
                margin: const EdgeInsets.symmetric(horizontal: 4.0),
                child: defaultTargetPlatform == TargetPlatform.iOS
                    ? new CupertinoButton(
                    child: new Text("Send"),
                    onPressed: _isComposing
                        ? () => handleSubmitted(textEditingController.text)
                        : null)
                    : new IconButton(
                    icon: new Icon(Icons.send),
                    onPressed: _isComposing
                        ? () => handleSubmitted(textEditingController.text)
                        : null))
          ],
        ));
  }

  @override
  Widget build(BuildContext context) {
    return new Scaffold(

        appBar: new AppBar(
            backgroundColor: Colors.teal,
            title: new Text(
              "Help Chat",
              style: TextStyle(
              color: Colors.white,
              ),
            ),
            elevation: defaultTargetPlatform == TargetPlatform.iOS ? 0.0 : 4.0

        ),

        body: new Column(children: <Widget>[
           
          new Flexible(
              child: new ListView.builder(
                  padding: new EdgeInsets.all(8.0),
                  reverse: true,
                  itemBuilder: (BuildContext context, int index) =>
                  chatMessages[index],
                  itemCount: chatMessages.length)),
          new Divider(height: 1.0),
          new Container(
              decoration: new BoxDecoration(color: Theme.of(context).cardColor),
              child: _fixTextWeight())
        ]));
  }
}