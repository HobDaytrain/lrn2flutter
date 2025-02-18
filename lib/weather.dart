import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:geolocator/geolocator.dart';

import 'main.dart' show GeneralAppState;

class WeatherPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    var appState = context.watch<GeneralAppState>();
    appState.updateCoords();

    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'Welcome to US Weather!',
                style: Theme.of(context).textTheme.headlineMedium,
              ),
            ],
          ),
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                appState.coords.toString(),
                style: Theme.of(context).textTheme.headlineMedium,
              ),
            ],
          ),
        ],
      ),
    );
  }
}
