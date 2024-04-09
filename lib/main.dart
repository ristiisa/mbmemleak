import 'package:flutter/material.dart';
import 'package:mapbox_maps_flutter/mapbox_maps_flutter.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  MapboxOptions.setAccessToken("<TOKEN HERE>");

  runApp(MaterialApp(home: MapSample()));
}

class MapSample extends StatefulWidget {
  @override
  State<MapSample> createState() => _MapSampleState();
}

class _MapSampleState extends State<MapSample> {
  final locationSettings = LocationComponentSettings(
    enabled: true,
    showAccuracyRing: true,
    pulsingEnabled: false,
    puckBearingEnabled: true,
    puckBearing: PuckBearing.HEADING
  );

  var lastLocation = Position(24, 59);

  Stream<Position>? location;

  @override
  initState() {
    super.initState();

    location = Stream.periodic(const Duration(seconds: 1), (_) {
      lastLocation = Position((lastLocation.lng + 1 % 180), (lastLocation.lat + 1) % 90);

      return lastLocation;
    });
  }

  @override
  Widget build(BuildContext context) => Scaffold(
    body: IndexedStack(children: [
      Container(),
      StreamBuilder<Position>(stream: location, builder: (context, snapshot) {
        return MapWidget(
          key: ValueKey(lastLocation.toJson().toString()),
          cameraOptions: CameraOptions(center: Point(coordinates: snapshot.data ?? lastLocation), zoom: 4, pitch: 0.0),
          onMapCreated: (MapboxMap mapboxMap) async {
            await Future.wait([
              mapboxMap.scaleBar.updateSettings(ScaleBarSettings(enabled: false)),
              mapboxMap.gestures.updateSettings(GesturesSettings(rotateEnabled: false)),
              mapboxMap.attribution.updateSettings(AttributionSettings(clickable: false, iconColor: 1)),
              mapboxMap.location.updateSettings(locationSettings),
            ]);
          }
        );
      })
    ]));
}