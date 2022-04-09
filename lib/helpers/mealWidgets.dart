import 'package:flutter/material.dart';

import '../models/food.dart';

class FoodCard extends StatelessWidget {
  const FoodCard({Key? key, required this.food}) : super(key: key);

  final Food food;

  Image _getOptionIcon (Options op) {
    return Image.network('https://nutrition.umd.edu/LegendImages/icons_2016_${op.toString().split(".")[1]}.gif', scale: 0.5,);
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(15.0),
      ),
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(food.name, style: const TextStyle(fontSize: 30),),
            Row(
              children: food.options.map(_getOptionIcon).toList(),
            )
          ],
        ),
      )
    );
  }
}

class MealFilter extends StatefulWidget {
  const MealFilter({Key? key}) : super(key: key);

  @override
  State<MealFilter> createState() => _MealFilterState();
}

class _MealFilterState extends State<MealFilter> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<Color?> _colorAnim;
  final ColorTween _colorTween = ColorTween(begin: Colors.white, end: Colors.green);
  bool active = false;
  double _fontSize = 0;

  @override
  void initState() {
    super.initState();

    _controller = AnimationController(
      duration: const Duration(milliseconds: 250),
      vsync: this,
    )
      ..addListener(() { setState(() {}); });

    _colorAnim = _colorTween.animate(_controller);
  }

  @override
  void dispose() {
    super.dispose();
    _controller.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () {
        active ? _controller.reverse() : _controller.forward();
        active = !active;
        _fontSize = 14 - _fontSize;
      },
      child: Card(
        color: _colorAnim.value,
        shape: const StadiumBorder(),
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Row(
            children: [
              ClipOval(child: Image.network('https://nutrition.umd.edu/LegendImages/icons_2016_vegetarian.gif')),
              Padding(
                padding: const EdgeInsets.only(left: 8),
                child: AnimatedDefaultTextStyle(
                    duration: const Duration(milliseconds: 250),
                    style: TextStyle(fontSize: _fontSize, color: Colors.black),
                    child: const Text('Vegetarian')
                ),
              )
            ],
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
  State<FoodCardList> createState() => _FoodCardListState();
}

class _FoodCardListState extends State<FoodCardList> {
  @override
  Widget build(BuildContext context) {
    return ListView.builder(
        itemBuilder: (context, index) => FoodCard(food: widget.foodItems[index])
    );
  }
}

