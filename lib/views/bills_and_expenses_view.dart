import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dorx/constants/constants.dart';
import 'package:dorx/models/models.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/services.dart';
import '../widgets/widgets.dart';

class BillsAndExpensesView extends StatefulWidget {
  const BillsAndExpensesView({Key key}) : super(key: key);

  @override
  State<BillsAndExpensesView> createState() => _BillsAndExpensesViewState();
}

class _BillsAndExpensesViewState extends State<BillsAndExpensesView> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            BackBar(
              icon: null,
              onPressed: null,
              text: "Bills and Expenses tracker",
            ),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 8.0),
                child: PaginateFirestore(
                  header: SliverList(
                    delegate: SliverChildListDelegate(
                      [
                        StatisticText(
                          title: "Your Expense Categories",
                        ),
                        SizedBox(
                          height: 130,
                          child: PaginateFirestore(
                            isLive: true,
                            header: SliverList(
                              delegate: SliverChildListDelegate(
                                [
                                  GestureDetector(
                                    onTap: () {
                                      UIServices().showDatSheet(
                                        AddExpenseCategoryBottomSheet(),
                                        true,
                                        context,
                                      );
                                    },
                                    child: Container(
                                      margin: EdgeInsets.symmetric(
                                        vertical: 5,
                                        horizontal: 3,
                                      ),
                                      padding: EdgeInsets.symmetric(
                                        horizontal: 20,
                                      ),
                                      decoration: BoxDecoration(
                                        border: Border.all(),
                                        borderRadius: standardBorderRadius,
                                      ),
                                      child: Column(
                                        mainAxisAlignment:
                                            MainAxisAlignment.center,
                                        children: [
                                          Icon(
                                            Icons.add,
                                            size: 30,
                                          ),
                                          SizedBox(
                                            height: 5,
                                          ),
                                          Text(
                                            "Add a new\nexpense category",
                                            textAlign: TextAlign.center,
                                            style: darkTitle,
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            onEmpty: GestureDetector(
                              onTap: () {
                                UIServices().showDatSheet(
                                  AddExpenseCategoryBottomSheet(),
                                  true,
                                  context,
                                );
                              },
                              child: Container(
                                width: double.infinity,
                                height: double.infinity,
                                margin: EdgeInsets.symmetric(
                                  vertical: 5,
                                  horizontal: 3,
                                ),
                                decoration: BoxDecoration(
                                  border: Border.all(),
                                  borderRadius: standardBorderRadius,
                                ),
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Icon(
                                      Icons.add,
                                      size: 30,
                                    ),
                                    SizedBox(
                                      height: 5,
                                    ),
                                    Text(
                                      "Add a new category",
                                      style: darkTitle,
                                    ),
                                  ],
                                ),
                              ),
                            ),
                            scrollDirection: Axis.horizontal,
                            itemBuilderType: PaginateBuilderType.listView,
                            itemBuilder: (context, snapshot, index) {
                              ExpenseCategory expenseCategory =
                                  ExpenseCategory.fromSnapshot(snapshot[index]);

                              return GestureDetector(
                                onTap: () {
                                  context.pushNamed(
                                    RouteConstants.expensesByCategory,
                                    queryParams: {
                                      "name": expenseCategory.name,
                                    },
                                    params: {
                                      "id": expenseCategory.id,
                                    },
                                  );
                                },
                                child: SingleExpenseCategory(
                                  expenseCategory: expenseCategory,
                                  index: index,
                                  selected: false,
                                ),
                              );
                            },
                            query: FirebaseFirestore.instance
                                .collection(ExpenseCategory.DIRECTORY)
                                .where(
                                  ExpenseCategory.ENTITY,
                                  isEqualTo:
                                      Provider.of<PropertyManagement>(context)
                                          .getCurrentPropertyID(),
                                )
                                .orderBy(
                                  ExpenseCategory.DATE,
                                  descending: true,
                                ),
                          ),
                        ),
                        SizedBox(
                          height: 20,
                        ),
                        StatisticText(
                          title: "Your Expenses",
                        ),
                      ],
                    ),
                  ),
                  itemBuilderType: PaginateBuilderType.listView,
                  isLive: true,
                  itemBuilder: (context, snapshot, index) {
                    Expense expense = Expense.fromSnapshot(snapshot[index]);

                    return SingleExpense(
                      expense: expense,
                    );
                  },
                  query: FirebaseFirestore.instance
                      .collection(Expense.DIRECTORY)
                      .where(
                        Expense.ENTITY,
                        isEqualTo: Provider.of<PropertyManagement>(context)
                            .getCurrentPropertyID(),
                      )
                      .orderBy(
                        Expense.DATE,
                        descending: true,
                      ),
                ),
              ),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          UIServices().showDatSheet(
            AddAnExpenseBottomSheet(),
            true,
            context,
          );
        },
        label: Text("Add an expense"),
        icon: Icon(
          Icons.add,
        ),
      ),
    );
  }
}

