import 'package:flutter/material.dart';
import 'package:rental_manager/tabs/reservations.dart';
import '../globals.dart' as globals;
import 'pill_gesture.dart';

class SlideDialog extends StatefulWidget {
  final Widget child;
  final Color backgroundColor;
  final Color pillColor;
  final Container textField;
  SlideDialog({
    @required this.child,
    @required this.pillColor,
    @required this.backgroundColor,
    @required this.textField,
  });

  @override
  _SlideDialogState createState() => _SlideDialogState();
}

class _SlideDialogState extends State<SlideDialog> {
  var _initialPosition = 0.0;
  var _currentPosition = 0.0;

  @override
  Widget build(BuildContext context) {
    final deviceWidth = MediaQuery.of(context).size.width;
    final deviceHeight = MediaQuery.of(context).size.height;
    //resizeToAvoidBottomInset: false,

    return AnimatedPadding(
      padding: MediaQuery.of(context).viewInsets +
          EdgeInsets.only(top:  100),
      duration: Duration(milliseconds: 100),
      curve: Curves.decelerate,
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onPanDown: (_) {
          FocusScope.of(context).requestFocus(FocusNode());
        },
        onTap: (){

          FocusScope.of(context).requestFocus(new FocusNode());
        },
        child: SingleChildScrollView(
          child: MediaQuery.removeViewInsets(
            removeLeft: true,
            removeTop: true,
            removeRight: true,
            removeBottom: true,
            context: context,
            child: Center(
              child: Container(
                width: deviceWidth,
                height: deviceHeight,
                child: Material(
                  color: widget.backgroundColor ??
                      Theme.of(context).dialogBackgroundColor,
                  elevation: 24.0,
                  type: MaterialType.card,
                  child: Column(
                    children: <Widget>[
                      PillGesture(
                        pillColor: widget.pillColor,
                        onVerticalDragStart: _onVerticalDragStart,
                        onVerticalDragEnd: _onVerticalDragEnd,
                        onVerticalDragUpdate: _onVerticalDragUpdate,
                      ),
                      widget.child,
                      widget.textField,
                      SizedBox(
                        width: 300,
                        child: RaisedButton(
                          highlightElevation: 0.0,
                          splashColor: Colors.greenAccent,
                          highlightColor: Colors.green,
                          elevation: 0.0,
                          color: Colors.blue,
                          shape: RoundedRectangleBorder(borderRadius: new BorderRadius.circular(30.0)),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: <Widget>[
                              Center(
                                child: Text(
                                  "Dismiss",
                                  style: TextStyle(
                                    fontSize: 15,
                                    // backgroundColor:  Colors.teal[50],
                                    color: Colors.white,
                                    fontFamily: 'Montserrat',
                                  ),
                                ),
                              ),

                            ],
                          ),
                          onPressed: (){
                            FocusScope.of(context).requestFocus(FocusNode());
                            Navigator.pop(context, false);
                            //Navigator.push(context, MaterialPageRoute(builder: (context) => SecondTab()));
                          },
                          padding: EdgeInsets.all(7.0),
                          //color: Colors.teal.shade900,
                          disabledColor: Colors.black,
                          disabledTextColor: Colors.black,

                        ),
                      ),
                    ],
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(20.0),
                      topRight: Radius.circular(20.0),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );

  }

  void _onVerticalDragStart(DragStartDetails drag) {
    setState(() {
      _initialPosition = drag.globalPosition.dy;
    });
  }

  void _onVerticalDragUpdate(DragUpdateDetails drag) {
    setState(() {
      final temp = _currentPosition;
      _currentPosition = drag.globalPosition.dy - _initialPosition;
      if (_currentPosition < 0) {
        _currentPosition = temp;
      }
    });
  }

  void _onVerticalDragEnd(DragEndDetails drag) {
    if (_currentPosition > 100.0) {
      Navigator.pop(context);
      return;
    }
    setState(() {
      _currentPosition = 0.0;
    });
  }
}
