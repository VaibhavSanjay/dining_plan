import 'package:circular_menu/circular_menu.dart';
import 'package:dining_plan/helpers/mealWidgets.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:postgres/postgres.dart';

import 'models/food.dart';

void main() {
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
        primarySwatch: Colors.blue,
      ),
      home: const MyHomePage(title: 'Flutter Demo Home Page'),
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

class _MyHomePageState extends State<MyHomePage> {
  int _meal = 0;

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
  void initState() async {
    super.initState();
    var connection = PostgreSQLConnection(
        "free-tier11.gcp-us-east1.cockroachlabs.cloud",
        26257,
        "swift-hare-482.defaultdb",
        username: "nathanb9",
        password: "AsR0kDQTDNyn5z-nxxfHuA"
    );
    await connection.open();
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
        alignment: Alignment.bottomRight,
        backgroundWidget: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Stack(
                children: [
                  ClipRRect(
                    borderRadius: const BorderRadius.all(Radius.circular(30.0)),
                    child: ColorFiltered(
                        colorFilter: const ColorFilter.mode(Colors.grey, BlendMode.darken),
                        child: Image.asset('images/diner.jpg')
                    )
                  ),
                  Container(
                    transform: Matrix4.translationValues(20, 205, 0),
                    child: const Text('The Diner', style: TextStyle(color: Colors.white, fontSize: 30, fontWeight: FontWeight.bold))
                  )
                ],
              ),
              Card(
                child: Container(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        Colors.yellow,
                        Colors.orangeAccent,
                        Colors.yellow.shade300,
                      ],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                  ),
                  child: Text(_mealText(), style: const TextStyle(fontSize: 30),), //declare your widget here
                ),
              ),
              Row(
                children: const [
                  MealFilter()
                ],
              ),
              const FoodCard(food: Food(name: 'X', options: [Options.vegan]))
            ],
          ),
        ),
        toggleButtonBoxShadow: [],
        items: [
          CircularMenuItem(icon: FontAwesomeIcons.bacon, onTap: () {
            setState(() {
              _meal = 0;
            });
            },
            boxShadow: [],
            color: Colors.amber,
          ),
          CircularMenuItem(icon: FontAwesomeIcons.burger, onTap: () {
            setState(() {
              _meal = 1;
            });
          },
          boxShadow: [],
          color: Colors.deepOrange,),
          CircularMenuItem(icon: FontAwesomeIcons.bowlRice, onTap: () {
            setState(() {
              _meal = 2;
            });
          },
          boxShadow: [],
          color: Colors.indigo,),
        ],
      )
    );
  }
}
