import 'package:flutter/material.dart';
import 'package:kitsain_frontend_spring2023/app_typography.dart';
import 'package:kitsain_frontend_spring2023/models/comment.dart';
import 'package:kitsain_frontend_spring2023/services/comment_service.dart';
import 'package:kitsain_frontend_spring2023/assets/comment_box.dart';
import 'package:kitsain_frontend_spring2023/services/post_service.dart';
import 'package:flutter_gen/gen_l10n/app-localizations.dart';


/// Class for creating the comment section view.
class CommentSectionView extends StatefulWidget {
  final String postID;
  final List<Comment> comments;

  const CommentSectionView(
      {super.key, required this.postID, required this.comments});

  @override
  State<CommentSectionView> createState() => _CommentSectionViewState();
}

class _CommentSectionViewState extends State<CommentSectionView> {
  late List<Comment> _tempComments = [];
  late final List<String> _users = [];
  late String _currUser = '';

  late TextEditingController _textFieldController;
  late ScrollController _scrollController;

  final CommentService commentService = CommentService();
  final PostService postService = PostService();

  @override
  void initState() {
    super.initState();
    _tempComments = List.of(widget.comments);

    _textFieldController = TextEditingController();
    _scrollController = ScrollController();

    _fetchUserId();
    _refreshComments();
    _usersList();
  }

  /// Finds id of current user
  Future<void> _fetchUserId() async {
    final fetchedUserId = await postService.getUserId();
    setState(() {
      _currUser = fetchedUserId;
    });
  }

  /// Makes a list of the users who have commented in the order of commenting.
  void _usersList() {
    for (int i = 0; i < _tempComments.length; i++) {
      String user = _tempComments[i].author;
      if (!_users.contains(user)) {
        _users.add(user);
      }
    }
  }

  /// Sets the position to the top of the scroll view.
  void _scrollToTop() {
    _scrollController.animateTo(_scrollController.position.minScrollExtent,
        duration: const Duration(seconds: 1), curve: Curves.decelerate);
  }

  /// Adds  a new comment to the backend and updates information locally
  void _addComment(String message) async {
    await commentService.postComment(
      postID: widget.postID,
      content: message,
    );

    _refreshComments();
  }

  /// Fetches most recent comment information from backend and updates locally.
  void _refreshComments() async {
    try {
      List<Comment> newComments =
          await commentService.getComments(widget.postID);
      setState(() {
        _tempComments.clear();
        _tempComments.addAll(newComments);
        _users.clear();
        _usersList();
      });
    } catch (e) {
      debugPrint('Error loading posts: $e');
    }
  }

  /// Removes comment from the backend.
  void _removeComment(int index) {
    //commentService.deleteComment(_tempComments[index].Id, _currUser);
    _tempComments[index].message = 'null#800020';
    commentService.putComment(
        _tempComments[index].id, _currUser, widget.postID);
  }

  /// Formats comment for modal bottom sheet.
  ///
  /// Displayed when user tries to remove a
  /// comment or reply to other users' comment
  String _formatComment(int i) {
    Comment comment = _tempComments[i];
    int userIndex = (_users.indexOf(comment.author)) + 1;
    String? message = comment.message;

    return '"user $userIndex": "$message"';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(AppLocalizations.of(context)!.commentsViewTitle,
            style: AppTypography.heading4),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.pop(context, _tempComments);
          },
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.only(bottom: 85),
        child: SizedBox(
          height: MediaQuery.of(context).size.height,
          width: MediaQuery.of(context).size.width,
          child: RefreshIndicator(
            onRefresh: () {
              return Future.delayed(
                const Duration(seconds: 1),
                () {
                  setState(() {});
                },
              );
            },
            child: SingleChildScrollView(
              physics: const AlwaysScrollableScrollPhysics(),
              controller: _scrollController,
              child: ListView.builder(
                physics: const NeverScrollableScrollPhysics(),
                reverse: true,
                shrinkWrap: true,
                itemCount: _tempComments.length,
                itemBuilder: (context, index) {
                  return GestureDetector(
                    onLongPress: () {
                      if (_currUser == _tempComments[index].author) {
                        showModalBottomSheet(
                            context: context,
                            builder: (BuildContext context) {
                              return Padding(
                                padding: const EdgeInsets.all(16.0),
                                child: Column(
                                    mainAxisSize: MainAxisSize.min,
                                    children: <Widget>[
                                      Text(_formatComment(index)),
                                      ListTile(
                                        textColor: Colors.red,
                                        iconColor: Colors.red,
                                        leading: const Icon(Icons.delete),
                                        title: Text(
                                            AppLocalizations.of(context)!
                                                .commentsViewRemoveComment,
                                            style: AppTypography
                                                .postCommentTitles),
                                        onTap: () {
                                          setState(() {
                                            _removeComment(index);
                                            Navigator.of(context).pop();
                                          });
                                        },
                                      ),
                                      /*ListTile(
                                        leading: const Icon(Icons.edit),
                                        title: Text(
                                            AppLocalizations.of(context)!
                                                .commentsViewEditComment,
                                            style: AppTypography
                                                .postCommentTitles),
                                        onTap: () {
                                          // TODO: logic for editing comment
                                        },
                                      ),*/
                                    ]),
                              );
                            });
                      } else {
                        // TODO: Logic for case where user is not author
                        /*showModalBottomSheet(
                          context: context,
                          builder: (BuildContext context) {
                            return Padding(
                              padding: const EdgeInsets.all(16.0),
                              child: Column(
                                  mainAxisSize: MainAxisSize.min,
                                  children: <Widget>[
                                    Text(_formatComment(index)),
                                    ListTile(
                                      leading: const Icon(Icons.reply),
                                      title: Text(AppLocalizations.of(context)!
                                          .commentsViewReply),
                                      onTap: () {
                                        // TODO: reply logic
                                      },
                                    ),
                                  ]),
                            );
                          },
                        );*/
                      }
                    },
                    child: _tempComments[index].message != 'null#800020'
                        ? CommentBox(
                            comment: _tempComments[index].message,
                            author:
                                'user ${(_users.indexOf(_tempComments[index].author) + 1)}',
                            date: _tempComments[index].date,
                          )
                        : Container(),
                  );
                },
              ),
            ),
          ),
        ),
      ),
      bottomSheet: Padding(
        padding: const EdgeInsets.fromLTRB(10, 0, 10, 15),
        child: Row(
          children: [
            Flexible(
              child: TextField(
                controller: _textFieldController,
                decoration: InputDecoration(
                  labelText:
                      AppLocalizations.of(context)!.commentsViewNewComment,
                  labelStyle: AppTypography.postCommentTitles,
                ),
              ),
            ),
            IconButton(
                onPressed: () {
                  String message = _textFieldController.text;
                  if (message != '') {
                    setState(() {
                      _addComment(message);
                    });
                    FocusManager.instance.primaryFocus?.unfocus();
                    _textFieldController.clear();
                    _scrollToTop();
                  }
                },
                icon: const Icon(Icons.send))
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    _textFieldController.dispose();
    _scrollController.dispose();
    super.dispose();
  }
}
