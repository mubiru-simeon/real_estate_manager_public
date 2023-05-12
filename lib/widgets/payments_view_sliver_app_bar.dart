import 'package:animate_do/animate_do.dart';
import 'package:flutter/material.dart';
import '../constants/constants.dart';
import '../services/services.dart';

class PaymentsViewappBar extends StatefulWidget {
  final bool isScrolled;
  final String viewerID;
  final String viewerType;
  PaymentsViewappBar({
    Key key,
    @required this.isScrolled,
    @required this.viewerType,
    @required this.viewerID,
  }) : super(key: key);

  @override
  State<PaymentsViewappBar> createState() => _PaymentsViewappBarState();
}

class _PaymentsViewappBarState extends State<PaymentsViewappBar> {
  @override
  Widget build(BuildContext context) {
    return SliverAppBar(
      expandedHeight: 150.0,
      elevation: 0,
      pinned: true,
      stretch: true,
      toolbarHeight: 80,
      actions: [
        IconButton(
          onPressed: () {
            StorageServices().launchTheThing("tel:$dorxPhoneNumber");
          },
          icon: Icon(
            Icons.phone,
          ),
        )
      ],
      leading: IconButton(
        onPressed: () {
          Navigator.of(context).pop();
        },
        icon: Icon(Icons.arrow_back),
      ),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.only(
          bottomLeft: Radius.circular(40),
          bottomRight: Radius.circular(40),
        ),
      ),
      centerTitle: true,
      title: AnimatedOpacity(
        opacity: widget.isScrolled ? 1.0 : 0.0,
        duration: const Duration(milliseconds: 500),
        child: Column(
          children: [
            Container(
              width: 30,
              height: 4,
              decoration: BoxDecoration(
                color: Colors.grey,
                borderRadius: BorderRadius.circular(10),
              ),
            ),
          ],
        ),
      ),
      flexibleSpace: FlexibleSpaceBar(
        collapseMode: CollapseMode.pin,
        titlePadding: const EdgeInsets.only(left: 20, right: 20),
        title: AnimatedOpacity(
          duration: const Duration(milliseconds: 500),
          opacity: widget.isScrolled ? 0.0 : 1.0,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              FadeIn(
                duration: const Duration(milliseconds: 500),
                child: Row(
                  children: [],
                ),
              ),
              SizedBox(
                height: 5,
              ),
              Container(
                width: 30,
                height: 3,
                decoration: BoxDecoration(
                  color: Colors.grey,
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              SizedBox(
                height: 5,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
