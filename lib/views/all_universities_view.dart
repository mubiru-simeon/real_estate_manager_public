import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import '../models/models.dart';
import '../widgets/widgets.dart';

class AllUniversitiesView extends StatefulWidget {
  final bool selectable;
  AllUniversitiesView({
    Key key,
    @required this.selectable,
  }) : super(key: key);

  @override
  State<AllUniversitiesView> createState() => _AllUniversitiesViewState();
}

class _AllUniversitiesViewState extends State<AllUniversitiesView> {
  String selectedUniversity;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            BackBar(
              icon: null,
              onPressed: null,
              text: "All Schools",
            ),
            Expanded(
              child: PaginateFirestore(
                isLive: true,
                itemBuilderType: PaginateBuilderType.listView,
                itemBuilder: (
                  context,
                  snapshot,
                  index,
                ) {
                  SchoolModel university = SchoolModel.fromSnapshot(
                    snapshot[index],
                  );

                  return SingleSchool(
                    school: university,
                    onTap: () {
                      if (widget.selectable) {
                        setState(() {
                          selectedUniversity = university.id;
                        });
                      } else {}
                    },
                    selected: widget.selectable
                        ? selectedUniversity != null &&
                            selectedUniversity == university.id
                        : false,
                    schoolID: university.id,
                  );
                },
                query: FirebaseFirestore.instance
                    .collection(SchoolModel.DIRECTORY),
              ),
            )
          ],
        ),
      ),
      floatingActionButton: selectedUniversity == null
          ? null
          : FloatingActionButton(
              child: Icon(Icons.done),
              onPressed: () {
                Navigator.of(context).pop(selectedUniversity);
              },
            ),
    );
  }
}
