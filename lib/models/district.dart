import 'package:kitsain_frontend_spring2023/models/store.dart';

/// Represents a district.
class District {
  String districtName;
  String districtId;
  bool hasStores = false;
  List<Store> districtStores;

  /// Constructs a new instance of the [District] class.
  ///
  /// The [districtName] and [districtId] parameters are required.
  /// The [hasStores] parameter is optional and defaults to `false`.
  /// The [districtStores] parameter is optional and defaults to an empty list.
  District({
    required this.districtName,
    required this.districtId,
    required this.hasStores,
    this.districtStores = const [],
  });
}
