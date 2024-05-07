import 'package:flutter/material.dart';
import 'package:kitsain_frontend_spring2023/app_colors.dart';
import 'package:kitsain_frontend_spring2023/app_typography.dart';

const List<List<String>> paragraphs = [
  [
    'In the Discount Feed, you can post images',
    'of discounted items that you find in stores.',
    'You can also add a description, tags, and',
    'location to your post. Other users can',
    'then see your post and decide if they want',
    'to go to the store and buy the discounted',
    'item.'
  ],
  [
    'From the button on the bottom right corner,',
    'you can enter in the post creation page.',
    'Here you can add a photo of the discounted',
    'item and share it with the community.',
    'You need to add at least one image, a',
    'title, and location to your post. You can',
    'also add a clear image of the procuct,',
    'barcode and app will automatically',
    'recognize the product and fill the',
    'title and barcode fields for you.'
  ],
  [
    'You can also filter the posts by tags and',
    'location. This way you can see only the',
    'posts that interest you. To filter the posts,',
    'click on the filter button on the top right',
    'of the feed.'
  ],
  [
    'If post have a barcode, you can shearch',
    'more information about the product',
    'by clicking the OpenFoodFacts or Google',
    'search buttons behind the details button.',
  ],
  [
    'In comments, you can ask questions about',
    'the discounted item or share your opinion',
    'about it. You can delete or edit your own comments',
    'by pressing the comment longer and selecting',
    'delete or edit. You can also show your appreciation',
    'for the post by clicking the thumbs up button.',
  ]
];

class FeedHelp extends StatefulWidget {
  const FeedHelp({super.key});

  @override
  State<FeedHelp> createState() => _FeedHelpState();
}

class _FeedHelpState extends State<FeedHelp> {
  // Helper function for creating texts and icons.
  // Returns text and icon widgets.
  Widget _createParagraph(List<String> paragraph, bool icons) {
    List<Widget> list = <Widget>[];
    for (var line in paragraph) {
      list.add(Text(line, style: AppTypography.paragraph));
      // After last row don't add empty space
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
        body: ListView(
          children: <Widget>[
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
                        },
                      ),
                    ),
                  ),
                ),
                Text(
                  "WHAT IS\nDISCOUNT FEED?",
                  style:
                      AppTypography.heading2.copyWith(color: AppColors.main3),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 15),
                _createParagraph(paragraphs[0], true),
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Container(
                    height: MediaQuery.of(context).size.height * 0.25,
                    width: MediaQuery.of(context).size.width * 0.6,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(10),
                      image: const DecorationImage(
                        image: AssetImage("assets/images/feed_help1.jpg"),
                        fit: BoxFit.fill,
                        // alignment: Alignment.bottomCenter,
                      ),
                    ),
                  ),
                ),
                _createParagraph(paragraphs[1], true),
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Container(
                    height: MediaQuery.of(context).size.height * 0.25,
                    width: MediaQuery.of(context).size.width * 0.6,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(10),
                      image: const DecorationImage(
                        image: AssetImage("assets/images/feed_help2.png"),
                        fit: BoxFit.fill,
                        // alignment: Alignment.bottomCenter,
                      ),
                    ),
                  ),
                ),
                _createParagraph(paragraphs[2], true),
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Container(
                    height: MediaQuery.of(context).size.height * 0.25,
                    width: MediaQuery.of(context).size.width * 0.6,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(10),
                      image: const DecorationImage(
                        image: AssetImage("assets/images/feed_help3.png"),
                        fit: BoxFit.fill,
                        // alignment: Alignment.bottomCenter,
                      ),
                    ),
                  ),
                ),
                _createParagraph(paragraphs[3], true),
                const SizedBox(height: 30),
                _createParagraph(paragraphs[4], true),
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
          ],
        ),
      );
    });
  }
}
