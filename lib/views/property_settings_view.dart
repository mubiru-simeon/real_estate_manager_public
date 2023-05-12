import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dorx/constants/constants.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:syncfusion_flutter_charts/charts.dart';
import '../models/models.dart';
import '../services/services.dart';
import '../widgets/widgets.dart';

class PropertySettingsView extends StatefulWidget {
  final String propertyID;
  final Property property;
  PropertySettingsView({
    Key key,
    @required this.property,
    @required this.propertyID,
  }) : super(key: key);

  @override
  State<PropertySettingsView> createState() => _PropertySettingsViewState();
}

class _PropertySettingsViewState extends State<PropertySettingsView>
    with TickerProviderStateMixin {
  @override
  void initState() {
    super.initState();
    categories = [
      "statistics",
      "room types",
    ];

    _tabController = TabController(
      initialIndex: 0,
      length: categories.length,
      vsync: this,
    );
  }

  bool shareProcessing = false;
  TabController _tabController;
  List<String> categories;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: OnlyWhenLoggedIn(
        signedInBuilder: (uid) {
          return Stack(
            children: [
              NestedScrollView(
                headerSliverBuilder: (ctx, doIt) {
                  return [
                    SliverAppBar(
                      pinned: true,
                      floating: false,
                      snap: false,
                      leading: GestureDetector(
                        onTap: () {
                          Navigator.of(context).pop();
                        },
                        child: Icon(
                          Icons.arrow_back_ios,
                          color: Colors.white,
                        ),
                      ),
                      expandedHeight: 100,
                      flexibleSpace: FlexibleSpaceBar(
                        title: Text(
                          "Property Management",
                          style: TextStyle(
                            color: Colors.white,
                          ),
                        ),
                        background: Image.asset(
                          compound,
                          fit: BoxFit.cover,
                          color: Colors.black.withOpacity(0.5),
                          colorBlendMode: BlendMode.darken,
                        ),
                      ),
                    ),
                    SliverPersistentHeader(
                      pinned: true,
                      delegate: MySliverAppBarDelegate(
                        TabBar(
                          isScrollable: true,
                          labelColor: getTabColor(context, true),
                          unselectedLabelColor: getTabColor(context, false),
                          controller: _tabController,
                          tabs: categories
                              .map(
                                (e) => Tab(
                                  text: e.capitalizeFirstOfEach,
                                ),
                              )
                              .toList(),
                        ),
                      ),
                    )
                  ];
                },
                body: TabBarView(
                  controller: _tabController,
                  children: [
                    PropertyStatistics(
                      propertyID: widget.propertyID,
                    ),
                    PropertyRoomsView(
                      propertyID: widget.propertyID,
                    )
                  ],
                ),
              ),
              Positioned(
                bottom: 4,
                right: 2,
                child: SizedBox(
                  width: MediaQuery.of(context).size.width,
                  child: Row(
                    children: [
                      SizedBox(
                        width: 5,
                      ),
                      FloatingActionButton(
                        heroTag: "share_property",
                        onPressed: () async {
                          //TODO: share link
                          // setState(() {
                          //   shareProcessing = true;
                          // });

                          // String pp = await DynamicLinkServices().generateLink(
                          //   context: context,
                          //   id: widget.property.id,
                          //   title: widget.property.name,
                          //   desc: widget.property.description,
                          //   type: ThingType.PROPERTY,
                          //   image: widget.property.images.isEmpty
                          //       ? null
                          //       : widget.property.images[0],
                          //   userID: AuthProvider.of(context).auth.isSignedIn()
                          //       ? AuthProvider.of(context).auth.getCurrentUID()
                          //       : "anon",
                          // );

                          // if (pp != null) {
                          //   Share.share(
                          //     pp,
                          //     subject:
                          //         "Check out this ${ThingType.PROPERTY} from $capitalizedAppName",
                          //   );
                          // }

                          // setState(() {
                          //   shareProcessing = false;
                          // });
                        },
                        child: shareProcessing
                            ? CircularProgressIndicator()
                            : Icon(
                                Icons.share,
                              ),
                      ),
                      SizedBox(
                        width: 5,
                      ),
                    ],
                  ),
                ),
              )
            ],
          );
        },
      ),
    );
  }
}

