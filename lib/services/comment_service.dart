import 'dart:convert';
import 'package:get/get.dart';
import 'package:kitsain_frontend_spring2023/models/post.dart';
import 'package:http/http.dart' as http;
import 'package:kitsain_frontend_spring2023/services/auth_service.dart';
import 'package:logger/logger.dart';
import 'package:kitsain_frontend_spring2023/models/comment.dart';
import 'package:realm/realm.dart';

class CommentService {
  final accessToken = Get.put(AuthService()).accessToken;
  var logger = Logger(printer: PrettyPrinter());

  final String baseUrl = 'http://nocng.id.vn:9090/api/v1/comments';

  /// Retrieves list of comments associated with a post
  ///
  /// Returns a list of [Comment] objects.
  Future<List<Comment>> getComments(String id) async {
    try {
      var uri = Uri.parse('$baseUrl/$id');
      var response = await http.get(
        uri.replace(queryParameters: {
          'limit': "10",
          'offset': "0",
        }),
        headers: {
          'accept': '*/*',
          'Authorization': 'Bearer ${accessToken.value}',
        },
      );

      if (response.statusCode == 200) {
        dynamic responseData = jsonDecode(response.body);
        // logger.i(response.body);

        // Assuming responseData is a JSON object with a key 'posts' containing a list of posts
        List<dynamic> commentData = responseData['details']['records'];

        // Fetch and parse posts concurrently
        List<Comment> comments =
            await Future.wait(commentData.map((json) async {
          return await parseComment(json);
        }));

        logger.i("Comments loaded successfully");
        return comments.reversed.toList();
      } else {
        throw Exception(
            'Failed to load posts: ${response.statusCode} /n ${response.body}');
      }
    } catch (e) {
      throw Exception('Error fetching comments: $e');
    }
  }

  /// Creates a new post with the given [images], [title], [description], [price], and [expiringDate].
  ///
  /// Returns the created [Post] object if successful, otherwise returns null.
  Future<void> postComment(
      {required String postID, required String content}) async {
    // Format the expiration date of the post
    // String formattedDate = DateFormat("yyyy-MM-dd'T'HH:mm:ss.SSS'Z'").format(date.toUtc());

    try {
      // Send a POST request to the server with the post data

      final response = await http.post(Uri.parse(baseUrl),
          headers: {
            'Content-Type': 'application/json',
            'accept': '*/*',
            'Authorization': 'Bearer ${accessToken.value}',
          },
          body: jsonEncode({
            'content': content,
            'postId': postID,
          }));

      if (response.statusCode == 200) {
        logger.i("Comment posted successfully");
      } else {
        // Handle other status codes if needed
        logger.e('Request failed with status: ${response.statusCode}');
        logger.e(response.body);
      }
    } catch (error) {
      logger.e("ERROR: $error");
      // Handle any errors that occur during the request
    }
  }

  Future<bool> deleteComment(String id, String userId) async {
    try {
      // Send a POST request to the server with the post data
      final response =
          await http.put(Uri.parse('$baseUrl/disable/$id'), headers: {
        'Content-Type': 'application/json',
        'accept': '*/*',
        'Authorization': 'Bearer ${accessToken.value}',
      });
      if (response.statusCode == 200) {
        logger.i("Comment removed successfully");
        return true;
      } else {
        // Handle other status codes if needed
        logger.e('Request failed with status: ${response.statusCode}');
        //logger.e(response.body);
        return false;
      }
    } catch (error) {
      logger.e("ERROR: $error");
      return false;
      // Handle any errors that occur during the request
    }
  }

  Future<bool> putComment(String id, String userId, String postId) async {
    try {
      // Send a POST request to the server with the post data
      final response =
      await http.put(Uri.parse('$baseUrl/$id'),
          headers: {
        'Content-Type': 'application/json',
        'accept': '*/*',
        'Authorization': 'Bearer ${accessToken.value}',
      },
      body: jsonEncode({
            'content': 'null#800020',
            'postId': postId
          }));

      if (response.statusCode == 200) {
        logger.i("Comment removed successfully");
        return true;
      } else {
        // Handle other status codes if needed
        logger.e('Request failed with status: ${response.statusCode}');
        print(postId);
        logger.e(response.body);
        return false;
      }
    } catch (error) {
      logger.e("ERROR: $error");
      return false;
      // Handle any errors that occur during the request
    }
  }

  Future<Comment> parseComment(Map<String, dynamic> json) async {
    try {
      return Comment(
        id: json['id'],
        author: json['userId'],
        message: json['content'],
        date: DateTime.parse(json['createdDate']),
      );
    } catch (e) {
      throw Exception('Error parsing comment: $e');
    }
  }
}
