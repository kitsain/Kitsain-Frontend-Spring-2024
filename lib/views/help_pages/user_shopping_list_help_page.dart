import 'package:flutter/material.dart';
import 'package:kitsain_frontend_spring2023/app_colors.dart';
import 'package:kitsain_frontend_spring2023/app_typography.dart';

const List<List<String>> paragraphs = [
  ["Once you've opened a shopping list, you", 'can manage its contents.'],
  [
    'While grocery shopping, you can check off',
    "items as you go. Once you're done, you can",
    'move all checked items to pantry. This',
    "doesn't remove items from the",
    'shopping lists, so you can keep reusing the',
    'same list over and over if you want to!'
  ],
  [
    'Add items to the shopping list either by',
    'hand or by using your phone as an EAN',
    'code scanner. Item needs to be sorted to a',
    'category upon adding, and you can add a',
    'description.'
  ],
  [
    'Other details, like an expiration date can',
    'be added after you move it to the pantry'
  ]
];

class UserShoppingListHelp extends StatefulWidget {
  const UserShoppingListHelp({super.key});

  @override
  State<UserShoppingListHelp> createState() => _UserShoppingListHelp();
}

class _UserShoppingListHelp extends State<UserShoppingListHelp> {
  //Helper function for creating texts and icons.
  //Returns text and icon widgets.
  Widget _createParagraph(List<String> paragraph, bool icons) {
    List<Widget> list = <Widget>[];
    for (var line in paragraph) {
      list.add(Text(line, style: AppTypography.paragraph));
      //After last row don't add empty space
      if (line != paragraph[paragraph.length - 1]) {
        list.add(const SizedBox(height: 3));
      }
    }
    return Column(children: list);
  }

  @override
  Widget build(BuildContext context) {
    return Builder(builder: (context) {
      return Scaffold(
        backgroundColor: AppColors.main2,
        body: ListView(children: <Widget>[
          Column(
            children: [
              const SizedBox(height: 50),
              Padding(
                padding: const EdgeInsets.only(right: 10),
                child: Align(
                  alignment: Alignment.centerRight,
                  child: SizedBox(
                    height: MediaQuery.of(context).size.height * 0.05,
                    child: FloatingActionButton(
                        foregroundColor: AppColors.main2,
                        backgroundColor: AppColors.main3,
                        child: const Icon(Icons.close),
                        onPressed: () {
                          Navigator.pop(context);
                        }),
                  ),
                ),
              ),
              const SizedBox(height: 15),
              Text(
                "WHAT CAN I DO\nWITH AN OPENED\nSHOPPING LIST?",
                style: AppTypography.heading2.copyWith(color: AppColors.main3),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 15),
              _createParagraph(paragraphs[0], true),
              _createParagraph(paragraphs[1], true),
              Container(
                height: MediaQuery.of(context).size.height * 0.3,
                decoration: const BoxDecoration(
                  image: DecorationImage(
                    image: AssetImage("assets/images/shopping_lists_help.png"),
                    // fit: BoxFit.cover,
                    // alignment: Alignment.bottomCenter,
                  ),
                ),
              ),
              _createParagraph(paragraphs[2], true),
              _createParagraph(paragraphs[3], false),
              const SizedBox(height: 50),
              SizedBox(
                width: 100,
                height: 50,
                child: ElevatedButton(
                  style: ButtonStyle(
                    foregroundColor: MaterialStateProperty.resolveWith(
                        (states) => AppColors.main2),
                    backgroundColor: MaterialStateProperty.resolveWith(
                        (states) => AppColors.main3),
                  ),
                  onPressed: () {
                    Navigator.pop(context);
                  },
                  child: const Text(
                    "GOT IT",
                    style: AppTypography.category,
                  ),
                ),
              ),
              const SizedBox(height: 50),
            ],
          ),
        ]),
      );
    });
  }
}
