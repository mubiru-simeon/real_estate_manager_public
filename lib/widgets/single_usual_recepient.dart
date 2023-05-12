import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

import '../models/models.dart';
import 'single_previous_item.dart';

class SingleUsualRecepient extends StatefulWidget {
  final String recepientID;
  final UsualRecepients recepient;
  SingleUsualRecepient({
    Key key,
    @required this.recepient,
    @required this.recepientID,
  }) : super(key: key);

  @override
  State<SingleUsualRecepient> createState() => _SingleUsualRecepientState();
}

class _SingleUsualRecepientState extends State<SingleUsualRecepient> {
  @override
  Widget build(BuildContext context) {
    return Container(
      constraints: BoxConstraints(
        maxWidth: kIsWeb ? 300 : MediaQuery.of(context).size.width * 0.7,
      ),
      child: Column(
        children: [
          SinglePreviousItem(
            type: widget.recepient.type,
            usableThingID: widget.recepient.id,
          ),
        ],
      ),
    );
  }
}
