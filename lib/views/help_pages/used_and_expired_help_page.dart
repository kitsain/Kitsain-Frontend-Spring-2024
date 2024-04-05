import 'package:flutter/material.dart';
import 'package:kitsain_frontend_spring2023/app_colors.dart';
import 'package:kitsain_frontend_spring2023/app_typography.dart';

const List<List<String>> paragraphs = [
  [
    'In pantry history, you can access items that',
    'are no longer in your pantry and follow the',
    "amount of food waste you're producing by",
    'using the toggle button.'
  ],
  [
    'In the bin, you can see the percentage of',
    "your household's food waste. The average",
    'household food waste counts for almost 1/3',
    'of all food waste produced globally. Every',
    'small bit counts, so in Kitsain, you set and',
    'follow your own realistic goals.'
  ],
  [
    'In used, you can see all items listed that',
    "you've had in your pantry in the order",
    "you've used them. You can copy a item to",
    'pantry or a shopping list through the item',
    'card options button.'
  ],
  [
    'If you need tips for how to reduce your',
    'household food waste or want to know',
    'more of it, you can start by visiting:'
  ],
  [
    'Harward / sustainability / food waste',
    'European Comission / food waste',
    'Kuluttajaliitto / ruokahävikki'
  ]
];

class UsedAndExpiredHelp extends StatefulWidget {
  const UsedAndExpiredHelp({super.key});

  @override
  State<UsedAndExpiredHelp> createState() => _UsedAndExpiredHelp();
}

class _UsedAndExpiredHelp extends State<UsedAndExpiredHelp> {
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
                "WHAT IS\nPANTRY HISTORY?",
                style: AppTypography.heading2.copyWith(color: AppColors.main3),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 15),
              _createParagraph(paragraphs[0], true),
              Container(
                height: MediaQuery.of(context).size.height * 0.3,
                decoration: const BoxDecoration(
                  image: DecorationImage(
                    image: AssetImage("assets/images/pantry_history1.png"),
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
                    image: AssetImage("assets/images/pantry_history2.png"),
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
                    image: AssetImage("assets/images/pantry_history3.png"),
                    // fit: BoxFit.cover,
                    // alignment: Alignment.bottomCenter,
                  ),
                ),
              ),
              _createParagraph(paragraphs[3], false),
              const SizedBox(height: 30),
              _createParagraph(paragraphs[4], false),
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
