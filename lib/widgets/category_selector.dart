import 'package:flutter/material.dart';
import 'package:dorx/theming/theme_controller.dart';

class CategorySelector extends StatefulWidget {
  final List<String> categories;
  final Function(int) onTap;
  final int selectedIndex;
  CategorySelector({
    Key key,
    @required this.categories,
    @required this.onTap,
    @required this.selectedIndex,
  }) : super(key: key);

  @override
  State<CategorySelector> createState() => _CategorySelectorState();
}

class _CategorySelectorState extends State<CategorySelector> {
  Color selectedColor;
  Color notSelectedColor;

  @override
  Widget build(BuildContext context) {
    Brightness theme = ThemeBuilder.of(context).getCurrentTheme();
    if (theme == Brightness.dark) {
      selectedColor = Colors.white;
      notSelectedColor = Colors.white54;
    } else {
      selectedColor = Colors.black;
      notSelectedColor = Colors.black38;
    }

    return Container(
      height: 40,
      margin: EdgeInsets.only(
        top: 5,
        bottom: 5,
        left: 5,
      ),
      alignment: Alignment.center,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: widget.categories.length,
        itemBuilder: (context, index) {
          return Center(
            child: GestureDetector(
              onTap: () {
                widget.onTap(index);
              },
              child: Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      widget.categories[index],
                      style: TextStyle(
                        color: widget.selectedIndex == index
                            ? selectedColor
                            : notSelectedColor,
                        fontSize: 20,
                        letterSpacing: 1,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Container(
                      height: 2,
                      width: 50,
                      color: widget.selectedIndex == index ? Colors.blue : null,
                    )
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
