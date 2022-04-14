import 'dart:math';

import 'package:dining_plan/services/shared_preferences.dart';
import 'package:flutter/material.dart';

import '../models/food.dart';
import 'hero_dialogue_route.dart';

Image getOptionIcon (Options op, double scale) {
  return Image.network('https://nutrition.umd.edu/LegendImages/icons_2016_${op.toString().split(".")[1]}.gif', scale: scale);
}

extension StringExtension on String {
  String capitalize() {
    return "${this[0].toUpperCase()}${substring(1).toLowerCase()}";
  }
}

class FoodCard extends StatelessWidget {
  const FoodCard({Key? key, required this.food, this.starred = false, required this.onInfoCardComplete, required this.index}) : super(key: key);

  final Food food;
  final bool starred;
  final int index;
  final Function() onInfoCardComplete;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () {
        Navigator.of(context).push(HeroDialogRoute(builder: (context) {
          return FoodInfoCard(food: food, onStar: (){}, padding: EdgeInsets.symmetric(vertical: MediaQuery.of(context).size.height/2 - 200, horizontal: 25), heroTag: index, starred: starred,);
        })).whenComplete(onInfoCardComplete);
      },
      child: Hero(
        tag: index,
        createRectTween: (begin, end) {
          return CustomRectTween(begin: begin, end: end);
        },
        child: Card(
          color: starred ? Colors.amber : Colors.white,
          elevation: 5,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(15.0),
          ),
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('${food.name.substring(0, min(20, food.name.length))}${food.name.length > 20 ? '...' : ''}', style: const TextStyle(fontSize: 15),),
                Row(
                  children: food.options.map((op) => Padding(
                    padding: const EdgeInsets.only(right: 8),
                    child: ClipOval(child: getOptionIcon(op, 0.7)),
                  )).toList(),
                )
              ],
            ),
          )
        ),
      ),
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
        child: AnimatedContainer(
          padding: EdgeInsets.symmetric(horizontal: 14 - _sizeList[_active]),
          decoration: ShapeDecoration(
            shape: const StadiumBorder(),
            color: _colorList[_active],
          ),
          duration: const Duration(milliseconds: 250),
          child: InkWell(
            onTap: () {
              _updateTween();
              widget.onTap();
            },
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  AnimatedContainer(
                    duration: Duration(milliseconds: 200),
                    transform: Matrix4.translationValues(5 - _sizeList[_active]*5/14, 0, 0),
                    child: ClipOval(child: getOptionIcon(widget.option, 0.8))
                  ),
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
  const FoodCardList({Key? key, required this.foodItems, required this.onScroll}) : super(key: key);

  final List<Food> foodItems;
  final Function(double) onScroll;

  @override
  State<FoodCardList> createState() => FoodCardListState();
}

class FoodCardListState extends State<FoodCardList> {
  late List<Food> _curFoodItems;
  late List<Food> _origFoodItems;
  String _search = '';
  List<Options> _active = [];
  List<Options> _disable = [];
  late List<FoodCard> _items = [];
  bool _setList = false;

  @override
  void initState() {
    super.initState();
    _origFoodItems = widget.foodItems;
    _curFoodItems = [...widget.foodItems];
    _createItems().whenComplete(() {
      setState(() {
        _setList = true;
      });
    });
  }

  Future<void> _createItems() async {
    _items = [];
    int cur = 0;
    for (Food f in _curFoodItems) {
      if (await SharedPreferencesService.checkStar(f.name)) {
        _items.add(FoodCard(food: f, index: cur++, starred: true, onInfoCardComplete: _fixList));
      }
    }
    for (Food f in _curFoodItems) {
      if (!await SharedPreferencesService.checkStar(f.name)) {
        _items.add(FoodCard(food: f, index: cur++, starred: false, onInfoCardComplete: _fixList));
      }
    }
  }

  void updateTable(List<Food> newItems) {
    _origFoodItems = newItems;
    _fixList();
  }

  void _fixList() {
    setState(() {
      _setList = false;
    });
    bool found = false;
    _curFoodItems = [];
    for (int i = 0; i < _origFoodItems.length; i++) {
      found = false;
      for (Options option in _disable) {
        found = _origFoodItems[i].options.contains(option);
      }
      if (!found) {
        if (_active.isEmpty && _origFoodItems[i].name.toLowerCase().contains(_search)) {
          _curFoodItems.add(_origFoodItems[i]);
        } else if (_origFoodItems[i].name.toLowerCase().contains(_search)) {
          for (Options option in _active) {
            if (_origFoodItems[i].options.contains(option)) {
              _curFoodItems.add(_origFoodItems[i]);
              break;
            }
          }
        }
      }
    }
    _createItems().whenComplete(() {
      setState(() {
        _setList = true;
      });
    });
  }

  void filter(Options op) {
    if (!_disable.remove(op)) {
      _active.remove(op) ? _disable.add(op) : _active.add(op);
    }

    _fixList();
  }

  void search(String value) {
    _search = value;

    _fixList();
  }

  @override
  Widget build(BuildContext context) {
    return _setList ? NotificationListener<ScrollNotification>(
      onNotification: (notification) {
        widget.onScroll(notification.metrics.pixels);
        return true;
      },
      child: ListView(
        scrollDirection: Axis.vertical,
        shrinkWrap: true,
        children: _items,
      ),
    ) : const CircularProgressIndicator();
  }
}

class FoodInfoCard extends StatefulWidget {
  const FoodInfoCard({Key? key, required this.food, required this.onStar, required this.padding, required this.heroTag, this.starred = false}) : super(key: key);

  final Food food;
  final bool starred;
  final Function() onStar;
  final EdgeInsets padding;
  final int heroTag;

  @override
  State<FoodInfoCard> createState() => _FoodInfoCardState();
}

class _FoodInfoCardState extends State<FoodInfoCard> with SingleTickerProviderStateMixin {
  late final AnimationController _controller = AnimationController(
    duration: const Duration(milliseconds: 1500),
    vsync: this,
  );
  late final Animation<double> _animation = CurvedAnimation(
    parent: _controller,
    curve: Curves.elasticInOut,
  );
  late bool _starred;
  
  @override
  void initState() {
    super.initState();
    _starred = widget.starred;
    _controller.forward(from: 1);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _onStar() {
    _controller.reset();
    _starred = !_starred;
    _starred ? SharedPreferencesService.setStar(widget.food.name) : SharedPreferencesService.removeStar(widget.food.name);
    setState(() {});
    _controller.forward(from: 0.4);
  }
  
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: widget.padding,
      child: Hero(
        tag: widget.heroTag,
        child: Card(
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Text(widget.food.name, style: const TextStyle(fontSize: 30, fontWeight: FontWeight.bold)),
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: ScaleTransition(
                          scale: _animation,
                          child: IconButton(
                            onPressed: _onStar,
                            icon: Icon(_starred ? Icons.star : Icons.star_border),
                            iconSize: 40,
                            color: _starred ? Colors.amber : Colors.black,
                          ),
                        ),
                      )
                    ],
                  ),
                  const Divider(
                    color: Colors.grey,
                    thickness: 4,
                    height: 10
                  ),
                  const Padding(
                    padding: EdgeInsets.symmetric(vertical: 8, horizontal: 12),
                    child: Text('Restrictions:', style: TextStyle(fontStyle: FontStyle.italic, fontSize: 18),),
                  ),
                  widget.food.options.isNotEmpty ? Center(
                    child: Wrap(
                      children: widget.food.options.map((op) => Padding(
                        padding: const EdgeInsets.all(8),
                        child: Card(
                            elevation: 5,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(15)
                            ),
                            child: Container(
                              padding: const EdgeInsets.all(8.0),
                              height: 70,
                              width: 85,
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.spaceAround,
                                children: [
                                  ClipOval(child: getOptionIcon(op, 0.7)),
                                  Text(op.toString().split('.')[1].capitalize(), style: const TextStyle(color: Colors.grey),)
                                ],
                              ),
                            )
                        ),
                      )).toList(),
                    ),
                  ) : const Padding(
                    padding: EdgeInsets.symmetric(horizontal: 12),
                    child: Text('None!', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),),
                  ),
                ],
              ),
            ),
          )
        ),
      )
    );
  }
}


