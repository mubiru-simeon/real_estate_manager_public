import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dorx/views/all_customers_view.dart';
import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import 'package:provider/provider.dart';
import '../constants/constants.dart';
import '../models/models.dart';
import '../services/communications.dart';
import '../services/date_service.dart';
import '../services/ui_services.dart';
import '../widgets/widgets.dart';
import 'no_data_found_view.dart';

class AllRemindersView extends StatefulWidget {
  AllRemindersView({Key key}) : super(key: key);

  @override
  State<AllRemindersView> createState() => _AllRemindersViewState();
}

class _AllRemindersViewState extends State<AllRemindersView>
    with TickerProviderStateMixin {
  TabController controller;
  List modes = [];

  @override
  void initState() {
    super.initState();
    modes = [
      "all",
      Reminder.RENTISALMOSTDUE,
      Reminder.RENTISDUE,
      Reminder.CUSTOM,
    ];

    controller = TabController(
      vsync: this,
      length: modes.length,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: NestedScrollView(
        headerSliverBuilder: (gh, hg) {
          return [
            CustomSliverAppBar(
              title: "Scheduled Reminders",
            ),
            SliverList(
              delegate: SliverChildListDelegate([
                InformationalBox(
                  visible: true,
                  onClose: null,
                  message:
                      "All Reminders shown here will trigger on the intended day.",
                ),
              ]),
            ),
            SliverPersistentHeader(
              pinned: true,
              delegate: MySliverAppBarDelegate(
                TabBar(
                  controller: controller,
                  labelColor: getTabColor(context, true),
                  unselectedLabelColor: getTabColor(context, false),
                  isScrollable: true,
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
          controller: controller,
          children: modes
              .map(
                (e) => SingleReminderPage(
                  mode: e,
                ),
              )
              .toList(),
        ),
      ),
      floatingActionButton: FloatingActionButton(
          onPressed: () {
            UIServices().showDatSheet(
              AddAReminderBottomSheet(
                reminderType: Reminder.RENTISDUE,
              ),
              true,
              context,
            );
          },
          child: Icon(
            Icons.add,
          )),
    );
  }
}

class SingleReminderPage extends StatefulWidget {
  final String mode;
  SingleReminderPage({
    Key key,
    @required this.mode,
  }) : super(key: key);

  @override
  State<SingleReminderPage> createState() => _SingleReminderPageState();
}

class _SingleReminderPageState extends State<SingleReminderPage> {
  @override
  Widget build(BuildContext context) {
    return PaginateFirestore(
      padding: EdgeInsets.symmetric(horizontal: 5),
      isLive: true,
      onEmpty: NoDataFound(
        text: "No data Found",
      ),
      itemsPerPage: 5,
      itemBuilder: (context, snapshot, index) {
        Reminder reminder = Reminder.fromSnapshot(snapshot[index]);

        return SingleReminder(
          reminder: reminder,
          reminderID: reminder.id,
        );
      },
      query: getQuery(),
      itemBuilderType: PaginateBuilderType.listView,
    );
  }

  Query getQuery() {
    Query qq = FirebaseFirestore.instance
        .collection(Reminder.DIRECTORY)
        .where(
          Reminder.ENTITY,
          isEqualTo:
              Provider.of<PropertyManagement>(context).getCurrentPropertyID(),
        )
        .orderBy(
          Reminder.DATE,
          descending: true,
        );

    if (widget.mode != "all") {
      qq = qq.where(
        Reminder.REMINDERTYPE,
        isEqualTo: widget.mode,
      );
    }

    return qq;
  }
}

class ReminderDetailsBottomSheet extends StatefulWidget {
  final String reminderID;
  final Reminder reminder;
  ReminderDetailsBottomSheet({
    Key key,
    @required this.reminder,
    @required this.reminderID,
  }) : super(key: key);

  @override
  State<ReminderDetailsBottomSheet> createState() =>
      _ReminderDetailsBottomSheetState();
}

class _ReminderDetailsBottomSheetState
    extends State<ReminderDetailsBottomSheet> {
  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        BackBar(
          icon: null,
          onPressed: null,
          text: "Reminder Details",
        ),
        Expanded(
          child: SingleChildScrollView(
            child: Column(
              children: [
                SingleReminder(
                  reminder: widget.reminder,
                  reminderID: widget.reminderID,
                )
              ],
            ),
          ),
        )
      ],
    );
  }
}

class AddAReminderBottomSheet extends StatefulWidget {
  final String reminderType;

  AddAReminderBottomSheet({
    Key key,
    @required this.reminderType,
  }) : super(key: key);

  @override
  State<AddAReminderBottomSheet> createState() =>
      _AddAReminderBottomSheetState();
}

class _AddAReminderBottomSheetState extends State<AddAReminderBottomSheet> {
  DateTime reminderDate;
  bool processing = false;
  String customer;
  TimeOfDay reminderTime;
  Property property;
  TextEditingController entityMessageController = TextEditingController(
    text:
        "Hello. This is  We would like to remind you to deposit some money on your ",
  );
  TextEditingController partnerMessageController = TextEditingController(
    text:
        "Hello. This is a reminder for you to notify this customer to deposit some money on their wallet.",
  );

  @override
  void initState() {
    super.initState();
    property = Provider.of<PropertyManagement>(
      context,
      listen: false,
    ).getCurrentPropertyModel();

    entityMessageController = TextEditingController(
      text:
          "Hello. This is a system reminder you set reminding you to tell customer_name to deposit some money on his wallet. Thank you for using Dorx",
    );

    partnerMessageController = TextEditingController(
      text:
          "Hello. This is a polite reminder from ${property.name} reminding you to deposit some money on your ${property.name} wallet. Thank you for using Dorx",
    );
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        BackBar(
          icon: null,
          onPressed: null,
          text: "Add A Reminder",
        ),
        Expanded(
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: SingleChildScrollView(
              child: Column(
                children: [
                  SizedBox(
                    height: 10,
                  ),
                  CustomDivider(),
                  ListTile(
                    onTap: () async {
                      List pp = await UIServices().showDatSheet(
                        AllCustomersView(
                          returning: true,
                        ),
                        true,
                        context,
                      );

                      if (pp != null && pp.isNotEmpty) {
                        setState(() {
                          customer = pp[0];
                        });
                      }
                    },
                    leading: Icon(Icons.verified_user),
                    title: Text(
                      "Which customer do you need to remind?",
                    ),
                    subtitle: Text(
                      "Tap here to select the customer",
                    ),
                  ),
                  CustomDivider(),
                  if (customer != null)
                    SingleUser(
                      user: null,
                      userID: customer,
                    ),
                  SizedBox(
                    height: 20,
                  ),
                  HeadLineText(
                    onTap: null,
                    plain: true,
                    text: "Add a custom message for our client?",
                  ),
                  TextField(
                    controller: partnerMessageController,
                    maxLines: 5,
                    decoration: InputDecoration(
                      hintText: "Custom Message for the client",
                    ),
                  ),
                  SizedBox(
                    height: 10,
                  ),
                  HeadLineText(
                    onTap: null,
                    plain: true,
                    text:
                        "You can edit the message you shall receive when the reminder is triggered.",
                  ),
                  InformationalBox(
                      visible: true,
                      onClose: null,
                      message:
                          "We shall replace \"customer_name\" with the customer's name and also attatch relevant contact informartion."),
                  TextField(
                    maxLines: 5,
                    controller: entityMessageController,
                    decoration: InputDecoration(
                      hintText: "Custom Message for the Entity",
                    ),
                  ),
                  SizedBox(
                    height: 20,
                  ),
                  HeadLineText(
                    onTap: null,
                    plain: true,
                    text: "When do you want the reminder?",
                  ),
                  ProceedButton(
                    text: reminderDate != null
                        ? "Reminder on ${DateService().dateFromMilliseconds(
                            reminderDate.millisecondsSinceEpoch,
                          )}"
                        : "When do you want the recepient reminded?",
                    onTap: () async {
                      reminderDate = await showDatePicker(
                        context: context,
                        initialDate: reminderDate ?? DateTime.now(),
                        firstDate: DateTime.now(),
                        lastDate: DateTime.now().add(
                          Duration(days: 360),
                        ),
                      );

                      setState(() {});
                    },
                  ),
                  ProceedButton(
                    text: reminderTime != null
                        ? "Reminder at ${reminderTime.hour}: ${reminderTime.minute}"
                        : "What time?",
                    onTap: () async {
                      reminderTime = await showTimePicker(
                        context: context,
                        initialTime: reminderTime ?? TimeOfDay.now(),
                      );

                      setState(() {});
                    },
                  ),
                  SizedBox(
                    height: 20,
                  ),
                ],
              ),
            ),
          ),
        ),
        ProceedButton(
          onTap: () {
            if (reminderTime == null) {
              CommunicationServices().showToast(
                "Please provide the time.",
                Colors.red,
              );
            } else {
              if (reminderDate == null) {
                CommunicationServices().showToast(
                  "Please provide the date.",
                  Colors.red,
                );
              } else {
                if (customer == null) {
                  CommunicationServices().showToast(
                    "Please provide the customer.",
                    Colors.red,
                  );
                } else {
                  createReminder();
                }
              }
            }
          },
          text: "Proceed",
          processing: processing,
        )
      ],
    );
  }

  createReminder() async {
    DateTime dd = DateTime(
      reminderDate.year,
      reminderDate.month,
      reminderDate.day,
      reminderTime.hour,
      reminderTime.minute,
    );

    setState(() {
      processing = true;
    });

    String entityMessage = entityMessageController.text.trim();

    await FirebaseFirestore.instance
        .collection(UserModel.DIRECTORY)
        .doc(customer)
        .get()
        .then((value) {
      UserModel user = UserModel.fromSnapshot(
          value,
          Provider.of<PropertyManagement>(context, listen: false)
              .getCurrentPropertyID());

      entityMessage = entityMessage.replaceAll(
        'customer_name',
        user.userName,
      );

      entityMessage =
          "$entityMessage.\nClient's contact information: Phone Number- ${user.phoneNumber}\nEmail- ${user.email}";

      FirebaseFirestore.instance.collection(Reminder.DIRECTORY).add({
        Reminder.ENTITY: Provider.of<PropertyManagement>(
          context,
          listen: false,
        ).getCurrentPropertyID(),
        Reminder.PARTNER: customer,
        Reminder.PARTNERTYPE: ThingType.USER,
        Reminder.ENTITYTYPE: ThingType.PROPERTY,
        Reminder.ENTITYMESSAGE: entityMessage,
        Reminder.PARTNERMESSAGE: partnerMessageController.text.trim(),
        Reminder.REMINDERTYPE: widget.reminderType,
        Reminder.DAY: dd.day,
        Reminder.HOUR: dd.hour,
        Reminder.MINUTE: dd.minute,
        Reminder.ENTITYAPPLINK: realEstateManagerAppLinkToPlaystore,
        Reminder.PARTNERAPPLINK: clientAppLinkToPlaystore,
        Reminder.DATE: DateTime.now().millisecondsSinceEpoch,
        Reminder.MONTH: dd.month,
      }).then((value) {
        Navigator.of(context).pop();

        CommunicationServices().showToast(
          "Successfully added the reminder.",
          primaryColor,
        );
      });
    });
  }
}

