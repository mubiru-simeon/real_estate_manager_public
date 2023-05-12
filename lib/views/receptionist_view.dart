import 'package:flutter/material.dart';

class ReceptionistView extends StatefulWidget {
  final bool pushed;
  ReceptionistView({
    Key key,
    this.pushed = false,
  }) : super(key: key);

  @override
  State<ReceptionistView> createState() => _ReceptionistViewState();
}

class _ReceptionistViewState extends State<ReceptionistView> {
  @override
  Widget build(BuildContext context) {
    return widget.pushed
        ? Scaffold(
            appBar: AppBar(
              title: Text(
                "Receptionist Dashboard",
              ),
            ),
            body: Container(),
          )
        : Container();
  }
}
