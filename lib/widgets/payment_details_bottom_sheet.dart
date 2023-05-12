import 'package:dorx/models/thing_type.dart';
import 'package:dorx/widgets/proceed_button.dart';
import 'package:dorx/widgets/single_payment.dart';
import 'package:dorx/widgets/top_back_bar.dart';
import 'package:flutter/material.dart';
import '../constants/constants.dart';
import '../models/payment.dart';
import '../services/services.dart';

class PaymentDetailsBottomSheet extends StatefulWidget {
  final Payment payment;
  final String paymentID;
  final String paymentViewerID;
  PaymentDetailsBottomSheet({
    Key key,
    @required this.payment,
    @required this.paymentID,
    @required this.paymentViewerID,
  }) : super(key: key);

  @override
  State<PaymentDetailsBottomSheet> createState() =>
      _PaymentDetailsBottomSheetState();
}

class _PaymentDetailsBottomSheetState extends State<PaymentDetailsBottomSheet> {
  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        BackBar(
          icon: null,
          onPressed: null,
          text: "Details About This Payment",
        ),
        Expanded(
          child: SingleChildScrollView(
            child: Column(
              children: [
                SinglePayment(
                  payment: widget.payment,
                  paymentID: widget.paymentID,
                  simple: false,
                  paymentViewerID: widget.paymentViewerID,
                ),
              ],
            ),
          ),
        ),
        if (appMode != ThingType.ADMIN)
          ProceedButton(
            text: "Something wrong? Tap here to call us. We're eager to help.",
            onTap: () {
              StorageServices().launchTheThing("tel:$dorxPhoneNumber");
            },
          )
      ],
    );
  }
}
