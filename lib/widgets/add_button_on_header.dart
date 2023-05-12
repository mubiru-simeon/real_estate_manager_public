import 'package:flutter/material.dart';

import '../constants/constants.dart';

class AddButtonOnHeader extends StatelessWidget {
  final Function onTap;
  final String word;
  const AddButtonOnHeader({
    Key key,
    @required this.onTap,
    @required this.word,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        onTap();
      },
      child: Container(
        padding: EdgeInsets.all(10),
        margin: EdgeInsets.all(5),
        decoration: BoxDecoration(
          gradient: listColors[0],
          borderRadius: standardBorderRadius,
        ),
        child: Center(
          child: Text(
            word,
            textAlign: TextAlign.center,
            style: whiteTitle,
          ),
        ),
      ),
    );
  }
}