class PropertyRoomsView extends StatefulWidget {
  final String propertyID;
  PropertyRoomsView({
    Key key,
    @required this.propertyID,
  }) : super(key: key);

  @override
  State<PropertyRoomsView> createState() => _PropertyRoomsViewState();
}

class _PropertyRoomsViewState extends State<PropertyRoomsView> {
  @override
  Widget build(BuildContext context) {
    return PaginateFirestore(
      itemBuilderType: PaginateBuilderType.listView,
      isLive: true,
      footer: SliverList(
        delegate: SliverChildListDelegate(
          [
            SizedBox(height: 80),
          ],
        ),
      ),
      query: FirebaseFirestore.instance
          .collection(RoomType.DIRECTORY)
          .where(RoomType.PROPERTY, isEqualTo: widget.propertyID),
      itemBuilder: (context, snapshot, index) {
        RoomType roomType = RoomType.fromSnapshot(snapshot[index]);

        return singleRoomType(
          roomType,
          roomType.id,
        );
      },
    );
  }

  singleRoomType(
    RoomType roomType,
    String roomTypeID,
  ) {
    return Container(
      height: MediaQuery.of(context).size.height * 0.5,
      decoration: BoxDecoration(
        border: Border.all(
          color: Colors.grey,
        ),
        borderRadius: standardBorderRadius,
      ),
      padding: EdgeInsets.all(3),
      margin: EdgeInsets.all(3),
      child: Column(
        children: [
          SingleRoomType(
            onEditRoomType: () {
              //TODO: Here
            },
            roomType: null,
            simple: true,
            roomTypeID: roomTypeID,
          ),
          SizedBox(
            height: 8,
          ),
          Expanded(
            child: SizedBox(
              height: MediaQuery.of(context).size.height * 0.3,
              child: PaginateFirestore(
                query: FirebaseFirestore.instance
                    .collection(
                      Room.DIRECTORY,
                    )
                    .where(
                      Room.ROOMTYPE,
                      isEqualTo: roomTypeID,
                    ),
                scrollDirection: Axis.horizontal,
                isLive: true,
                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                ),
                itemBuilder: (context, snapshot, index) {
                  Room room = Room.fromSnapshot(snapshot[index]);

                  return SingleRoomContainer(
                    room: room,
                    propertyID: widget.propertyID,
                  );
                },
                itemBuilderType: PaginateBuilderType.gridView,
              ),
            ),
          ),
          SizedBox(
            height: 10,
          )
        ],
      ),
    );
  }
}

class PropertyStatistics extends StatefulWidget {
  final String propertyID;
  PropertyStatistics({
    Key key,
    @required this.propertyID,
  }) : super(key: key);

  @override
  State<PropertyStatistics> createState() => _PropertyStatisticsState();
}