class SingleExpense extends StatelessWidget {
  final Expense expense;

  SingleExpense({
    Key key,
    @required this.expense,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.symmetric(
        vertical: 5,
        horizontal: 3,
      ),
      decoration: BoxDecoration(
        border: Border.all(),
        borderRadius: standardBorderRadius,
      ),
      padding: EdgeInsets.all(10),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (expense.details != null)
            Text(
              expense.details,
              style: darkTitle,
            ),
          if (expense.details != null)
            SizedBox(
              height: 10,
            ),
          if (expense.categoryName != null)
            Text(
              expense.categoryName,
            ),
          if (expense.amount != null)
            Text(
              "${TextService().putCommas(expense.amount.toString())} UGX",
              style: TextStyle(
                fontSize: 20,
                color: primaryColor,
                fontWeight: FontWeight.bold,
              ),
            ),
          SizedBox(
            height: 10,
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              Text(
                DateService().dateFromMilliseconds(
                  expense.date,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class AddAnExpenseBottomSheet extends StatefulWidget {
  final String category;
  final String categoryName;
  const AddAnExpenseBottomSheet({
    Key key,
    this.category,
    this.categoryName,
  }) : super(key: key);

  @override
  State<AddAnExpenseBottomSheet> createState() =>
      _AddAnExpenseBottomSheetState();
}

class _AddAnExpenseBottomSheetState extends State<AddAnExpenseBottomSheet> {
  bool processing = false;
  String _categoryName;
  Map<String, String> categoryNames = {};
  String _categoryID;
  PageController pageController = PageController();
  int _currentIndex = 0;
  List<Widget> pages;
  TextEditingController amountController = TextEditingController();
  TextEditingController detailsController = TextEditingController();

  @override
  void initState() {
    _categoryID = widget.category;
    _categoryName = widget.categoryName;
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    pages = [
      categoryPage(),
      amountPage(),
      detailsPage(),
    ];

    return WillPopScope(
      onWillPop: () {
        return handleBackButton();
      },
      child: Scaffold(
        body: MyKeyboardListenerWidget(
          proceed: () {
            checkIfItsSafeToProceed();
          },
          child: Column(
            children: [
              BackBar(
                icon: _currentIndex == 0 ? Icons.close : null,
                onPressed: _currentIndex == 0
                    ? null
                    : () {
                        goBack();
                      },
                text: "Add New Expense",
              ),
              Row(
                children: pages.map((e) {
                  return Expanded(
                    child: Container(
                      margin: EdgeInsets.symmetric(
                        horizontal: 1,
                      ),
                      height: 5,
                      color: _currentIndex >= pages.indexOf(e)
                          ? primaryColor
                          : Colors.grey,
                    ),
                  );
                }).toList(),
              ),
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 8.0),
                  child: PageView(
                    physics: NeverScrollableScrollPhysics(),
                    onPageChanged: (v) {
                      setState(() {
                        _currentIndex = v;
                      });
                    },
                    controller: pageController,
                    children: pages,
                  ),
                ),
              ),
              ProceedButton(
                processing: processing,
                onTap: () {
                  checkIfItsSafeToProceed();
                },
                text: "Proceed",
              ),
            ],
          ),
        ),
      ),
    );
  }

  detailsPage() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8.0),
      child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(
              height: 10,
            ),
            StatisticText(
              title: "Any other details",
            ),
            SizedBox(
              height: 10,
            ),
            TextField(
              controller: detailsController,
              maxLines: 5,
              decoration: InputDecoration(
                hintText: "What was this payment for?",
              ),
            ),
            SizedBox(
              height: 20,
            ),
          ],
        ),
      ),
    );
  }

  categoryPage() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          height: 10,
        ),
        StatisticText(
          title: "Select an expense category",
        ),
        InformationalBox(
          visible: true,
          onClose: null,
          message:
              "Tap on a category to select it\nif it turns green, it's been selected",
        ),
        Expanded(
          child: PaginateFirestore(
            onEmpty: GestureDetector(
              onTap: () {
                UIServices().showDatSheet(
                  AddExpenseCategoryBottomSheet(),
                  true,
                  context,
                );
              },
              child: Container(
                width: double.infinity,
                height: double.infinity,
                margin: EdgeInsets.symmetric(
                  vertical: 5,
                  horizontal: 3,
                ),
                decoration: BoxDecoration(
                  border: Border.all(),
                  borderRadius: standardBorderRadius,
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.add,
                      size: 30,
                    ),
                    SizedBox(
                      height: 5,
                    ),
                    Text(
                      "Add a new category",
                      style: darkTitle,
                    ),
                  ],
                ),
              ),
            ),
            itemBuilderType: PaginateBuilderType.listView,
            isLive: true,
            header: SliverList(
              delegate: SliverChildListDelegate(
                [
                  GestureDetector(
                    onTap: () {
                      UIServices().showDatSheet(
                        AddExpenseCategoryBottomSheet(),
                        true,
                        context,
                      );
                    },
                    child: Container(
                      margin: EdgeInsets.symmetric(
                        vertical: 5,
                        horizontal: 3,
                      ),
                      padding: EdgeInsets.symmetric(
                        horizontal: 20,
                      ),
                      decoration: BoxDecoration(
                        border: Border.all(),
                        borderRadius: standardBorderRadius,
                      ),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.add,
                            size: 30,
                          ),
                          SizedBox(
                            height: 5,
                          ),
                          Text(
                            "Add a new category",
                            style: darkTitle,
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
            scrollDirection: Axis.horizontal,
            itemBuilder: (context, snapshot, index) {
              ExpenseCategory expenseCategory =
                  ExpenseCategory.fromSnapshot(snapshot[index]);

              categoryNames.addAll({
                expenseCategory.id: expenseCategory.name,
              });

              return GestureDetector(
                onTap: () {
                  setState(() {
                    _categoryName = expenseCategory.name;
                    _categoryID = expenseCategory.id;
                  });
                },
                child: Column(
                  children: [
                    Expanded(
                      child: SingleExpenseCategory(
                        expenseCategory: expenseCategory,
                        selected: _categoryID == expenseCategory.id,
                        index: index,
                      ),
                    ),
                    if (_categoryID != expenseCategory.id)
                      SingleBigButton(
                        text: "Select this category",
                        color: primaryColor,
                        onPressed: () {
                          setState(() {
                            _categoryName = expenseCategory.name;
                            _categoryID = expenseCategory.id;
                          });
                        },
                      )
                  ],
                ),
              );
            },
            query: FirebaseFirestore.instance
                .collection(ExpenseCategory.DIRECTORY)
                .where(
                  ExpenseCategory.ENTITY,
                  isEqualTo: Provider.of<PropertyManagement>(context)
                      .getCurrentPropertyID(),
                )
                .orderBy(
                  ExpenseCategory.DATE,
                  descending: true,
                ),
          ),
        ),
      ],
    );
  }

  amountPage() {
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            height: 10,
          ),
          StatisticText(
            title: "How much money?",
          ),
          SizedBox(
            height: 10,
          ),
          Row(
            children: [
              Expanded(
                child: TextField(
                  keyboardType: TextInputType.number,
                  controller: amountController,
                  decoration: InputDecoration(
                    contentPadding: EdgeInsets.symmetric(
                      horizontal: 15,
                      vertical: 20,
                    ),
                    hintText: "Amount In UGX",
                  ),
                ),
              ),
              SizedBox(
                width: 10,
              ),
              Text(
                "UGX",
                style: darkTitle,
              ),
              SizedBox(
                width: 10,
              ),
            ],
          ),
        ],
      ),
    );
  }

  handleBackButton() {
    if (_currentIndex != 0) {
      goBack();
    } else {
      Navigator.of(context).pop();
    }
  }

  goNext() {
    pageController.animateToPage(
      (pageController.page + 1).toInt(),
      duration: Duration(milliseconds: 300),
      curve: Curves.easeIn,
    );
  }

  goBack() {
    pageController.animateToPage(
      (pageController.page - 1).toInt(),
      duration: Duration(milliseconds: 300),
      curve: Curves.easeIn,
    );
  }

  checkIfItsSafeToProceed() {
    if (_currentIndex == 0 && _categoryName == null) {
      CommunicationServices().showSnackBar(
        "You need to select a category.",
        context,
      );
    } else {
      if (_currentIndex == 1 && amountController.text.trim().isEmpty) {
        CommunicationServices().showSnackBar(
          "You need to enter the amount.",
          context,
        );
      } else {
        if (_currentIndex == pages.length - 1) {
          uploadExpense();
        } else {
          goNext();
        }
      }
    }
  }

  uploadExpense() async {
    setState(() {
      processing = true;
    });

    FirebaseFirestore.instance.collection(Expense.DIRECTORY).add({
      Expense.ADDER: AuthProvider.of(context).auth.getCurrentUID(),
      Expense.AMOUNT: double.parse(amountController.text.trim()),
      Expense.DETAILS: detailsController.text.trim().isNotEmpty
          ? detailsController.text.trim()
          : null,
      Expense.DATE: DateTime.now().millisecondsSinceEpoch,
      Expense.CATEGORY: _categoryName,
      Expense.CATEGORYID: _categoryID,
      Expense.ENTITYTYPE: ThingType.PROPERTY,
      Expense.ENTITY: Provider.of<PropertyManagement>(
        context,
        listen: false,
      ).getCurrentPropertyID(),
    }).then((value) {
      CommunicationServices().showToast(
        "Successfully added the expense.",
        Colors.green,
      );

      Navigator.of(context).pop();
    });
  }
}

