import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:kitsain_frontend_spring2023/assets/tag.dart';
import 'package:kitsain_frontend_spring2023/login_controller.dart';
import 'package:kitsain_frontend_spring2023/models/comment.dart';
import 'package:kitsain_frontend_spring2023/models/post.dart';
import 'package:kitsain_frontend_spring2023/services/auth_service.dart';
import 'package:kitsain_frontend_spring2023/services/post_service.dart';
import 'package:kitsain_frontend_spring2023/services/store_service.dart';
import 'package:kitsain_frontend_spring2023/views/main_menu_pages/feed/comment_section_view.dart';
import 'package:kitsain_frontend_spring2023/views/main_menu_pages/feed/create_edit_post_view.dart';
import 'package:logger/logger.dart';
import 'package:external_app_launcher/external_app_launcher.dart';
import 'package:url_launcher/url_launcher.dart';
import 'image_carousel.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:flutter_gen/gen_l10n/app-localizations.dart';
import 'package:kitsain_frontend_spring2023/app_typography.dart';

/// A card widget that displays a post.
class PostCard extends StatefulWidget {
  final Post post;
  final Function(Post) onRemovePost;
  final Function(Post) onEditPost;

  const PostCard({
    super.key,
    required this.post,
    required this.onRemovePost,
    required this.onEditPost,
  });

  @override
  State<PostCard> createState() => _PostCardState();
}

class _PostCardState extends State<PostCard> {
  // Variable to hold the current user
  final loginController = Get.put(LoginController());
  final authService = Get.put(AuthService());
  var logger = Logger(printer: PrettyPrinter());
  final postService = PostService();
  final StoreService storeService = StoreService();
  late String userId;
  bool isOwner = false;
  String storeName = "";
  String expiringDate = "";
  // Stuff for extended postcard
  Widget extendedPostCard = Container();
  bool isExtended = false;
  Icon extendButtonIcon = const Icon(Icons.keyboard_arrow_down);

  @override
  void initState() {
    super.initState();
    fetchUserId();
    fetchStoreName();
    //loadComments();
    if (widget.post.expiringDate != DateTime(2000, 1, 2)) {
      expiringDate = DateFormat('dd.MM.yyyy').format(widget.post.expiringDate);
    } else {
      expiringDate = '';
    }
  }

  Future<void> fetchStoreName() async {
    if (widget.post.storeId == '') {
      setState(() {
        storeName = 'No store';
      });
      return;
    }
    final storeNameFromId = await storeService.getStore(widget.post.storeId);
    setState(() {
      storeName = storeNameFromId.storeName;
    });
  }

  Future<void> fetchUserId() async {
    final fetchedUserId = await postService.getUserId();
    setState(() {
      userId = fetchedUserId;
      isOwner = widget.post.userId == userId;
    });
  }

  Future<void> markPostUseful() async {
    await postService.markPostUseful(widget.post.id);
    Post? updatedPost = await postService.getPostById(widget.post.id);
    setState(() {
      if (updatedPost != null) widget.post.useful = updatedPost.useful;
    });
  }

