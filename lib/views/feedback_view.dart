import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dorx/constants/constants.dart';
import 'package:dorx/services/services.dart';
import 'package:dorx/widgets/widgets.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/models.dart';

class FeedbackView extends StatefulWidget {
  const FeedbackView({Key key}) : super(key: key);

  @override
  State<FeedbackView> createState() => _FeedbackViewState();
}

class _FeedbackViewState extends State<FeedbackView>
    with TickerProviderStateMixin, AutomaticKeepAliveClientMixin {
  List modes = [
    "pending",
    "handled",
  ];

  TabController tabController;

  @override
  void initState() {
    super.initState();
    tabController = TabController(
      length: modes.length,
      vsync: this,
    );
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);

    return NestedScrollView(
      headerSliverBuilder: (gh, hg) {
        return [
          SliverPersistentHeader(
            pinned: true,
            delegate: MySliverAppBarDelegate(
              TabBar(
                controller: tabController,
                isScrollable: true,
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
              (e) => SingleFeedbackView(
                mode: e,
              ),
            )
            .toList(),
      ),
    );
  }

  @override
  bool get wantKeepAlive => true;
}

class SingleFeedbackView extends StatefulWidget {
  final String mode;

  const SingleFeedbackView({
    Key key,
    @required this.mode,
  }) : super(key: key);

  @override
  State<SingleFeedbackView> createState() => _SingleFeedbackViewState();
}

class _SingleFeedbackViewState extends State<SingleFeedbackView>
    with AutomaticKeepAliveClientMixin {
  @override
  Widget build(BuildContext context) {
    super.build(context);

    return PaginateFirestore(
      itemBuilderType: PaginateBuilderType.listView,
      isLive: true,
      query: getQuery(),
      itemBuilder: (context, snapshot, index) {
        UserFeedback userFeedback = UserFeedback.fromSnapshot(snapshot[index]);

        return Container(
          decoration: BoxDecoration(
            border: Border.all(),
            borderRadius: standardBorderRadius,
          ),
          margin: EdgeInsets.symmetric(
            horizontal: 10,
            vertical: 5,
          ),
          padding: EdgeInsets.all(5),
          child: Column(
            children: [
              ListTile(
                title: Text(
                  userFeedback.text.toString(),
                ),
                subtitle: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "Category: ${userFeedback.category.toUpperCase()}",
                    ),
                    if (userFeedback.internal)
                      Text(
                        "This is an internal message",
                      ),
                    SizedBox(
                      height: 5,
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        Text(
                          DateService().dateFromMilliseconds(
                            userFeedback.date,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              if (userFeedback.pending)
                SingleBigButton(
                  text: "Mark as handled",
                  color: primaryColor,
                  onPressed: () {
                    showDialog(
                      context: context,
                      builder: (context) {
                        return CustomDialogBox(
                          bodyText:
                              "Are you sure you want to mark this feedback as handled?",
                          buttonText: "Proceed",
                          onButtonTap: () {
                            FirebaseFirestore.instance
                                .collection(UserFeedback.DIRECTORY)
                                .doc(userFeedback.id)
                                .update({
                              UserFeedback.PENDING: false,
                            });
                          },
                          showOtherButton: true,
                        );
                      },
                    );
                  },
                ),
            ],
          ),
        );
      },
    );
  }

  Query getQuery() {
    Query qq = FirebaseFirestore.instance
        .collection(UserFeedback.DIRECTORY)
        .where(UserFeedback.ENTITY,
            isEqualTo:
                Provider.of<PropertyManagement>(context).getCurrentPropertyID())
        .orderBy(
          UserFeedback.DATE,
          descending: true,
        );

    if (widget.mode == UserFeedback.PENDING) {
      qq = qq.where(
        UserFeedback.PENDING,
        isEqualTo: true,
      );
    } else {
      qq = qq.where(
        UserFeedback.PENDING,
        isEqualTo: false,
      );
    }

    return qq;
  }

  @override
  bool get wantKeepAlive => true;
}
