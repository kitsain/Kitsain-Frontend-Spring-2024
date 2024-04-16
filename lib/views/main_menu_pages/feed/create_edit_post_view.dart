import 'dart:io';
import 'package:currency_text_input_formatter/currency_text_input_formatter.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import 'package:kitsain_frontend_spring2023/assets/image_carousel.dart';
import 'package:kitsain_frontend_spring2023/database/openfoodfacts.dart';
import 'package:kitsain_frontend_spring2023/models/post.dart';
import 'package:kitsain_frontend_spring2023/services/post_service.dart';
import 'package:logger/logger.dart';
import 'package:google_ml_kit/google_ml_kit.dart';
import 'package:openfoodfacts/openfoodfacts.dart';

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
  late List<String> _images = [];
  String _id = '';
  String _title = '';
  String _description = '';
  String _price = '';
  DateTime _expiringDate = DateTime.now();
  List<File> tempImages = [];
  final DateFormat _dateFormat = DateFormat('dd.MM.yyyy');
  final TextEditingController _dateController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  bool imageSelected = true;
  final FocusNode _descriptionFocusNode = FocusNode();
  final FocusNode _titleFocusNode = FocusNode();

  final TextEditingController _titleController = TextEditingController();

  var currencyFormatter = CurrencyTextInputFormatter(
    decimalDigits: 2,
    locale: 'eu',
    symbol: '€',
  );

  @override
  void initState() {
    super.initState();
    if (widget.post != null) {
      _id = widget.post!.id;
      _images = List.from(widget.existingImages ?? []);
      _title = widget.post!.title;
      _description = widget.post!.description;
      _price = widget.post!.price;
      _expiringDate = widget.post!.expiringDate;
      _dateController.text = _dateFormat.format(_expiringDate);
    } else {
      _images = [];
      _title = '';
      _description = '';
      _price = '';
      _expiringDate = DateTime.now();
      _dateController.text = _dateFormat.format(_expiringDate);
    }
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
          title: _title,
          description: _description,
          price: _price,
          expiringDate: _expiringDate,
        );
      } else {
        // Create a new post
        return await _postService.createPost(
          images: _images,
          title: _title,
          description: _description,
          price: _price,
          expiringDate: _expiringDate,
        );
      }
    } catch (error) {
      // Handle errors
      print('Error in _updateOrCreatePost: $error');
      // Return null to indicate failure
      return null;
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

          if (_titleController.text.isEmpty) {
            _titleController.text = product!.productName ?? '';
            _title = product.productName ?? '';
          }
        } catch (e) {
          // Handle any errors that occur during fetching product information
          logger.e('Error fetching product information: $e');
        }
      } else {
        logger.w('Barcode raw value is null');
      }
    }
  }

  @override
  void dispose() {
    _titleController.dispose();
    _dateController.dispose();
    _descriptionFocusNode.dispose();
    _titleFocusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    _titleController.text = _title;
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.post != null ? 'Edit Post' : 'Create Post'),
      ),
      body: SingleChildScrollView(
        child: Form(
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
                if ((widget.existingImages?.isEmpty ?? true) && !imageSelected)
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
                      _title = value;
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
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return "Please enter description";
                    }
                    return null;
                  },
                ),
                TextFormField(
                  keyboardType: TextInputType.number,
                  inputFormatters: [currencyFormatter],
                  decoration: const InputDecoration(
                    labelText: 'Price',
                  ),
                  initialValue: _price,
                  onChanged: (value) {
                    setState(() {
                      _price = value;
                    });
                  },
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return "Please enter price";
                    }
                    return null;
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
                const SizedBox(height: 16),
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
        ),
      ),
    );
  }
}
