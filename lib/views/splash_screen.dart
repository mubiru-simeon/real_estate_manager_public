import 'dart:async';
import 'package:dorx/constants/constants.dart';
import 'package:flutter/material.dart';
import 'package:dorx/widgets/pulser.dart';
import '../services/services.dart';

class SplashScreenView extends StatefulWidget {
  SplashScreenView({Key key}) : super(key: key);

  @override
  State<SplashScreenView> createState() => _SplashScreenViewState();
}

class _SplashScreenViewState extends State<SplashScreenView> {
  @override
  void initState() {
    super.initState();
    startTime();
  }

  void navigationPage() async {
    context.pushReplacementNamed(
      RouteConstants.allMyProperties,
    );
  }

  startTime() async {
    var duration = Duration(seconds: 3);
    return Timer(duration, navigationPage);
  }

  @override
  Widget build(BuildContext context) {
    AuthProvider.of(context).auth.reloadAccount(context);

    return Scaffold(
      backgroundColor: darkBgColor,
      body: SizedBox(
        height: MediaQuery.of(context).size.height,
        child: SafeArea(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Spacer(
                flex: 1,
              ),
              Center(
                child: Pulser(
                  duration: 800,
                  child: Image(
                    width: MediaQuery.of(context).size.width * 0.4,
                    image: AssetImage(
                      dorxLogoLight,
                    ),
                  ),
                ),
              ),
              Spacer(
                flex: 2,
              ),
              SizedBox(
                height: 20,
              )
            ],
          ),
        ),
      ),
    );
  }
}
