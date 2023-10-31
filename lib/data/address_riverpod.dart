import 'dart:developer';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:geocoding/geocoding.dart';
import 'package:geolocator/geolocator.dart';

final addressProvider =
    NotifierProvider<AdressProvider, AdressModel>(AdressProvider.new);

class AdressProvider extends Notifier<AdressModel> {
  @override
  AdressModel build() {
    return AdressModel(latlng: '', address: '');
  }

  Future<Position> initPosition() async {
    LocationPermission permission;
    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        return Future.error('Location permissions are denied');
      }
    }
    if (permission == LocationPermission.deniedForever) {
      return Future.error(
          'Location permissions are permanently denied, we cannot request permissions.');
    }
    return await Geolocator.getCurrentPosition(
        timeLimit: const Duration(seconds: 10));
  }

  // get lat lng of device
  Future<void> getPosition() async {
    try {
      final result = await initPosition();
      state.latlng = "${result.latitude} ${result.longitude}";
      log(state.latlng);
      await translateLatLng(result.latitude, result.longitude);
    } catch (e) {
      log(e.toString());
    }
  }

  // translate latlng to address
  Future<void> translateLatLng(double lat, double lng) async {
    try {
      final result = await placemarkFromCoordinates(lat, lng);
      state.address =
          "${result.first.subAdministrativeArea} ${result.first.locality} ${result.first.thoroughfare} ${result.first.street}";
      log(state.address);
    } catch (e) {
      log(e.toString());
    }
  }
}

class AdressModel {
  String latlng;
  String address;

  AdressModel({required this.latlng, required this.address});
}
