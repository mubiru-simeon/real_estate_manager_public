import 'package:flutter/material.dart';

class HeadLineText extends StatelessWidget {
  final String text;
  final String subText;
  final Function onTap;
  final bool plain;
  const HeadLineText({
    Key key,
    @required this.onTap,
    @required this.text,
    this.subText = "Tap to view more",
    this.plain = false,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: plain ? null : EdgeInsets.symmetric(horizontal: 10),
      child: InkWell(
        onTap: onTap,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    text,
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  if (!plain)
                    Text(
                      subText,
                    ),
                ],
              ),
            ),
            onTap == null
                ? SizedBox()
                : IconButton(
                    icon: Icon(
                      Icons.arrow_forward_ios,
                      size: 18,
                    ),
                    onPressed: onTap ?? () {},
                  )
          ],
        ),
      ),
    );
  }
}
