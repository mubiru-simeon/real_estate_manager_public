import 'package:flutter/material.dart';

class OrDivider extends StatelessWidget {
  final double height;
  final Color color;
  const OrDivider({
    Key key,
    this.color,
    this.height,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Column(
        children: [
          if (height != null)
            SizedBox(
              height: height,
            ),
          Row(
            children: [
              Expanded(
                child: Divider(
                  thickness: 2,
                  color: Colors.grey,
                ),
              ),
              SizedBox(
                width: 5,
              ),
              Text(
                "OR",
                style: TextStyle(
                  fontSize: 16,
                  color: color,
                ),
              ),
              SizedBox(
                width: 5,
              ),
              Expanded(
                child: Divider(
                  color: Colors.grey,
                  thickness: 2,
                ),
              ),
            ],
          ),
          if (height != null)
            SizedBox(
              height: height,
            ),
        ],
      ),
    );
  }
}
