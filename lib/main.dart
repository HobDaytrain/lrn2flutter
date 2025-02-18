import 'package:english_words/english_words.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:geolocator/geolocator.dart';
// import 'weather.dart';
import 'favorites.dart';
import 'home.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (context) => GeneralAppState(),
      child: ChangeNotifierProvider<FavoritesState>(
        create: (context) => FavoritesState(),
        child: Consumer<GeneralAppState>(
          builder: (context, appState, child) {
            return MaterialApp(
              title: 'lrn2flutter',
              theme: ThemeData(
                useMaterial3: true,
                colorScheme: ColorScheme.fromSeed(
                  seedColor: Colors.green,
                  brightness:
                      appState.isDarkMode ? Brightness.dark : Brightness.light,
                ),
                visualDensity: VisualDensity.comfortable,
                textTheme: TextTheme(
                  headlineMedium: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                  bodyLarge: TextStyle(fontSize: 18),
                  bodyMedium: TextStyle(fontSize: 16),
                ),
              ),
              home: AppShell(),
            );
          },
        ),
      ),
    );
  }
}

class GeneralAppState extends ChangeNotifier {
  var current = WordPair.random();
  var isDarkMode = true;
  var favorites = <WordPair>[];
  var coords = <String, double>{};

  Future<Position> _determinePosition() async {
    bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      return Future.error('Location services are disabled.');
    }

    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        return Future.error('Location permissions are denied');
      }
    }

    if (permission == LocationPermission.deniedForever) {
      return Future.error('Location permissions are permanently denied');
    }

    Position position = await Geolocator.getCurrentPosition();

    return position;
  }

  void updateCoords() async {
    var position = await _determinePosition();
    coords = {
      'latitude': position.latitude,
      'longitude': position.longitude,
    };
    notifyListeners();
  }

  void toggleFavorite() {
    if (favorites.contains(current)) {
      favorites.remove(current);
    } else {
      favorites.add(current);
    }
    notifyListeners();
  }

  void getNext() {
    current = WordPair.random();
    notifyListeners();
  }

  void toggleTheme() {
    isDarkMode = !isDarkMode;
    notifyListeners();
  }
}

class AppShell extends StatefulWidget {
  @override
  State<AppShell> createState() => _AppShellState();
}

class _AppShellState extends State<AppShell> {
  var selectedIndex = 0;

  @override
  Widget build(BuildContext context) {
    var destinations = <Widget Function()>[
      () => HomePage(),
      // () => WeatherPage(),
      () => GeneratorPage(),
      () => FavoritesPage(),
    ];

    if (selectedIndex >= destinations.length) {
      throw UnimplementedError('no widget for $selectedIndex');
    }

    Widget page = destinations[selectedIndex]();

    return LayoutBuilder(
      builder: (context, constraints) {
        return Scaffold(
          body: Row(
            children: [
              SafeArea(
                child: NavigationRail(
                  extended: constraints.maxWidth >= 600,
                  destinations: [
                    NavigationRailDestination(
                      icon: Icon(Icons.home),
                      label: Text('Home'),
                    ),
                    // NavigationRailDestination(
                    //   icon: Icon(Icons.cloud),
                    //   label: Text('Weather'),
                    // ),
                    NavigationRailDestination(
                      icon: Icon(Icons.generating_tokens),
                      label: Text('Generator'),
                    ),
                    NavigationRailDestination(
                      icon: Consumer<GeneralAppState>(
                          builder: (context, appState, child) {
                        if (appState.favorites.isEmpty) {
                          return Icon(Icons.favorite);
                        }
                        return Badge(
                          backgroundColor:
                              Theme.of(context).colorScheme.secondary,
                          label: Text(appState.favorites.length.toString()),
                          child: Icon(Icons.favorite),
                        );
                      }),
                      label: Text('Favorites'),
                    ),
                  ],
                  selectedIndex: selectedIndex,
                  onDestinationSelected: (value) {
                    setState(() {
                      selectedIndex = value;
                    });
                  },
                  trailing: Consumer<GeneralAppState>(
                    builder: (context, appState, child) {
                      return IconButton(
                        icon: Icon(
                          appState.isDarkMode
                              ? Icons.light_mode
                              : Icons.dark_mode,
                        ),
                        onPressed: () {
                          appState.toggleTheme();
                        },
                      );
                    },
                  ),
                ),
              ),
              Expanded(
                child: Container(
                  color: Theme.of(context).colorScheme.primaryContainer,
                  child: page,
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
