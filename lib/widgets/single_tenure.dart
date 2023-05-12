import 'package:dorx/services/services.dart';
import 'package:flutter/material.dart';

import '../constants/constants.dart';

class SingleTenure extends StatefulWidget {
  final String text;
  final bool selected;
  final Function onTap;

  SingleTenure({
    Key key,
    @required this.text,
    @required this.onTap,
    @required this.selected,
  }) : super(key: key);

  @override
  State<SingleTenure> createState() => _SingleTenureState();
}

class _SingleTenureState extends State<SingleTenure> {
  @override
  Widget build(BuildContext context) {
    return Container(
      width: MediaQuery.of(context).size.width * 0.35,
      margin: EdgeInsets.symmetric(
        vertical: 3,
        horizontal: 3,
      ),
      child: GestureDetector(
        onTap: widget.onTap,
        child: Material(
          elevation: 8,
          color: widget.selected ? Colors.green : null,
          borderRadius: standardBorderRadius,
          child: (Center(
            child: Text(
              widget.text.capitalizeFirstOfEach,
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 16,
                color: widget.selected ? Colors.white : null,
              ),
            ),
          )),
        ),
      ),
    );
  }
}
