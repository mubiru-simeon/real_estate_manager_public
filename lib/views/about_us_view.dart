import 'package:dorx/models/language.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import '../constants/constants.dart';
import '../services/services.dart';
import '../widgets/widgets.dart';

class AboutUs extends StatefulWidget {
  AboutUs({
    Key key,
  }) : super(key: key);

  @override
  State<AboutUs> createState() => _AboutUsState();
}

class _AboutUsState extends State<AboutUs> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            BackBar(
              icon: null,
              onPressed: null,
              text: "${translation(context).about} $capitalizedAppName",
            ),
            Expanded(
              child: Padding(
                padding: EdgeInsets.symmetric(horizontal: 8.0),
                child: SingleChildScrollView(
                  child: Column(
                    children: [
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          Column(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Padding(
                                padding: const EdgeInsets.all(8.0),
                                child: Image(
                                  height: 100,
                                  image: AssetImage(
                                    dorxLogo,
                                  ),
                                ),
                              ),
                              Column(
                                children: [
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Text(
                                        capitalizedAppName,
                                        style: TextStyle(
                                          fontWeight: FontWeight.w700,
                                          color: Colors.purple,
                                          fontSize: 25,
                                        ),
                                      ),
                                      Text(
                                        ".",
                                        style: TextStyle(
                                          fontWeight: FontWeight.w700,
                                          fontSize: 25,
                                        ),
                                      ),
                                    ],
                                  ),
                                  Text(
                                    "${translation(context).version} $versionNumber",
                                    style: TextStyle(
                                      //fontWeight: FontWeight.w700,
                                      color: Colors.grey,
                                      fontSize: 18,
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ],
                      ),
                      CustomSizedBox(
                        sbSize: SBSize.smallest,
                        height: true,
                      ),
                      Text(
                        translation(context)
                            .appCatchPhrase
                            .capitalizeFirstOfEach,
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          color: Colors.grey,
                        ),
                      ),
                      CustomSizedBox(
                        sbSize: SBSize.small,
                        height: true,
                      ),
                      CustomDivider(),
                      CustomSizedBox(
                        sbSize: SBSize.small,
                        height: true,
                      ),
                      iconThing(
                        FontAwesomeIcons.locationArrow,
                        " Kulambiro Ring road, next to Pal and Lisa Secondary and Junior school",
                        () {
                          LocationService().openInGoogleMaps(
                            dorxOfficeLocation.latitude,
                            dorxOfficeLocation.longitude,
                          );
                        },
                      ),
                      iconThing(
                        FontAwesomeIcons.phone,
                        dorxPhoneNumber,
                        () {
                          StorageServices().launchTheThing(
                            "tel:$dorxPhoneNumber",
                          );
                        },
                      ),
                      iconThing(
                        Icons.email,
                        dorxEmail,
                        () {
                          StorageServices().launchTheThing(
                            "mailto:$dorxEmail?subject=Greetings&body=Hello",
                          );
                        },
                      ),
                      iconThing(
                        FontAwesomeIcons.facebook,
                        dorxFacebook,
                        () {
                          StorageServices().launchSocialLink(
                            dorxFacebook,
                            FACEBOOKURLLEAD,
                          );
                        },
                      ),
                      iconThing(
                        FontAwesomeIcons.twitter,
                        dorxTwitter,
                        () {
                          StorageServices().launchSocialLink(
                            dorxTwitter,
                            TWITTERURLLEAD,
                          );
                        },
                      ),
                      iconThing(
                        FontAwesomeIcons.instagram,
                        dorxInstagram,
                        () {
                          StorageServices().launchSocialLink(
                            dorxInstagram,
                            INSTAGRAMURLLEAD,
                          );
                        },
                      ),
                      CustomSizedBox(
                        sbSize: SBSize.small,
                        height: true,
                      ),
                      CustomDivider(),
                      CustomSizedBox(
                        sbSize: SBSize.small,
                        height: true,
                      ),
                      Text(
                        translation(context).thisAppAndAllIts,
                        textAlign: TextAlign.center,
                      ),
                      CustomSizedBox(
                        sbSize: SBSize.small,
                        height: true,
                      ),
                      CustomDivider(),
                      ListTile(
                        leading: Icon(
                          Icons.phone,
                        ),
                        title: Text(
                          translation(context).emailUs,
                        ),
                        onTap: () async {
                          StorageServices()
                              .launchTheThing("tel:$dorxPhoneNumber");
                        },
                      ),
                      CustomDivider(),
                      CustomSizedBox(
                        sbSize: SBSize.smallest,
                        height: true,
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  iconThing(
    IconData icon,
    String text,
    Function onTap,
  ) {
    return GestureDetector(
      onTap: () {
        onTap();
      },
      child: Row(
        children: [
          IconButton(
            onPressed: () {
              onTap();
            },
            icon: Icon(
              icon,
            ),
          ),
          Expanded(
            child: Text(
              text,
            ),
          )
        ],
      ),
    );
  }
}
