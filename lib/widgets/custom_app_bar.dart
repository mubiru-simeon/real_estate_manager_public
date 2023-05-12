import 'package:dorx/widgets/notifications_button.dart';
import 'package:flutter/material.dart';
import 'package:dorx/views/search_view.dart';

import '../services/services.dart';

class CustomAppBar extends StatefulWidget {
  final String title;
  final bool pushed;
  final bool showLeading;
  final bool showSearched;

  CustomAppBar({
    Key key,
    @required this.title,
    this.pushed = false,
    this.showSearched = false,
    this.showLeading = true,
  }) : super(key: key);

  @override
  State<CustomAppBar> createState() => _CustomAppBarState();
}

class _CustomAppBarState extends State<CustomAppBar> {
  @override
  Widget build(BuildContext context) {
    return AppBar(
      elevation: 0,
      backgroundColor: Theme.of(context).canvasColor,
      title: widget.title != null
          ? Text(
              widget.title,
              style: TextStyle(
                color: Colors.grey,
              ),
            )
          : null,
      leading: widget.showLeading
          ? GestureDetector(
              onTap: () {
                if (widget.pushed) {
                  Navigator.of(context).pop();
                } else {
                  Scaffold.of(context).openDrawer();
                }
              },
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: CircleAvatar(
                  child: IconButton(
                    icon: Icon(
                      widget.pushed ? Icons.arrow_back_ios : Icons.menu,
                    ),
                    onPressed: () {
                      if (widget.pushed) {
                        Navigator.of(context).pop();
                      } else {
                        Scaffold.of(context).openDrawer();
                      }
                    },
                  ),
                ),
              ),
            )
          : null,
      actions: [
        if (widget.showSearched)
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: GestureDetector(
              onTap: () {
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
              child: Icon(
                Icons.search,
                size: 30,
                color: Colors.grey,
              ),
            ),
          ),
        NotificationsButton(
          color: Colors.grey,
        ),
        SizedBox(
          width: 20,
        ),
      ],
    );
  }
}
