import 'package:flutter/material.dart';

import '../constants/constants.dart';

class Circle extends StatelessWidget {
  final Color color;
  final double diameter;
  final Offset center;

  Circle({Key key, @required this.color, @required this.diameter, this.center})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      size: Size(diameter, diameter),
      painter: CirclePainter(color, center: center),
    );
  }
}

class CirclePainter extends CustomPainter {
  final Color color;
  final Offset center;

  CirclePainter(this.color, {this.center});

  @override
  void paint(Canvas canvas, Size size) {
    canvas.drawCircle(
      center ?? Offset(size.width / 2, size.height / 2),
      size.width / 2,
      Paint()..color = color,
    );
  }

  @override
  bool shouldRepaint(CirclePainter oldDelegate) => true;
}

class SpreadCircles extends StatefulWidget {
  const SpreadCircles({Key key}) : super(key: key);

  @override
  State createState() => SpreadCirclesState();
}

class SpreadCirclesState extends State<SpreadCircles>
    with SingleTickerProviderStateMixin {
  AnimationController animationController;
  Animation<double> purpleCircleDiameter;
  Animation<double> yellowCircleDiameter;
  Animation<double> greenCircleDiameter;

  @override
  void initState() {
    super.initState();

    animationController =
        AnimationController(vsync: this, duration: Duration(milliseconds: 800));

    purpleCircleDiameter = Tween<double>(begin: 0.0, end: 130.0).animate(
        CurvedAnimation(
            parent: animationController,
            curve: Interval(0.0, 0.6, curve: Curves.bounceInOut)));

    yellowCircleDiameter = Tween<double>(begin: 0.0, end: 80.0).animate(
        CurvedAnimation(
            parent: animationController,
            curve: Interval(0.3, 0.7, curve: Curves.bounceInOut)));

    greenCircleDiameter = Tween<double>(begin: 0.0, end: 60.0).animate(
        CurvedAnimation(
            parent: animationController,
            curve: Interval(0.6, 1.0, curve: Curves.easeIn)));

    purpleCircleDiameter.addListener(() {
      setState(() {});
    });

    greenCircleDiameter.addListener(() {
      setState(() {});
    });

    yellowCircleDiameter.addListener(() {
      setState(() {});
    });

    animationController.forward();
  }

  @override
  void dispose() {
    animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.transparent,
      child: Stack(
        children: <Widget>[
          Align(
            // light green circle on the left border
            alignment: Alignment(-1.0, -0.05),
            child: Circle(
              color: primaryColor.withGreen(190).withOpacity(0.5),
              diameter: greenCircleDiameter.value,
              center: Offset(10.0, 25.0),
            ),
          ),
          Align(
            // purple circle on the right border
            alignment: Alignment(1.0, 0.24),
            child: Circle(
              color: primaryColor.withOpacity(0.8),
              diameter: purpleCircleDiameter.value,
              center: Offset(95.0, 75.0),
            ),
          ),
          Align(
            // yellow circle at the top
            alignment: Alignment(0.6, -0.85),
            child: Circle(
                color: primaryColor.withOpacity(0.8),
                diameter: yellowCircleDiameter.value),
          ),
        ],
      ),
    );
  }
}
