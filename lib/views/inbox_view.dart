import 'package:flutter/material.dart';


class InboxView extends StatefulWidget {
  InboxView({Key key}) : super(key: key);

  @override
  State<InboxView> createState() => _InboxViewState();
}

class _InboxViewState extends State<InboxView>
    with AutomaticKeepAliveClientMixin, TickerProviderStateMixin {
  @override
  void initState() {
    super.initState();
    tabController = TabController(
      vsync: this,
      length: categories.length,
    );
  }

  TabController tabController;

  @override
  bool get wantKeepAlive => true;

  PageController controller = PageController();
  List<String> categories = [
    "Chats",
    "Notifications",
  ];
  int selectedIndex = 0;

  @override
  Widget build(BuildContext context) {
    super.build(context);

    return Container();
  }
}

class ChatsView extends StatefulWidget {
  const ChatsView({Key key}) : super(key: key);

  @override
  State<ChatsView> createState() => _ChatsViewState();
}

class _ChatsViewState extends State<ChatsView>
    with AutomaticKeepAliveClientMixin {
  @override
  bool get wantKeepAlive => true;

  @override
  Widget build(BuildContext context) {
    super.build(context);
    return Container();
  }
}
