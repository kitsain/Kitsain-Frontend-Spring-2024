import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import 'package:kitsain_frontend_spring2023/assets/image_carousel.dart';
import 'package:kitsain_frontend_spring2023/database/openfoodfacts.dart';
import 'package:kitsain_frontend_spring2023/models/city.dart';
import 'package:kitsain_frontend_spring2023/models/district.dart';
import 'package:kitsain_frontend_spring2023/models/post.dart';
import 'package:kitsain_frontend_spring2023/models/store.dart';
import 'package:kitsain_frontend_spring2023/services/post_service.dart';
import 'package:kitsain_frontend_spring2023/services/store_service.dart';
import 'package:kitsain_frontend_spring2023/views/main_menu_pages/feed/tag_select_view.dart';
import 'package:logger/logger.dart';
import 'package:google_ml_kit/google_ml_kit.dart';
import 'package:openfoodfacts/openfoodfacts.dart';

import '../../../assets/tag.dart';

class CreateEditPostView extends StatefulWidget {
  final Post? post;
  final List<String>? existingImages;

  const CreateEditPostView({super.key, this.post, this.existingImages});

  @override
  _CreateEditPostViewState createState() => _CreateEditPostViewState();
}

class _CreateEditPostViewState extends State<CreateEditPostView> {
  var logger = Logger(printer: PrettyPrinter());
  final PostService _postService = PostService();
  final StoreService _storeService = StoreService();

  late List<String> _images = [];
  String _id = '';
  String _description = '';
  DateTime _expiringDate = DateTime(2000, 1, 2);
  List<String> _myTags = [];
  List<File> tempImages = [];
  final DateFormat _dateFormat = DateFormat('dd.MM.yyyy');
  final TextEditingController _dateController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  bool imageSelected = true;
  final FocusNode _descriptionFocusNode = FocusNode();
  final FocusNode _titleFocusNode = FocusNode();
  final FocusNode _barcodeFocusNode = FocusNode();
  final _priceFocusNode = FocusNode();

  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _priceController = TextEditingController();
  final TextEditingController _barcodeController = TextEditingController();

  String? _selectedCityValue;
  String? _selectedDistrictValue;
  String? _selectedStoreValue;
  List<City> cities = [];
  List<District> districts = [];
  List<Store> stores = [];

  bool dataReady = false;

  @override
  void initState() {
    super.initState();
    if (widget.post != null) {
      _id = widget.post!.id;
      _images = List.from(widget.existingImages ?? []);
      _titleController.text = widget.post!.title;
      _description = widget.post!.description;
      _priceController.text = widget.post!.price;
      _expiringDate = widget.post!.expiringDate;
      _dateController.text = _expiringDate != DateTime(2000, 1, 2)
          ? _dateFormat.format(_expiringDate)
          : '';
      _myTags = widget.post!.tags;
      _selectedStoreValue = widget.post!.storeId;
      _barcodeController.text = widget.post!.productBarcode;
    } else {
      _images = [];
      _titleController.text = '';
      _description = '';
      _priceController.text = '';
      _expiringDate = DateTime(2000, 1, 2);
      _dateController.text = '';
      _myTags = [];
      _selectedStoreValue = null;
      _barcodeController.text = '';
    }
    _priceFocusNode.addListener(() {
      if (!_priceFocusNode.hasFocus) {
        final String text = _priceController.text.replaceAll(',', '.');
        final num? value = num.tryParse(text);
        if (value != null) {
          _priceController.text =
              NumberFormat.currency(locale: 'eu', symbol: '€', decimalDigits: 2)
                  .format(value);
          setState(() {});
        }
      }
    });

    fetchCityData();
  }

  /// Function for taking an image with camera.
  Future<void> _pickImageFromCamera() async {
    try {
      final pickedImage =
          await ImagePicker().pickImage(source: ImageSource.camera);
      if (pickedImage == null) return;
      fetchBarCode(File(pickedImage.path));
      tempImages.add(File(pickedImage.path));
      setState(() {
        imageSelected = tempImages.isNotEmpty;
      });
    } on PlatformException catch (e) {
      debugPrint('Failed to pick Image: $e');
    }
  }

  /// Function for selecting a picture from gallery.
  Future<void> _pickImageFromGallery() async {
    try {
      final pickedImage = await ImagePicker().pickImage(
        imageQuality: 100,
        maxHeight: 1000,
        maxWidth: 1000,
        source: ImageSource.gallery,
      );

      if (pickedImage != null) {
        fetchBarCode(File(pickedImage.path));
        tempImages.add(File(pickedImage.path));
        setState(() {
          imageSelected = tempImages.isNotEmpty;
        });
      }
    } on PlatformException catch (e) {
      debugPrint('Failed to pick Image: $e');
    }
  }

