import 'package:animate_do/animate_do.dart';
import 'package:dorx/views/no_data_found_view.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import '../models/models.dart';
import '../widgets/widgets.dart';

class PaymentsView extends StatefulWidget {
  final String viewerID;
  final String viewerType;

  PaymentsView({
    Key key,
    @required this.viewerType,
    @required this.viewerID,
  }) : super(key: key);

  @override
  State<PaymentsView> createState() => _PaymentsViewState();
}

class _PaymentsViewState extends State<PaymentsView> {
  ScrollController _scrollController;
  bool _isScrolled = false;

  @override
  void initState() {
    _scrollController = ScrollController();
    _scrollController.addListener(_listenToScrollChange);

    super.initState();
  }

  void _listenToScrollChange() {
    if (_scrollController.offset >= 100.0) {
      setState(() {
        _isScrolled = true;
      });
    } else {
      setState(() {
        _isScrolled = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: CustomScrollView(
        controller: _scrollController,
        slivers: [
          PaymentsViewappBar(
            isScrolled: _isScrolled,
            viewerType: widget.viewerType,
            viewerID: widget.viewerID,
          ),
          SliverFillRemaining(
            child: FadeInDown(
              duration: Duration(milliseconds: 500),
              child: PaginateFirestore(
                isLive: true,
                onEmpty: NoDataFound(text: "No Payment History Yet"),
                itemBuilderType: PaginateBuilderType.listView,
                query: FirebaseFirestore.instance
                    .collection(Payment.DIRECTORY)
                    .where(
                      Payment.PARTICIPANTS,
                      arrayContains: widget.viewerID,
                    )
                    .orderBy(Payment.TIME, descending: true),
                itemsPerPage: 3,
                itemBuilder: (
                  context,
                  snapshot,
                  index,
                ) {
                  Payment payment = Payment.fromSnapshot(
                    snapshot[index],
                    widget.viewerID,
                  );

                  return SinglePayment(
                    payment: payment,
                    paymentID: payment.id,
                    paymentViewerID: widget.viewerID,
                  );
                },
                padding: EdgeInsets.only(
                  left: 10,
                  right: 10,
                  top: 10,
                ),
              ),
            ),
          )
        ],
      ),
    );
  }
}

enum PaymentType {
  deposit,
  credit,
  withdrawal,
}