class SingleReminder extends StatefulWidget {
  final String reminderID;
  final Reminder reminder;
  SingleReminder({
    Key key,
    @required this.reminder,
    @required this.reminderID,
  }) : super(key: key);

  @override
  State<SingleReminder> createState() => _SingleReminderState();
}

class _SingleReminderState extends State<SingleReminder> {
  String mode;
  Box box;

  @override
  void initState() {
    super.initState();
    box = Hive.box(DorxSettings.DORXBOXNAME);
  }

  @override
  Widget build(BuildContext context) {
    return widget.reminder == null
        ? StreamBuilder(
            stream: FirebaseFirestore.instance
                .collection(Reminder.DIRECTORY)
                .doc(widget.reminderID)
                .snapshots(),
            builder: (context, snapshot) {
              if (!snapshot.hasData) {
                return LoadingWidget();
              } else {
                if (snapshot.data.data() == null) {
                  return DeletedItem(
                    what: "Reminder",
                    thingID: null,
                  );
                } else {
                  Reminder reminder = Reminder.fromSnapshot(snapshot.data);

                  return body(
                    reminder,
                  );
                }
              }
            },
          )
        : body(
            widget.reminder,
          );
  }

  body(Reminder reminder) {
    mode = box.get(UserModel.ACCOUNTTYPES);

    return Container(
      padding: EdgeInsets.all(5),
      margin: EdgeInsets.symmetric(
        vertical: 4,
      ),
      decoration: BoxDecoration(
        borderRadius: standardBorderRadius,
        border: Border.all(
          color: Colors.grey,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ExpansionTile(
            expandedCrossAxisAlignment: CrossAxisAlignment.start,
            leading: CircleAvatar(
              child: Icon(
                Icons.info,
              ),
            ),
            subtitle: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "TAP HERE TO VIEW DETAILS ABOUT THIS REMINDER",
                  style: TextStyle(
                    fontStyle: FontStyle.italic,
                  ),
                ),
              ],
            ),
            title: Text(
              "Reminder Scheduled for ${reminder.day}th, ${months[reminder.month]} at ${reminder.hour}:${reminder.minute} hrs",
            ),
            children: [
              CopiableIDThing(
                thing: "Cron Job ID",
                id: reminder.cronJobID.toString(),
              ),
              SizedBox(
                height: 10,
              ),
              CopiableIDThing(
                id: reminder.id,
                thing: "Reminder ID",
              ),
              SizedBox(
                height: 10,
              ),
              Text(
                reminder.reminderType.toUpperCase(),
              ),
              SizedBox(
                height: 20,
              ),
              Text(
                "Entity Message",
                style: darkTitle,
              ),
              Text(
                reminder.entityMessage,
              ),
              SizedBox(
                height: 10,
              ),
              Text(
                "Partner Message",
                style: darkTitle,
              ),
              Text(
                reminder.partnerMessage,
              ),
              SizedBox(
                height: 10,
              ),
              Text(
                "Recepient",
                style: darkTitle,
              ),
              SinglePreviousItem(
                horizontal: false,
                usableThingID: reminder.partner,
                type: reminder.partnerType,
              ),
              SizedBox(
                height: 10,
              ),
              if (reminder.thingID != null)
                Text(
                  "The ${reminder.thingType}",
                  style: darkTitle,
                ),
              if (reminder.thingID != null)
                SinglePreviousItem(
                  usableThingID: reminder.thingID,
                  type: reminder.thingType,
                )
            ],
          ),
          CustomDivider(),
          if (mode == ThingType.PROPERTYMANAGER)
            Row(
              children: [
                Expanded(
                  child: SingleBigButton(
                    text: reminder.cancelled
                        ? "Cancelling the reminder. Please wait.."
                        : "Cancel This reminder",
                    color: Colors.red,
                    onPressed: () {
                      if (reminder.cancelled != true) {
                        showDialog(
                          context: context,
                          builder: (context) {
                            return CustomDialogBox(
                              bodyText:
                                  "Do you really want to cancel this reminder?",
                              buttonText: "Do It",
                              onButtonTap: () {
                                FirebaseFirestore.instance
                                    .collection(Reminder.DIRECTORY)
                                    .doc(reminder.id)
                                    .update({
                                  Reminder.CANCELLED: true,
                                });
                              },
                              showOtherButton: true,
                            );
                          },
                        );
                      }
                    },
                  ),
                )
              ],
            )
        ],
      ),
    );
  }
}
