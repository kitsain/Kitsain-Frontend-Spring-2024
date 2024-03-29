import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/scheduler.dart';
import 'package:intl/intl.dart';
import 'package:kitsain_frontend_spring2023/models/comment.dart';
import 'package:kitsain_frontend_spring2023/services/comment_service.dart';

/// TODO:
/// - Connect user information to comment box; an identifier
///   for unique users.

/// Class for creating the comment section view.
class CommentSectionView extends StatefulWidget {
  final String parentID;
  final List<Comment> comments;

  const CommentSectionView({super.key,
    required this.parentID,
    required this.comments});

  @override
  State<CommentSectionView> createState() => _CommentSectionViewState();
}

class _CommentSectionViewState extends State<CommentSectionView> {
  List<Comment> _tempComments = [];
  late TextEditingController _textFieldController;
  late ScrollController _scrollController;
  final CommentService commentService = CommentService();

  @override
  void initState() {
    super.initState();
    _tempComments = List.of(widget.comments);

    _textFieldController = TextEditingController();
    _scrollController = ScrollController();
  }

  /// Comment object for storing info about
  /// current instance of comment.
  Comment _createCommentObj(String author, String message, DateTime date) {
    return Comment(
        postID: widget.parentID,
        author: author,
        message: message,
        date: date);
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
          width: MediaQuery.of(context).size.width *1 ,
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
                      showModalBottomSheet(
                        context: context,
                        builder: (BuildContext context) {
                          return Container(
                            child: Padding(
                              padding: EdgeInsets.all(16.0),
                              child: Column(
                                mainAxisSize: MainAxisSize.min,
                                children: <Widget>[
                                  ListTile(
                                    textColor: Colors.red,
                                    iconColor: Colors.red,
                                    leading: Icon(Icons.delete),
                                    title: Text('Remove post'),
                                    onTap: (){
                                      setState(() {
                                        // TODO: check if user matches comment author
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
                    },
                    child: CommentBox(
                      comment: _tempComments[index].message,
                      author: 'user1', // TODO: implement author
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
                      "user", //TODO: connect to real user
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

  void _scrollToTop(){
    _scrollController.animateTo(
        _scrollController.position.minScrollExtent,
        duration: const Duration(seconds: 1),
        curve: Curves.decelerate);
  }

  void _removeComment(int index){
    _tempComments.removeAt(index);
  }

  @override
  void dispose() {
    _textFieldController.dispose();
    super.dispose();
  }
}

/// Class for individual comment boxes.
class CommentBox extends StatelessWidget {
  // TODO: connect author to actual user

  final String author;
  final String comment;
  final DateTime date;

  const CommentBox(
      {super.key,
      required this.author,
      required this.comment,
      required this.date});

  /// Converts the time into a pretty string.
  /// > If comment was posted within 7 days -> display days ago
  /// > If time was under 1 minute ago -> displau 'just now'
  /// > If time was under 1 hour ago -> display minutes
  /// > If time was over 1 hour ago -> display hours
  String _timeToString(DateTime t) {

    DateTime currTime = DateTime.now();
    final difference = currTime.difference(t);

    String minute = t.minute.toString();
    if (t.minute < 10){
      minute = '0$minute';
    }

    if (difference.inSeconds < 60) {
      return 'just now';
    } else if (difference.inMinutes < 60) {
      return '${difference.inMinutes}m';
    } else if (difference.inHours < 24) {
      return '${difference.inHours}h';
    } else if (difference.inDays < 7) {
      return '${difference.inDays}d';
    }

    return '${DateFormat('dd.MM.yyyy').format(t)}   ${t.hour}:$minute';
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 5),
      child: ConstrainedBox(
        constraints: const BoxConstraints(minHeight: 100),
        child: Container(
          color: Colors.grey[200],
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Container(
                  width: MediaQuery.of(context).size.width * .5,
                  alignment: Alignment.centerLeft,
                  child: Row(
                    children: [
                      const Icon(Icons.person),
                      const SizedBox(width: 5),
                      Text('$author  •  ${_timeToString(date)}'),
                    ],
                  )
                ),
                const SizedBox(height: 15),
                Align(alignment: Alignment.centerLeft, child: Text(comment)),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
