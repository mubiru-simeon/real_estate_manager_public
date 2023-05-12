import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import '../constants/constants.dart';
import '../models/models.dart';
import '../services/services.dart';
import 'widgets.dart';

class FeedbackOptionsBottomSheet extends StatefulWidget {
  final String additionalInfo;
  FeedbackOptionsBottomSheet({
    Key key,
    @required this.additionalInfo,
  }) : super(key: key);

  @override
  State<FeedbackOptionsBottomSheet> createState() =>
      _FeedbackOptionsBottomSheetState();
}

class _FeedbackOptionsBottomSheetState
    extends State<FeedbackOptionsBottomSheet> {
  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
          width: double.infinity,
          padding: EdgeInsets.symmetric(
            vertical: 30,
            horizontal: 20,
          ),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [
                Colors.indigoAccent,
                primaryColor,
              ],
            ),
          ),
          child: Column(
            children: [
              Text(
                translation(context).ola,
                style: TextStyle(
                  fontSize: 25,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
              Text(
                translation(context).weTreasureYourOpinion,
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: Colors.white,
                ),
              ),
            ],
          ),
        ),
        Expanded(
          child: SingleChildScrollView(
            child: Column(
              children: [
                CustomSizedBox(
                  sbSize: SBSize.small,
                  height: true,
                ),
                SingleSelectTile(
                  onTap: () {
                    Navigator.of(context).pop();

                    UIServices().showDatSheet(
                      OnlyTextBottomSheet(
                        category: UserFeedback.REPORT,
                      ),
                      true,
                      context,
                    );
                    /*  BetterFeedback.of(context).show((p) {
                      handleFeedback(
                        p,
                        UserFeedback.REPORT,
                      );
                    }); */
                  },
                  selected: false,
                  asset: null,
                  text: translation(context).reportSomething,
                  desc: translation(context).offensivePost,
                  icon: Icons.warning,
                ),
                CustomSizedBox(
                  sbSize: SBSize.small,
                  height: true,
                ),
                SingleSelectTile(
                  onTap: () {
                    Navigator.of(context).pop();

                    UIServices().showDatSheet(
                      OnlyTextBottomSheet(
                        category: UserFeedback.BUG,
                      ),
                      true,
                      context,
                    );

                    /*  BetterFeedback.of(context).show((p0) {
                      handleFeedback(
                        p0,
                        UserFeedback.BUG,
                      );
                    }); */
                  },
                  selected: false,
                  asset: null,
                  text: translation(context).reportError,
                  icon: FontAwesomeIcons.spider,
                ),
                CustomSizedBox(
                  sbSize: SBSize.small,
                  height: true,
                ),
                SingleSelectTile(
                  onTap: () {
                    Navigator.of(context).pop();

                    UIServices().showDatSheet(
                      OnlyTextBottomSheet(
                        category: UserFeedback.FEATURE,
                      ),
                      true,
                      context,
                    );
                  },
                  selected: false,
                  asset: null,
                  text: translation(context).suggestAFeature,
                  icon: Icons.new_releases,
                ),
                CustomSizedBox(
                  sbSize: SBSize.small,
                  height: true,
                ),
                SingleSelectTile(
                  onTap: () {
                    Navigator.of(context).pop();

                    UIServices().showDatSheet(
                      OnlyTextBottomSheet(
                        category: UserFeedback.LIKES,
                      ),
                      true,
                      context,
                    );
                  },
                  selected: false,
                  asset: null,
                  text: translation(context).tellUsWhatYouLike,
                  icon: FontAwesomeIcons.thumbsUp,
                ),
                CustomSizedBox(
                  sbSize: SBSize.small,
                  height: true,
                ),
                SingleSelectTile(
                  onTap: () {
                    Navigator.of(context).pop();

                    UIServices().showDatSheet(
                      OnlyTextBottomSheet(
                        category: UserFeedback.DISLIKES,
                      ),
                      true,
                      context,
                    );
                  },
                  selected: false,
                  asset: null,
                  text: translation(context).tellUsWhatYouDisLike,
                  icon: FontAwesomeIcons.thumbsDown,
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  handleFeedback(
    TempFeedback feedback,
    String category,
  ) async {
    CommunicationServices().showToast(
      translation(context).thankYouForFeedback,
      Colors.green,
    );

    List imgs = await ImageServices().uploadImages(
      path: "feedback_images",
      onError: () {},
      images: [],
      bytes: feedback.screenshot,
    );

    FirebaseFirestore.instance.collection(UserFeedback.DIRECTORY).add({
      UserFeedback.ADDITIONALINFO: widget.additionalInfo,
      UserFeedback.APPVERSION: versionNumber,
      UserFeedback.PENDING: true,
      UserFeedback.IMAGES: imgs,
      UserFeedback.CATEGORY: category,
      UserFeedback.TEXT: feedback.text,
      UserFeedback.ATTACHEDDATA: feedback.extra,
      UserFeedback.DATE: DateTime.now().millisecondsSinceEpoch,
      UserFeedback.SENDER: AuthProvider.of(context).auth.isSignedIn()
          ? AuthProvider.of(context).auth.getCurrentUID()
          : null,
    });
  }
}

class OnlyTextBottomSheet extends StatefulWidget {
  final String category;
  OnlyTextBottomSheet({
    Key key,
    @required this.category,
  }) : super(key: key);

  @override
  State<OnlyTextBottomSheet> createState() => _OnlyTextBottomSheetState();
}

class _OnlyTextBottomSheetState extends State<OnlyTextBottomSheet> {
  TextEditingController feedbackController = TextEditingController();
  bool processing = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          BackBar(
            icon: null,
            onPressed: null,
            text: translation(context).wereAllEars,
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Column(
              children: [
                InformationalBox(
                  visible: true,
                  onClose: null,
                  message: translation(context).whatsOnYourMind,
                ),
                TextField(
                  maxLines: null,
                  controller: feedbackController,
                  decoration: InputDecoration(
                    hintText: "Type here",
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
      bottomNavigationBar: Wrap(children: [
        ProceedButton(
          text: translation(context).proceed,
          processing: processing,
          onTap: () async {
            if (feedbackController.text.trim().isEmpty) {
              CommunicationServices().showToast(
                translation(context).enterSuggestion,
                Colors.red,
              );
            } else {
              setState(() {
                processing = true;
              });

              CommunicationServices().showToast(
                translation(context).thankYouForFeedback,
                Colors.green,
              );

              Navigator.of(context).pop();

              FirebaseFirestore.instance.collection(UserFeedback.DIRECTORY).add(
                {
                  UserFeedback.APPVERSION: versionNumber,
                  UserFeedback.PENDING: true,
                  UserFeedback.CATEGORY: widget.category,
                  UserFeedback.TEXT: feedbackController.text.trim(),
                  UserFeedback.DATE: DateTime.now().millisecondsSinceEpoch,
                  UserFeedback.SENDER:
                      AuthProvider.of(context).auth.isSignedIn()
                          ? AuthProvider.of(context).auth.getCurrentUID()
                          : null,
                },
              );
            }
          },
        )
      ]),
    );
  }
}
