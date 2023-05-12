import 'package:dorx/services/services.dart';
import 'package:flutter/material.dart';
import 'package:hive/hive.dart';

import '../models/models.dart';

class BackBar extends StatefulWidget {
  final String text;
  final bool showIcon;
  final Function onPressed;
  final bool dontShowSettings;
  final Widget action;
  final IconData icon;

  BackBar({
    Key key,
    @required this.icon,
    this.showIcon = true,
    @required this.onPressed,
    @required this.text,
    this.action,
    this.dontShowSettings = false,
  }) : super(key: key);

  @override
  State<BackBar> createState() => _BackBarState();
}

class _BackBarState extends State<BackBar> {
  String mode;
  Box box;

  @override
  void initState() {
    box = Hive.box(DorxSettings.DORXBOXNAME);
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    mode = box.get(UserModel.ACCOUNTTYPES);

    return Column(
      children: [
        SizedBox(
          height: 10,
        ),
        Container(
          padding: EdgeInsets.symmetric(
            vertical: 4,
            horizontal: 2,
          ),
          width: MediaQuery.of(context).size.width,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              widget.showIcon
                  ? Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: GestureDetector(
                        onTap: widget.onPressed ??
                            () {
                              if (context.canPop()) {
                                Navigator.of(context).pop();
                              } else {
                                context.pushReplacementNamed(
                                  RouteConstants.allMyProperties,
                                );
                              }
                            },
                        child: CircleAvatar(
                          child: IconButton(
                            icon: Icon(
                              widget.icon ?? Icons.arrow_back_ios_rounded,
                            ),
                            onPressed: widget.onPressed ??
                                () {
                                  if (context.canPop()) {
                                    Navigator.of(context).pop();
                                  } else {
                                    context.pushReplacementNamed(
                                      RouteConstants.allMyProperties,
                                    );
                                  }
                                },
                          ),
                        ),
                      ),
                    )
                  : SizedBox(
                      width: 20,
                    ),
              Expanded(
                child: Text(
                  widget.text,
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              if (widget.action != null) widget.action,
              if (!widget.dontShowSettings)
                SizedBox(
                  width: 10,
                ),
              if (!widget.dontShowSettings)
                IconButton(
                  onPressed: () {
                    FeedbackServices().startFeedingBackward(
                      context,
                      mode,
                    );
                  },
                  icon: Icon(
                    Icons.feedback,
                  ),
                ),
              SizedBox(
                width: 10,
              ),
            ],
          ),
        ),
      ],
    );
  }
}
