/// Represents a store with its unique identifier, name, location coordinates, and store chain information.
class Store {
  String storeId;
  String storeName;
  double longitude;
  double latitude;
  String storeChain;
  String lowerStoreChain;

  /// Constructs a new instance of the [Store] class with the given parameters.
  Store({
    required this.storeId,
    required this.storeName,
    required this.longitude,
    required this.latitude,
    required this.storeChain,
    required this.lowerStoreChain,
  });
}
