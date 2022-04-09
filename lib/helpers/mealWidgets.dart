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