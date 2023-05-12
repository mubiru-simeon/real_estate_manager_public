import 'package:flutter/material.dart';
import 'package:dorx/constants/images.dart';
import '../constants/ui.dart';

class NoDataFound extends StatefulWidget {
  final String text;
  final String doSthText;
  final Function onTap;
  final double picSize;
  NoDataFound({
    Key key,
    @required this.text,
    this.onTap,
    this.doSthText,
    this.picSize,
  }) : super(key: key);

  @override
  State<NoDataFound> createState() => _NoDataFoundState();
}

class _NoDataFoundState extends State<NoDataFound> {
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Center(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Image.asset(
              voidPic,
              height: MediaQuery.of(context).size.height * 0.1,
            ),
            SizedBox(
              height: 10,
            ),
            Text(
              widget.text ?? "No Data Found",
              textAlign: TextAlign.center,
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
            ),
            SizedBox(
              height: 10,
            ),
            if (widget.onTap != null)
              GestureDetector(
                onTap: () async {
                  widget.onTap();
                },
                child: Container(
                  padding: EdgeInsets.symmetric(horizontal: 12, vertical: 5),
                  decoration: BoxDecoration(
                    borderRadius: standardBorderRadius,
                    border: Border.all(width: 1),
                  ),
                  child: Text(
                    widget.doSthText ?? "Tap here",
                    style: TextStyle(
                      fontSize: 16,
                    ),
                  ),
                ),
              ),
            if (widget.onTap != null)
              SizedBox(
                height: 1,
              ),
          ],
        ),
      ),
    );
  }
}
