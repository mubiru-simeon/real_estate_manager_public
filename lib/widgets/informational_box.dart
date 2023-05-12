import 'package:flutter/material.dart';

import '../constants/ui.dart';

class InformationalBox extends StatefulWidget {
  final bool visible;
  final Color textColor;
  final Color bgColor;
  final double textSize;
  final Function onClose;
  final String message;
  InformationalBox({
    Key key,
    @required this.visible,
    this.textColor,
    this.bgColor,
    this.textSize,
    @required this.onClose,
    @required this.message,
  }) : super(key: key);

  @override
  State<InformationalBox> createState() => _InformationalBoxState();
}

class _InformationalBoxState extends State<InformationalBox> {
  @override
  Widget build(BuildContext context) {
    return widget.visible
        ? Padding(
            padding: const EdgeInsets.symmetric(
              vertical: 10,
              horizontal: 5,
            ),
            child: Material(
              elevation: 10,
              borderRadius: standardBorderRadius,
              child: Container(
                padding: EdgeInsets.only(
                  left: 20,
                  right: 20,
                  top: 25,
                  bottom: 25,
                ),
                width: double.infinity,
                decoration: BoxDecoration(
                  borderRadius: standardBorderRadius,
                  color: widget.bgColor ?? primaryColor.withOpacity(0.5),
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: Text(
                        widget.message,
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: widget.textSize ?? 15,
                          color: widget.textColor,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    SizedBox(
                      width: 5,
                    ),
                    if (widget.onClose != null)
                      GestureDetector(
                        onTap: () {
                          widget.onClose();
                        },
                        child: Icon(
                          Icons.close,
                        ),
                      )
                  ],
                ),
              ),
            ),
          )
        : SizedBox();
  }
}
