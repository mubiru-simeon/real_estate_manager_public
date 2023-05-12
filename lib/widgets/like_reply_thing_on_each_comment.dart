import 'package:flutter/material.dart';

class LikeReplyThingPerComment extends StatefulWidget {
  final Function onCommentPressed;
  final String commentID;
  final bool isTopLevelComment;

  LikeReplyThingPerComment({
    Key key,
    @required this.onCommentPressed,
    @required this.commentID,
    @required this.isTopLevelComment,
  }) : super(key: key);

  @override
  State<LikeReplyThingPerComment> createState() =>
      _LikeReplyThingPerCommentState();
}

class _LikeReplyThingPerCommentState extends State<LikeReplyThingPerComment> {
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: 2,
        vertical: 2,
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.end,
        children: <Widget>[
          widget.isTopLevelComment
              ? IconButton(
                  icon: Icon(Icons.message),
                  onPressed: () {
                    widget.onCommentPressed();
                  },
                )
              : SizedBox(
                  width: 1,
                ),
        ],
      ),
    );
  }
}
