import 'dart:io';
import 'package:rental_manager/PlatformWidget/platform_widget.dart';
import 'package:rental_manager/PlatformWidget/keys.dart';
import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/services.dart';

class PlatformAlertDialog extends PlatformWidget {
  PlatformAlertDialog({
    @required this.title,
    @required this.content,
    this.cancelActionText,
    @required this.defaultActionText,
  })  : assert(title != null),
        assert(content != null),
        assert(defaultActionText != null);

  final String title;
  final String content;
  final String cancelActionText;
  final String defaultActionText;

  Future<bool> show(BuildContext context) async {
    return Platform.isIOS
        ? await showCupertinoDialog<bool>(
            context: context,
            builder: (BuildContext context) => this,
          )
        : await showDialog<bool>(
            context: context,
            barrierDismissible: false,
            builder: (BuildContext context) => this,
          );
  }

  @override
  Widget buildCupertinoWidget(BuildContext context) {
    return CupertinoAlertDialog(
      title: Text(title),
      content: Text(content),
      actions: _buildActions(context),
    );
  }

  @override
  Widget buildMaterialWidget(BuildContext context) {
    return AlertDialog(
      title: Text(title),
      content: Text(content),
      actions: _buildActions(context),
    );
  }

  List<Widget> _buildActions(BuildContext context) {
    final List<Widget> actions = <Widget>[];
    if (cancelActionText != null) {
      actions.add(
        PlatformAlertDialogAction(
          child: Text(
            cancelActionText,
            key: Key(Keys.alertCancel),
          ),
          onPressed: () => Navigator.of(context).pop(false),
        ),
      );
    }
    actions.add(
      PlatformAlertDialogAction(
        child: Text(
          defaultActionText,
          key: Key(Keys.alertDefault),
        ),
        onPressed: () => Navigator.of(context).pop(true),
      ),
    );
    return actions;
  }
}

class PlatformAlertDialogAction extends PlatformWidget {
  PlatformAlertDialogAction({this.child, this.onPressed});
  final Widget child;
  final VoidCallback onPressed;

  @override
  Widget buildCupertinoWidget(BuildContext context) {
    return CupertinoDialogAction(
      child: child,
      onPressed: onPressed,
    );
  }

  @override
  Widget buildMaterialWidget(BuildContext context) {
    return FlatButton(
      child: child,
      onPressed: onPressed,
    );
  }
  // static String message(PlatformException exception) {
  //   if (exception.message == 'FIRFirestoreErrorDomain') {
  //     if (exception.code == 'Code 7') {
  //       return 'This operation could not be completed due to a server error';
  //     }
  //     return exception.details;
  //   }
  //   return errors[exception.code] ?? exception.message;
  // }

  // static Map<String, String> errors = {
  //   'ERROR_WEAK_PASSWORD': 'The password must be 8 characters long or more.',
  //   'ERROR_INVALID_CREDENTIAL': 'The email address is badly formatted.',
  //   'ERROR_EMAIL_ALREADY_IN_USE': 'The email address is already registered. Sign in instead?',
  //   'ERROR_INVALID_EMAIL': 'The email address is badly formatted.',
  //   'ERROR_WRONG_PASSWORD': 'The password is incorrect. Please try again.',
  //   'ERROR_USER_NOT_FOUND': 'The email address is not registered. Need an account?',
  //   'ERROR_TOO_MANY_REQUESTS': 'We have blocked all requests from this device due to unusual activity. Try again later.',
  //   'ERROR_OPERATION_NOT_ALLOWED': 'This sign in method is not allowed. Please contact support.',
  // };
}