class AddExpenseCategoryBottomSheet extends StatefulWidget {
  const AddExpenseCategoryBottomSheet({Key key}) : super(key: key);

  @override
  State<AddExpenseCategoryBottomSheet> createState() =>
      _AddExpenseCategoryBottomSheetState();
}

class _AddExpenseCategoryBottomSheetState
    extends State<AddExpenseCategoryBottomSheet> {
  TextEditingController nameController = TextEditingController();
  bool processing = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          BackBar(
            icon: null,
            onPressed: null,
            text: "Add an expense category",
          ),
          Expanded(
            child: Padding(
              padding: EdgeInsets.symmetric(
                horizontal: 10,
              ),
              child: Column(
                children: [
                  TextField(
                    controller: nameController,
                    decoration: InputDecoration(
                      hintText: "Name this category",
                    ),
                  ),
                ],
              ),
            ),
          ),
          ProceedButton(
            text: "Proceed",
            processing: processing,
            onTap: () {
              proceed();
            },
          )
        ],
      ),
    );
  }

  proceed() {
    if (nameController.text.trim().isEmpty) {
      CommunicationServices().showToast(
        "Provide a name",
        Colors.red,
      );
    } else {
      setState(() {
        processing = true;
      });

      FirebaseFirestore.instance.collection(ExpenseCategory.DIRECTORY).add({
        ExpenseCategory.NAME: nameController.text.trim(),
        ExpenseCategory.DATE: DateTime.now().millisecondsSinceEpoch,
        ExpenseCategory.ADDER: AuthProvider.of(context).auth.getCurrentUID(),
        ExpenseCategory.ENTITY:
            Provider.of<PropertyManagement>(context, listen: false)
                .getCurrentPropertyID(),
      }).then((value) {
        Navigator.of(context).pop();

        CommunicationServices().showToast(
          "Successfully added category",
          Colors.red,
        );
      });
    }
  }
}

