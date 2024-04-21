import 'dart:convert';

import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'package:kitsain_frontend_spring2023/models/city.dart';
import 'package:kitsain_frontend_spring2023/models/district.dart';
import 'package:kitsain_frontend_spring2023/models/store.dart';
import 'package:kitsain_frontend_spring2023/services/auth_service.dart';
import 'package:logger/logger.dart';

class StoreService {
  final accessToken = Get.put(AuthService()).accessToken;
  var logger = Logger(printer: PrettyPrinter());

  // Base URL for the API
  final String baseUrl = 'http://nocng.id.vn:9090/api/v1';

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

        //logger.i("Cities loaded successfully");
        return cities;
      } else {
        throw Exception(
            'Failed to load posts: ${response.statusCode} /n ${response.body}');
      }
    } catch (e) {
      throw Exception('Error fetching posts: $e');
    }
  }

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

        //logger.i("Districts loaded successfully");
        return districts;
      } else {
        throw Exception(
            'Failed to load posts: ${response.statusCode} /n ${response.body}');
      }
    } catch (e) {
      throw Exception('Error fetching posts: $e');
    }
  }

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

        //logger.i("Stores loaded successfully");
        return stores;
      } else {
        throw Exception(
            'Failed to load posts: ${response.statusCode} /n ${response.body}');
      }
    } catch (e) {
      throw Exception('Error fetching posts: $e');
    }
  }

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
      throw Exception('Error fetching posts: $e');
    }
  }
}
