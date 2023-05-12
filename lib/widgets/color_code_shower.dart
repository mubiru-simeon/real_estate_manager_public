import 'package:flutter/material.dart';
import 'package:dorx/constants/constants.dart';

class ColorCodeShower extends StatelessWidget {
  final List<ColorCode> colors;
  const ColorCodeShower({
    Key key,
    @required this.colors,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8.0),
      child: SizedBox(
        height: 60,
        child: ClipRRect(
          borderRadius: standardBorderRadius,
          child: Row(
            children: colors
                .map(
                  (e) => Expanded(
                    child: SingleColorCode(
                      color: e.color,
                      onTap: e.onTap,
                      text: e.text,
                    ),
                  ),
                )
                .toList(),
          ),
        ),
      ),
    );
  }
}

class SingleColorCode extends StatelessWidget {
  final String text;
  final Color color;
  final Function onTap;
  const SingleColorCode({
    Key key,
    @required this.color,
    @required this.text,
    @required this.onTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        onTap();
      },
      child: Container(
        width: double.infinity,
        decoration: BoxDecoration(
          color: color,
        ),
        padding: EdgeInsets.only(
          left: 3,
          right: 3,
          bottom: 6,
          top: 6,
        ),
        child: Center(
          child: Text(
            text ?? "",
            textAlign: TextAlign.center,
            style: TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ),
    );
  }
}

class ColorCode {
  String _text;
  Color _color;
  Function _onTap;

  String get text => _text;
  Function get onTap => _onTap;
  Color get color => _color;

  ColorCode.fromData(
    Color color,
    String text,
    Function onTap,
  ) {
    _text = text;
    _color = color;
    _onTap = onTap;
  }
}
