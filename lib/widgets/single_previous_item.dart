import 'package:flutter/cupertino.dart';
import 'package:dorx/models/thing_type.dart';
import '../models/models.dart';
import 'widgets.dart';

class SinglePreviousItem extends StatelessWidget {
  final String usableThingID;
  final String type;
  final bool selectable;
  final bool showBalance;
  final bool list;
  final bool selected;
  final String searchedText;
  final bool sized;
  final bool sensitive;
  final bool showButton;
  final bool horizontal;
  final Function onTap;

  const SinglePreviousItem({
    Key key,
    @required this.usableThingID,
    @required this.type,
    this.selected = false,
    this.horizontal = true,
    this.sensitive = false,
    this.selectable = false,
    this.showButton = true,
    this.sized = false,
    this.searchedText = "]",
    this.list = true,
    this.onTap,
    this.showBalance = true,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return type == ThingType.USER
        ? Container(
            constraints: BoxConstraints(
              maxWidth: horizontal
                  ? MediaQuery.of(context).size.width * 0.7
                  : MediaQuery.of(context).size.width,
            ),
            child: Stack(
              children: [
                SingleUser(
                  showButton: showButton,
                  user: null,
                  onTap: onTap,
                  showBalance: showBalance,
                  userID: usableThingID,
                ),
                if (selected) SelectorThingie()
              ],
            ),
          )
        : type == ThingType.PROPERTY
            ? SingleProperty(
                property: null,
                selectable: selectable,
                horizontal: horizontal,
                propertyID: usableThingID,
                selected: selected,
                onTap: onTap,
              )
            : Text(type);
  }
}
