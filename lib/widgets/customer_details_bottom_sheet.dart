import 'package:dorx/models/language.dart';
import 'package:flutter/material.dart';

import '../models/user.dart';
import '../services/communications.dart';
import 'proceed_button.dart';
import 'top_back_bar.dart';

class CustomerDetailsBottomSheet extends StatefulWidget {
  final String title;
  CustomerDetailsBottomSheet({
    Key key,
    @required this.title,
  }) : super(key: key);

  @override
  State<CustomerDetailsBottomSheet> createState() =>
      _CustomerDetailsBottomSheetState();
}

class _CustomerDetailsBottomSheetState
    extends State<CustomerDetailsBottomSheet> {
  TextEditingController nameController = TextEditingController();
  TextEditingController emailController = TextEditingController();
  TextEditingController phoneNumberController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          BackBar(
            icon: null,
            onPressed: null,
            text: widget.title ?? translation(context).aFewMoreDetails,
          ),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: SingleChildScrollView(
                child: Column(
                  children: [
                    TextFormField(
                      controller: nameController,
                      decoration: InputDecoration(
                        hintText: translation(context).firstName,
                      ),
                    ),
                    SizedBox(
                      height: 5,
                    ),
                    TextFormField(
                      controller: phoneNumberController,
                      decoration: InputDecoration(
                          hintText: translation(context).phoneNumber),
                    ),
                    SizedBox(
                      height: 5,
                    ),
                    TextFormField(
                      controller: emailController,
                      keyboardType: TextInputType.emailAddress,
                      decoration: InputDecoration(
                        hintText: translation(context).email,
                      ),
                    ),
                    SizedBox(
                      height: 5,
                    ),
                  ],
                ),
              ),
            ),
          )
        ],
      ),
      bottomNavigationBar: Wrap(children: [
        ProceedButton(
            text: translation(context).proceed,
            onTap: () {
              if (nameController.text.trim().isEmpty) {
                CommunicationServices().showToast(
                  "Please tell us your name",
                  Colors.red,
                );
              } else {
                Navigator.of(context).pop({
                  UserModel.EMAIL: emailController.text.trim(),
                  UserModel.PHONENUMBER: phoneNumberController.text.trim(),
                  UserModel.USERNAME: nameController.text.trim(),
                });
              }
            })
      ]),
    );
  }
}
