import 'dart:io';
import 'package:currency_text_input_formatter/currency_text_input_formatter.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import 'package:kitsain_frontend_spring2023/app_colors.dart';
import 'package:kitsain_frontend_spring2023/assets/image_carousel.dart';
import 'package:kitsain_frontend_spring2023/models/post.dart';
import 'package:kitsain_frontend_spring2023/services/post_service.dart';
import 'package:logger/logger.dart';
import 'package:kitsain_frontend_spring2023/database/item.dart';

class tagSelectView extends StatefulWidget {
  final List<String> myTags;

  const tagSelectView({
    super.key, required this.myTags
  });

  @override
  State<tagSelectView> createState() => _tagSelectViewState();
}

class _tagSelectViewState extends State<tagSelectView> {
  final Map _tags = CategoryMaps().catEnglish;
  late List<String> _myTags = [];
  final List<Color> _buttonColors = [];

  @override
  void initState() {
    super.initState();
    _myTags = widget.myTags;
    // markTagsSelected();
  }

  bool _isSelected(String tag) {
    return _myTags.contains(tag);
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(20.0),
      child: Container(
        width: MediaQuery.of(context).size.width,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(child: Text('Select tags:')),
            SizedBox(height: 10),
            Wrap(
              children: List.generate(_tags.length, (index) {
                Color color;
                if (_myTags.contains(_tags[index+1])){
                  color = Colors.grey;
                } else {
                  color = Colors.white;
                }
                _buttonColors.add(color);

                return Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 2.0),
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: _buttonColors[index]
                    ),
                      onPressed: () {
                        Color BtnColor = _buttonColors[index];
                        setState(() {
                          if (BtnColor == Colors.white){
                            _buttonColors[index] = Colors.grey;
                            _myTags.add(_tags[index+1]);
                          } else if (BtnColor == Colors.grey) {
                            _buttonColors[index] = Colors.white;
                            _myTags.remove(_tags[index+1]);
                          }
                          print(_myTags);
                        });
                      },
                      child: Text('+  ${_tags[index + 1]}')),
                );
              }),
            ),
            SizedBox(height: 30),
            Center(
              child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.deepPurple,
                    foregroundColor: Colors.white,
                  ),
                  onPressed: (){
                    Navigator.pop(context, _myTags);
                  },
                  child: const Text('Done')
              ),
            )
          ],
        ),
      ),
    );
  }
}
