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
  List<List<String?>> _filtering = [];


  @override
  void initState() {
    super.initState();
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

  /// filters post according to determined parameters.
  /// User can now filter posts by:
  ///  * tags
  ///  * location <- TODO
  void filterPosts(){
    List<Post> filteredPosts = [];
    List<String?> tags = _filtering[0];
    List<String?> location = _filtering[1];

    isFiltering = true;
    for (Post post in postProvider.posts) {
      if (tags.every((element) => post.tags.contains(element))){
        filteredPosts.add(post);
      }
      // TODO: filter location
    }

    if (filteredPosts.isNotEmpty){
      setState(() {
        _posts = filteredPosts;
      });
    } else {
      setState(() {
        _posts = postProvider.posts;
      });
    }
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
                const Text('Filter: ',
                  style: TextStyle(
                      fontWeight: FontWeight.bold
                  ),
                ),
                  IconButton(
                    icon: const Icon(Icons.tune),
                    onPressed: () {
                      // Open a view for picking filters
                      showModalBottomSheet(
                        context: context,
                        builder: (buildContext) {
                          return FilterView(parameters: _filtering);
                      }). then((parameters) {
                        parameters != null
                            ? _filtering = parameters
                            : parameters = [];
                        filterPosts();
                      });
                    },
                  ),
                  const Text('Sort: ',
                    style: TextStyle(
                      fontWeight: FontWeight.bold
                    ),
                  ),
                  IconButton(
                      onPressed: () {
                        showModalBottomSheet(
                            context: context,
                            builder: (buildContext) {
                              return Container();
                            });
                      },
                      icon: const Icon(Icons.filter_list)
                  )
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
            MaterialPageRoute(
                builder: (context) =>
                    const CreateEditPostView(existingImages: [])),
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
