import 'package:dorx/services/ui_services.dart';
import 'package:flutter/material.dart';
import '../views/views.dart';
import 'notifications_button.dart';

class CustomSliverAppBar extends StatelessWidget {
  final String title;
  final double height;
  final Color titleColor;
  final List<Widget> actions;
  final FlexibleSpaceBar flexibleSpaceBar;
  const CustomSliverAppBar({
    Key key,
    this.title,
    this.flexibleSpaceBar,
    this.height = 0,
    this.actions = const [],
    this.titleColor = Colors.grey,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return SliverAppBar(
      pinned: true,
      backgroundColor: Theme.of(context).canvasColor,
      snap: false,
      flexibleSpace: flexibleSpaceBar,
      floating: false,
      expandedHeight: height,
      title: title != null
          ? Text(
              title,
              style: TextStyle(
                color: titleColor,
              ),
            )
          : null,
      leading: GestureDetector(
        onTap: () {
          Navigator.of(context).pop();
        },
        child: Icon(
          Icons.arrow_back_ios,
          color: Colors.grey,
        ),
      ),
      actions: <Widget>[
        IconButton(
          onPressed: () {
            UIServices().showDatSheet(
              SearchView(
                returnList: false,
                returning: false,
                whatToReturn: null,
              ),
              true,
              context,
            );
          },
          icon: Icon(
            Icons.search,
            color: Colors.grey,
          ),
        ),
        NotificationsButton(
          color: null,
        ),
      ]
          .followedBy(
        actions.map((e) => e),
      )
          .followedBy([
        SizedBox(
          width: 10,
        )
      ]).toList(),
    );
  }
}