  /// Function to select the expiration date of the post
  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime(2101),
    );
    if (picked != null && picked != _expiringDate) {
      final DateTime now = DateTime.now();
      final DateTime yesterday = DateTime(now.year, now.month, now.day);
      if (picked.isBefore(yesterday)) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Expiration date cannot be in the past.'),
          ),
        );
        return;
      }
      setState(() {
        _expiringDate = picked;
        _dateController.text = _dateFormat.format(_expiringDate);
      });
    }
  }

  Future<Post?> _updateOrCreatePost() async {
    try {
      // Upload images
      for (var image in tempImages) {
        _images.add(await _postService.uploadFile(image));
      }
      // Check if it's an update operation
      if (widget.post != null) {
        // Update the existing post
        return await _postService.updatePost(
            id: _id,
            images: _images,
            title: _titleController.text,
            description: _description,
            price: _priceController.text,
            expiringDate: _expiringDate,
            tags: _myTags,
            storeId: _selectedStoreValue ?? "",
            productBarcode: _barcodeController.text);
      } else {
        // Create a new post
        return await _postService.createPost(
            images: _images,
            title: _titleController.text,
            description: _description,
            price: _priceController.text,
            expiringDate: _expiringDate,
            tags: _myTags,
            storeId: _selectedStoreValue ?? "",
            productBarcode: _barcodeController.text);
      }
    } catch (error) {
      // Handle errors
      print('Error in _updateOrCreatePost: $error');
      // Return null to indicate failure
      return null;
    }
  }

  Future<void> fetchBarCode(File file) async {
    //logger.i('Fetching barcode from image');
    var barCodeScanner = GoogleMlKit.vision.barcodeScanner();
    final inputImage = InputImage.fromFile(file);
    final List<Barcode> barcodes =
        await barCodeScanner.processImage(inputImage);
    if (barcodes.isEmpty) {
      //logger.i('No barcode found');
      return;
    }
    for (Barcode barcode in barcodes) {
      if (barcode.rawValue != null) {
        final String rawValue = barcode.rawValue!;

        OpenFoodAPIConfiguration.userAgent = UserAgent(
          name: 'Kitsain',
        );

        try {
          _barcodeController.text = rawValue;
          var product = await getFromJson(rawValue);

          _titleController.text = product!.productName ?? '';
        } catch (e) {
          // Handle any errors that occur during fetching product information
          logger.e('Error fetching product information: $e');
        }
      } else {
        logger.w('Barcode raw value is null');
      }
    }
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

    if (widget.post != null) {
      for (City city in allCities) {
        final allDistricts = await _storeService.getDistricts(city.cityId);
        for (District dist in allDistricts) {
          if (dist.hasStores) {
            stores = await _storeService.getStores(dist.districtId);
            if (stores.isNotEmpty) {
              for (Store store in stores) {
                if (store.storeId == widget.post!.storeId) {
                  setState(() {
                    cities = allCities;
                    districts = allDistricts
                        .where((district) => district.hasStores)
                        .toList();
                    _selectedCityValue = city.cityId;
                    _selectedDistrictValue = dist.districtId;
                    _selectedStoreValue = store.storeId;
                    dataReady = true;
                  });
                  return;
                }
              }
            }
          }
        }
      }
    }

    setState(() {
      logger.i('Store: ');
      cities = allCities;
      dataReady = true;
    });
  }

  @override
  void dispose() {
    _titleController.dispose();
    _dateController.dispose();
    _descriptionFocusNode.dispose();
    _titleFocusNode.dispose();
    _priceFocusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.post != null ? 'Edit Post' : 'Create Post'),
      ),
      body: SingleChildScrollView(
        child: dataReady
            ? Form(
                key: _formKey,
                child: Padding(
                  padding: const EdgeInsets.all(15.0),
                  child: Column(
                    children: [
                      EditImageWidget(
                        images: tempImages,
                        stringImages: widget.existingImages ?? [],
                        feedImages: false,
                      ),
                      if ((widget.existingImages?.isEmpty ?? true) &&
                          !imageSelected)
                        const Text(
                          'Select at least one image to create a post.',
                          style: TextStyle(color: Colors.red),
                        ),
                      const SizedBox(height: 5),
                      Padding(
                        padding: const EdgeInsets.all(15.0),
                        child: ElevatedButton(
                          onPressed: () {
                            showDialog(
                              context: context,
                              builder: (BuildContext context) {
                                return AlertDialog(
                                  title: const Text('Select Image Source'),
                                  actions: <Widget>[
                                    Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceEvenly,
                                      children: [
                                        TextButton(
                                          child: const Text('Camera'),
                                          onPressed: () {
                                            Navigator.of(context).pop();
                                            _pickImageFromCamera();
                                          },
                                        ),
                                        const SizedBox(height: 10),
                                        TextButton(
                                          child: const Text('Gallery'),
                                          onPressed: () {
                                            Navigator.of(context).pop();
                                            _pickImageFromGallery();
                                          },
                                        ),
                                      ],
                                    ),
                                  ],
                                );
                              },
                            );
                          },
                          child: const Text('Add Image'),
                        ),
                      ),
                      TextFormField(
                        focusNode: _titleFocusNode,
                        controller: _titleController,
                        decoration: const InputDecoration(
                          labelText: 'Title',
                        ),
                        onChanged: (value) {
                          setState(() {
                            _titleController.text = value;
                          });
                        },
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return "Please enter title";
                          }
                          return null;
                        },
                      ),
                      TextFormField(
                        focusNode: _descriptionFocusNode,
                        decoration: const InputDecoration(
                          labelText: 'Description',
                        ),
                        initialValue: _description,
                        onChanged: (value) {
                          setState(() {
                            _description = value;
                          });
                        },
                      ),
                      TextFormField(
                        controller: _priceController,
                        focusNode: _priceFocusNode,
                        keyboardType: TextInputType.number,
                        decoration: const InputDecoration(
                          labelText: 'Price',
                        ),
                        onEditingComplete: () {
                          final String text =
                              _priceController.text.replaceAll(',', '.');
                          final num? value = num.tryParse(text);
                          if (value != null) {
                            _priceController.text = NumberFormat.currency(
                                    locale: 'eu', symbol: '€', decimalDigits: 2)
                                .format(value);
                            setState(() {});
                          }
                        },
                      ),
                      TextFormField(
                        controller: _dateController,
                        readOnly: true,
                        onTap: () => _selectDate(context),
                        decoration: const InputDecoration(
                          labelText: 'Select expiring date',
                          suffixIcon: Icon(Icons.calendar_today),
                        ),
                      ),
                      TextFormField(
                        focusNode: _barcodeFocusNode,
                        controller: _barcodeController,
                        decoration: const InputDecoration(
                          labelText: 'Product barcode',
                        ),
                        onChanged: (value) {
                          setState(() {
                            _barcodeController.text = value;
                          });
                        },
                      ),
                      const SizedBox(height: 10),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text('Tags'),
                          ElevatedButton(
                            onPressed: () {
                              showModalBottomSheet(
                                  context: context,
                                  builder: (BuildContext context) {
                                    return TagSelectView(myTags: _myTags);
                                  }).then((tags) {
                                setState(() {
                                  if (tags != null) {
                                    _myTags = tags;
                                  }
                                });
                                print(_myTags);
                              });
                            },
                            child: const Text('Set tags'),
                          ),
                        ],
                      ),
                      Align(
                        alignment: Alignment.centerLeft,
                        child: Wrap(
                            children: List.generate(_myTags.length, (index) {
                          return _myTags.isEmpty
                              ? const Text('NoTags')
                              : Padding(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 2.0),
                                  child: Tag(text: _myTags[index]));
                        })),
                      ),
                      const Divider(),
                      const SizedBox(height: 16),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          DropdownButton<String>(
                            value: _selectedCityValue,
                            hint: const Text('City'),
                            items: cities.map((City city) {
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
                                stores = [];
                                districts = [];
                              });
                              // Fetch districts for the newly selected city
                              var allDistricts =
                                  await _storeService.getDistricts(newValue!);
                              for (District district in allDistricts) {
                                if (district.hasStores) {
                                  districts.add(district);
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
                            items: districts.map((District district) {
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
                                stores = [];
                              });
                              // Fetch districts for the newly selected city
                              stores = await _storeService.getStores(newValue!);
                              setState(() {
                                _selectedDistrictValue = newValue;
                              });
                            },
                          ),
                        ],
                      ),
                      SizedBox(
                        width: 240,
                        child: DropdownButtonFormField<String>(
                          value: _selectedStoreValue,
                          hint: const Text('Select Store'),
                          items: stores.map((Store store) {
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
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return "Please enter city, district and store";
                            }
                            return null;
                          },
                        ),
                      ),
                      ElevatedButton(
                        onPressed: () async {
                          try {
                            setState(() {
                              imageSelected = tempImages.isNotEmpty;
                            });
                            if (_formKey.currentState!.validate() &&
                                tempImages.isNotEmpty) {
                              Post? updatedPost = await _updateOrCreatePost();
                              Navigator.pop(context, updatedPost);
                            }
                          } catch (e) {
                            print(e);
                          }
                        },
                        child: Text(widget.post != null ? 'Update' : 'Create'),
                      ),
                    ],
                  ),
                ),
              )
            : const CircularProgressIndicator(),
      ),
    );
  }
}
