import 'package:flutter/material.dart';

class IconTextThingie extends StatelessWidget {
  final IconData icon;
  final String topText;
  final bool rowMode;
  final String value;
  IconTextThingie({
    Key key,
    @required this.icon,
    @required this.topText,
    @required this.value,
    this.rowMode = false,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return rowMode
        ? Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              SizedBox(
                height: 10,
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    icon,
                    size: 35,
                  ),
                  SizedBox(
                    width: 15,
                  ),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(topText),
                      Text(
                        value.toUpperCase(),
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                    ],
                  )
                ],
              ),
              SizedBox(
                height: 10,
              ),
            ],
          )
        : Column(
            children: [
              SizedBox(
                height: 10,
              ),
              Icon(
                icon,
                size: 35,
              ),
              SizedBox(
                height: 10,
              ),
              Text(topText),
              Text(
                value.toUpperCase(),
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
              ),
              SizedBox(
                height: 10,
              ),
            ],
          );
  }
}
