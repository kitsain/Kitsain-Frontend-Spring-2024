import 'dart:io';
import 'package:currency_text_input_formatter/currency_text_input_formatter.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import 'package:kitsain_frontend_spring2023/models/post.dart';
import 'package:kitsain_frontend_spring2023/services/post_service.dart';
import 'package:kitsain_frontend_spring2023/views/createPost/create_post_image_widget.dart';
import 'dart:math';

class CreateEditPostView extends StatefulWidget {
  final Post? post;

  const CreateEditPostView({Key? key, this.post}) : super(key: key);

  @override
  _CreateEditPostViewState createState() => _CreateEditPostViewState();
}

class _CreateEditPostViewState extends State<CreateEditPostView> {
  late List<String> _images;
  late String _title;
  late String _description;
  late String _price;
  late DateTime _expiringDate;

  final DateFormat _dateFormat = DateFormat('dd.MM.yyyy');
  final TextEditingController _dateController = TextEditingController();
  final FocusNode _descriptionFocusNode = FocusNode();
  final FocusNode _titleFocusNode = FocusNode();
  final PostService _postService = PostService();

  @override
  void initState() {
    super.initState();
    if (widget.post != null) {
      _images = List.from(widget.post!.images);
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

      _images.add(await _postService.uploadFile(File(pickedImage.path)));
      setState(() {});
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
          source: ImageSource.gallery);

      if (pickedImage != null) {
        _images.add(await _postService.uploadFile(File(pickedImage.path)));
        debugPrint('Added image to _images list: $_images');
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

  Future<Post?> _updateOrCreatePost() async {
    // Extract values from the form fields
    String title = _title;
    String description = _description;
    String price = _price;
    DateTime expiringDate = _expiringDate;

    // Create or update the post
    return await _postService.createPost(
      images: _images,
      title: title,
      description: description,
      price: price,
      expiringDate: expiringDate,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.post != null ? 'Edit Post' : 'Create Post'),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(15.0),
          child: Column(
            children: [
              editImageWidget(
                images: const [],
                stringImages: _images,
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
              TextFormField(
                focusNode: _titleFocusNode,
                decoration: InputDecoration(
                  labelText: 'Title',
                ),
                initialValue: _title,
                onChanged: (value) {
                  setState(() {
                    _title = value;
                  });
                },
              ),
              TextFormField(
                focusNode: _descriptionFocusNode,
                decoration: InputDecoration(
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
                initialValue: _price,
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
                  Post? updatedPost = await _updateOrCreatePost();
                  Navigator.pop(context, updatedPost);
                },
                child: Text(widget.post != null ? 'Update' : 'Create'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