  /// Edits a post.
  void _editPost(Post post) async {
// Navigate to the CreateEditPostView and wait for the result
    final updatedPost = await Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => CreateEditPostView(post: post)),
    );

    // Check if the updatedPost is not null
    if (updatedPost != null) {
      // Pass the updated post back to the FeedView
      widget.onEditPost(updatedPost);
    }
  }

  /// Shows a confirmation dialog before removing a post.
  void _removeConfirmation(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Remove Post'),
          content: const Text('Are you sure you want to remove this post?'),
          actions: <Widget>[
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
                // Call the removePost method from FeedView
                widget.onRemovePost(widget.post);
              },
              child: const Text('Remove'),
            ),
          ],
        );
      },
    );
  }

  int _commentCount() {
    int count = 0;
    for (var element in widget.post.comments) {
      if (element.message != 'null#800020') count++;
    }
    return count;
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      color: const Color.fromARGB(255, 206, 205, 205),
      child: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  widget.post.title,
                  style: AppTypography.heading4,
                ),
                if (isOwner)
                  PopupMenuButton<String>(
                    icon: const Icon(Icons.more_horiz),
                    onSelected: (value) {
                      if (value == 'remove') {
                        _removeConfirmation(context);
                      } else if (value == 'edit') {
                        _editPost(widget.post);
                      }
                    },
                    itemBuilder: (BuildContext context) =>
                        <PopupMenuEntry<String>>[
                      PopupMenuItem<String>(
                        value: 'edit',
                        child: Text(
                            AppLocalizations.of(context)!.postCardEditButton,
                            style: AppTypography.paragraph),
                      ),
                      PopupMenuItem<String>(
                        value: 'remove',
                        child: Text(
                            AppLocalizations.of(context)!.postCardRemoveButton,
                            style: AppTypography.paragraph),
                      ),
                    ],
                  ),
                if (!isOwner)
                  const SizedBox(
                    height: 40,
                  ),
              ],
            ),
            // Check if there are images to display
            // Add image holder here
            if (widget.post.images.isNotEmpty)
              EditImageWidget(
                  stringImages: widget.post.images, feedImages: true),

            Padding(
              padding: const EdgeInsets.all(4.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  if (expiringDate != '')
                    Flexible(
                      child: Row(
                        children: [
                          Text(
                              "${AppLocalizations.of(context)!.postCardExpiringDate} ",
                              style: AppTypography.postCardTitles),
                          Text(expiringDate,
                              style: AppTypography.postCardValues),
                        ],
                      ),
                    ),
                  if (widget.post.price != '')
                    Flexible(
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          Text(
                              '${AppLocalizations.of(context)!.postCardPrice} ',
                              style: AppTypography.postCardTitles),
                          Text(widget.post.price,
                              style: AppTypography.postCardValues),
                        ],
                      ),
                    ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(4.0),
              child: Row(
                children: [
                  Text('${AppLocalizations.of(context)!.postCardLocation} ',
                      style: AppTypography.postCardTitles),
                  Text(storeName, style: AppTypography.postCardValues),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      IconButton(
                        icon: const Icon(Icons.thumb_up_alt_outlined),
                        onPressed: () {
                          markPostUseful();
                        },
                      ),
                      Text(widget.post.useful.toString()),
                      const SizedBox(width: 16),
                      IconButton(
                        icon: const Icon(Icons.comment_rounded),
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(builder: (context) {
                              List<Comment> comments =
                                  widget.post.comments.cast<Comment>();
                              if (comments.isEmpty) {
                                return CommentSectionView(
                                    postID: widget.post.id, comments: const []);
                              } else {
                                return CommentSectionView(
                                    postID: widget.post.id, comments: comments);
                              }
                            }),
                          ).then((updatedComments) {
                            setState(() {
                              widget.post.comments = updatedComments;
                            });
                          });
                        },
                      ),
                      Text(_commentCount().toString())
                    ],
                  ),
                  OutlinedButton(
                    style: OutlinedButton.styleFrom(
                        alignment: Alignment.centerRight),
                    onPressed: () {
                      setState(() {
                        if (isExtended == false) {
                          extendedPostCard =
                              ExtendedPostCard(post: widget.post);
                          isExtended = true;
                          extendButtonIcon =
                              const Icon(Icons.keyboard_arrow_up);
                        } else {
                          extendedPostCard = Container();
                          isExtended = false;
                          extendButtonIcon =
                              const Icon(Icons.keyboard_arrow_down);
                        }
                      });
                    },
                    child: Row(
                      children: [
                        Text(
                            AppLocalizations.of(context)!.postCardDetailsButton,
                            style: AppTypography.postCardTitles),
                        extendButtonIcon
                      ],
                    ),
                  ),
                ],
              ),
            ),
            ConstrainedBox(
              constraints: const BoxConstraints(minHeight: 0),
              child: extendedPostCard,
            )
          ],
        ),
      ),
    );
  }
}

/// A widget that represents an extended post card.
class ExtendedPostCard extends StatefulWidget {
  final Post post;

  /// Constructs an [ExtendedPostCard] widget.
  ///
  /// The [post] parameter is required and represents the post data.
  const ExtendedPostCard({super.key, required this.post});

