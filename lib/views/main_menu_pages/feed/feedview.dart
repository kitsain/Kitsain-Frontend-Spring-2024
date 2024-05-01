import 'package:flutter/material.dart';
import 'package:kitsain_frontend_spring2023/app_colors.dart';
import 'package:kitsain_frontend_spring2023/assets/post_card.dart';
import 'package:kitsain_frontend_spring2023/assets/top_bar.dart';
import 'package:kitsain_frontend_spring2023/models/post.dart';
import 'package:kitsain_frontend_spring2023/services/post_service.dart';
import 'package:kitsain_frontend_spring2023/views/help_pages/pantry_help_page.dart';
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

  bool isLoading = false;
  bool isFiltering = false;

  final ScrollController _scrollController = ScrollController();

  // Parameters for filtering
  late List<List<String?>> _filtering;

  @override
  void initState() {
    super.initState();
    loadPosts();

    // Add listener to scroll controller
    _scrollController.addListener(_scrollListener);

    // Assign posts to local variable
    _posts = postProvider.posts;

    // initialize filtering values
    _filtering = [
      [],
      [null, null, null]
    ];
  }

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
        postProvider.posts.addAll(newPosts); // Filter out null posts
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
  /// order of the posts in the feed accordingly.
  Future<void> filterPosts() async {
    List<Post> filteredPosts =
        await postService.getPosts(filtering: _filtering);
    setState(() {
      _posts.clear();
      _posts = filteredPosts;
    });
  }

  /// Sorts posts according to chosen parameter and refreshes feed.
  void _sortPosts(String order) async {
    List<Post> temp = _posts;
    if (order == 'exp_OLDEST') {
      temp = await postService.getPosts(
          filtering: _filtering, sorting: 'expringDate', direction: 'asc');
    } else if (order == 'exp_NEWEST') {
      temp = await postService.getPosts(
          filtering: _filtering, sorting: 'expringDate', direction: 'desc');
    } else if (order == 'posted_OLDEST'){
      temp = await postService.getPosts(
          filtering: _filtering, sorting: 'createdDate', direction: 'asc');
    } else if (order == "posted_NEWEST" || order == 'default') {
      // Default order of posts in the backend is by time of posting
      temp = await postService.getPosts(filtering: _filtering);
    }
    setState(() {
      _posts = temp;
    });
  }

  void refreshView(List<Post> newPosts) {
    setState(() {
      _posts.clear();
    });
    setState(() {
      _posts = newPosts;
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
                  const Text(
                    'Filter: ',
                    style: TextStyle(fontWeight: FontWeight.bold),
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
                  const Text(
                    'Sort: ',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  PopupMenuButton<String>(
                    icon: const Icon(Icons.filter_list),
                    onSelected: (value) {
                      _sortPosts(value);
                    },
                    itemBuilder: (BuildContext context) =>
                        <PopupMenuEntry<String>>[
                      const PopupMenuItem<String>(
                        value: 'exp_OLDEST',
                        child: Text('Expiry date (closest first)'),
                      ),
                      const PopupMenuItem<String>(
                        value: 'exp_NEWEST',
                        child: Text('Expiry date (farthest first)'),
                      ),
                      const PopupMenuItem<String>(
                        value: 'posted_OLDEST',
                        child: Text('Date posted (oldest)'),
                      ),
                      const PopupMenuItem<String>(
                        value: 'posted_NEWEST',
                        child: Text('Date posted (newest)'),
                      ),
                      const PopupMenuItem<String>(
                        value: 'default',
                        child: Text('Default'),
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
