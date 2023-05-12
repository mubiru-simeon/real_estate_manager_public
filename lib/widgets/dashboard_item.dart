import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../constants/constants.dart';
import '../models/models.dart';
import '../services/services.dart';

class StatisticText extends StatelessWidget {
  final String title;
  const StatisticText({
    Key key,
    @required this.title,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        Container(
          width: MediaQuery.of(context).size.width * 0.4,
          color: primaryColor,
          height: 2,
        )
      ],
    );
  }
}

class SingleDashboardCategory extends StatelessWidget {
  final String text;
  final Function onTap;
  final IconData icon;
  final Color color;
  final String buttonText;
  final String pending;
  final String demi;
  final String manufacturing;
  final String delivering;
  final Function onbutonTap;
  final bool stat;
  final String statDirectory;
  final String image;
  final bool showButton;

  const SingleDashboardCategory({
    Key key,
    @required this.text,
    @required this.onTap,
    @required this.icon,
    this.demi,
    @required this.color,
    @required this.buttonText,
    this.delivering,
    @required this.onbutonTap,
    this.statDirectory,
    this.showButton = true,
    this.stat = false,
    this.image,
    this.manufacturing,
    this.pending,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(2),
      margin: EdgeInsets.symmetric(
        vertical: 3,
      ),
      decoration: BoxDecoration(
        border: Border.all(
          width: 1,
          color: Colors.grey,
        ),
        borderRadius: standardBorderRadius,
      ),
      child: Column(
        children: [
          if (showButton)
            GestureDetector(
              onTap: onbutonTap,
              child: Material(
                elevation: 8,
                borderRadius: standardBorderRadius,
                child: Container(
                  padding: EdgeInsets.all(15),
                  decoration: BoxDecoration(
                    borderRadius: standardBorderRadius,
                    image: DecorationImage(
                      colorFilter: ColorFilter.mode(
                        Colors.black.withOpacity(0.5),
                        BlendMode.darken,
                      ),
                      fit: BoxFit.cover,
                      image: AssetImage(
                        image ?? bedroom,
                      ),
                    ),
                  ),
                  width: double.infinity,
                  child: Center(
                    child: Text(
                      buttonText,
                      style: TextStyle(
                        fontSize: 16,
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
              ),
            ),
          stat
              ? SingleCounter(
                  color: color,
                  demi: demi,
                  icon: icon,
                  stat: statDirectory,
                  onTap: onTap,
                  text: text,
                )
              : HomeScreenCard(
                  color: color,
                  text: text,
                  icon: icon,
                  onTap: onTap,
                ),
        ],
      ),
    );
  }
}

class SingleCounter extends StatelessWidget {
  final Color color;
  final String stat;
  final String demi;
  final String text;
  final IconData icon;
  final Function onTap;
  const SingleCounter({
    Key key,
    this.color,
    @required this.stat,
    @required this.onTap,
    @required this.text,
    this.demi,
    @required this.icon,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        onTap();
      },
      child: Container(
        width: double.infinity,
        margin: EdgeInsets.symmetric(
          vertical: 2,
        ),
        decoration: BoxDecoration(
          borderRadius: standardBorderRadius,
          boxShadow: [
            BoxShadow(
              color: Colors.black38,
              offset: Offset(0, 10),
              blurRadius: 15,
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: standardBorderRadius,
          child: Material(
            color: color == null
                ? primaryColor.withOpacity(0.5)
                : color.withOpacity(0.5),
            child: Stack(
              clipBehavior: Clip.antiAliasWithSaveLayer,
              children: [
                Positioned(
                  right: -15,
                  top: -15,
                  child: Icon(
                    icon,
                    size: 100,
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(15),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        text,
                        style: TextStyle(
                          fontSize: 17,
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      body(context),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  body(
    BuildContext context,
  ) {
    return StreamBuilder(
      stream: FirebaseDatabase.instance
          .ref()
          .child(Statistic.DIRECTORY)
          .child(
              Provider.of<PropertyManagement>(context).getCurrentPropertyID())
          .child(stat)
          .onValue,
      builder: (context, snapshot) {
        if (!snapshot.hasData || snapshot.data == null) {
          return Text(
            "0",
            style: TextStyle(
              fontSize: 21,
              color: Colors.white,
              fontWeight: FontWeight.bold,
            ),
          );
        } else {
          return Text(
            TextService().formatter(
              snapshot.data.snapshot.value,
            ),
            style: TextStyle(
              fontSize: 21,
              color: Colors.white,
              fontWeight: FontWeight.bold,
            ),
          );
        }
      },
    );
  }
}

class HomeScreenCard extends StatelessWidget {
  final String text;
  final Function onTap;
  final IconData icon;
  final Color color;
  const HomeScreenCard({
    Key key,
    @required this.text,
    @required this.onTap,
    @required this.icon,
    @required this.color,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: double.infinity,
        margin: EdgeInsets.symmetric(vertical: 2),
        decoration: BoxDecoration(
          borderRadius: standardBorderRadius,
          boxShadow: [
            BoxShadow(
              color: Colors.black38,
              offset: Offset(0, 10),
              blurRadius: 15,
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: standardBorderRadius,
          child: Material(
            color: color.withOpacity(0.5),
            child: Stack(
              clipBehavior: Clip.antiAliasWithSaveLayer,
              children: [
                Positioned(
                  right: -8,
                  top: -8,
                  child: Icon(
                    icon,
                    size: 80,
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(15),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        text,
                        style: TextStyle(
                          fontSize: 17,
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
