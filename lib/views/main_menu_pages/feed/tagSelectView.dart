import 'package:flutter/material.dart';
import 'package:kitsain_frontend_spring2023/services/post_service.dart';
import 'package:kitsain_frontend_spring2023/database/item.dart';

class TagSelectView extends StatefulWidget {
  final List<String> myTags;

  const TagSelectView({
    super.key, required this.myTags
  });

  @override
  State<TagSelectView> createState() => _TagSelectViewState();
}

class _TagSelectViewState extends State<TagSelectView> {
  PostService postService = PostService();
  //List<String> _tags = [];
  final Map _tags = CategoryMaps().catEnglish;
  late List<String> _myTags = [];
  final List<Color> _buttonColors = [];

  @override
  void initState() {
    super.initState();
    _myTags = widget.myTags;
    // markTagsSelected();
    //loadTags();
  }

  void loadTags() async {
    // _tags = await postService.getTags();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(20.0),
      child: SizedBox(
        width: MediaQuery.of(context).size.width,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Center(child: Text('Select tags:')),
            const SizedBox(height: 10),
            Expanded(
              child: Scrollbar(
                thumbVisibility: true,
                child: SingleChildScrollView(
                  physics: const AlwaysScrollableScrollPhysics(),
                  child: Padding(
                    padding: const EdgeInsets.only(right: 10),
                    child: Wrap(
                      children: List.generate(_tags.length, (index) {
                        Color color;
                        if (_myTags.contains(_tags[index])){
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
                                    _myTags.add(_tags[index]);
                                  } else if (BtnColor == Colors.grey) {
                                    _buttonColors[index] = Colors.white;
                                    _myTags.remove(_tags[index]);
                                  }
                                  print(_myTags);
                                });
                              },
                              child: Text('+  ${_tags[index]}')),
                        );
                      }),
                    ),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 30),
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
