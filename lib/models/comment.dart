/// Class for creating a comment object.
class Comment {
  String id = 'NO_ID';
  String author = 'NO_AUTHOR';
  String? message = 'NO_MESSAGE';
  DateTime date = DateTime.now();

  Comment(
      {required this.id,
      required this.author,
      required this.message,
      required this.date});
}
