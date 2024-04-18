import 'package:realm/realm.dart';
part 'item.g.dart';

@RealmModel()
class _Item {
  @PrimaryKey()
  late final String id; // This will NOT be shown to the user
  late String name;
  late String location;
  late int mainCat;
  late bool favorite = false;
  late String? barcode;
  late String? brand;
  late int? quantity;
  late double? price;
  late DateTime? addedDate;
  late DateTime? openedDate;
  late DateTime? expiryDate;
  late bool?
      hasExpiryDate; // used to put items with no expiry date to the bottom of the results when querying by expdate
  late int? usedMonth;
  late int? usedYear;
  late List<String?> categories;
  late List<String?> labels;
  late List<String?> ingredients;
  late String? processing;
  late String? nutritionGrade;
  late List<String?> nutriments;
  late String? ecoscoreGrade;
  late String? packaging;
  late String? origins;
  late String? details;
  late String? googleTaskId;
  late String? amount;
}

@RealmModel()
class _Recipe {
  @PrimaryKey()
  late final String id; // This will NOT be shown to the user
  late String name;
  late Map<String, String> ingredients;
  late List<String> instructions;
  late String? googleTaskId;
  late bool done = false;
}

class CategoryMaps {
  Map catEnglish = {
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

  Map catFinnish = {
    0: 'Ei kategoriaa',
    1: 'Liha',
    2: 'Merenantimet',
    3: 'Hedelmät',
    4: 'Vihannekset',
    5: 'Pakasteet',
    6: 'Juomat',
    7: 'Leivät',
    8: 'Herkut',
    9: 'Maitotuotteet',
    10: 'Valmisateriat',
    11: 'Kuivatuotteet',
    12: 'Muut'
  };
}
