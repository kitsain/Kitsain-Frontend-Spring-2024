import 'dart:ffi';
import 'dart:io';
import 'dart:math';
import 'package:currency_text_input_formatter/currency_text_input_formatter.dart';
import 'package:kitsain_frontend_spring2023/database/openfoodfacts.dart';
import 'package:kitsain_frontend_spring2023/models/post.dart';
import 'package:kitsain_frontend_spring2023/services/post_service.dart';
import 'package:kitsain_frontend_spring2023/views/createPost/create_post_image_widget.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import 'package:kitsain_frontend_spring2023/views/main_menu_pages/feed/feed_image_widget.dart';
import 'package:logger/logger.dart';
import 'package:google_ml_kit/google_ml_kit.dart';
import 'package:openfoodfacts/openfoodfacts.dart';

/// A view for creating a new post.
///
/// This view allows the user to enter a title and an image for the post.
/// Once the user clicks the "Create" button, the post will be created.
class CreatePostView extends StatefulWidget {
  const CreatePostView({super.key});

  @override
  CreatePostViewState createState() => CreatePostViewState();
}

/// The state of the [CreatePostView] widget.
///
/// This state manages the title, image, price, and selected date for the post.
class CreatePostViewState extends State<CreatePostView> {
  var logger = Logger(printer: PrettyPrinter());
  final PostService _postService = PostService();
  // Content variables for the content of the post
  final List<String> _images = [];
  String _title = '';
  String _description = '';
  String _price = '';
  DateTime _expiringDate = DateTime.now();

  // Date variables for the expiration date of the post
  final DateFormat _dateFormat = DateFormat('dd.MM.yyyy');
  final TextEditingController _dateController = TextEditingController();

  /// Function for taking an image with camera.
  Future<void> _pickImageFromCamera() async {
    try {
      final pickedImage =
          await ImagePicker().pickImage(source: ImageSource.camera);
      if (pickedImage == null) return;
      fetchBarCode(File(pickedImage.path));
      _images.add(await _postService.uploadFile(File(pickedImage.path)));
      setState(() {});
    } on PlatformException catch (e) {
      debugPrint('Failed to pick Image: $e');
    }
  }

  Future<void> fetchBarCode(File file) async {
    logger.i('Fetching barcode from image');
    var barCodeScanner = GoogleMlKit.vision.barcodeScanner();
    final inputImage = InputImage.fromFile(file);
    final List<Barcode> barcodes =
        await barCodeScanner.processImage(inputImage);
    if (barcodes.isEmpty) {
      logger.i('No barcode found');
      return;
    }
    for (Barcode barcode in barcodes) {
      if (barcode.rawValue != null) {
        final String rawValue = barcode.rawValue!;
        logger.i('Barcode raw value: $rawValue');
        OpenFoodAPIConfiguration.userAgent = UserAgent(
          name: 'Kitsain',
        );

        try {
          var product = await getFromJson(rawValue);
          logger.i('Product name: ${product!.productName}');
        } catch (e) {
          // Handle any errors that occur during fetching product information
          logger.e('Error fetching product information: $e');
        }
      } else {
        logger.w('Barcode raw value is null');
      }
    }
  }

  /// Function for selecting a picture from gallery.
  Future<void> _pickImageFromGallery() async {
    try {
      final pickedImage = await ImagePicker().pickImage(
          imageQuality: 100,
          maxHeight: 1000,
          maxWidth: 1000,
          source: ImageSource.gallery);

      if (pickedImage != null) {
        fetchBarCode(File(pickedImage.path));
        _images.add(await _postService.uploadFile(File(pickedImage.path)));
        setState(() {});
      }
    } on PlatformException catch (e) {
      debugPrint('Failed to pick Image: $e');
    }
    // Add logic to select an image from the gallery
  }

  /// Function to select the expiration date of the post
  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _expiringDate,
      firstDate: DateTime(2000),
      lastDate: DateTime(2101),
    );
    if (picked != null && picked != _expiringDate) {
      setState(() {
        _expiringDate = picked;
        _dateController.text = _dateFormat.format(_expiringDate);
      });
    }
  }

  Future<Post?> _createPost() async {
    // Create a Post object using the entered data
    return await _postService.createPost(
      images: _images,
      title: _title,
      description: _description,
      price: _price,
      expiringDate: _expiringDate,
    );

    // TODO Add logic to save the post or perform any other actions
    // TODO send photo or image file to back-end
    // TODO send content to back-end
  }

  @override
  void initState() {
    super.initState();
    _dateController.text = _dateFormat.format(_expiringDate);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Create Post'),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(15.0),
          child: Column(
            children: [
              editImageWidget(images: _images),
              const SizedBox(height: 5),
              Padding(
                padding: const EdgeInsets.all(15.0),
                child: ElevatedButton(
                  onPressed: () {
                    showDialog(
                      context: context,
                      builder: (BuildContext context) {
                        return AlertDialog(
                          title: Text('Select Image Source'),
                          actions: <Widget>[
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                              children: [
                                TextButton(
                                  child: Text('Camera'),
                                  onPressed: () {
                                    Navigator.of(context).pop();
                                    _pickImageFromCamera();
                                  },
                                ),
                                SizedBox(height: 10),
                                TextButton(
                                  child: Text('Gallery'),
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
                  child: Text('Add Image'),
                ),
              ),
              TextField(
                decoration: const InputDecoration(
                  labelText: 'Title',
                ),
                onChanged: (value) {
                  setState(() {
                    _title = value;
                  });
                },
              ),
              TextField(
                decoration: const InputDecoration(
                  labelText: 'Description',
                ),
                onChanged: (value) {
                  setState(() {
                    _description = value;
                  });
                },
              ),
              TextField(
                keyboardType: TextInputType.number,
                inputFormatters: [
                  CurrencyTextInputFormatter(
                    decimalDigits: 2,
                    locale: 'eu',
                    symbol: '€',
                  )
                ],
                decoration: const InputDecoration(
                  labelText: 'Price',
                ),
                onChanged: (value) {
                  setState(() {
                    _price = value;
                  });
                },
              ),
              TextFormField(
                controller: _dateController,
                readOnly: true,
                onTap: () => _selectDate(context),
                decoration: InputDecoration(
                  labelText: 'Select expiring date',
                  suffixIcon: Icon(Icons.calendar_today),
                ),
              ),
              SizedBox(height: 16),
              ElevatedButton(
                onPressed: () async {
                  Post? newPost = await _createPost();
                  Navigator.pop(context, newPost);
                },
                child: Text('Create'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
