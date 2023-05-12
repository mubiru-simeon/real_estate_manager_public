import 'dart:io';
import 'package:flutter/material.dart';
import '../constants/basic.dart';

class SingleImage extends StatelessWidget {
  final dynamic image;
  final double height;
  final BoxFit fit;
  final Widget placeHolderWidget;
  final String placeholderText;
  final bool darken;
  final double width;
  const SingleImage({
    Key key,
    @required this.image,
    this.height,
    this.placeholderText = capitalizedAppName,
    this.placeHolderWidget,
    this.darken = false,
    this.fit = BoxFit.cover,
    this.width,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return image == null
        ? SizedBox()
        : image is File
            ? Image.file(
                image,
                height: height,
                width: width,
                fit: fit,
                colorBlendMode: darken ? BlendMode.darken : BlendMode.clear,
                color: darken
                    ? Colors.black.withOpacity(
                        darken ? 0.6 : 0.0,
                      )
                    : null,
              )
            : image.toString().trim().contains("assets/images")
                ? Image.asset(
                    image,
                    height: height,
                    width: width,
                    fit: fit,
                    colorBlendMode: darken ? BlendMode.darken : BlendMode.clear,
                    color: darken
                        ? Colors.black.withOpacity(
                            darken ? 0.6 : 0.0,
                          )
                        : null,
                  )
                : Image.network(
                    image,
                    height: height,
                    width: width,
                    fit: fit,
                    colorBlendMode: darken ? BlendMode.darken : BlendMode.clear,
                    color: darken
                        ? Colors.black.withOpacity(
                            darken ? 0.6 : 0.0,
                          )
                        : null,
                  );
  }
}
