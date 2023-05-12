import 'package:dorx/widgets/widgets.dart';
import 'package:flutter/material.dart';

class NoticeBoardManagemnetView extends StatefulWidget {
  const NoticeBoardManagemnetView({Key key}) : super(key: key);

  @override
  State<NoticeBoardManagemnetView> createState() =>
      _NoticeBoardManagemnetViewState();
}

class _NoticeBoardManagemnetViewState extends State<NoticeBoardManagemnetView> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
          child: Column(
        children: [
          BackBar(
            icon: null,
            onPressed: null,
            text: "Notice Board",
          ),
        ],
      )),
    );
  }
}
