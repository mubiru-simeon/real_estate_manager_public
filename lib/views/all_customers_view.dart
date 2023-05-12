import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dorx/models/models.dart';
import 'package:dorx/services/services.dart';
import 'package:dorx/views/search_view.dart';
import 'package:dorx/widgets/widgets.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class AllCustomersView extends StatefulWidget {
  final bool returning;
  final bool pushed;
  AllCustomersView({
    Key key,
    this.returning = false,
    this.pushed = true,
  }) : super(key: key);

  @override
  State<AllCustomersView> createState() => _AllCustomersViewState();
}

class _AllCustomersViewState extends State<AllCustomersView>
    with AutomaticKeepAliveClientMixin {
  List selected = [];

  @override
  Widget build(BuildContext context) {
    super.build(context);

    return widget.pushed
        ? Scaffold(
            body: body(),
            bottomNavigationBar: Wrap(children: [
              if (widget.returning)
                ProceedButton(
                  enablable: true,
                  enabled: selected.isNotEmpty,
                  text: selected == null
                      ? translation(context).tapOnACustomer
                      : translation(context).pressHereToProceed,
                  onTap: () {
                    if (context.canPop()) {
                      Navigator.of(context).pop(selected);
                    } else {
                      context.pushReplacementNamed(
                        RouteConstants.allMyProperties,
                      );
                    }
                  },
                )
            ]),
            floatingActionButton: FloatingActionButton(
              onPressed: () async {
                String pp = await UIServices().showDatSheet(
                  AddACustomerBottomSheet(
                    returning: widget.returning,
                  ),
                  true,
                  context,
                );

                if (pp != null && pp.isNotEmpty) {
                  setState(() {
                    selected.add(pp);
                  });
                }
              },
              child: Icon(Icons.add),
            ),
          )
        : body();
  }

  body() {
    return MyKeyboardListenerWidget(
      proceed: () {
        proceed();
      },
      child: SafeArea(
        child: Column(
          children: [
            if (widget.pushed)
              BackBar(
                icon: null,
                onPressed: null,
                action: GestureDetector(
                  onTap: () async {
                    List pp = await Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (context) {
                          return SearchView(
                            returning: widget.returning,
                            returnList: true,
                            addKey: true,
                            whatToReturn: [
                              ThingType.USER,
                            ],
                          );
                        },
                      ),
                    );

                    if (pp != null && pp.isNotEmpty) {
                      setState(() {
                        for (var element in pp) {
                          selected.add(element);
                        }
                      });
                    }
                  },
                  child: Icon(
                    Icons.search,
                  ),
                ),
                text: translation(context).allCustomers,
              ),
            Expanded(
              child: PaginateFirestore(
                isLive: true,
                itemBuilderType: PaginateBuilderType.listView,
                itemBuilder: (context, snapshot, index) {
                  UserModel userModel = UserModel.fromSnapshot(
                    snapshot[index],
                    Provider.of<PropertyManagement>(context)
                        .getCurrentPropertyID(),
                  );

                  return SingleUser(
                    selected: selected.contains(userModel.id),
                    showButton: !widget.returning,
                    onTap: () {
                      if (widget.returning) {
                        if (selected.contains(userModel.id)) {
                          setState(() {
                            selected.remove(userModel.id);
                          });
                        } else {
                          setState(() {
                            selected.add(userModel.id);
                          });
                        }
                      } else {
                        context.pushNamed(
                          RouteConstants.user,
                          extra: userModel,
                          params: {
                            "id": userModel.id,
                          },
                        );
                      }
                    },
                    user: userModel,
                    userID: userModel.id,
                  );
                },
                query: FirebaseFirestore.instance
                    .collection(UserModel.DIRECTORY)
                    .where(
                      UserModel.AFFILIATION,
                      arrayContains: Provider.of<PropertyManagement>(context)
                          .getCurrentPropertyID(),
                    )
                    .orderBy(
                      UserModel.USERNAME,
                    ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  proceed() {
    if (widget.returning) {
      if (selected.isEmpty) {
        CommunicationServices().showToast(
          translation(context).pleaseselectsomecustomers,
          Colors.red,
        );
      } else {
        if (context.canPop()) {
          Navigator.of(context).pop(selected);
        } else {
          context.pushReplacementNamed(
            RouteConstants.allMyProperties,
          );
        }
      }
    }
  }

  @override
  bool get wantKeepAlive => true;
}
