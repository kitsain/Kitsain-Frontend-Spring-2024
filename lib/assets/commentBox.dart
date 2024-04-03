import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:intl/intl.dart';

/// Class for individual comment boxes.
///
/// Displayed in CommentSectionView
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