class _PropertyStatisticsState extends State<PropertyStatistics>
    with AutomaticKeepAliveClientMixin {
  String viewMode = SEVENDAYS;
  List<_ChartData> chartData = [];

  @override
  Widget build(BuildContext context) {
    super.build(context);

    return Scaffold(
      body: SingleChildScrollView(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: HeadLineText(
                onTap: null,
                plain: true,
                text: "Insights about your property and how it's performing.",
              ),
            ),
            SizedBox(
              height: 10,
            ),
            Material(
              color: Colors.grey,
              child: Padding(
                padding: const EdgeInsets.all(2),
                child: ListTile(
                  title: Text(viewMode),
                  subtitle: Text(
                      "${DateService().datewithoutFirstWords(DateTime.now().millisecondsSinceEpoch)} - ${DateService().datewithoutFirstWords(DateTime.now().subtract(Duration(days: viewMode == SEVENDAYS ? 7 : viewMode == THIRTYDAYS ? 30 : 180)).millisecondsSinceEpoch)}"),
                  trailing: DropdownButton<String>(
                    items: modes
                        .map(
                          (e) => DropdownMenuItem<String>(
                            value: e,
                            child: Text(e),
                          ),
                        )
                        .toList(),
                    value: viewMode,
                    onChanged: (v) {
                      if (v != null) {
                        setState(() {
                          viewMode = v;
                        });
                      }
                    },
                  ),
                ),
              ),
            ),
            SizedBox(
              height: 10,
            ),
            StreamBuilder(
              stream: FirebaseFirestore.instance
                  .collection(Analytics.DIRECTORY)
                  .doc(widget.propertyID)
                  .collection(widget.propertyID)
                  .where(
                    Analytics.DATE,
                    isGreaterThan: DateTime.now()
                        .subtract(
                          Duration(
                              days: viewMode == SEVENDAYS
                                  ? 7
                                  : viewMode == THIRTYDAYS
                                      ? 30
                                      : 180),
                        )
                        .millisecondsSinceEpoch,
                  )
                  .snapshots(),
              builder: (context, snapshot) {
                if (!snapshot.hasData) {
                  return LoadingWidget();
                } else {
                  List<Analytics> pp = [];

                  for (var item in snapshot.data.docs) {
                    Analytics analytics = Analytics.fromSnapshot(item);

                    pp.add(analytics);
                  }

                  return pp.length <= 1
                      ? Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Center(child: Text("Not Enough Data")),
                        )
                      : ChartThingie(analytics: pp);
                }
              },
            ),
            SizedBox(
              height: 10,
            ),
            GestureDetector(
              onTap: () {
                StorageServices().launchTheThing("tel:$dorxPhoneNumber");
              },
              child: InformationalBox(
                visible: true,
                onClose: null,
                message:
                    "Tap here to Boost and promote your service to increase your impressions and income",
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  bool get wantKeepAlive => true;
}

class ChartThingie extends StatefulWidget {
  final List<Analytics> analytics;
  ChartThingie({
    Key key,
    @required this.analytics,
  }) : super(key: key);

  @override
  State<ChartThingie> createState() => _ChartThingieState();
}

class _ChartThingieState extends State<ChartThingie> {
  List<_ChartData> chartData = [];

  int i = 0;

  @override
  Widget build(BuildContext context) {
    chartData.clear();

    for (var v in widget.analytics) {
      double mini = double.tryParse(v.count.toString());
      double maxi = double.tryParse(v.maxi.toString());
      //  double total = double.tryParse(v.total.toString());

      i = i + 1;

      chartData.add(
        _ChartData(
          DateTime.fromMillisecondsSinceEpoch(v.date),
          mini,
          maxi,
          //   total,
        ),
      );
    }

    return SfCartesianChart(
      plotAreaBorderWidth: 0,
      enableAxisAnimation: true,
      title: ChartTitle(text: 'Views'),
      legend: Legend(
        isVisible: true,
        position: LegendPosition.bottom,
        overflowMode: LegendItemOverflowMode.wrap,
      ),
      primaryXAxis: DateTimeAxis(
        dateFormat: DateFormat("d/M"),
      ),
      primaryYAxis: NumericAxis(
          labelFormat: '{value}',
          axisLine: const AxisLine(width: 0),
          majorTickLines: const MajorTickLines(
            color: Colors.transparent,
          )),
      series: _getDefaultLineSeries(),
      tooltipBehavior: TooltipBehavior(enable: true),
    );
  }

  List<LineSeries<_ChartData, dynamic>> _getDefaultLineSeries() {
    return <LineSeries<_ChartData, dynamic>>[
      LineSeries<_ChartData, dynamic>(
        animationDuration: 2500,
        dataSource: chartData,
        xValueMapper: (_ChartData sales, _) => sales.date,
        yValueMapper: (_ChartData sales, _) => sales.y1,
        width: 2,
        name: 'Mini',
        markerSettings: const MarkerSettings(isVisible: true),
      ),
      LineSeries<_ChartData, dynamic>(
        animationDuration: 2500,
        dataSource: chartData,
        width: 2,
        name: 'Max',
        xValueMapper: (_ChartData sales, _) => sales.date,
        yValueMapper: (_ChartData sales, _) => sales.y2,
        markerSettings: const MarkerSettings(
          isVisible: true,
        ),
      ),
      /*  LineSeries<_ChartData, num>(
        animationDuration: 2500,
        dataSource: chartData,
        xValueMapper: (_ChartData sales, _) => sales.date,
        yValueMapper: (_ChartData sales, _) => sales.sum,
        width: 2,
        name: 'Full Page',
        markerSettings: const MarkerSettings(isVisible: true),
      ), */
    ];
  }
}

class _ChartData {
  _ChartData(
    this.date,
    this.y1,
    this.y2,
    //  this.sum,
  );

  final DateTime date;
  final double y1;
  final double y2;
  // final double sum;
}
