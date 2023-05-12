
import 'package:flutter/material.dart';
import 'package:dorx/theming/theme_controller.dart';

import '../constants/ui.dart';

class AttachImageButton extends StatelessWidget {
  final String text;
  final Function onAttachPressed;
  AttachImageButton({
    Key key,
    @required this.onAttachPressed,
    this.text,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () {
        onAttachPressed();
      },
      child: Container(
        margin: EdgeInsets.symmetric(horizontal: 10),
        padding: EdgeInsets.all(15),
        decoration: BoxDecoration(
          borderRadius: standardBorderRadius,
          border: Border.all(
            width: 1,
            color: ThemeBuilder.of(context).getCurrentTheme() == Brightness.dark
                ? Colors.white
                : Colors.black,
          ),
        ),
        child: Center(
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.add_photo_alternate),
              Text(text ?? "Add Images")
            ],
          ),
        ),
      ),
    );
  }
}
