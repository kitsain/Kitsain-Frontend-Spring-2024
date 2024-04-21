import 'package:kitsain_frontend_spring2023/models/store.dart';

class District {
  String districtName;
  String districtId;
  bool hasStores = false;
  List<Store> districtStores;

  District(
      {required this.districtName,
      required this.districtId,
      required this.hasStores,
      this.districtStores = const []});
}