class SingleExpenseCategory extends StatefulWidget {
  final ExpenseCategory expenseCategory;
  final bool selected;
  final int index;
  const SingleExpenseCategory({
    Key key,
    @required this.expenseCategory,
    @required this.index,
    @required this.selected,
  }) : super(key: key);

  @override
  State<SingleExpenseCategory> createState() => _SingleExpenseCategoryState();
}

class _SingleExpenseCategoryState extends State<SingleExpenseCategory> {
  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.symmetric(
        vertical: 5,
        horizontal: 3,
      ),
      padding: EdgeInsets.all(10),
      width: 180,
      decoration: BoxDecoration(
        color: widget.selected ? Colors.green : null,
        borderRadius: standardBorderRadius,
        gradient: widget.selected
            ? null
            : listColors[widget.index % listColors.length],
      ),
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              widget.expenseCategory.name,
              textAlign: TextAlign.center,
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(
              height: 5,
            ),
            Text(
              "${TextService().putCommas(widget.expenseCategory.amount.toString())} UGX",
              style: TextStyle(
                color: Colors.white,
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            )
          ],
        ),
      ),
    );
  }
}

class ExpensesByCategoryView extends StatefulWidget {
  final String category;
  final String categoryName;
  const ExpensesByCategoryView({
    Key key,
    @required this.category,
    @required this.categoryName,
  }) : super(key: key);

  @override
  State<ExpensesByCategoryView> createState() => _ExpensesByCategoryViewState();
}

class _ExpensesByCategoryViewState extends State<ExpensesByCategoryView> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            BackBar(
              icon: null,
              onPressed: null,
              text: "Expenses by Category",
            ),
            Expanded(
              child: PaginateFirestore(
                itemBuilderType: PaginateBuilderType.listView,
                isLive: true,
                query: FirebaseFirestore.instance
                    .collection(Expense.DIRECTORY)
                    .where(
                      Expense.CATEGORYID,
                      isEqualTo: widget.category,
                    )
                    .orderBy(
                      Expense.DATE,
                      descending: true,
                    ),
                itemBuilder: (context, snapshot, index) {
                  Expense expense = Expense.fromSnapshot(snapshot[index]);

                  return SingleExpense(expense: expense);
                },
              ),
            )
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          UIServices().showDatSheet(
            AddAnExpenseBottomSheet(
              category: widget.category,
              categoryName: widget.categoryName,
            ),
            true,
            context,
          );
        },
        label: Text(
          "Add an expense",
        ),
      ),
    );
  }
}
