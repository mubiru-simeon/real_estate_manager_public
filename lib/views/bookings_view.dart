import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dorx/constants/constants.dart';
import 'package:dorx/models/models.dart';
import 'package:dorx/services/services.dart';
import 'package:dorx/views/no_data_found_view.dart';
import 'package:dorx/widgets/widgets.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class BookingsView extends StatefulWidget {
  const BookingsView({Key key}) : super(key: key);

  @override
  State<BookingsView> createState() => _BookingsViewState();
}

class _BookingsViewState extends State<BookingsView>
    with TickerProviderStateMixin {
  bool visible = true;

  List modes = [
    Booking.PENDING,
    Booking.APPROVED,
    Booking.CHECKEDIN,
    Booking.ONGOING,
    "History",
    Booking.CANCELLED,
    Booking.REJECTED,
  ];

  TabController tabController;

  @override
  void initState() {
    tabController = TabController(
      length: modes.length,
      vsync: this,
    );

    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return NestedScrollView(
      headerSliverBuilder: (gh, hg) {
        return [
          SliverList(
            delegate: SliverChildListDelegate(
              [
                if (!Provider.of<PropertyManagement>(context)
                    .getCurrentPropertyModel()
                    .useAdvanced)
                  GestureDetector(
                    onTap: () {
                      UIServices().showDatSheet(
                        BenefitsOfSigningIn(),
                        true,
                        context,
                      );
                    },
                    child: InformationalBox(
                      visible: visible,
                      onClose: () {
                        setState(() {
                          visible = false;
                        });
                      },
                      message:
                          "There are many other useful real estate management tools you can use in this same app. Tap here to learn more.",
                    ),
                  ),
              ],
            ),
          ),
          SliverPersistentHeader(
            pinned: true,
            delegate: MySliverAppBarDelegate(
              TabBar(
                isScrollable: true,
                controller: tabController,
                labelColor: getTabColor(context, true),
                unselectedLabelColor: getTabColor(context, false),
                tabs: modes
                    .map(
                      (e) => Tab(
                        text: e.toString().toUpperCase(),
                      ),
                    )
                    .toList(),
              ),
            ),
          )
        ];
      },
      body: TabBarView(
        controller: tabController,
        children: modes
            .map(
              (e) => SingleBookingView(
                mode: e,
              ),
            )
            .toList(),
      ),
    );
  }
}

class SingleBookingView extends StatefulWidget {
  final String mode;
  const SingleBookingView({
    Key key,
    @required this.mode,
  }) : super(key: key);

  @override
  State<SingleBookingView> createState() => _SingleBookingViewState();
}

class _SingleBookingViewState extends State<SingleBookingView> {
  @override
  Widget build(BuildContext context) {
    return PaginateFirestore(
      itemBuilderType: PaginateBuilderType.listView,
      isLive: true,
      onEmpty: NoDataFound(
        onTap: () {
          StorageServices().launchTheThing(
            "tel:$dorxPhoneNumber",
          );
        },
        doSthText: "Tap here to call us. We can help",
        text:
            "No bookings here.\nAre you facing some difficulty getting bookings?",
      ),
      query: getQuery(),
      itemBuilder: (context, snapshot, index) {
        Booking booking = Booking.fromSnapshot(snapshot[index]);

        return SingleBooking(
          index: index,
          bookingID: booking.id,
          booking: booking,
        );
      },
    );
  }

  Query getQuery() {
    Query qq = FirebaseFirestore.instance
        .collection(Booking.DIRECTORY)
        .where(
          Booking.PROPERTY,
          isEqualTo:
              Provider.of<PropertyManagement>(context).getCurrentPropertyID(),
        )
        .orderBy(
          Booking.DATE,
        );

    if (widget.mode == "history") {
      qq = qq.where(Booking.COMPLETE, isEqualTo: true);
    } else {
      qq = qq.where(widget.mode, isEqualTo: true);
    }

    return qq;
  }
}

class SingleBooking extends StatefulWidget {
  final Booking booking;
  final String bookingID;
  final int index;

  SingleBooking({
    Key key,
    @required this.booking,
    @required this.bookingID,
    this.index,
  }) : super(key: key);

  @override
  State<SingleBooking> createState() => _SingleBookingState();
}

class _SingleBookingState extends State<SingleBooking> {
  bool processing = false;
  bool callProcessing = false;

  @override
  Widget build(BuildContext context) {
    return widget.booking == null
        ? StreamBuilder(
            stream: FirebaseFirestore.instance
                .collection(Booking.DIRECTORY)
                .doc(widget.bookingID)
                .snapshots(),
            builder: (context, snapshot) {
              if (snapshot.hasData) {
                if (snapshot.data.data() == null) {
                  return DeletedItem(
                    what: "Booking",
                    thingID: widget.bookingID,
                  );
                } else {
                  Booking model = Booking.fromSnapshot(
                    snapshot.data,
                  );

                  return body(model);
                }
              } else {
                return LoadingWidget();
              }
            })
        : body(
            widget.booking,
          );
  }

  body(Booking booking) {
    return Material(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              SizedBox(
                width: 10,
              ),
              if (widget.index != null)
                Text(
                  widget.index.toString(),
                ),
              SizedBox(
                width: 10,
              ),
              if (widget.index != null) divider(true),
              SizedBox(
                width: 10,
              ),
              Expanded(
                child: Text(
                  "${DateService().dateFromMilliseconds(
                    booking.date,
                  )} at ${DateService().timeIn24Hours(
                    booking.date,
                  )} ",
                ),
              ),
              divider(true),
              SizedBox(
                width: 10,
              ),
              Expanded(
                child: Text(
                  booking.name,
                ),
              ),
              SizedBox(
                width: 10,
              ),
              divider(true),
              SizedBox(
                width: 10,
              ),
              SingleBigButton(
                color: primaryColor,
                text: booking.pending ? "Follow up" : "View Details",
                onPressed: () {
                  context.pushNamed(
                    RouteConstants.bookingManagement,
                    params: {
                      "id": booking.id,
                    },
                  );
                },
              ),
              SizedBox(
                width: 10,
              ),
            ],
          ),
          divider(
            false,
          )
        ],
      ),
    );
  }

  Widget divider(bool vertical) {
    return Container(
      margin: EdgeInsets.symmetric(
        horizontal: 5,
      ),
      width: vertical ? 2 : double.infinity,
      color: Colors.grey,
      height: vertical ? 50 : 2,
    );
  }
}
