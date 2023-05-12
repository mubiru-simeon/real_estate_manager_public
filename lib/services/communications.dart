import 'package:dorx/widgets/custom_dialog_box.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';

class CommunicationServices {
  showdaBox({
    @required BuildContext context,
    @required String text,
    @required bool dismissable,
    @required Function onTap,
    @required String buttonText,
    @required bool showButton,
  }) {
    showDialog(
      context: context,
      barrierDismissible: dismissable,
      builder: (context) {
        return CustomDialogBox(
          bodyText: text,
          buttonText: buttonText,
          onButtonTap: onTap,
          showOtherButton: showButton,
        );
      },
    );
  }

  showToast(String message, Color color) {
    Fluttertoast.showToast(
      msg: message,
      toastLength: Toast.LENGTH_LONG,
      gravity: ToastGravity.CENTER,
      backgroundColor: color,
      textColor: Colors.white,
      fontSize: 15.0,
    );
  }

  showSnackBar(String message, BuildContext context,
      {Function whatToDo, String buttonText, SnackBarBehavior behavior}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        behavior: behavior,
        action: whatToDo == null
            ? null
            : SnackBarAction(
                label: buttonText,
                onPressed: whatToDo,
              ),
      ),
    );
  }
}
