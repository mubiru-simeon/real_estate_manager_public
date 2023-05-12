import 'dart:async';

import 'package:algolia/algolia.dart';
import 'package:flutter/material.dart';
import 'package:dorx/services/algolia.dart';
import 'package:dorx/services/sq_lite_services.dart';
import 'package:dorx/services/ui_services.dart';
import 'package:dorx/theming/theme_controller.dart';
import 'package:dorx/views/no_data_found_view.dart';
import 'package:dorx/widgets/custom_dialog_box.dart';
import 'package:dorx/widgets/custom_divider.dart';
import 'package:dorx/widgets/single_search_result.dart';
import 'package:hive/hive.dart';

import '../constants/basic.dart';
import '../constants/core.dart';
import '../constants/images.dart';
import '../constants/ui.dart';
import '../models/models.dart';
import '../widgets/loading_widget.dart';

class SearchView extends StatefulWidget {
  final bool returning;
  final bool returnList;
  final bool addKey;
  final List<String> whatToReturn;
  SearchView({
    Key key,
    @required this.returning,
    @required this.returnList,
    @required this.whatToReturn,
    this.addKey = false,
  }) : super(key: key);

  @override
  State<SearchView> createState() => _SearchViewState();
}

class SingleSearchHistory extends StatelessWidget {
  final Function onDelete;
  final Function onTap;
  final SearchHistory searchHistory;
  const SingleSearchHistory({
    Key key,
    @required this.searchHistory,
    @required this.onDelete,
    @required this.onTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        onTap();
      },
      child: Column(
        children: [
          Row(
            children: [
              Icon(Icons.timelapse),
              SizedBox(
                width: 5,
              ),
              Expanded(
                child: Text(
                  searchHistory.text,
                ),
              ),
              IconButton(
                onPressed: () {
                  onDelete();
                },
                icon: Icon(
                  Icons.close,
                ),
              )
            ],
          ),
          CustomDivider()
        ],
      ),
    );
  }
}

