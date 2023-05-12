import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:dorx/constants/basic.dart';
import 'package:dorx/models/models.dart';
import '../services/services.dart';
import 'package:provider/provider.dart';

import 'widgets.dart';

class SelectDeliveryLocationBottomSheet extends StatelessWidget {
  const SelectDeliveryLocationBottomSheet({Key key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        BackBar(
          icon: null,
          onPressed: null,
          text: "Your Delivery Location",
        ),
        InformationalBox(
          visible: true,
          onClose: null,
          message:
              "In order to simplify your life, $capitalizedAppName lets you save your usual locations to your account and access them anytime.",
        ),
        Expanded(
          child: PaginateFirestore(
            onEmpty: TransparentButton(
                icon: Icon(
                  Icons.add_location,
                ),
                text: "Add A Location",
                onTap: () async {
                  UIServices().showDatSheet(
                    EditLocationBottomSheet(
                      deliveryLocation: null,
                    ),
                    false,
                    context,
                  );
                }),
            scrollDirection: Axis.vertical,
            header: SliverList(
                delegate: SliverChildListDelegate([
              TransparentButton(
                icon: Icon(
                  Icons.add_location,
                ),
                text: "Add A Location",
                onTap: () {
                  UIServices().showDatSheet(
                    EditLocationBottomSheet(
                      deliveryLocation: null,
                    ),
                    false,
                    context,
                  );
                },
              ),
            ])),
            isLive: true,
            itemBuilderType: PaginateBuilderType.listView,
            itemBuilder: (
              context,
              snapshot,
              index,
            ) {
              DeliveryLocation deliveryLocation =
                  DeliveryLocation.fromSnapshot(snapshot[index]);

              return SingleDeliveryLocation(
                selected: Provider.of<UsableConstants>(context, listen: true)
                            .currentDeliveryLocation !=
                        null &&
                    deliveryLocation.id ==
                        Provider.of<UsableConstants>(context, listen: true)
                            .currentDeliveryLocation
                            .id,
                onTap: () {
                  if (Provider.of<UsableConstants>(context, listen: false)
                              .currentDeliveryLocation !=
                          null &&
                      Provider.of<UsableConstants>(context, listen: false)
                              .currentDeliveryLocation
                              .id ==
                          deliveryLocation.id) {
                    Provider.of<UsableConstants>(context, listen: false)
                        .removeDeliveryLocation(
                      context,
                    );
                  } else {
                    Provider.of<UsableConstants>(context, listen: false)
                        .addDeliveryLocation(
                      deliveryLocation,
                      "Home Location",
                    );
                  }
                },
                deliveryLocation: deliveryLocation,
              );
            },
            query: FirebaseFirestore.instance
                .collection(DeliveryLocation.DIRECTORY)
                .doc(AuthProvider.of(context).auth.getCurrentUID())
                .collection(AuthProvider.of(context).auth.getCurrentUID()),
          ),
        ),
        ProceedButton(
          onTap: () {
            Navigator.of(context).pop(
              Provider.of<UsableConstants>(context, listen: false)
                      .currentDeliveryLocation !=
                  null,
            );
          },
          text: "Done",
        )
      ],
    );
  }
}
