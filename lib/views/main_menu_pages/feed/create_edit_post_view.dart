import 'dart:io';
import 'package:currency_text_input_formatter/currency_text_input_formatter.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import 'package:kitsain_frontend_spring2023/assets/image_carousel.dart';
import 'package:kitsain_frontend_spring2023/models/post.dart';
import 'package:kitsain_frontend_spring2023/services/post_service.dart';
import 'package:logger/logger.dart';

class CreateEditPostView extends StatefulWidget {
  final Post? post;
  final List<String>? existingImages;

  const CreateEditPostView({Key? key, this.post, this.existingImages})
      : super(key: key);

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

  @override
  Widget build(BuildContext context) {
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
                editImageWidget(
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
                            title: Text('Select Image Source'),
                            actions: <Widget>[
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceEvenly,
                                children: [
                                  TextButton(
                                    child: Text('Camera'),
                                    onPressed: () {
                                      Navigator.of(context).pop();
                                      _pickImageFromCamera();
                                    },
                                  ),
                                  const SizedBox(height: 10),
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
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return "Please enter title";
                    }
                    return null;
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
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return "Please enter description";
                    }
                    return null;
                  },
                ),
                TextFormField(
                  keyboardType: TextInputType.number,
                  inputFormatters: [
                    CurrencyTextInputFormatter.currency(
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
                  decoration: InputDecoration(
                    labelText: 'Select expiring date',
                    suffixIcon: Icon(Icons.calendar_today),
                  ),
                ),
                SizedBox(height: 16),
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
