import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

import '../models/models.dart';
import '../services/services.dart';
import 'widgets.dart';

class SetRulesBottomSheet extends StatefulWidget {
  final dynamic existingRules;
  final dynamic additionalRules;
  SetRulesBottomSheet({
    Key key,
    @required this.existingRules,
    @required this.additionalRules,
  }) : super(key: key);

  @override
  State<SetRulesBottomSheet> createState() => _SetRulesBottomSheetState();
}

class _SetRulesBottomSheetState extends State<SetRulesBottomSheet> {
  Map houseRules = {};
  Map additionalRules = {};
  bool tipVisible = true;

  @override
  void initState() {
    super.initState();
    if (widget.existingRules != null) {
      widget.existingRules.forEach((k, v) {
        houseRules.addAll({k: v});
      });
    }

    if (widget.additionalRules != null) {
      widget.additionalRules.forEach((k, v) {
        additionalRules.addAll({k: v});
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        BackBar(
          icon: null,
          onPressed: null,
          text: "House Rules",
        ),
        CustomDivider(),
        ListTile(
          onTap: () async {
            Map pp = await UIServices().showDatSheet(
              AddNewHouseRule(),
              true,
              context,
            );

            if (pp != null && pp.isNotEmpty) {
              setState(() {
                additionalRules.addAll(
                  {
                    pp[HouseRules.NAME]: {
                      HouseRules.PROHIBITED: pp[HouseRules.PROHIBITED] ?? true
                    },
                  },
                );
              });
            }
          },
          title: Text(
            "Custom Rules",
          ),
          trailing: Text(
            "Add",
            style: TextStyle(
              decoration: TextDecoration.underline,
              fontWeight: FontWeight.bold,
              decorationStyle: TextDecorationStyle.solid,
            ),
          ),
          subtitle: Text(
            "Any other rules you want to add? Should guests clean up as they're leaving?",
          ),
        ),
        CustomDivider(),
        Expanded(
          child: PaginateFirestore(
            header: SliverList(
              delegate: SliverChildListDelegate(
                additionalRules.entries.map<Widget>((e) {
                  HouseRules rule = HouseRules.fromMap(
                    e.key,
                    e.value[HouseRules.PROHIBITED],
                  );

                  return singleRule(
                    rule,
                    additionalRules,
                    additionalRule: true,
                  );
                }).followedBy([
                  SizedBox(
                    height: 10,
                  ),
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Text(
                      "Usual Houserules. Tap on the tick for something that's allowed and the X for what is prohibited.",
                    ),
                  ),
                ]).toList(),
              ),
            ),
            isLive: true,
            itemBuilder: (
              context,
              snapshot,
              index,
            ) {
              HouseRules rule = HouseRules.fromSnapshot(
                snapshot[index],
              );

              return singleRule(
                rule,
                houseRules,
              );
            },
            itemBuilderType: PaginateBuilderType.listView,
            query: FirebaseFirestore.instance.collection(HouseRules.DIRECTORY),
          ),
        ),
        ProceedButton(
          text: "Proceed",
          onTap: () {
            Navigator.of(context).pop({
              HouseRules.HOUSERULES: houseRules,
              HouseRules.ADDITIONALRULES: additionalRules,
            });
          },
        )
      ],
    );
  }

