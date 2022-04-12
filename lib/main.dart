import 'package:circular_menu/circular_menu.dart';
import 'package:dining_plan/helpers/mealWidgets.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:postgres/postgres.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:dots_indicator/dots_indicator.dart';

import 'models/food.dart';

void main() async {
  await dotenv.load(fileName: ".env");
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        // This is the theme of your application.
        //
        // Try running your application with "flutter run". You'll see the
        // application has a blue toolbar. Then, without quitting the app, try
        // changing the primarySwatch below to Colors.green and then invoke
        // "hot reload" (press "r" in the console where you ran "flutter run",
        // or simply save your changes to "hot reload" in a Flutter IDE).
        // Notice that the counter didn't reset back to zero; the application
        // is not restarted.
        primarySwatch: Colors.red,
      ),
      home: const MyHomePage(title: "What's Cookin?"),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({Key? key, required this.title}) : super(key: key);

  // This widget is the home page of your application. It is stateful, meaning
  // that it has a State object (defined below) that contains fields that affect
  // how it looks.

  // This class is the configuration for the state. It holds the values (in this
  // case the title) provided by the parent (in this case the App widget) and
  // used by the build method of the State. Fields in a Widget subclass are
  // always marked "final".

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> with TickerProviderStateMixin {
  int _meal = 0;
  late List<Food> _foodList;
  bool _setList = false;
  final GlobalKey<FoodCardListState> _keyFoodList = GlobalKey();
  late final AnimationController _controller = AnimationController(
    duration: const Duration(milliseconds: 100),
    vsync: this,
  );
  late final Animation<double> _animation = CurvedAnimation(
    parent: _controller,
    curve: Curves.easeIn,
  );
  late final AnimationController _nameController = AnimationController(
    duration: const Duration(milliseconds: 300),
    vsync: this,
  );
  late final Animation<double> _nameAnimation = CurvedAnimation(
    parent: _nameController,
    curve: Curves.easeInOutBack,
  );
  int _cur = 0;
  final List<String> _imgs = ['diner', 'north', 'south'];
  final List<String> _names = ['The Diner', '251 North', 'South Diner'];
  final PageController _pageController = PageController();
  late PostgreSQLConnection connection;

  @override
  void dispose() {
    _controller.dispose();
    _pageController.dispose();
    super.dispose();
  }

  String _mealText() {
    switch(_meal) {
      case 0:
        return 'Breakfast';
      case 1:
        return 'Lunch';
      case 2:
        return 'Dinner';
      default:
        return '';
    }
  }

  @override
  void initState() {
    super.initState();
    connect();
    _controller.forward();
    _nameController.forward();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    precacheImage(const AssetImage('images/diner.jpg'), context);
    precacheImage(const AssetImage('images/north.jpg'), context);
    precacheImage(const AssetImage('images/south.jpg'), context);
  }

  Future<void> setList() async {
    await connection.query("USE defaultdb");
    _foodList = (await connection.query("SELECT * FROM food${_meal * 3 + _cur + 1}")).map(
            (res) => Food(name: res[0], options: Food.bitsToOptionList(res[1]))).toList();
    if (!_setList) {
      setState(() {
        _setList = true;
      });
    } else {
      _keyFoodList.currentState!.updateTable(_foodList);
      setState(() {});
    }
  }

  void connect() async {
    connection = PostgreSQLConnection(
        dotenv.env['HOST'] ?? '',
        int.parse(dotenv.env['PORT'] ?? '0'),
        dotenv.env['DATABASE'] ?? '',
        username: dotenv.env['USERNAME'] ?? '',
        password: dotenv.env['PASSWORD'] ?? '',
        useSSL: true,
        allowClearTextPassword: true
    );
    try {
      await connection.open();
    } catch (e) {
      print(e);
    }

    setList();
  }

  @override
  Widget build(BuildContext context) {
    // This method is rerun every time setState is called, for instance as done
    // by the _incrementCounter method above.
    //
    // The Flutter framework has been optimized to make rerunning build methods
    // fast, so that you can just rebuild anything that needs updating rather
    // than having to individually change instances of widgets.
    return Scaffold(
      appBar: AppBar(
        // Here we take the value from the MyHomePage object that was created by
        // the App.build method, and use it to set our appbar title.
        title: Text(widget.title),
      ),
      body: CircularMenu(
        alignment: Alignment.topRight,
        backgroundWidget: Container(
          color: Colors.black87,
          child: Column(
            children: [
              Expanded(
                child: Stack(
                  children: [
                    PageView(
                      onPageChanged: (index) async {
                        _cur = index;
                        _nameController.reverse().whenComplete(() {
                          setList();
                          setState(() {});
                          _nameController.forward();
                        });
                      },
                      controller: _pageController,
                      children: List<Widget>.generate(_imgs.length, (index) =>
                          ClipRRect(
                              child: ColorFiltered(
                                  colorFilter: const ColorFilter.mode(Colors.grey, BlendMode.darken),
                                  child: Image.asset('images/${_imgs[index]}.jpg', fit: BoxFit.cover,)
                              )
                          )
                      ),
                    ),
                    Container(
                      alignment: Alignment.bottomCenter,
                      padding: const EdgeInsets.only(bottom: 20),
                      child: DotsIndicator(
                        dotsCount: _imgs.length,
                        position: _cur.toDouble(),
                        decorator: const DotsDecorator(
                          color: Colors.blueGrey, // Inactive color
                          activeColor: Colors.amber,
                        ),
                      ),
                    ),
                    SizeTransition(
                      sizeFactor: _nameAnimation,
                      axisAlignment: 0,
                      child: Container(
                        transform: Matrix4.translationValues(10, 10, 0),
                        child: Card(
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(15)
                          ),
                          color: Colors.amber,
                          child: Padding(
                            padding: const EdgeInsets.only(left: 8, right: 8, top: 8, bottom: 16),
                            child: Text(_names[_cur], style: const TextStyle(fontSize: 30, fontWeight: FontWeight.bold)),
                          )
                        )
                      ),
                    ),
                    Container(
                      alignment: Alignment.center,
                      transform: Matrix4.translationValues(0, 235, 0),
                      child: SizeTransition(
                        sizeFactor: _animation,
                        axis: Axis.horizontal,
                        axisAlignment: -1,
                        child: Stack(
                          alignment: Alignment.center,
                          children: [
                            const Opacity(
                              opacity: 0.7,
                              child: SizedBox(
                                width: 160,
                                height: 50,
                                child: Card(
                                  elevation: 5,
                                  color: Colors.red,
                                ),
                              ),
                            ),
                            Text(
                              _mealText(),
                              style: const TextStyle(fontSize: 30, fontWeight: FontWeight.bold)
                            )
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                alignment: Alignment.center,
                padding: const EdgeInsets.only(top: 40, bottom: 20),
                width: 365,
                child: Wrap(
                  children: Options.values.toList().map(
                          (op) => MealFilter(
                              option: op,
                              onTap: () => _keyFoodList.currentState!.filter(op)
                          )).toList()
                ),
              ),
              Divider(
                color: Colors.grey.withOpacity(0.5),
                thickness: 10,
              ),
              _setList ? Expanded(
                child: Padding(
                  padding: const EdgeInsets.only(top: 10),
                  child: FoodCardList(foodItems: _foodList, key: _keyFoodList),
                )
              ) : const CircularProgressIndicator()
            ],
          ),
        ),
        toggleButtonBoxShadow: const [],
        items: [
          CircularMenuItem(icon: FontAwesomeIcons.bacon, onTap: () async {
            _meal = 0;
            await setList();
            _controller.reverse().whenComplete(() {
              setState(() {});
              _controller.forward();
            });
            },
            boxShadow: const [],
            color: Colors.amber,
          ),
          CircularMenuItem(icon: FontAwesomeIcons.pizzaSlice, onTap: () async {
            _meal = 1;
            await setList();
            _controller.reverse().whenComplete(() {
              setState(() {});
              _controller.forward();
            });
          },
          boxShadow: const [],
          color: Colors.deepOrange,),
          CircularMenuItem(icon: FontAwesomeIcons.burger, onTap: () async {
            _meal = 2;
            await setList();
            _controller.reverse().whenComplete(() {
              setState(() {});
              _controller.forward();
            });
          },
          boxShadow: const [],
          color: Colors.indigo,),
        ],
      )
    );
  }
}
