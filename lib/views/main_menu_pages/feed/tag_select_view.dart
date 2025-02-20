import 'package:flutter/material.dart';
import 'package:kitsain_frontend_spring2023/services/post_service.dart';
import 'package:kitsain_frontend_spring2023/database/item.dart';
import 'package:flutter_gen/gen_l10n/app-localizations.dart';

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
  final List<String> _tags = CategoryMaps().catEnglish;
  late List<String> _myTags = [];
  final List<Color> _buttonColors = [];

  @override
  void initState() {
    super.initState();
    _myTags = widget.myTags;
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
            Center(child: Text('${AppLocalizations.of(context)!.selectTags}:')),
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
                        // if tag is in myTags, set color to grey indicating it is selected
                        // else set color to white indicating it is not selected.
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
                                  // if button is white (not selected), change to grey
                                  if (BtnColor == Colors.white){
                                    _buttonColors[index] = Colors.grey;
                                    _myTags.add(_tags[index]);
                                  // if button is grey (selected), change to white
                                  } else if (BtnColor == Colors.grey) {
                                    _buttonColors[index] = Colors.white;
                                    _myTags.remove(_tags[index]);
                                  }
                                });
                              },
                              child: Text(
                              '+  ${AppLocalizations.of(context)!.tags.split(',')[index]}')
                          ),
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
                  child: Text(AppLocalizations.of(context)!.doneButton)
              ),
            )
          ],
        ),
      ),
    );
  }
}
