import 'package:car_sharing/screens/carDetail.dart';
import 'package:car_sharing/screens/updateCar.dart';
import 'package:dio/dio.dart';
import 'package:car_sharing/screens/addCar.dart';
import 'package:english_words/english_words.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:car_sharing/env.sample.dart';
import 'package:car_sharing/models/cars.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'models/sharing.dart';


void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (context) => MyAppState(),
      child: MaterialApp(
        themeMode: ThemeMode.dark,
        debugShowCheckedModeBanner: false,
        title: 'Namer App',
        theme: ThemeData.dark(
          useMaterial3: true,
        ),
        initialRoute: '/',
        routes: {
        '/': (context) => MyHomePage(),
      },
      ),
    );
  }
}

class MyAppState extends ChangeNotifier {
  MyAppState();

  late Car updatableCar;
  var current = WordPair.random();

  // List of cars
  List<Car> _cars = [];
  List<Car> get cars {
    return [..._cars];
  }

  // List of ALL shares
  List<Share> _shares = [];
  List<Share> get shares {
    return [..._shares];
  }

  String get ip {
    return ipController.text;
  }

  void setIp(String value) {
    ipController.text = value;
    notifyListeners();
  }

  late String urlMainPart = 'http://$ip';
  late String urlCars = '$urlMainPart:8000/api/cars/';
  late String urlShares = '$urlMainPart:8000/api/sharings/';

  var favorites = <WordPair>[];
  final dio = Dio();

  void getNext() {
    current = WordPair.random();
    notifyListeners();
  }

  void toggleFavorite() {
    if (favorites.contains(current)) {
      favorites.remove(current);
    } else {
      favorites.add(current);
    }/**/
    notifyListeners();
  }

  void getSharingsList() async {
    print('hi shares!');
    final uri = Uri.parse(urlShares);
    http.Response response = await http.get(uri);
    print(response.statusCode);
    if (response.statusCode == 200) {
      var data = jsonDecode(response.body.replaceAll("\n","")) as List;
      _shares = data.map<Share>((json) => Share.fromJson(json)).toList();
      notifyListeners();
    }
  }

  void getCarsList() async {
    print('hi');
    print('IP is $ip');
    final uri = Uri.parse(urlCars);
    http.Response response = await http.get(uri);
    print(response.statusCode);
    if (response.statusCode == 200) {
      var data = jsonDecode(response.body.replaceAll("\n","")) as List;
      _cars = data.map<Car>((json) => Car.fromJson(json)).toList();
      notifyListeners();
    }
  }

  void addCar(Car car, String image) async {
    final uri = Uri.parse(urlCars);
    var request = http.MultipartRequest("POST", uri);
    Map<String, dynamic> fields = {
      'model': car.model,
      'type': car.type,
      'color': car.color,
      'mileage': car.mileage.toString(),
      'cost_per_day': car.costPerDay.toString()
    };

    try {
      fields.forEach((k, v) => request.fields[k] = v);
      request.files.add(await http.MultipartFile.fromPath('image', image));
    } catch (error) {
      print("Request sending error: $error");
    }

    await request.send().then((response) {
      if (response.statusCode == 201) {
        car.id = jsonDecode(response.toString())['id'];
        _cars.add(car);
        notifyListeners();
      } else {
        print('image upload error');
      }
    });
  }

  void deleteCar(Car car) async {
    final uri = Uri.parse('$urlCars${car.id}/');
    http.Response response = await http.delete(uri);
    if (response.statusCode == 204) {
      _cars.remove(car);
      notifyListeners();
    }
  }

  void updateCar(Car car) async {
    final uri = Uri.parse('$urlCars${car.id}/');
    var request = http.MultipartRequest("PUT", uri);

    Map<String, dynamic> fields = {
      'model': car.model,
      'type': car.type,
      'color': car.color,
      'mileage': car.mileage.toString(),
      'cost_per_day': car.costPerDay.toString()
    };

    try {
      fields.forEach((k, v) => request.fields[k] = v);
      request.files.add(await http.MultipartFile.fromPath('image', car.image));
    } catch (error) {
      print("Request sending error: $error");
    }

    await request.send().then((response) => {
      if (response.statusCode == 200) {
          _cars[_cars.indexOf(updatableCar)] = car,
          notifyListeners(),
      }
    });
  }

