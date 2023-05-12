import 'package:dorx/constants/constants.dart';
import 'package:dorx/services/storage_services.dart';
import 'package:flutter/material.dart';

import 'widgets.dart';

class BenefitsOfSigningIn extends StatefulWidget {
  BenefitsOfSigningIn({Key key}) : super(key: key);

  @override
  State<BenefitsOfSigningIn> createState() => _BenefitsOfSigningInState();
}

class _BenefitsOfSigningInState extends State<BenefitsOfSigningIn> {
  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Column(
          children: [
            Expanded(
              child: AnimatedBackground(
                image: lobby,
              ),
            ),
            SizedBox(
              height: 100,
            )
          ],
        ),
        SpreadCircles(),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: Stack(
                children: [
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 15.0),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.start,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        SizedBox(
                          height: 10,
                        ),
                        AnimatedTextKit(
                          totalRepeatCount: 1,
                          animatedTexts: [
                            TyperAnimatedText(
                              "What do i get when i upgrade to a Pro account?",
                              textStyle: TextStyle(
                                fontWeight: FontWeight.w600,
                                fontSize: 23.0,
                              ),
                            ),
                          ],
                        ),
                        Spacer(),
                        AnimatedTextKit(
                          repeatForever: true,
                          pause: Duration(milliseconds: 500),
                          animatedTexts: [
                            "Manage tenant details",
                            "Document management and storage",
                            "Walk-in tenants (non Dorx Customers)",
                            "Room service requests",
                            "Restaurant management",
                            "Ability to edit your property listing any time",
                            "Manage all your expenses",
                            "Advanced room management and booking features",
                          ].map((e) {
                            return RotateAnimatedText(
                              e,
                              duration: Duration(milliseconds: 2000),
                              textStyle: TextStyle(
                                fontSize: 30,
                                color: primaryColor,
                              ),
                            );
                          }).toList(),
                        ),
                        SizedBox(
                          height: 20,
                        ),
                      ],
                    ),
                  )
                ],
              ),
            ),
            SingleBigButton(
              color: primaryColor,
              onPressed: () async {
                StorageServices().launchTheThing(
                  "tel:$dorxPhoneNumber",
                );
              },
              text:
                  "Press here to contact $capitalizedAppName team and get upgraded.",
            )
          ],
        ),
      ],
    );
  }
}
