import 'package:flutter/material.dart';
import 'package:kitsain_frontend_spring2023/views/main_menu_pages/feed/tag_select_view.dart';
import 'package:logger/logger.dart';
import '../../../assets/tag.dart';
import '../../../models/city.dart';
import '../../../models/district.dart';
import '../../../models/store.dart';
import '../../../services/store_service.dart';
import 'package:flutter_gen/gen_l10n/app-localizations.dart';
import 'package:kitsain_frontend_spring2023/app_typography.dart';
import 'package:flutter_gen/gen_l10n/app-localizations.dart';

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
  // previously selected parameters
  late List<List<String?>> _parameters; // = [tags, [city, district, store]]

  // List of tags selected by user
  late List<String> _myTags = [];

  // Information selected by the user from dropdown buttons
  late String? _selectedCityValue;
  late String? _selectedDistrictValue;
  late String? _selectedStoreValue;

  // Information fetched from backend
  List<City> _cities = [];
  List<District> _districts = [];
  List<Store> _stores = [];
  bool _dataReady = false;

  @override
  void initState() {
    super.initState();
    _parameters = widget.parameters;

    if (widget.parameters[0].isNotEmpty) {
      _myTags = widget.parameters[0].map((e) => e.toString()).toList();
    }

    fetchCityData();

    _selectedCityValue = null;
    _selectedDistrictValue = null;
    _selectedStoreValue = null;
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

    // Iterate through all cities and finds each district within a city.
    for (City city in allCities) {
      final allDistricts = await _storeService.getDistricts(city.cityId);
      // Iterate through districts and finds the ones which have stores.
      for (District dist in allDistricts) {
        if (dist.hasStores) {
          _stores = await _storeService.getStores(dist.districtId);
          if (_stores.isNotEmpty) {
            // Iterate through stores and call setState to update the UI.
            for (Store store in _stores) {
              setState(() {
                _cities = allCities;
                _districts = allDistricts
                    .where((district) => district.hasStores)
                    .toList();

                // Check if location info matches previously selected
                // parameters, and update dropdown-button value accordingly.
                if(city.cityId == _parameters[1][0]){
                  _selectedCityValue = city.cityId;
                  if(dist.districtId == _parameters[1][1]){
                    _selectedDistrictValue = dist.districtId;
                    if(store.storeId == _parameters[1][2]){
                      _selectedStoreValue = store.storeId;
                    }
                  }
                }
              });
            }
          }
        }
        if (_selectedDistrictValue != null) {
          break;
        }
      }
      if (_selectedCityValue != null) {
        break;
      }
    }
    setState(() {
      _dataReady = true;
    });
  }

  /// Removes all current filter parameters.
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
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('${AppLocalizations.of(context)!.selectTags}:'),
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
                  child: Text(AppLocalizations.of(context)!.setTagsButton))
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
          Text("${AppLocalizations.of(context)!.selectLocation}:"),
          // Displays a CircularProgressIndicator wheel in UI,
          // if data is still being handled.
          _dataReady ? Column(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  DropdownButton<String>(
                    value: _selectedCityValue,
                    hint: Text(AppLocalizations.of(context)!.cityHint,
                        style: AppTypography.createPostHints),
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
                    hint: Text(AppLocalizations.of(context)!.districtHint,
                        style: AppTypography.createPostHints),
                    items: // Display districts only if a city is selected.
                    _selectedCityValue != null ? _districts.map((District district) {
                      return DropdownMenuItem<String>(
                        value: district.districtId,
                        child: Text(district.districtName),
                      );
                    }).toList()
                    : [],
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
                hint: Text(AppLocalizations.of(context)!.storeHint,
                    style: AppTypography.createPostHints),
                items: // Display stores only if a district is selected.
                _selectedDistrictValue != null ? _stores.map((Store store) {
                  return DropdownMenuItem<String>(
                    value: store.storeId,
                    child: Text(store.storeName),
                  );
                }).toList()
                : [],
                onChanged: (newValue) {
                  setState(() {
                    _selectedStoreValue = newValue!;
                  });
                },
              ),
            ],
          )
          : const CircularProgressIndicator(),
          const Divider(),
          OutlinedButton(
              onPressed: (){
                _removeFilters();
              },
              style: OutlinedButton.styleFrom(
                side: const BorderSide(color: Colors.red),
                foregroundColor: Colors.red,
              ),
              child: Text(AppLocalizations.of(context)!.removeFiltersButton)
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              ElevatedButton(
                  onPressed: (){
                    Navigator.pop(context);
                  },
                  child: Text(
                    AppLocalizations.of(context)!.cancelButton,
                    style: const TextStyle(
                      color: Colors.grey
                    ),
                  )
              ),
              const SizedBox(width: 10),
              ElevatedButton(
                  onPressed: (){
                    List<String?> filterLocation = [];
                    filterLocation.add(_selectedCityValue);
                    filterLocation.add(_selectedDistrictValue);
                    filterLocation.add(_selectedStoreValue);

                    // List of selected parameters with following values:
                    // [[tags] , [city, district, store]].
                    List<List<String?>> results = [];

                    results.add(_myTags);
                    results.add(filterLocation);

                    // Send results back to feedView.
                    Navigator.pop(context, results);
                  },
                  child: Text(AppLocalizations.of(context)!.doneButton)
              ),
            ],
          ),
          const SizedBox(height: 30,)
        ],
      ),
    );
  }
}
