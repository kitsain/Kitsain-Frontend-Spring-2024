import 'package:flutter/material.dart';
import 'package:kitsain_frontend_spring2023/app_colors.dart';
import 'package:kitsain_frontend_spring2023/app_typography.dart';

const List<List<String>> paragraphs = [
  [
    'In the pantry, you can easily see what',
    'items you currently have in your home.',
    'You can sort and filter the view with',
    'different preferences, making it easy to',
    'track down specific items.'
  ],
  [
    'Open an item card by clicking it and set an',
    'expiration and opening day and let Kitsain',
    'tell you which items should be used first',
    'through color coding. Items without a set',
    'expiration date will show up with a grey',
    'color code. Easy, right?'
  ],
  [
    'You can add a new item to your pantry',
    'either by hand or using your phones',
    'camera as an EAN code scanner. You can',
    'edit an item card anytime via the options',
    'icon on the card and drag an item to',
    'different section of the app.'
  ],
  [
    'As we all know, best before date are not',
    'absolute. That is why in Kitsain, You are in',
    'charge of your pantry and decide when an',
    'item is no longer viable for use. Items that',
    'have passed their expiration date will show',
    'up with a black color code but will stay in',
    'the pantry until you mark them either',
    'used or bin them.'
  ]
];

class PantryHelp extends StatefulWidget {
  const PantryHelp({super.key});

  @override
  State<PantryHelp> createState() => _PantryHelp();
}

class _PantryHelp extends State<PantryHelp> {
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
              Text(
                "WHAT IS\nPANTRY?",
                style: AppTypography.heading2.copyWith(color: AppColors.main3),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 15),
              _createParagraph(paragraphs[0], true),
              Container(
                height: MediaQuery.of(context).size.height * 0.3,
                decoration: const BoxDecoration(
                  image: DecorationImage(
                    image: AssetImage("assets/images/pantry_help1.png"),
                    // fit: BoxFit.cover,
                    // alignment: Alignment.bottomCenter,
                  ),
                ),
              ),
              _createParagraph(paragraphs[1], true),
              Container(
                height: MediaQuery.of(context).size.height * 0.3,
                decoration: const BoxDecoration(
                  image: DecorationImage(
                    image: AssetImage("assets/images/pantry_help2.png"),
                    // fit: BoxFit.cover,
                    // alignment: Alignment.bottomCenter,
                  ),
                ),
              ),
              _createParagraph(paragraphs[2], true),
              Container(
                height: MediaQuery.of(context).size.height * 0.3,
                decoration: const BoxDecoration(
                  image: DecorationImage(
                    image: AssetImage("assets/images/pantry_help3.png"),
                    // fit: BoxFit.cover,
                    // alignment: Alignment.bottomCenter,
                  ),
                ),
              ),
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
                  child: const Text("GOT IT"),
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