class _SearchViewState extends State<SearchView>
    with SingleTickerProviderStateMixin {
  AlgoliaAPI algoliaAPI = AlgoliaAPI();
  bool searching = false;
  bool showHistoryPage = true;
  Box box;
  List<AlgoliaObjectSnapshot> _results = [];
  Timer searchOnStoppedTyping;

  searchHistoryPage() {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: _previousSearches.isEmpty
          ? NoDataFound(
              text: "No Search History Yet",
            )
          : SingleChildScrollView(
              child: Column(
                children: [
                  CustomDivider(),
                  Row(
                    children: [
                      Text(
                        "Recent Searches",
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Spacer(),
                      OutlinedButton(
                        onPressed: () {
                          showDialog(
                              context: context,
                              builder: (context) {
                                return CustomDialogBox(
                                  bodyText:
                                      "Are you sure you want to clear your search history?",
                                  buttonText: "Yep. Clear it",
                                  onButtonTap: () {},
                                  showOtherButton: true,
                                );
                              });
                        },
                        child: Text(
                          "Clear",
                        ),
                      )
                    ],
                  ),
                  Column(
                    children: _previousSearches.reversed
                        .map(
                          (e) => SingleSearchHistory(
                            searchHistory: e,
                            onDelete: () {
                              _sqLiteServices.deleteSpecificHistory(
                                e.id,
                                box,
                              );
                            },
                            onTap: () {
                              _nameController.text = e.text;
                              doIt(e.text);
                            },
                          ),
                        )
                        .toList(),
                  )
                ],
              ),
            ),
    );
  }

  _onChangeHandler(value) {
    const duration = Duration(
      milliseconds: 200,
    );
    // set the duration that you want call search() after that.
    if (searchOnStoppedTyping != null) {
      searchOnStoppedTyping.cancel(); // clear timer
    }

    searchOnStoppedTyping = Timer(
      duration,
      () => doIt(value),
    );
  }

  _search(String searchText, String indexToQuery) {
    Future.delayed(Duration(milliseconds: 100), () async {
      if (searchText.trim().isNotEmpty) {
        setState(() {
          showHistoryPage = false;
          searching = true;
        });

        _sqLiteServices.saveSearchHistory(
          searchText,
          box,
        );

        loadHistory();

        Algolia algolia = Algolia.init(
          applicationId: algoliaAppID,
          apiKey: searchApiKey,
        );

        AlgoliaQuery query =
            algolia.instance.index(indexToQuery).query(searchText.trim());

        _results = (await query.getObjects()).hits;

        setState(() {
          searching = false;
        });
      } else {
        setState(() {
          showHistoryPage = true;
          _results.clear();
        });
      }
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  TextEditingController _nameController = TextEditingController();
  List<String> modes;
  PageController controller = PageController(
    initialPage: 0,
  );
  Map<String, Map<String, dynamic>> selectedStuff = {};

  int selectedIndex = 0;
  bool list = true;

  TabController _tabController;
  SearchHistoryDBServices _sqLiteServices = SearchHistoryDBServices();

  @override
  void initState() {
    super.initState();
    box = Hive.box(DorxSettings.SEARCHHISTORY);

    loadHistory();

    modes = [
      "all",
      if (widget.whatToReturn == null ||
          widget.whatToReturn.contains(ThingType.PROPERTY))
        ThingType.PROPERTY,
      if (widget.whatToReturn == null ||
          widget.whatToReturn.contains(ThingType.USER))
        ThingType.USER,
    ];

    _tabController = TabController(
      vsync: this,
      length: modes.length,
    );
  }

  static const THING = "thing";
  static const TYPE = "type";

  String hiya;

  List<SearchHistory> _previousSearches = [];

  void loadHistory() async {
    _previousSearches = _sqLiteServices.getPreviousHistory(box);

    if (mounted) setState(() {});
  }

  doIt(String vg) {
    _search(
      vg,
      allIndex,
    );
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () {
        return popAndReturn();
      },
      child: Scaffold(
        body: NestedScrollView(
          headerSliverBuilder: (context, inner) {
            return [
              SliverAppBar(
                actions: [
                  Center(
                    child: Padding(
                      padding: const EdgeInsets.only(right: 5.0),
                      child: Text(
                        "Go",
                        style: TextStyle(
                          color: Colors.orange,
                          fontSize: 16,
                        ),
                      ),
                    ),
                  )
                ],
                backgroundColor: Theme.of(context).canvasColor,
                pinned: true,
                automaticallyImplyLeading: false,
                title: Row(
                  children: [
                    GestureDetector(
                      child: Icon(
                        Icons.arrow_back_ios,
                        color: Colors.grey,
                      ),
                      onTap: () {
                        popAndReturn();
                      },
                    ),
                    Expanded(
                      child: TextField(
                        autofocus: true,
                        onTap: () {
                          setState(
                            () {
                              showHistoryPage = true;
                            },
                          );
                        },
                        controller: _nameController,
                        onChanged: (v) {
                          _onChangeHandler(v);
                        },
                        textInputAction: TextInputAction.search,
                        decoration: InputDecoration(
                          suffixIcon: IconButton(
                            icon: Icon(
                              Icons.clear,
                              size: 15,
                              color:
                                  ThemeBuilder.of(context).getCurrentTheme() ==
                                          Brightness.dark
                                      ? Colors.white
                                      : Colors.blue,
                            ),
                            onPressed: () {
                              _nameController.clear();
                              if (mounted) {
                                setState(() {
                                  _results.clear();
                                  searching = false;
                                });
                              }
                            },
                          ),
                          prefixIcon: Icon(
                            Icons.search,
                          ),
                          hintText: "Search",
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              if (!showHistoryPage)
                SliverPersistentHeader(
                  pinned: true,
                  delegate: MySliverAppBarDelegate(
                    TabBar(
                      isScrollable: widget.whatToReturn == null ||
                          widget.whatToReturn.isEmpty,
                      controller: _tabController,
                      labelColor: getTabColor(context, true),
                      unselectedLabelColor: getTabColor(context, false),
                      tabs: modes.map((e) {
                        return Tab(
                          text: e.toUpperCase(),
                        );
                      }).toList(),
                    ),
                  ),
                ),
            ];
          },
          body: showHistoryPage
              ? searchHistoryPage()
              : Stack(
                  children: [
                    TabBarView(
                        controller: _tabController,
                        children: modes.map((e) {
                          if (searching) {
                            return LoadingWidget();
                          } else {
                            if (_nameController.text.trim().isEmpty) {
                              return NotYetSearchingView(
                                text: "What Food are you looking for?",
                              );
                            } else {
                              List pp = [];

                              if (e == "all") {
                                for (var element in _results) {
                                  pp.add(element);
                                }
                              } else {
                                for (var element in _results) {
                                  if (e == element.data["type"]) {
                                    pp.add(element);
                                  }
                                }
                              }

                              if (pp.isEmpty) {
                                return NoDataFound(
                                  text:
                                      "No Items Found. Feel free to tap the button and sell this cloth to the people of $capitalizedAppName",
                                  onTap: null,
                                );
                              } else {
                                return ListView.builder(
                                  itemCount: pp.length,
                                  itemBuilder: (context, index) {
                                    return SingleSearchResult(
                                      list: false,
                                      sensitive: widget.returning,
                                      allowedTypes: widget.whatToReturn ?? [],
                                      thing: pp[index].data,
                                      horizontal: false,
                                      fullWidth: null,
                                      searchedText: _nameController.text.trim(),
                                      selectable: widget.returning,
                                      selected: selectedStuff.containsKey(
                                          pp[index].data["objectID"]),
                                      onTap: widget.returning
                                          ? () {
                                              if (selectedStuff.containsKey(
                                                  pp[index].data["objectID"])) {
                                                setState(
                                                  () {
                                                    selectedStuff.remove(
                                                        pp[index]
                                                            .data["objectID"]);
                                                  },
                                                );
                                              } else {
                                                setState(() {
                                                  selectedStuff.addAll({
                                                    pp[index].data["objectID"]:
                                                        {
                                                      TYPE: ThingType.PROPERTY,
                                                      THING: pp[index].data
                                                    }
                                                  });
                                                });
                                              }
                                            }
                                          : null,
                                      type: pp[index].data["type"],
                                    );
                                  },
                                );
                              }
                            }
                          }
                        }).toList()),
                    if (selectedStuff.isNotEmpty)
                      Positioned(
                        bottom: 2,
                        left: 0,
                        right: 0,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Padding(
                              padding:
                                  const EdgeInsets.symmetric(horizontal: 8.0),
                              child: Text(
                                "Selected Stuff",
                                style: TextStyle(
                                  fontSize: 17,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                            SingleChildScrollView(
                              scrollDirection: Axis.horizontal,
                              child: Row(
                                children: selectedStuff.entries.map((e) {
                                  return Stack(
                                    children: [
                                      SingleSearchResult(
                                        thing: e.value[THING],
                                        fullWidth: false,
                                        list: true,
                                        sensitive: widget.returning,
                                        allowedTypes: widget.whatToReturn ?? [],
                                        selectable: widget.returning,
                                        searchedText: "%",
                                        onTap: null,
                                        horizontal: true,
                                        selected: false,
                                        type: e.value[TYPE],
                                      ),
                                      Positioned(
                                        right: 8,
                                        top: 8,
                                        child: CircleAvatar(
                                          backgroundColor: Colors.white,
                                          child: GestureDetector(
                                            onTap: () {
                                              setState(() {
                                                selectedStuff.remove(
                                                  e.key,
                                                );
                                              });
                                            },
                                            child: Center(
                                              child: Icon(
                                                Icons.close,
                                                color: Colors.red,
                                                size: 25,
                                              ),
                                            ),
                                          ),
                                        ),
                                      )
                                    ],
                                  );
                                }).toList(),
                              ),
                            ),
                          ],
                        ),
                      )
                  ],
                ),
        ),
        floatingActionButton: selectedStuff.isNotEmpty
            ? FloatingActionButton.extended(
                heroTag: "nothing_useful",
                onPressed: () {
                  popAndReturn();
                },
                label: Text("Done"),
                icon: Icon(
                  Icons.done,
                ),
              )
            : null,
      ),
    );
  }

  navigateTo(int index) {
    _results.clear();
    searching = false;
    setState(() {
      selectedIndex = index;
    });
    controller.animateToPage(
      index,
      duration: Duration(milliseconds: 400),
      curve: Curves.easeInOut,
    );
  }

  popAndReturn() {
    if (widget.returning) {
      if (widget.returnList) {
        List<dynamic> stf = [];

        for (var item in selectedStuff.entries) {
          stf.add(
            widget.addKey ? item.key : item.value[THING],
          );
        }

        Navigator.of(context).pop(
          stf,
        );
      } else {
        Map<String, dynamic> stuff = {};

        for (var item in selectedStuff.entries) {
          stuff.addAll(
            {item.key: item.value[THING]},
          );
        }

        Navigator.of(context).pop(
          stuff,
        );
      }
    } else {
      Navigator.of(context).pop();
    }
  }
}

class NotYetSearchingView extends StatelessWidget {
  final String text;
  NotYetSearchingView({
    Key key,
    @required this.text,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        SizedBox(
          height: 10,
        ),
        Image.asset(
          voidPic,
          width: MediaQuery.of(context).size.width * 0.5,
          height: MediaQuery.of(context).size.width * 0.5,
        ),
        SizedBox(
          height: 20,
        ),
        Text(
          text,
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        )
      ],
    );
  }
}

class SearchBar extends StatelessWidget {
  final TextEditingController controller;
  final bool searching;
  final Function whatToDoWhenYouTapClear;
  final Function(String) search;
  const SearchBar({
    Key key,
    @required this.controller,
    @required this.whatToDoWhenYouTapClear,
    @required this.searching,
    @required this.search,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: controller,
      onFieldSubmitted: (vg) {
        search(vg);
      },
      onChanged: (vg) {
        search(vg);
      },
      textInputAction: TextInputAction.search,
      decoration: InputDecoration(
        hintText: "Search..",
        hintStyle: TextStyle(color: Colors.grey),
        suffixIcon: IconButton(
          icon: Icon(
            Icons.clear,
            size: 30,
            color: ThemeBuilder.of(context).getCurrentTheme() == Brightness.dark
                ? Colors.white
                : Colors.blue,
          ),
          onPressed: () {
            controller.clear();
            whatToDoWhenYouTapClear();
          },
        ),
      ),
    );

    /*   FloatingSearchBar(
      onSubmitted: (query) {
        search(query);
      },
      hint: 'Search...',
      controller: controller,
      scrollPadding: const EdgeInsets.only(top: 16, bottom: 56),
      transitionDuration: const Duration(milliseconds: 800),
      transitionCurve: Curves.easeInOut,
      physics: const BouncingScrollPhysics(),
      axisAlignment: isPortrait ? 0.0 : -1.0,
      openAxisAlignment: 0.0,
      width: isPortrait ? 600 : 500,
      automaticallyImplyBackButton: false,
      progress: searching,
      debounceDelay: const Duration(milliseconds: 500),
      onQueryChanged: (query) {
        search(query);
      },
      clearQueryOnClose: true,
      transition: CircularFloatingSearchBarTransition(),
      actions: [
        FloatingSearchBarAction(
          showIfOpened: true,
          showIfClosed: false,
          builder: (context, animation) {
            final bar = FloatingSearchAppBar.of(context);

            return ValueListenableBuilder<String>(
              valueListenable: bar.queryNotifer,
              builder: (context, query, _) {
                final isEmpty = query.trim().isEmpty;

                return SearchToClear(
                  isEmpty: isEmpty,
                  size: 24,
                  color: bar.style.iconColor,
                  duration: Duration(milliseconds: 900) * 0.5,
                  onTap: () {
                    if (!isEmpty) {
                      bar.clear();
                      whatToDoWhenYouTapClear();
                    } else {
                      bar.isOpen =
                          !bar.isOpen || (!bar.hasFocus && bar.isAlwaysOpened);
                    }
                  },
                );
              },
            );
          },
        ),
      ],
      builder: (context, transition) {
        return SizedBox();
      },
    ); */
  }
}
