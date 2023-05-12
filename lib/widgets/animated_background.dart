import 'package:flutter/material.dart';

class AnimatedBackground extends StatefulWidget {
  final String image;
  const AnimatedBackground({
    Key key,
    @required this.image,
  }) : super(key: key);

  @override
  State createState() => AnimatedBackgroundState();
}

class AnimatedBackgroundState extends State<AnimatedBackground>
    with SingleTickerProviderStateMixin {
  AnimationController animationController;
  Animation<double> imageSizeAnimation;
  Animation<double> imageSlideAnimation;

  @override
  void initState() {
    super.initState();

    animationController = AnimationController(
        vsync: this, duration: Duration(milliseconds: 6000));
    imageSizeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
        CurvedAnimation(
            parent: animationController,
            curve: Interval(0.0, 0.1, curve: Curves.bounceInOut)));
    imageSlideAnimation = Tween<double>(begin: 0.0, end: 0.5).animate(
        CurvedAnimation(
            parent: animationController,
            curve: Interval(0.1, 1.0, curve: Curves.linear)));

    imageSlideAnimation.addListener(() {
      setState(() {});
    });
    forward();
  }

  forward() {
    if (mounted) {
      animationController?.forward()?.whenCompleteOrCancel(() {
        reverse();
      });
    }
  }

  reverse() {
    if (mounted) {
      animationController?.reverse()?.whenComplete(() {
        forward();
      });
    }
  }

  @override
  void dispose() {
    animationController?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment(1.0, -0.3),
      child: ClipPath(
        clipper: _AnimatedBackgroundImageClipper(),
        child: Image(
          alignment: Alignment(imageSlideAnimation.value, 0.0),
          width: 350.0 * imageSizeAnimation.value,
          height: 350.0 * imageSizeAnimation.value,
          image: AssetImage(
            widget.image,
          ),
          fit: BoxFit.cover,
        ),
      ),
    );
  }
}

class _AnimatedBackgroundImageClipper extends CustomClipper<Path> {
  @override
  Path getClip(Size size) {
    Offset ctrl;
    Offset end;

    Path path = Path();
    path.moveTo(size.width, 0.0);

    path.lineTo(0.2 * size.width, size.height * 0.5 - 20);

    ctrl = Offset(-0.35 * size.width, size.height);
    end = Offset(0.6 * size.width, size.height * 0.95);
    path.quadraticBezierTo(ctrl.dx, ctrl.dy, end.dx, end.dy);

    path.lineTo(0.6 * size.width, size.height * 0.95);

    ctrl = Offset(0.7 * size.width, size.height - 20);
    end = Offset(0.8 * size.width, size.height * 0.9);
    path.quadraticBezierTo(ctrl.dx, ctrl.dy, end.dx, end.dy);

    path.lineTo(0.8 * size.width, size.height * 0.9);

    ctrl = Offset(0.9 * size.width, size.height * 0.9 - 15);
    end = Offset(size.width, size.height * 0.8);
    path.quadraticBezierTo(ctrl.dx, ctrl.dy, end.dx, end.dy);

    path.lineTo(size.width, size.height * 0.8);

    path.close();
    return path;
  }

  @override
  bool shouldReclip(CustomClipper<Path> oldClipper) => true;
}