  singleRule(
    HouseRules rule,
    Map pp, {
    bool additionalRule = false,
  }) {
    return Column(
      children: [
        ListTile(
          title: Text(rule.name),
          trailing: SizedBox(
            width: MediaQuery.of(context).size.width *
                (additionalRule ? 0.3 : 0.2),
            child: Row(
              children: [
                Expanded(
                  child: GestureDetector(
                    onTap: () {
                      setState(() {
                        if (pp.containsKey(rule.name)) {
                          if (pp[rule.name][HouseRules.PROHIBITED]) {
                            pp.addAll({
                              rule.name: {
                                HouseRules.PROHIBITED: false,
                              }
                            });
                          } else {
                            pp.remove(rule.name);
                          }
                        } else {
                          pp.addAll({
                            rule.name: {
                              HouseRules.PROHIBITED: false,
                            }
                          });
                        }
                      });
                    },
                    child: Container(
                      decoration: BoxDecoration(
                        color: pp.containsKey(rule.name) &&
                                pp[rule.name][HouseRules.PROHIBITED] == false
                            ? Colors.green
                            : null,
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: Colors.grey,
                        ),
                      ),
                      padding: EdgeInsets.all(2),
                      child: Icon(Icons.done,
                          color: pp.containsKey(rule.name) &&
                                  pp[rule.name][HouseRules.PROHIBITED] == false
                              ? Colors.white
                              : null),
                    ),
                  ),
                ),
                SizedBox(
                  width: 5,
                ),
                Expanded(
                  child: GestureDetector(
                    onTap: () {
                      setState(
                        () {
                          if (pp.containsKey(rule.name)) {
                            if (pp[rule.name][HouseRules.PROHIBITED] == false) {
                              pp.addAll({
                                rule.name: {
                                  HouseRules.PROHIBITED: true,
                                }
                              });
                            } else {
                              pp.remove(rule.name);
                            }
                          } else {
                            pp.addAll({
                              rule.name: {
                                HouseRules.PROHIBITED: true,
                              }
                            });
                          }
                        },
                      );
                    },
                    child: Container(
                      decoration: BoxDecoration(
                        color: pp.containsKey(rule.name) &&
                                pp[rule.name][HouseRules.PROHIBITED] == true
                            ? Colors.red
                            : null,
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: Colors.grey,
                        ),
                      ),
                      padding: EdgeInsets.all(2),
                      child: Icon(
                        Icons.close,
                        color: pp.containsKey(rule.name) &&
                                pp[rule.name][HouseRules.PROHIBITED] == true
                            ? Colors.white
                            : null,
                      ),
                    ),
                  ),
                ),
                if (additionalRule)
                  SizedBox(
                    width: 5,
                  ),
                if (additionalRule)
                  Expanded(
                    child: GestureDetector(
                      onTap: () {
                        setState(
                          () {
                            pp.remove(
                              rule.name,
                            );
                          },
                        );
                      },
                      child: Container(
                        padding: EdgeInsets.all(2),
                        child: Icon(
                          Icons.delete,
                          color: Colors.red,
                        ),
                      ),
                    ),
                  ),
              ],
            ),
          ),
        ),
        CustomDivider(),
      ],
    );
  }
}

class AddNewHouseRule extends StatefulWidget {
  AddNewHouseRule({Key key}) : super(key: key);

  @override
  State<AddNewHouseRule> createState() => _AddNewHouseRuleState();
}

class _AddNewHouseRuleState extends State<AddNewHouseRule> {
  @override
  void initState() {
    super.initState();
  }

  bool prohibited = true;
  TextEditingController ruleController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          BackBar(
            icon: null,
            onPressed: null,
            text: "Add New HouseRule",
          ),
          Expanded(
            child: SingleChildScrollView(
              child: Column(
                children: [
                  SizedBox(
                    height: 100,
                    child: Row(
                      children: [
                        Expanded(
                          child: RowSelector(
                            selectedColor: Colors.green,
                            text: "Accepted",
                            selected: !prohibited,
                            onTap: () {
                              setState(() {
                                prohibited = false;
                              });
                            },
                          ),
                        ),
                        Expanded(
                          child: RowSelector(
                            selectedColor: Colors.red,
                            text: "Prohibited",
                            selected: prohibited,
                            onTap: () {
                              setState(() {
                                prohibited = true;
                              });
                            },
                          ),
                        ),
                      ],
                    ),
                  ),
                  Container(
                    padding: EdgeInsets.all(10),
                    child: TextField(
                      controller: ruleController,
                      decoration: InputDecoration(
                        hintText: "Type a houserule",
                      ),
                      maxLines: 5,
                    ),
                  ),
                ],
              ),
            ),
          ),
          ProceedButton(
            text: "Finish",
            onTap: () {
              if (ruleController.text.trim().isEmpty) {
                CommunicationServices().showToast(
                  "Please tell us which rule you want to add",
                  Colors.red,
                );
              } else {
                Navigator.of(context).pop({
                  HouseRules.NAME: ruleController.text.trim(),
                  HouseRules.PROHIBITED: prohibited,
                });
              }
            },
          )
        ],
      ),
    );
  }
}

