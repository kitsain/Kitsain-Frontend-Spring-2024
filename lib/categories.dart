import 'package:flutter/material.dart';

class Categories {
  static List<Image> categoryImages = [
    'assets/images/meals.png', // new
    'assets/images/proteins.png',
    'assets/images/proteins.png', // seafood
    'assets/images/fruits.png',
    'assets/images/vegetables.png',
    'assets/images/frozen.png',
    'assets/images/drinks.png',
    'assets/images/drinks.png', // bread
    'assets/images/treats.png',
    'assets/images/dairy.png',
    'assets/images/meals.png',
    'assets/images/meals.png', // dry n canned goods
    'assets/images/meals.png', // other
  ].map((assetString) => Image.asset(assetString)).toList();

  static Map<int, String> categoriesByIndex = {
    0: 'No category',
    1: 'Meat',
    2: 'Seafood',
    3: 'Fruit',
    4: 'Vegetables',
    5: 'Frozen',
    6: 'Drinks',
    7: 'Bread',
    8: 'Treats',
    9: 'Dairy',
    10: 'Ready meals',
    11: 'Dry & canned goods',
    12: 'Other'
  };
}

class Categoriesr {
  static List<Image> categoryImages = [
    'assets/images/meals.png', // new
    'assets/images/proteins.png',
    'assets/images/proteins.png', // seafood
    'assets/images/fruits.png'
  ].map((assetString) => Image.asset(assetString)).toList();

  static Map<int, String> categoriesByIndex = {
    1: 'Weekend',
    2: 'Weekdays',
    3: 'Holidays',
    4: 'Quick recipes'
  };
}
