import 'package:flutter/material.dart';
import 'package:kitsain_frontend_spring2023/views/main_menu_pages/feed/tag_select_view.dart';
import 'package:logger/logger.dart';
import '../../../assets/tag.dart';
import '../../../models/city.dart';
import '../../../models/district.dart';
import '../../../models/store.dart';
import '../../../services/store_service.dart';

class FilterView extends StatefulWidget {
  final List<List<String?>> parameters;

  const FilterView({
    super.key, required this.parameters});

  @override
  State<FilterView> createState() => _FilterViewState();
}

class _FilterViewState extends State<FilterView> {
  var logger = Logger(printer: PrettyPrinter());
  final StoreService _storeService = StoreService();

  late List<String> _myTags = [];

  // Information fetched from dropdown menu
  String? _selectedCityValue;
  String? _selectedDistrictValue;
  String? _selectedStoreValue;

  // Information fetched from backend
  List<City> _cities = [];
  List<District> _districts = [];
  List<Store> _stores = [];
  bool _dataReady = false;

  // Filtering parameters to be returned
  final List<String?> _filterLocation = [];

  @override
  void initState() {
    super.initState();

    if (widget.parameters.isNotEmpty) {
      _myTags = widget.parameters[0].map((e) => e.toString()).toList();
    }

    /*_selectedCityValue = null;
    _selectedDistrictValue = null;
    _selectedStoreValue = null;*/

    fetchCityData();
  }

  /// Fetches city data and updates the state with the fetched data.
  /// If a post is provided, it sets the selected city, district, and store based on the post's store ID.
  /// If no post is provided, it fetches all cities and districts and sets the state accordingly.
  /// Removes cities and districts that do not have any stores.
  ///
  /// Returns: A [Future] that completes when the city data is fetched and the state is updated.
  Future<void> fetchCityData() async {
    final allCities = await _storeService.getCities();
    final citiesToRemove = <City>[];

    for (City city in allCities) {
      final districts = await _storeService.getDistricts(city.cityId);
      final districtsToRemove = <District>[];

      for (District district in districts) {
        if (!district.hasStores) {
          districtsToRemove.add(district);
        }
      }

      if (districts.length == districtsToRemove.length) {
        citiesToRemove.add(city);
      }
    }

    for (City city in citiesToRemove) {
      allCities.remove(city);
    }

    for (City city in allCities) {
      final allDistricts = await _storeService.getDistricts(city.cityId);
      for (District dist in allDistricts) {
        if (dist.hasStores) {
          _stores = await _storeService.getStores(dist.districtId);
          if (_stores.isNotEmpty) {
            for (Store store in _stores) {
              setState(() {
                _cities = allCities;
                _districts = allDistricts
                    .where((district) => district.hasStores)
                    .toList();
                /*_selectedCityValue = city.cityId;
                _selectedDistrictValue = dist.districtId;
                _selectedStoreValue = store.storeId;*/
                _dataReady = true;
              });
              return;
            }
          }
        }
      }
    }

    setState(() {
      logger.i('Store: ');
      _cities = allCities;
      _dataReady = true;
    });
  }

  void _removeFilters() {
    setState(() {
      _myTags.clear();
      _selectedCityValue = null;
      _selectedDistrictValue = null;
      _selectedStoreValue = null;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Container(
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text('Select tags:'),
                ElevatedButton(
                    onPressed: () {
                      showModalBottomSheet(context: context,
                          builder: (buildContext) {
                            return TagSelectView(myTags: _myTags);
                          }).then((tags) {
                            setState(() {
                              _myTags = tags;
                            });
                      });
                      },
                    child: const Text('Set tags'))
              ],
            ),
            Wrap(
              children: List.generate(_myTags.length, (index) {
                return _myTags.isEmpty
                  ? const Text('NoTags')
                  : Padding(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 2.0),
                  child: Tag(text: _myTags[index]));
              })
            ),
            const Divider(),
            const Text('Select store:'),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                DropdownButton<String>(
                  value: _selectedCityValue,
                  hint: const Text('City'),
                  items: _cities.map((City city) {
                    return DropdownMenuItem<String>(
                      value: city.cityId,
                      child: Text(city.cityName),
                    );
                  }).toList(),
                  onChanged: (newValue) async {
                    setState(() {
                      _selectedCityValue = newValue!;
                      // Reset the selected district value when the city changes
                      _selectedDistrictValue = null;
                      _selectedStoreValue = null;
                      _stores = [];
                      _districts = [];
                    });
                    // Fetch districts for the newly selected city
                    var allDistricts =
                    await _storeService.getDistricts(newValue!);
                    for (District district in allDistricts) {
                      if (district.hasStores) {
                        _districts.add(district);
                      }
                    }
                    setState(() {
                      _selectedCityValue = newValue;
                    });
                  },
                ),
                DropdownButton<String>(
                  value: _selectedDistrictValue,
                  hint: const Text('District'),
                  items: _districts.map((District district) {
                    return DropdownMenuItem<String>(
                      value: district.districtId,
                      child: Text(district.districtName),
                    );
                  }).toList(),
                  onChanged: (newValue) async {
                    setState(() {
                      _selectedDistrictValue = newValue!;
                      // Reset the selected district value when the city changes
                      _selectedStoreValue = null;
                      _stores = [];
                    });
                    // Fetch districts for the newly selected city
                    _stores = await _storeService.getStores(newValue!);
                    setState(() {
                      _selectedDistrictValue = newValue;
                    });
                  },
                ),
              ],
            ),
            DropdownButton<String>(
              value: _selectedStoreValue,
              hint: const Text('Select Store'),
              items: _stores.map((Store store) {
                return DropdownMenuItem<String>(
                  value: store.storeId,
                  child: Text(store.storeName),
                );
              }).toList(),
              onChanged: (newValue) {
                setState(() {
                  _selectedStoreValue = newValue!;
                });
              },
            ),
            const Divider(),
            OutlinedButton(
                onPressed: (){
                  _removeFilters();
                },
                style: OutlinedButton.styleFrom(
                  side: const BorderSide(color: Colors.red),
                  foregroundColor: Colors.red,
                ),
                child: const Text('Remove filters')
            ),
            ElevatedButton(
                onPressed: (){
                  _filterLocation.add(_selectedCityValue);
                  _filterLocation.add(_selectedDistrictValue);
                  _filterLocation.add(_selectedStoreValue);

                  // List of selected parameters, where value at idx 0 is
                  // a list of selected tags, and value at idx 1 is list
                  // of selected location
                  List<List<String?>> results = [];
                  results.add(_myTags);
                  results.add(_filterLocation);

                  Navigator.pop(context, results);
                },
                child: const Text('Done'))
          ],
        ),
      ),
    );
  }
}
