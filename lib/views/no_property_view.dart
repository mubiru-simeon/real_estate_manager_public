import 'package:flutter/material.dart';
import 'package:dorx/constants/basic.dart';
import 'package:provider/provider.dart';
import '../constants/images.dart';
import '../models/models.dart';
import '../services/services.dart';

class NoPropertyView extends StatefulWidget {
  NoPropertyView({Key key}) : super(key: key);

  @override
  State<NoPropertyView> createState() => _NoPropertyViewState();
}

class _NoPropertyViewState extends State<NoPropertyView> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: Stack(
      children: [
        SizedBox.expand(
          child: FittedBox(
            fit: BoxFit.cover,
            child: Image.asset(
              compound,
              color: Colors.black.withOpacity(0.7),
              colorBlendMode: BlendMode.darken,
            ),
          ),
        ),
        Center(
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Spacer(),
                Image.asset(
                  dorxLogoLight,
                  height: 100,
                ),
                SizedBox(
                  height: 100,
                ),
                Text(
                  "Let's set up your Property so we can start getting bookings.",
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                  ),
                ),
                SizedBox(
                  height: 10,
                ),
                Row(
                  children: [
                    Expanded(
                      child: ElevatedButton(
                        onPressed: () {
                          StorageServices()
                              .launchTheThing("tel:$dorxPhoneNumber");
                        },
                        style: ButtonStyle(),
                        child: Padding(
                          padding: const EdgeInsets.all(15.0),
                          child: Text(
                            "Set Up A Property",
                            style: TextStyle(
                              fontSize: 18,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
                Spacer(),
                OutlinedButton(
                  onPressed: () {
                    StorageServices().launchTheThing(
                      "tel:$dorxPhoneNumber",
                    );
                  },
                  child: Text(
                    "Experiencing some trouble?",
                    style: TextStyle(
                      color: Colors.white,
                    ),
                  ),
                ),
                OutlinedButton(
                  onPressed: () async {
                    await AuthProvider.of(context).auth.signOut();

                    Provider.of<PropertyManagement>(context, listen: false)
                        .clear();
                  },
                  child: Text(
                    "Log Out",
                    style: TextStyle(
                      color: Colors.white,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    ));
  }
}