  void rentCar(Share share) async {
    final uri = Uri.parse(urlShares);
    http.Response response = await http.post(uri,
        headers: {"Content-Type": "application/json"}, body: json.encode(share));
    if (response.statusCode == 201) {
      _shares.add(share);
      notifyListeners();
    }
  }

  void returnCar(Share share) async {
    final uri = Uri.parse('$urlShares${share.id}/');
    http.Response response = await http.delete(uri,
      headers: {"Content-Type": "application/json"});
    if (response.statusCode == 200) {
      _shares.remove(share);
      notifyListeners();
    }
  }

  void showToast() {
    Fluttertoast.showToast(
        msg: "Car has been returned!",
        toastLength: Toast.LENGTH_SHORT,
        gravity: ToastGravity.BOTTOM,
        timeInSecForIosWeb: 1,
        backgroundColor: Colors.red,
        textColor: Colors.white,
        fontSize: 32.0
    );
  }

  final ipController = TextEditingController();

  Future<void> _ipDialog(BuildContext context) {
    return showDialog<void>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Change an IP'),
          content: TextFormField(
            controller: ipController,
            keyboardType: TextInputType.number,
          ),
          actions: <Widget>[
            TextButton(
              style: TextButton.styleFrom(
                textStyle: Theme.of(context).textTheme.labelLarge,
              ),
              child: const Text('Cancel'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            FilledButton(
              style: TextButton.styleFrom(
                textStyle: Theme.of(context).textTheme.labelLarge,
              ),
              child: const Text('Save'),
              onPressed: () {
                setIp(ipController.text);
                print(ipController.text);
                notifyListeners();
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }
}

class MyHomePage extends StatefulWidget {
  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  var _selectedIndex = 0;
  static List<Widget> _widgetOptions = <Widget>[
    CarsList(),
    FavoritesPage(),
    GeneratorPage(),
  ];


  @override
  Widget build(BuildContext context) {
    var appState = context.watch<MyAppState>();
    return LayoutBuilder(
      builder: (context, constraints) {
        return Scaffold(
          body: Center(
            child: _widgetOptions.elementAt(_selectedIndex),
          ),
          bottomNavigationBar: NavigationBar(
            elevation: 4.5,
            onDestinationSelected: (int index) {
              setState(() {
                _selectedIndex = index;
              });
            },
            selectedIndex: _selectedIndex,
            destinations: <Widget> [
              NavigationDestination(
                  selectedIcon: Icon(Icons.home),
                  icon: Icon(Icons.home_outlined),
                  label: 'Home',
                  tooltip: 'Home',),
              NavigationDestination(
                  selectedIcon: Icon(Icons.favorite),
                  icon: Icon(Icons.favorite_outline),
                  label: 'Favorites',
                  tooltip: 'Favorites',),
              NavigationDestination(
                  selectedIcon: Icon(Icons.directions_car),
                  icon: Icon(Icons.directions_car_outlined),
                  label: 'Rents',
                  tooltip: 'Rents',),
            ],
          ),
        );
      }
    );
  }
}


class CarsList extends StatelessWidget {

  @override
  Widget build(BuildContext context) {
    var appState = context.watch<MyAppState>();
    var carsList = appState.cars;
    const title = 'Available cars';
    final carP = Provider.of<MyAppState>(context);
    return RefreshIndicator(
      triggerMode: RefreshIndicatorTriggerMode.anywhere,
      onRefresh: () async {
        Provider.of<MyAppState>(context, listen: false).getCarsList();
        Future<void>.delayed(const Duration(seconds: 3));
      },
      child: Scaffold(
        body: CustomScrollView(
          physics: const BouncingScrollPhysics(
              parent: AlwaysScrollableScrollPhysics()),
          slivers: [
            SliverAppBar(
              // Provide a standard title.
              // Allows the user to reveal the app bar if they begin scrolling
              // back up the list of items.
              floating: true,
              pinned: true,
              snap: false,
              elevation: 100.0,
              leading: IconButton(
                onPressed: () {
                  appState._ipDialog(context);
                },
                icon: Icon(Icons.menu),),
              actions: [
                IconButton(
                    onPressed: () => {},
                    icon: Icon(Icons.search))
              ],
              // Display a placeholder widget to visualize the shrinking size.
              // Make the initial height of the SliverAppBar larger than normal.
              expandedHeight: 230,
              flexibleSpace: FlexibleSpaceBar(
                expandedTitleScale: 2.2,
                centerTitle: true,
                //titlePadding: EdgeInsets.fromLTRB(0, 0, 0, 5),
                title: Text(
                  title,
                  textAlign: TextAlign.left,
                  style: GoogleFonts.poppins(
                    color: Colors.white,
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                background: Container(
                  height: MediaQuery.of(context).size.height * 0.7,
                  width: MediaQuery.of(context).size.width * 0.9,
                  decoration: BoxDecoration(
                    color: Colors.deepPurpleAccent.withAlpha(109),
                    borderRadius: BorderRadius.circular(20),
                  ),
                ),
              ),
            ),
            SliverList(
              delegate: SliverChildBuilderDelegate(
                    (context, index) => Card(
                        clipBehavior: Clip.hardEdge,
                        child: Ink.image(
                          height: 200,
                          image: Image.network(carsList[index].image).image,
                          fit: BoxFit.cover,
                          child: InkWell(
                            onTap: () {
                              Navigator.push(
                                  context,
                                  MaterialPageRoute(builder: (context) => CarDetail(),
                                  settings: RouteSettings(
                                    arguments: carP.cars[index]
                                  )));
                            },
                            child: Padding(
                              padding: const EdgeInsets.fromLTRB(5, 10, 0, 10),
                              child: ListTile(
                                trailing: PopupMenuButton<void Function()>(
                                  shadowColor: Colors.black87,
                                  itemBuilder: (context) {
                                    return [
                                      PopupMenuItem(
                                          child: Column(
                                            crossAxisAlignment: CrossAxisAlignment.end,
                                            children: [
                                              Row(
                                                children: [
                                                  Icon(Icons.edit, size: 20),
                                                  SizedBox(width: 10,),
                                                  Text('Edit'),
                                                ],
                                              ),
                                            ],
                                          ),
                                          value: () {
                                            Navigator.push(
                                                context,
                                                MaterialPageRoute(builder: (context) => UpdateCarScreen(),
                                                    settings: RouteSettings(
                                                      arguments: carP.cars[index],

                                                    )
                                                )
                                            );
                                            appState.updatableCar = carP.cars[index];
                                          }
                                      ),
                                      PopupMenuDivider(),
                                      PopupMenuItem(
                                        child: Column(
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          children: [
                                            Row(
                                              children: [
                                                Icon(Icons.delete, size: 20, color: Colors.redAccent.shade200,),
                                                SizedBox(width: 10,),
                                                Text('Delete', style: TextStyle(color: Colors.redAccent.shade200),),
                                              ],
                                            ),
                                          ],
                                        ),
                                        value: () => carP.deleteCar(carP.cars[index]),
                                      ),
                                    ];
                                  },
                                  onSelected: (fn) => fn(),
                                ),
                                title: Text(
                                  carsList[index].model.toString(),
                                  style: TextStyle(
                                      color: Colors.white,
                                      fontSize: 22,
                                      fontWeight: FontWeight.normal,
                                    shadows: [Shadow(
                                      blurRadius: 20.0,
                                      color: Color.fromARGB(255, 0, 0, 0),
                                    ),
                                      Shadow(
                                        blurRadius: 20.0,
                                        color: Color.fromARGB(200, 0, 0, 0),
                                      ),],
                                    fontFamily: GoogleFonts.poppins(
                                    ).fontFamily
                                  ),
                                ),
                                subtitle: Text(
                                    carsList[index].color.toString(),
                                  style: TextStyle(
                                      color: Colors.white,
                                      fontSize: 15,
                                      fontWeight: FontWeight.normal,
                                      shadows: [Shadow(
                                        blurRadius: 20.0,
                                        color: Color.fromARGB(255, 0, 0, 0),
                                      ),
                                        Shadow(
                                          blurRadius: 20.0,
                                          color: Color.fromARGB(200, 0, 0, 0),
                                        ),],
                                      fontFamily: GoogleFonts.poppins(
                                      ).fontFamily
                                  ),
                                ),
                              ),
                            ),
                          ),
                        )
                    ),
                childCount: carsList.length
                // Builds 1000 ListTiles
              ),
            ),
          ],
        ),
        floatingActionButton: FloatingActionButton.extended(
          onPressed: () {
            Navigator.of(context).
            push(MaterialPageRoute(builder: (ctx) => AddCarScreen()));
          },
          tooltip: 'Add a car',
          label: Text('Add a car'),
          icon: Icon(Icons.add),
        ),
      ),
    );
  }
}


class GeneratorPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    var appState = context.watch<MyAppState>();
    var sharesList = appState.shares;
    return RefreshIndicator(
      onRefresh: () async {
        Provider.of<MyAppState>(context, listen: false).getSharingsList();
        Future<void>.delayed(const Duration(seconds: 3));
      },
      child: Scaffold(
        appBar: AppBar(
          title: Text('My rents',
          style: GoogleFonts.poppins(
            fontSize: 20,
            fontWeight: FontWeight.w500
          ),),
          elevation: 2.0,
        ),
        body: ListView.builder(
          itemCount: appState.shares.length,
          itemBuilder: (_, int index) {
            return Card(
              elevation: 3.0,
              clipBehavior: Clip.hardEdge,
              child: InkWell(
                child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: ListTile(
                    title: Text(
                      sharesList[index].fullCar['model'].toString(),
                      style: GoogleFonts.poppins(
                          color: Colors.white70,
                          fontSize: 20,
                          fontWeight: FontWeight.normal
                      ),
                    ),
                    subtitle: Text(
                        sharesList[index].fullCar['type'].toString(),
                        style: TextStyle(color: Colors.grey),
                    ),
                  ),
                ),
                onTap: () {
                  showModalBottomSheet(
                      context: context,
                      isScrollControlled: true,
                      useSafeArea: true,
                      builder: (BuildContext context) {
                        return SizedBox(
                          height: 600,
                            child: Padding(
                              padding: const EdgeInsets.fromLTRB(30, 30, 30, 10),
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.spaceAround,
                                children: <Widget>[
                                  Row(
                                    children: [
                                      ClipRRect(
                                        borderRadius: BorderRadius.circular(10.0),
                                        child: Image.network(sharesList[index].fullCar['image'],
                                        width: 150, height: 100,
                                        fit: BoxFit.cover,),
                                      ),
                                      Flexible(
                                        child: Text(sharesList[index].fullCar['model'].toString(),
                                        textAlign: TextAlign.start,
                                        style: TextStyle(
                                          fontSize: 20
                                        ),),
                                      )
                                    ],
                                  ),
                                  Align(
                                    alignment: Alignment.bottomCenter,
                                    child: Padding(
                                      padding: const EdgeInsets.all(8.0),
                                      child: FilledButton(
                                        clipBehavior: Clip.hardEdge,
                                        child: const Text('Return'),
                                        onPressed: () => {
                                          appState.returnCar(sharesList[index]),
                                          Navigator.of(context).pop(),
                                          appState.showToast()
                                        },
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                        );
                      },
                  );
                },
              ),
            );
          }
        ),
      ),
    );
  }
}


class FavoritesPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    var appState = context.watch<MyAppState>();
    return ListView(
      children: [
        Padding(
          padding: const EdgeInsets.all(20),
          child: Text('You have '
              '${appState.favorites.length} favorites:',
          style: GoogleFonts.poppins(
            fontSize: 25,
            fontWeight: FontWeight.w300
          ),),
        ),
        for (var pair in appState.favorites)
          ListTile(
            title: Text(pair.asLowerCase),
            leading: Icon(Icons.favorite),
          )
      ],
    );
  }
}


class BigCard extends StatelessWidget {
  const BigCard({
    super.key,
    required this.pair,
  });

  final WordPair pair;

  @override
  Widget build(BuildContext context) {
    var theme = Theme.of(context);
    var style = theme.textTheme.displayMedium!.copyWith(
      color: theme.colorScheme.onSecondary,
    );
    return Card(
      color: theme.colorScheme.primary,
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Text(
          pair.asLowerCase,
          style: style,
          semanticsLabel: pair.asPascalCase,),
      ),
    );
  }
}