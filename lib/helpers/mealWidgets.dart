import 'package:flutter/material.dart';

import '../models/food.dart';

Image getOptionIcon (Options op, double scale) {
  return Image.network('https://nutrition.umd.edu/LegendImages/icons_2016_${op.toString().split(".")[1]}.gif', scale: scale);
}

extension StringExtension on String {
  String capitalize() {
    return "${this[0].toUpperCase()}${substring(1).toLowerCase()}";
  }
}

class FoodCard extends StatelessWidget {
  const FoodCard({Key? key, required this.food}) : super(key: key);

  final Food food;

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 5,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(15.0),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(food.name, style: const TextStyle(fontSize: 30),),
            Row(
              children: food.options.map((op) => Padding(
                padding: const EdgeInsets.only(right: 8),
                child: getOptionIcon(op, 0.7),
              )).toList(),
            )
          ],
        ),
      )
    );
  }
}

class MealFilter extends StatefulWidget {
  const MealFilter({Key? key, required this.option, required this.onTap}) : super(key: key);

  final Options option;
  final Function() onTap;

  @override
  State<MealFilter> createState() => _MealFilterState();
}

class _MealFilterState extends State<MealFilter> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  int _active = 0;
  final List<Color> _colorList = [Colors.white, Colors.green, Colors.red];
  final List<double> _sizeList = [0, 14, 14];

  @override
  void dispose() {
    super.dispose();
    _controller.dispose();
  }

  void _updateTween() {
    setState(() {
      _active = (_active + 1) % 3;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 5),
      child: Card(
        elevation: _sizeList[_active],
        shape: const StadiumBorder(),
        child: InkWell(
          onTap: () {
            _updateTween();
            widget.onTap();
          },
          child: AnimatedContainer(
            padding: EdgeInsets.symmetric(horizontal: 14 - _sizeList[_active]),
            decoration: ShapeDecoration(
              shape: const StadiumBorder(),
              color: _colorList[_active],
            ),
            duration: const Duration(milliseconds: 250),
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  ClipOval(child: getOptionIcon(widget.option, 0.8)),
                  Padding(
                    padding: const EdgeInsets.only(left: 8),
                    child: AnimatedDefaultTextStyle(
                        duration: const Duration(milliseconds: 125),
                        style: TextStyle(fontSize: _sizeList[_active], color: Colors.black),
                        child: Padding(
                          padding: const EdgeInsets.only(right: 5),
                          child: Text(widget.option.toString().split(".")[1].capitalize()),
                        )
                    ),
                  )
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class FoodCardList extends StatefulWidget {
  const FoodCardList({Key? key, required this.foodItems}) : super(key: key);

  final List<Food> foodItems;

  @override
  State<FoodCardList> createState() => FoodCardListState();
}

class FoodCardListState extends State<FoodCardList> {
  late List<Food> _curFoodItems;
  List<Options> _active = [];
  List<Options> _disable = [];

  @override
  void initState() {
    super.initState();
    _curFoodItems = [...widget.foodItems];
  }

  void filter(Options op) {
    if (!_disable.remove(op)) {
      _active.remove(op) ? _disable.add(op) : _active.add(op);
    }

    _curFoodItems = [...widget.foodItems];
    for (int i = 0; i < _curFoodItems.length; i++) {
      for (Options option in _active) {
        if (!_curFoodItems[i].options.contains(option)) {
          _curFoodItems.removeAt(i);
          i--;
        }
      }
      for (Options option in _disable) {
        if (_curFoodItems[i].options.contains(option)) {
          _curFoodItems.removeAt(i);
          i--;
        }
      }
    }
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      scrollDirection: Axis.vertical,
      shrinkWrap: true,
      itemCount: _curFoodItems.length,
      itemBuilder: (context, index) => FoodCard(food: _curFoodItems[index])
    );
  }
}

