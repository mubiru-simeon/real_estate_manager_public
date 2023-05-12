import 'package:flutter/material.dart';

import '../models/models.dart';

class DetailedBooking extends StatefulWidget {
  final Booking booking;
  final String bookingID;
  const DetailedBooking({
    Key key,
    @required this.booking,
    @required this.bookingID,
  }) : super(key: key);

  @override
  State<DetailedBooking> createState() => _DetailedBookingState();
}

class _DetailedBookingState extends State<DetailedBooking> {
  @override
  Widget build(BuildContext context) {
    return Container();
  }
}