  @override
  State<ExtendedPostCard> createState() => _ExtendedPostCardState();
}

class _ExtendedPostCardState extends State<ExtendedPostCard> {
  /// Launches the URL based on the given [target].
  ///
  /// If the [target] is 'google', it launches a Google search URL with the product barcode.
  /// If the [target] is 'openFoodFacts', it checks if the OpenFoodFacts app is installed.
  /// If the app is installed, it launches the OpenFoodFacts URL with the product barcode.
  /// If the app is not installed, it shows a dialog with options to open in the browser or download the app.
  Future<void> _launchUrl(context, target) async {
    if (target == 'google') {
      final Uri url = Uri.parse(
          'https://www.google.com/search?q=${widget.post.productBarcode}');
      if (!await launchUrl(url)) {
        throw Exception('Could not launch $url');
      }
    } else if (target == 'openFoodFacts') {
      var isAppInstalledResult = await LaunchApp.isAppInstalled(
          androidPackageName: 'org.openfoodfacts.scanner');
      if (!isAppInstalledResult) {
        return (showDialog(
          context: context,
          builder: (BuildContext context) {
            return AlertDialog(
              title: const Text('Choose an option'),
              content: const Text(
                  'Do you want to download OpenFoodFacts app or open in the browser?'),
              actions: <Widget>[
                TextButton(
                  onPressed: () async {
                    final Uri url = Uri.parse(
                        'https://world.openfoodfacts.org/product/${widget.post.productBarcode}');
                    if (!await launchUrl(url)) {
                      throw Exception('Could not launch $url');
                    }
                    Navigator.of(context).pop();
                  },
                  child: const Text('Browser'),
                ),
                TextButton(
                  onPressed: () async {
                    var openAppResult = await LaunchApp.openApp(
                      androidPackageName: 'org.openfoodfacts.scanner',
                      // openStore: false
                    );
                    print(
                        'openAppResult => $openAppResult ${openAppResult.runtimeType}');
                    Navigator.of(context).pop();
                  },
                  child: const Text('Download app'),
                ),
              ],
            );
          },
        ));
      } else {
        final Uri url = Uri.parse(
            'https://world.openfoodfacts.org/product/${widget.post.productBarcode}');
        if (!await launchUrl(url)) {
          throw Exception('Could not launch $url');
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Divider(color: Colors.grey),
        const SizedBox(height: 10),
        Text(AppLocalizations.of(context)!.postCardDescription,
            style: AppTypography.postCardTitles),
        Padding(
            padding: const EdgeInsets.all(8),
            child: Text(widget.post.description,
                style: AppTypography.postCardValues)),
        Text(AppLocalizations.of(context)!.postCardTags,
            style: AppTypography.postCardTitles),
        Padding(
          padding: const EdgeInsets.all(8),
          child: Wrap(
              children: List.generate(widget.post.tags.length, (index) {
            List<String> tags = AppLocalizations.of(context)!.tags.split(',');
            return tags.isEmpty
                ? const Text('NoTags')
                : Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 2.0),
                    child: Tag(text: tags[index]));
          })),
        ),
        if (widget.post.productBarcode != '')
          Row(
            children: [
              Text("${AppLocalizations.of(context)!.postCardBarcode} ",
                  style: AppTypography.postCardTitles),
              Text(widget.post.productBarcode,
                  style: AppTypography.postCardValues),
            ],
          ),
        if (widget.post.productBarcode != '')
          Row(
            children: [
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blue,
                  ),
                  onPressed: () async {
                    _launchUrl(context, 'openFoodFacts');
                  },
                  child: SvgPicture.asset(
                    'assets/icons/openFoodFactsIcon.svg', // Your SVG file path
                    semanticsLabel: 'Icon',
                    width: 24, // Adjust size as needed
                    height: 24,
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.black,
                  ),
                  onPressed: () async {
                    _launchUrl(context, 'google');
                  },
                  child: SvgPicture.asset(
                    'assets/icons/googleIcon.svg', // Your SVG file path
                    semanticsLabel: 'Icon',
                    width: 24, // Adjust size as needed
                    height: 24,
                  ),
                ),
              ),
            ],
          )
      ],
    );
  }
}
