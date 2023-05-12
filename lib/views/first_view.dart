import 'package:dorx/models/language.dart';
import 'package:dorx/services/services.dart';
import 'package:dorx/widgets/language_changer_widget.dart';
import 'package:flutter/material.dart';
import 'package:dorx/widgets/single_image.dart';
import '../constants/basic.dart';
import '../constants/images.dart';
import '../constants/ui.dart';

class FirstView extends StatelessWidget {
  const FirstView({Key key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final screenwidth = MediaQuery.of(context).size.width;
    final screenheight = MediaQuery.of(context).size.height;

    return Scaffold(
      backgroundColor: darkBgColor,
      body: SizedBox(
        width: screenwidth,
        height: screenheight,
        child: Stack(
          children: <Widget>[
            SizedBox.expand(
              child: FittedBox(
                fit: BoxFit.cover,
                child: Image.asset(
                  bedroom,
                  color: Colors.black.withOpacity(0.7),
                  colorBlendMode: BlendMode.darken,
                ),
              ),
            ),
            Positioned(
              top: 10,
              left: 10,
              right: 10,
              child: SafeArea(
                child: SingleImage(
                  height: 150,
                  fit: BoxFit.contain,
                  width: 250,
                  image: dorxLogoLight,
                ),
              ),
            ),
            Positioned(
              top: 10,
              right: 10,
              child: SafeArea(
                child: LanguageChangerWidget(
                  widgetColor: Colors.white,
                ),
              ),
            ),
            Positioned(
              bottom: 0,
              right: 0,
              left: 0,
              child: Container(
                padding: EdgeInsets.only(left: 10, right: 10),
                //height: _screenheight * 0.4,
                alignment: Alignment.bottomCenter,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [
                        Colors.transparent,
                        Colors.grey,
                      ],
                      stops: [
                        0,
                        0.9
                      ]),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    SizedBox(
                      height: 50,
                    ),
                    SizedBox(
                      width: screenwidth,
                      child: Row(
                        children: <Widget>[
                          Text(
                            capitalizedAppName,
                            textAlign: TextAlign.start,
                            style: TextStyle(
                              fontWeight: FontWeight.w700,
                              color: primaryColor,
                              fontSize: 25,
                            ),
                          ),
                          Text(
                            ".",
                            textAlign: TextAlign.start,
                            style: TextStyle(
                              fontWeight: FontWeight.w700,
                              color: Colors.white,
                              fontSize: 25,
                            ),
                          ),
                        ],
                      ),
                    ),
                    SizedBox(
                      height: 10,
                    ),
                    Text(
                      translation(context).appCatchPhrase.capitalizeFirstOfEach,
                      textAlign: TextAlign.start,
                      style: TextStyle(
                        color: Colors.white,
                      ),
                    ),
                    SizedBox(
                      height: screenheight * 0.03,
                    ),
                    Center(
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          padding: EdgeInsets.only(
                            top: 20,
                            left: 30,
                            right: 30,
                            bottom: 20,
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(
                              20,
                            ),
                          ),
                          backgroundColor: primaryColor,
                        ),
                        onPressed: () {
                          UIServices().showLoginSheet(
                            AuthFormType.signIn,
                            (v) {},
                            context,
                          );
                        },
                        child: Text(
                          translation(context).getStarted.capitalizeFirstOfEach,
                          style: TextStyle(
                            fontSize: 18,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ),
                    SizedBox(
                      height: 20,
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
