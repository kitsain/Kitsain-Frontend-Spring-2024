import 'package:flutter/material.dart';
import 'package:kitsain_frontend_spring2023/app_colors.dart';
import 'package:kitsain_frontend_spring2023/assets/post_card.dart';
import 'package:kitsain_frontend_spring2023/assets/top_bar.dart';
import 'package:kitsain_frontend_spring2023/models/post.dart';
import 'package:kitsain_frontend_spring2023/services/post_service.dart';
import 'package:kitsain_frontend_spring2023/views/help_pages/feed_help_page.dart';
import 'package:flutter_gen/gen_l10n/app-localizations.dart';
import 'package:kitsain_frontend_spring2023/views/main_menu_pages/feed/create_edit_post_view.dart';
import 'package:kitsain_frontend_spring2023/views/main_menu_pages/feed/filter_view.dart';
import 'package:logger/logger.dart';

/// The feed view widget that displays a list of posts.
class FeedView extends StatefulWidget {
  const FeedView({super.key});

  @override
  State<FeedView> createState() => _FeedViewState();
}

class _FeedViewState extends State<FeedView> {
  var logger = Logger(printer: PrettyPrinter());

  var postProvider = PostProvider();
  final PostService postService = PostService();
  List<Post> _posts = [];

  final ScrollController _scrollController = ScrollController();

  late List<List<String?>> _filtering; // = [tags, [city, district, store]]
  late String _sorting;
  late String _direction;

  @override
  void initState() {
    super.initState();

    // initialize filtering values
    _filtering = [
      [],
      [null, null, null]
    ];

    // initialize sorting value
    _sorting = '';

    // initialize order value
    _direction = '';

    loadPosts();

    // Add listener to scroll controller
    _scrollController.addListener(_scrollListener);

    // Assign posts to local variable
    _posts = postProvider.posts;
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  /// Loads the posts from the server.
  Future<void> loadPosts() async {
    try {
      List<Post> newPosts = await postService.getPosts(
        filtering: _filtering,
        sorting: _sorting,
        direction: _direction
      );
      setState(() {
        postProvider.posts.addAll(newPosts); // Filter out null posts
        _posts.clear();
        _posts = newPosts;
      });
    } catch (e) {
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
          child: FeedHelp(),
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
      refreshPosts();
    }
  }

  /// Edits a post in the list.
  void editPost(Post post) async {
    setState(() {
      postProvider.updatePost(post);
      refreshPosts();
    });
  }

  /// Fetches filtered posts from the backend and updates the
  /// posts shown in the UI accordingly.
  Future<void> filterPosts() async {
    List<Post> filteredPosts =
        await postService.getPosts(filtering: _filtering);
    setState(() {
      _posts.clear();
      _posts = filteredPosts;
    });
  }

  /// fetches sorted posts from the backend and updates
  /// the posts shown in the UI accordingly.
  /// order: 'exp_OLDEST'    -> furthest expirydate,
  ///        'exp_NEWEST'    -> closest expirydate,
  ///        'posted_OLDEST' -> oldest post,
  ///        'posted_NEWEST' -> newest post (also default).
  void _sortPosts(String order) async {
    List<Post> temp = _posts;
    String direction = '';
    if (order == 'exp_OLDEST') {
      temp = await postService.getPosts(
          filtering: _filtering, sorting: 'expringDate', direction: 'asc');
          direction = 'asc';
    } else if (order == 'exp_NEWEST') {
      temp = await postService.getPosts(
          filtering: _filtering, sorting: 'expringDate', direction: 'desc');
          direction = 'desc';
    } else if (order == 'posted_OLDEST'){
      temp = await postService.getPosts(
          filtering: _filtering, sorting: 'createdDate', direction: 'asc');
          direction = 'asc';
    } else if (order == "posted_NEWEST" || order == 'default') {
      // Default order of posts in the backend is by time of posting
      temp = await postService.getPosts(filtering: _filtering);
      direction = '';
      order = '';
    }
    setState(() {
      _posts = temp;
      _sorting = order;
      _direction = direction;
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
      body: Column(
        children: [
          SizedBox(
            width: MediaQuery.of(context).size.width,
            height: 50,
            child: Padding(
              padding: const EdgeInsets.all(4.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  Text(
                    '${AppLocalizations.of(context)!.filter}: ',
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                  IconButton(
                    icon: const Icon(Icons.tune),
                    onPressed: () {
                      // Open a view for picking filters
                      showModalBottomSheet(
                          context: context,
                          builder: (buildContext) {
                            return FilterView(parameters: _filtering);
                          }).then((parameters) {
                        // If view returns null, assumes action was cancelled
                        // and does not change filtering parameters
                        if (parameters != null) {
                          _filtering = parameters;
                        }
                        filterPosts();
                      });
                    },
                  ),
                  Text(
                    '${AppLocalizations.of(context)!.sort}: ',
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                  PopupMenuButton<String>(
                    icon: const Icon(Icons.filter_list),
                    onSelected: (value) {
                      _sortPosts(value);
                    },
                    itemBuilder: (BuildContext context) =>
                        <PopupMenuEntry<String>>[
                      PopupMenuItem<String>(
                        value: 'exp_OLDEST',
                        child: Text(AppLocalizations.of(context)!.expFarthest),
                      ),
                      PopupMenuItem<String>(
                        value: 'exp_NEWEST',
                        child: Text(AppLocalizations.of(context)!.expClosest),
                      ),
                      PopupMenuItem<String>(
                        value: 'posted_OLDEST',
                        child: Text(AppLocalizations.of(context)!.postedOldest),
                      ),
                      PopupMenuItem<String>(
                        value: 'posted_NEWEST',
                        child: Text(AppLocalizations.of(context)!.postedNewest),
                      ),
                      PopupMenuItem<String>(
                        value: 'default',
                        child: Text(AppLocalizations.of(context)!.defaultSort),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
          Expanded(
            child: RefreshIndicator(
              onRefresh: refreshPosts,
              child: ListView.builder(
                controller: _scrollController,
                itemCount: _posts.length,
                itemBuilder: (context, index) {
                  return PostCard(
                    key: ValueKey(_posts[index].id),
                    post: _posts[index],
                    onRemovePost: (Post removedPost) {
                      removePost(removedPost);
                      setState(() {
                        _posts.removeAt(index);
                      });
                    },
                    onEditPost: (Post updatedPost) {
                      editPost(updatedPost);
                    },
                  );
                },
              ),
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const CreateEditPostView()),
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
