import 'dart:io';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get/get_rx/src/rx_types/rx_types.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:intl/intl.dart';
import 'package:kitsain_frontend_spring2023/LoginController.dart';
import 'package:kitsain_frontend_spring2023/app_colors.dart';
import 'package:kitsain_frontend_spring2023/assets/top_bar.dart';
import 'package:kitsain_frontend_spring2023/models/comment.dart';
import 'package:kitsain_frontend_spring2023/models/post.dart';
import 'package:kitsain_frontend_spring2023/services/auth_service.dart';
import 'package:kitsain_frontend_spring2023/services/post_service.dart';
import 'package:kitsain_frontend_spring2023/views/createPost/create_post_view.dart';
import 'package:kitsain_frontend_spring2023/views/main_menu_pages/feed/comment_section_view.dart';
import 'package:kitsain_frontend_spring2023/views/help_pages/pantry_help_page.dart';
import 'package:flutter_gen/gen_l10n/app-localizations.dart';
import 'package:kitsain_frontend_spring2023/views/createPost/create_edit_post_view.dart';
import 'package:kitsain_frontend_spring2023/services/comment_service.dart';
import 'package:logger/logger.dart';
import 'package:google_mlkit_barcode_scanning/google_mlkit_barcode_scanning.dart';
import 'feed_image_widget.dart';

/// The feed view widget that displays a list of posts.
class FeedView extends StatefulWidget {
  const FeedView({Key? key});

  @override
  State<FeedView> createState() => _FeedViewState();
}

class _FeedViewState extends State<FeedView>
    with AutomaticKeepAliveClientMixin {
  var logger = Logger(printer: PrettyPrinter());
  var postProvider = PostProvider();
  final PostService postService = PostService();
  bool isLoading = false;
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    loadPosts();

    // Add listener to scroll controller
    _scrollController.addListener(_scrollListener);
  }

  @override
  bool get wantKeepAlive => true;

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  /// Loads the posts from the server.
  Future<void> loadPosts() async {
    setState(() {
      isLoading = true;
    });

    try {
      List<Post> newPosts = await postService.getPosts();
      setState(() {
        postProvider.posts.addAll(newPosts);
        isLoading = false;
      });
    } catch (e) {
      setState(() {
        isLoading = false;
      });
      logger.e('Error loading posts: $e');
    }
  }

  /// Refreshes the posts by clearing the existing posts and loading new ones.
  Future<void> refreshPosts() async {
    postProvider.posts.clear();
    await loadPosts();
  }

  /// Scroll listener method to detect when the user scrolls to the top of the feed.
  void _scrollListener() {
    if (_scrollController.position.pixels == -1) {
      // User has scrolled to the top, fetch new posts
      refreshPosts();
    }
  }

  /// Displays the help information in a modal bottom sheet.
  void _help() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (BuildContext context) {
        return const FractionallySizedBox(
          //heightFactor: 0.7,
          child: PantryHelp(),
        );
      },
    );
  }

  /// Removes a post from the list.
  Future<void> removePost(Post post) async {
    bool correctUser = await postService.deletePost(post.id, post.userId);
    if (correctUser) {
      setState(() {
        postProvider.deletePost(post);
      });
    }
  }

  /// Edits a post in the list.
  void editPost(Post post) {
    setState(() {
      postProvider.updatePost(post);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.main2,
      appBar: TopBar(
        title: AppLocalizations.of(context)!.feedScreen,
        helpFunction: _help,
        backgroundImageName: 'assets/images/pantry_banner_B1.jpg',
        titleBackgroundColor: AppColors.titleBackgroundBrown,
      ),
      body: RefreshIndicator(
        onRefresh: refreshPosts,
        child: ListView.builder(
          controller: _scrollController,
          itemCount: postProvider.posts.length,
          itemBuilder: (context, index) {
            return PostCard(
              post: postProvider.posts[index],
              onRemovePost: (Post removedPost) {
                removePost(removedPost);
              },
              onEditPost: (Post updatedPost) {
                editPost(updatedPost);
              },
            );
          },
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => CreatePostView()),
          ).then((newPost) async {
            if (newPost != null) {
              setState(() {
                postProvider.addPost(newPost);
                refreshPosts();
              });
            }
          });
        },
        child: const Icon(Icons.add),
      ),
    );
  }
}

/// A card widget that displays a post.
class PostCard extends StatefulWidget {
  final Post post;
  final Function(Post) onRemovePost;
  final Function(Post) onEditPost;

  const PostCard({
    Key? key,
    required this.post,
    required this.onRemovePost,
    required this.onEditPost,
  }) : super(key: key);

  @override
  State<PostCard> createState() => _PostCardState();
}

class _PostCardState extends State<PostCard> {
  // Variable to hold the current user
  final loginController = Get.put(LoginController());
  final authService = Get.put(AuthService());
  var logger = Logger(printer: PrettyPrinter());
  final postService = PostService();
  final CommentService commentService = CommentService();
  late String userId;
  bool isOwner = false;

  @override
  void initState() {
    super.initState();
    fetchUserId();
    //loadComments();
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
  void _editPost(Post post) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => CreateEditPostView(post: post),
      ),
    ).then((updatedPost) {
      if (updatedPost != null) {
        widget.onEditPost(updatedPost); // Pass the updated post back
      }
    });
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
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
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
                      const PopupMenuItem<String>(
                        value: 'edit',
                        child: Text('Edit'),
                      ),
                      const PopupMenuItem<String>(
                        value: 'remove',
                        child: Text('Remove'),
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
              feedImageWidget(images: widget.post.images),

            Padding(
              padding: const EdgeInsets.all(4.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Expiring date: ${DateFormat('dd.MM.yyyy').format(widget.post.expiringDate)}',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  Text(
                    'Price: ${widget.post.price}',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(4.0),
              child: Text(
                widget.post.description,
                style: const TextStyle(fontSize: 14),
              ),
            ),
            const SizedBox(height: 8),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Row(
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
                                parentID: widget.post.id, comments: const []);
                          } else {
                            return CommentSectionView(
                                parentID: widget.post.id, comments: comments);
                          }
                        }),
                      ).then((updatedComments) {
                        setState(() {
                          widget.post.comments = updatedComments;
                        });
                      });
                    },
                  ),
                  Text(widget.post.comments.length.toString())
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
