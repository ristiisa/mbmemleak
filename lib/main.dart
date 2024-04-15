import 'dart:async';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:mapbox_maps_flutter/mapbox_maps_flutter.dart';

List<PolylineAnnotationOptions> polylines = [];

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  MapboxOptions.setAccessToken("<TOKEN HERE>");

  var data = json.decode(await rootBundle.loadString("path.json")) as List;
  for(var n = 0; n < 10; n++) polylines.addAll(data.map((e) => PolylineAnnotationOptions(
    geometry: e,
    lineWidth: 5.0,
    lineColor: Colors.red.value,
    lineJoin: LineJoin.ROUND,
  )).toList());

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

  Stream<Position>? location;

  PolylineAnnotationManager? polylineAnnotationManager;
  
  @override
  initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) => Scaffold(
    body: MapWidget(
      key: ValueKey("map"),
      cameraOptions: CameraOptions(center: Point(coordinates: Position(-122.04160728, 37.33676622)), zoom: 12, pitch: 0.0),
      onMapCreated: (mapboxMap) async {
            await Future.wait([
              mapboxMap.scaleBar.updateSettings(ScaleBarSettings(enabled: false)),
              mapboxMap.gestures.updateSettings(GesturesSettings(rotateEnabled: false)),
              mapboxMap.attribution.updateSettings(AttributionSettings(clickable: false, iconColor: 1)),
              mapboxMap.location.updateSettings(locationSettings),
            ]);
        polylineAnnotationManager ??= await mapboxMap.annotations.createPolylineAnnotationManager();

        Timer.periodic(const Duration(milliseconds: 100), (_) async {
          polylineAnnotationManager!.deleteAll();
          await polylineAnnotationManager!.createMulti(polylines!);
        });
      }
    )
  );
}