class ProvidedHouseRules extends StatefulWidget {
  final Map rules;
  final Function(String) onDismiss;
  final Function(String) addProhibit;
  final Function(String) addAccepted;
  ProvidedHouseRules({
    Key key,
    @required this.rules,
    @required this.onDismiss,
    @required this.addProhibit,
    @required this.addAccepted,
  }) : super(key: key);

  @override
  State<ProvidedHouseRules> createState() => _ProvidedHouseRulesState();
}

class _ProvidedHouseRulesState extends State<ProvidedHouseRules> {
  bool tip = true;
  Map pp = {};

  @override
  void initState() {
    super.initState();
    widget.rules.forEach(
      (key, value) {
        pp.addAll({
          key: value,
        });
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        BackBar(
          icon: null,
          onPressed: null,
          text: "House Rules",
        ),
        InformationalBox(
          visible: tip,
          onClose: () {
            setState(
              () {
                tip = false;
              },
            );
          },
          message: "You can drag a rule left or right to remove it.",
        ),
        Expanded(
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: 10),
            child: SingleChildScrollView(
              child: Column(
                children: pp.entries
                    .map(
                      (e) => Dismissible(
                        onDismissed: (direction) {
                          setState(() {
                            pp.remove(e.key);
                          });

                          widget.onDismiss(e.key);
                        },
                        key: Key(e.key),
                        background: Container(
                          color: Colors.red[400],
                          padding: EdgeInsets.symmetric(horizontal: 20),
                          child: Row(
                            children: [
                              Icon(
                                Icons.delete_outline,
                                size: 30,
                              ),
                              Spacer(),
                              Icon(
                                Icons.delete_outline,
                                size: 30,
                              ),
                            ],
                          ),
                        ),
                        child: Column(
                          children: [
                            ListTile(
                              title: Text(e.key),
                              trailing: SizedBox(
                                width: MediaQuery.of(context).size.width * 0.2,
                                child: Row(
                                  children: [
                                    Expanded(
                                      child: GestureDetector(
                                        onTap: () {
                                          setState(() {
                                            if (pp[e.key]
                                                [HouseRules.PROHIBITED]) {
                                              widget.addAccepted(e.key);

                                              pp.addAll({
                                                e.key: {
                                                  HouseRules.PROHIBITED: false,
                                                }
                                              });
                                            } else {
                                              widget.onDismiss(e.key);

                                              pp.remove(e.key);
                                            }
                                          });
                                        },
                                        child: Container(
                                          decoration: BoxDecoration(
                                            color: pp[e.key][HouseRules
                                                        .PROHIBITED] ==
                                                    false
                                                ? Colors.green
                                                : null,
                                            shape: BoxShape.circle,
                                            border: Border.all(
                                              color: Colors.grey,
                                            ),
                                          ),
                                          padding: EdgeInsets.all(2),
                                          child: Icon(Icons.done,
                                              color: pp[e.key][HouseRules
                                                          .PROHIBITED] ==
                                                      false
                                                  ? Colors.white
                                                  : null),
                                        ),
                                      ),
                                    ),
                                    SizedBox(
                                      width: 5,
                                    ),
                                    Expanded(
                                      child: GestureDetector(
                                        onTap: () {
                                          setState(
                                            () {
                                              if (pp[e.key]
                                                      [HouseRules.PROHIBITED] ==
                                                  false) {
                                                widget.addProhibit(e.key);

                                                pp.addAll({
                                                  e.key: {
                                                    HouseRules.PROHIBITED: true,
                                                  }
                                                });
                                              } else {
                                                widget.onDismiss(e.key);

                                                pp.remove(e.key);
                                              }
                                            },
                                          );
                                        },
                                        child: Container(
                                          decoration: BoxDecoration(
                                            color: pp[e.key]
                                                    [HouseRules.PROHIBITED]
                                                ? Colors.red
                                                : null,
                                            shape: BoxShape.circle,
                                            border: Border.all(
                                              color: Colors.grey,
                                            ),
                                          ),
                                          padding: EdgeInsets.all(2),
                                          child: Icon(Icons.close,
                                              color: pp[e.key]
                                                      [HouseRules.PROHIBITED]
                                                  ? Colors.white
                                                  : null),
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                            CustomDivider()
                          ],
                        ),
                      ),
                    )
                    .toList(),
              ),
            ),
          ),
        ),
      ],
    );
  }
}
