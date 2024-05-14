import 'dart:convert';

import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'package:kitsain_frontend_spring2023/models/city.dart';
import 'package:kitsain_frontend_spring2023/models/district.dart';
import 'package:kitsain_frontend_spring2023/models/store.dart';
import 'package:kitsain_frontend_spring2023/services/auth_service.dart';
import 'package:logger/logger.dart';

/// A service class for handling store-related operations.
class StoreService {
  final accessToken = Get.put(AuthService()).accessToken;
  var logger = Logger(printer: PrettyPrinter());

  // Base URL for the API
  final String baseUrl = 'http://40.113.61.81:9090/api/v1';

  /// Fetches a list of cities from the API.
  ///
  /// Returns a list of [City] objects representing the cities.
  /// Throws an exception if the API request fails.
  Future<List<City>> getCities() async {
    try {
      final response = await http.get(Uri.parse('$baseUrl/cities'), headers: {
        'Content-Type': 'application/json',
        'accept': '*/*',
        'Authorization': 'Bearer ${accessToken.value}',
      });

      if (response.statusCode == 200) {
        List<dynamic> cityResponse = jsonDecode(response.body)['details'];

        List<City> cities = cityResponse
            .map((json) => City(
                  cityId: json['id'],
                  cityName: json['name'],
                ))
            .toList();
        return cities;
      } else {
        throw Exception(
            'Failed to load cities: ${response.statusCode} /n ${response.body}');
      }
    } catch (e) {
      throw Exception('Error fetching cities: $e');
    }
  }

  /// Fetches a list of districts for a given city from the API.
  ///
  /// Returns a list of [District] objects representing the districts.
  /// Throws an exception if the API request fails.
  Future<List<District>> getDistricts(String cityId) async {
    try {
      final response =
          await http.get(Uri.parse('$baseUrl/districts/$cityId'), headers: {
        'Content-Type': 'application/json',
        'accept': '*/*',
        'Authorization': 'Bearer ${accessToken.value}',
      });

      if (response.statusCode == 200) {
        List<dynamic> cityResponse = jsonDecode(response.body)['details'];

        List<District> districts = cityResponse
            .map((json) => District(
                  districtId: json['id'],
                  districtName: json['name'],
                  hasStores: json['stores'].length > 0,
                ))
            .toList();

        return districts;
      } else {
        throw Exception(
            'Failed to load districts: ${response.statusCode} /n ${response.body}');
      }
    } catch (e) {
      throw Exception('Error fetching districts: $e');
    }
  }

  /// Fetches a list of stores for a given district from the API.
  ///
  /// Returns a list of [Store] objects representing the stores.
  /// Throws an exception if the API request fails.
  Future<List<Store>> getStores(String districtId) async {
    try {
      final response = await http
          .get(Uri.parse('$baseUrl/stores?districtId=$districtId'), headers: {
        'Content-Type': 'application/json',
        'accept': '*/*',
        'Authorization': 'Bearer ${accessToken.value}',
      });

      if (response.statusCode == 200) {
        List<dynamic> districtResponse = jsonDecode(response.body)['details'];

        List<Store> stores = districtResponse
            .map((json) => Store(
                  storeId: json['id'],
                  storeName: json['name'],
                  longitude: json['longitude'],
                  latitude: json['latitude'],
                  storeChain: json['storeChain'],
                  lowerStoreChain: json['lowerStoreChain'],
                ))
            .toList();
        return stores;
      } else {
        throw Exception(
            'Failed to load stores: ${response.statusCode} /n ${response.body}');
      }
    } catch (e) {
      throw Exception('Error fetching stores: $e');
    }
  }

  /// Fetches a store with the given store ID from the API.
  ///
  /// Returns a [Store] object representing the store.
  /// Throws an exception if the API request fails.
  Future<Store> getStore(String storeId) async {
    try {
      final response =
          await http.get(Uri.parse('$baseUrl/stores/$storeId'), headers: {
        'Content-Type': 'application/json',
        'accept': '*/*',
        'Authorization': 'Bearer ${accessToken.value}',
      });

      if (response.statusCode == 200) {
        Map<String, dynamic> storeResponse =
            jsonDecode(response.body)['details'];

        Store store = Store(
          storeId: storeResponse['id'],
          storeName: storeResponse['name'],
          longitude: storeResponse['longitude'],
          latitude: storeResponse['latitude'],
          storeChain: storeResponse['storeChain'],
          lowerStoreChain: storeResponse['lowerStoreChain'],
        );

        return store;
      } else {
        throw Exception(
            'Failed to load store name: ${response.statusCode} /n ${response.body}');
      }
    } catch (e) {
      throw Exception('Error fetching store name: $e');
    }
  }
}
