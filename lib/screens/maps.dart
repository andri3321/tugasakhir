import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:geolocator/geolocator.dart';
import 'package:permission_handler/permission_handler.dart';

class MapsPage extends StatefulWidget {
  @override
  _MapsPageState createState() => _MapsPageState();
}

class _MapsPageState extends State<MapsPage> {
  late GoogleMapController mapController;
  LatLng _currentPosition = LatLng(0, 0);
  bool _isLoadingLocation = false;
  double _currentZoom = 15.0; // Zoom level default
  double _circleRadius = 10; // Radius lingkaran awal dalam meter

  @override
  void initState() {
    super.initState();
    _getUserLocation(); // Ambil lokasi pengguna saat aplikasi dimulai
  }

  Future<void> _getUserLocation({bool moveToLocation = false}) async {
    setState(() {
      _isLoadingLocation = true;
    });

    if (await Permission.location.request().isGranted) {
      Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );

      setState(() {
        _currentPosition = LatLng(position.latitude, position.longitude);
        _isLoadingLocation = false;

        if (moveToLocation) {
          // Pindahkan kamera ke lokasi pengguna dengan zoom in
          mapController.animateCamera(
            CameraUpdate.newLatLngZoom(_currentPosition, 15.0),
          );
        }
      });
    } else {
      setState(() {
        _isLoadingLocation = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Izin lokasi ditolak")),
      );
    }
  }

  void _updateCircleRadius(double zoom) {
    // Perhitungan radius lingkaran dinamis berdasarkan zoom level
    setState(() {
      _circleRadius =
          50 * (20 - zoom); // Sesuaikan faktor perhitungan sesuai kebutuhan
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Maps")),
      body: Stack(
        children: [
          GoogleMap(
            initialCameraPosition: CameraPosition(
              target: _currentPosition,
              zoom: _currentZoom,
            ),
            myLocationEnabled: false,
            myLocationButtonEnabled: false,
            onMapCreated: (controller) {
              mapController = controller;
            },
            onCameraMove: (CameraPosition position) {
              _currentZoom = position.zoom;
              _updateCircleRadius(
                  _currentZoom); // Perbarui radius lingkaran saat zoom berubah
            },
            markers: {
              Marker(
                markerId: MarkerId('userLocation'),
                position: _currentPosition,
                icon: BitmapDescriptor.defaultMarkerWithHue(
                  BitmapDescriptor.hueBlue,
                ),
                visible: false,
              ),
            },
            circles: {
              Circle(
                circleId: CircleId("userCircle"),
                center: _currentPosition,
                radius: _circleRadius, // Radius dinamis
                strokeWidth: 2,
                strokeColor: Colors.blue,
                fillColor: Colors.blue.withOpacity(0.5),
              ),
            },
          ),
          if (_isLoadingLocation)
            Center(
              child: CircularProgressIndicator(),
            ),
          Positioned(
            right: 10,
            bottom: 100,
            child: FloatingActionButton(
              heroTag: "myLocation",
              onPressed: () => _getUserLocation(
                  moveToLocation: true), // Ambil lokasi dan pindahkan kamera
              backgroundColor: Colors.white,
              child: Icon(
                Icons.my_location,
                color: Colors.blue,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
