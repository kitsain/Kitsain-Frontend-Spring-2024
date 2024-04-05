import 'package:flutter/material.dart';
import 'package:kitsain_frontend_spring2023/models/comment.dart';
import 'package:kitsain_frontend_spring2023/services/comment_service.dart';
import 'package:kitsain_frontend_spring2023/assets/commentBox.dart';
import 'package:kitsain_frontend_spring2023/services/post_service.dart';

/// TODO:
/// - Connect user information to comment box; an identifier
///   for unique users.

/// Class for creating the comment section view.
class CommentSectionView extends StatefulWidget {
  final String parentID;
  final List<Comment> comments;

  const CommentSectionView(
      {super.key, required this.parentID, required this.comments});

  @override
  State<CommentSectionView> createState() => _CommentSectionViewState();
}

class _CommentSectionViewState extends State<CommentSectionView> {
  late List<Comment> _tempComments = [];
  late List<String> _users = [];
  late String _currUser = '';
  late bool _isOwner = false;

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

    fetchUserId();
    usersList();
  }

  Future<void> fetchUserId() async {
    final fetchedUserId = await postService.getUserId();
    setState(() {
      _currUser = fetchedUserId;
    });
  }

  void usersList() {
    for (int i = 0; i < _tempComments.length; i++) {
      String user = _tempComments[i].author;
      if (!_users.contains(user)) {
        _users.add(user);
      }
      print('List of *******************: $_users');
    }
  }

  /// Comment object for storing info about
  /// current instance of comment.
  Comment _createCommentObj(String author, String message, DateTime date) {
    return Comment(
        postID: widget.parentID, author: author, message: message, date: date);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Comments'),
        leading: IconButton(
          icon: Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.pop(context, _tempComments);
          },
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.only(bottom: 85),
        child: Container(
          height: MediaQuery.of(context).size.height * 1,
          width: MediaQuery.of(context).size.width * 1,
          child: RefreshIndicator(
            onRefresh: () {
              return Future.delayed(
                Duration(seconds: 1),
                () {
                  setState(() {});
                },
              );
            },
            child: SingleChildScrollView(
              physics: AlwaysScrollableScrollPhysics(),
              controller: _scrollController,
              child: ListView.builder(
                physics: const NeverScrollableScrollPhysics(),
                reverse: true,
                shrinkWrap: true,
                itemCount: _tempComments.length,
                itemBuilder: (context, index) {
                  return GestureDetector(
                    onLongPress: () {
                      if (_currUser == _tempComments[index].author){
                        showModalBottomSheet(
                          context: context,
                          builder: (BuildContext context) {
                            return Container(
                                child: Padding(
                                  padding: EdgeInsets.all(16.0),
                                  child: Column(
                                      mainAxisSize: MainAxisSize.min,
                                      children: <Widget>[
                                        Text(
                                            '${_tempComments[index].message}'
                                        ),
                                        ListTile(
                                          textColor: Colors.red,
                                          iconColor: Colors.red,
                                          leading: Icon(Icons.delete),
                                          title: Text('Remove comment'),
                                          onTap: (){
                                            setState(() {
                                                _removeComment(index);
                                              Navigator.of(context).pop();
                                            });
                                          },
                                        ),
                                        ListTile(
                                          leading: Icon(Icons.edit),
                                          title: Text('Edit'),
                                          onTap: (){
                                            // TODO: logic for editing comment
                                          },
                                        ),
                                      ]
                                  ),
                                )
                            );
                          }
                        );
                      }
                    },
                    child: CommentBox(
                      comment: _tempComments[index].message,
                      author: (_getUserIdx(_tempComments[index].author)+1).toString(), // TODO: implement author
                      date: _tempComments[index].date,
                    ),
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
                decoration: const InputDecoration(labelText: 'New comment...'),
              ),
            ),
            IconButton(
                onPressed: () {
                  String message = _textFieldController.text;
                  Comment myComment = _createCommentObj(
                      _currUser, //TODO: connect to real user
                      _textFieldController.text,
                      DateTime.now());
                  if (message != '') {
                    setState(() {
                      commentService.postComment(
                        postID: widget.parentID,
                        user: "user",
                        content: message,
                        date: DateTime.now(),
                      );
                      _tempComments.add(myComment);
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

  void _scrollToTop() {
    _scrollController.animateTo(_scrollController.position.minScrollExtent,
        duration: const Duration(seconds: 1), curve: Curves.decelerate);
  }

  void _removeComment(int index) {
    _tempComments.removeAt(index);
  }

  int _getUserIdx(String userId) {
    return _users.indexOf(userId);
  }

  @override
  void dispose() {
    _textFieldController.dispose();
    super.dispose();
  }
}
