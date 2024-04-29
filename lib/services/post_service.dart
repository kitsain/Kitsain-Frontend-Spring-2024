import 'dart:convert';
import 'dart:io';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:kitsain_frontend_spring2023/models/post.dart';
import 'package:http/http.dart' as http;
import 'package:kitsain_frontend_spring2023/services/auth_service.dart';
import 'package:kitsain_frontend_spring2023/services/comment_service.dart';
import 'package:logger/logger.dart';

/// A service class for managing posts.
class PostService {
  final accessToken = Get.put(AuthService()).accessToken;
  var logger = Logger(printer: PrettyPrinter());
  final CommentService commentService = CommentService();

  // Base URL for the API
  final String baseUrl = 'http://nocng.id.vn:9090/api/v1/posts';

  /// Retrieves a list of all posts.
  ///
  /// Returns a list of [Post] objects.
  Future<List<Post>> getPosts({List<List<String?>> parameters = const []}) async {
    try {
      List<String> tags = [];
      String cityId = '';
      String districtId = '';
      String storeId = '';

      if (parameters.isNotEmpty){
        if (parameters[0].isNotEmpty){
          List<String> formattedTags =
          parameters[0].map((e) => e.toString().toUpperCase().replaceAll(' ', '_')).toList();
          for (String tag in formattedTags) {
            tags.add(tag);
          }
        }
        if (parameters[1].isNotEmpty) {
          List<String> location = parameters[1].map((e) => e.toString()).toList();
          if(location[0] != 'null'){
            cityId = location[0];
          }
          if (location[1] != 'null'){
            districtId = location[1];
          }
          if (location[2] != 'null'){
            storeId = location[2];
          }
        }
      }

      var uri = Uri.parse('$baseUrl/feed');
      var response = await http.get(
        uri.replace(queryParameters: {
          'limit': "10",
          'offset': "0",
          'tags': tags,
          'storeId': storeId,
          'districtId': districtId,
          'cityId': cityId
        }),
        headers: {
          'accept': '*/*',
          'Authorization': 'Bearer ${accessToken.value}',
        },
      );

      if (response.statusCode == 200) {
        dynamic responseData = json.decode(utf8.decode(response.bodyBytes));

        List<dynamic> postsData = responseData['details']['records'];

        // Fetch and parse posts concurrently
        List<Post> posts = await Future.wait(postsData.map((json) async {
          return await parsePost(json);
        }));

        logger.i("Posts loaded successfully");
        return posts;
      } else {
        throw Exception(
            'Failed to load posts: ${response.statusCode} /n ${response.body}');
      }
    } catch (e) {
      throw Exception('Error fetching posts: $e');
    }
  }

  /// Retrieves a post by its ID.
  ///
  /// Returns a [Post] object if found, otherwise returns null.
  Future<Post?> getPostById(String id) async {
    try {
      final response = await http.get(Uri.parse('$baseUrl/$id'), headers: {
        'Content-Type': 'application/json',
        'accept': '*/*',
        'Authorization': 'Bearer ${accessToken.value}',
      });

      if (response.statusCode == 200) {
        //logger.i("Post loaded successfully");
        Map<String, dynamic> postResponse =
            jsonDecode(response.body)['details'];

        return parsePost(postResponse);
      } else {
        // Handle other status codes if needed
        logger.e('Request failed with status: ${response.statusCode}');
        logger.e(response.body);
      }
    } catch (error) {
      logger.e("ERROR: $error");
      // Handle any errors that occur during the request
    }
    return null;
  }

  /// Creates a new post with the given [images], [title], [description], [price], and [expiringDate].
  ///
  /// Returns the created [Post] object if successful, otherwise returns null.
  Future<Post?> createPost(
      {required List<String> images,
      required String title,
      required String description,
      required String price,
      required DateTime expiringDate,
      List<String> tags = const [],
      required String storeId,
      required String productBarcode}) async {
    // Format the expiration date of the post

    String formattedDate =
        DateFormat("yyyy-MM-dd'T'HH:mm:ss.SSS'Z'").format(expiringDate.toUtc());
    List<String> formattedTags =
        tags.map((e) => e.toUpperCase().replaceAll(' ', '_')).toList();
    print(formattedTags);

    try {
      // Send a POST request to the server with the post data
      final response = await http.post(
        Uri.parse(baseUrl),
        headers: {
          'Content-Type': 'application/json',
          'accept': '*/*',
          'Authorization': 'Bearer ${accessToken.value}',
        },
        body: jsonEncode({
          'title': title,
          'description': description,
          'price': price,
          'images': images,
          'expringDate':
              expiringDate != DateTime(2000, 1, 2) ? formattedDate : "",
          'tags': formattedTags,
          'storeId': storeId,
          'productBarcode': productBarcode
        }),
      );

      if (response.statusCode == 200) {
        //logger.i("Post created successfully");
        Map<String, dynamic> postResponse =
            jsonDecode(response.body)['details'];

        String id = postResponse['id'];
        String user = postResponse['user']['id'];

        return Post(
            images: images,
            title: title,
            description: description,
            price: price,
            expiringDate: expiringDate,
            id: id,
            userId: user,
            storeId: storeId,
            productBarcode: productBarcode);
      } else {
        // Handle other status codes if needed
        logger.e('Request failed with status: ${response.statusCode}');
        logger.e(response.body);
      }
    } catch (error) {
      logger.e("ERROR: $error");
      // Handle any errors that occur during the request
    }
    return null;
  }

  /// Updates an existing post with the given [post].
  ///
  /// Returns the updated [Post] object if successful, otherwise returns null.
  /// Currently gives an error even tho it does update the post
  Future<Post?> updatePost(
      {required String id,
      required List<String> images,
      required String title,
      required String description,
      required String price,
      required DateTime expiringDate,
      List<String> tags = const [],
      required String storeId,
      required String productBarcode}) async {
    try {
      // Get the existing post by ID
      Post? existingPost = await getPostById(id);

      // Tags formatted to uppercase to match enums in backend
      List<String> formattedTags =
          tags.map((e) => e.replaceAll(' ', '_').toUpperCase()).toList();

      if (existingPost != null) {
        // Update only if the existing post is not null
        existingPost.title = title;
        existingPost.description = description;
        existingPost.price = price;
        existingPost.expiringDate = expiringDate;
        existingPost.images = images;
        existingPost.tags = formattedTags;
        existingPost.storeId = storeId;
        existingPost.productBarcode = productBarcode;

        // Send a PUT request to update the post on the server
        final response = await http.put(
          Uri.parse('$baseUrl/$id'),
          headers: {
            'Content-Type': 'application/json',
            'Authorization': 'Bearer ${accessToken.value}',
          },
          body: jsonEncode(
              existingPost.toJson()), // Serialize only the updated fields
        );

        if (response.statusCode == 200) {
          // logger.i("Post updated successfully");
          // Deserialize the updated post and return it
          Map<String, dynamic> postResponse = jsonDecode(response.body);
          return Post.fromJson(postResponse['details']);
        } else {
          // Handle other status codes if needed
          logger.e('Failed to update post: ${response.statusCode}');
          logger.e(response.body);
        }
      } else {
        // Handle case when existing post is null
        logger.e('Existing post with ID $id not found');
      }
    } catch (error) {
      logger.e("Error updating post: $error");
    }
    // Return null if the update fails
    return null;
  }

  /// Deletes a post by its ID.
  ///
  /// Throws an exception if the deletion fails.
  Future<bool> deletePost(String id, String userId) async {
    try {
      // Send a POST request to the server with the post data
      if (userId != await getUserId()) {
        logger.e("You are not authorized to delete this post");
        return false;
      }
      final response =
          await http.put(Uri.parse('$baseUrl/disable/$id'), headers: {
        'Content-Type': 'application/json',
        'accept': '*/*',
        'Authorization': 'Bearer ${accessToken.value}',
      });

      if (response.statusCode == 200) {
        // logger.i("Post removed successfully");
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

  /// Uploads multiple files to the server.
  ///
  /// Takes a list of [File] objects as input and returns a list of [String] filenames.
  /// Returns an empty list if the upload fails.
  Future<String> uploadFile(File file) async {
    try {
      // Create a MultipartFile object
      String fileName = file.path.split('/').last;
      var multipartFile = await http.MultipartFile.fromPath('files', file.path,
          filename: fileName);

      // Create a multipart request
      var request = http.MultipartRequest('POST',
          Uri.parse('http://nocng.id.vn:9090/api/v1/files/upload/files'));

      // Add the file to the request
      request.files.add(multipartFile);
      request.headers.addAll({
        'accept': '*/*',
        'Authorization': 'Bearer ${accessToken.value}',
      });

      // Send the request
      var streamedResponse = await request.send();

      // Convert the streamedResponse into a response
      var response = await http.Response.fromStream(streamedResponse);

      // Handle response from the backend
      if (response.statusCode == 200) {
        //logger.i("File uploaded successfully");

        // Decode the response body
        dynamic responseData = jsonDecode(response.body);

        // Check if responseData is a list or a single file
        if (responseData is List) {
          // If responseData is a list, process each file
          List<String> filenames = [];
          for (var fileData in responseData) {
            filenames.add(fileData['filename']);
          }
          // Return list of filenames
          return filenames.join(', '); // or any other format you prefer
        } else if (responseData is Map<String, dynamic>) {
          // If responseData is a single file, extract filename
          String filename = responseData['filename'];
          return filename;
        } else {
          throw Exception('Unexpected response format');
        }
      } else {
        // Error handling
        logger.e('Failed to upload file. Status code: ${response.statusCode}');
        logger.e(response.body);
        return "";
      }
    } catch (e) {
      // Error handling
      logger.e('Error uploading file: $e');
      return "";
    }
  }

  /// Parses a JSON map into a [Post] object.
  ///
  /// The [json] parameter is a map containing the data to be parsed.
  /// Returns a [Future] that completes with a [Post] object.
  /// Throws an [Exception] if there is an error parsing the post.
  Future<Post> parsePost(Map<String, dynamic> json) async {
    try {
      // Parse the list of images
      List<String> images =
          json['images'] != null ? List<String>.from(json['images']) : [];

      // Parse other fields with null checks and error handling
      String title = json['title'] ?? '';
      String description = json['description'] ?? '';
      String price = json['price'] ?? '';
      DateTime expiringDate = json['expringDate'] != null
          ? DateTime.parse(json['expringDate'])
          : DateTime(2000, 1, 2);
      String id = json['id'] ?? '';
      String userId = json['user'] != null ? json['user']['id'] ?? '' : '';
      int useful = json['favourite'] ?? false;
      List<dynamic> tags = json['tags'];
      String productBarcode = json['productBarcode'] ?? '';

      List<String> formattedTags = tags.map((e) {
        String substring = e.substring(1);
        return e.replaceRange(1, e.length, substring.toLowerCase()).toString();
      }).toList();

      // Create and return the Post object
      return Post(
          images: images,
          title: title,
          description: description,
          price: price,
          expiringDate: expiringDate,
          id: id,
          userId: userId,
          comments: await commentService.getComments(id),
          useful: useful,
          //tags: tags.map((e) => e.toString()).toList()
          tags: formattedTags,
          storeId: json['storeId'] ?? '',
          productBarcode: productBarcode);
    } catch (e) {
      throw Exception('Error parsing post: $e');
    }
  }

  /// Fetches the user ID from the server.
  ///
  /// This method sends a GET request to the server to retrieve the user ID.
  /// It requires an access token for authentication.
  /// If the request is successful, it returns the user ID as a string.
  Future<String> getUserId() async {
    try {
      var uri = Uri.parse('http://nocng.id.vn:9090/api/v1/users/me');
      var response = await http.get(
        uri,
        headers: {
          'accept': '*/*',
          'Authorization': 'Bearer ${accessToken.value}',
        },
      );

      if (response.statusCode == 200) {
        dynamic responseData = jsonDecode(response.body);

        // Assuming responseData is a JSON object with a key 'id' containing the user ID
        String userId = responseData['id'];

        return userId;
      } else {
        logger.e(
            'Failed to load posts: ${response.statusCode} /n ${response.body}');
        return "";
      }
    } catch (e) {
      throw Exception('Error fetching posts: $e');
    }
  }

  Future<void> markPostUseful(String postId) async {
    try {
      var uri = Uri.parse('http://nocng.id.vn:9090/api/v1/favorites/$postId');
      var response = await http.put(uri, headers: {
        'accept': '*/*',
        'Authorization': 'Bearer ${accessToken.value}',
      });

      if (response.statusCode == 200) {
        //logger.i("Post marked as useful");
      } else {
        logger.e(
            'Failed to mark post as useful: ${response.statusCode} /n ${response.body}');
      }
    } catch (e) {
      logger.e('Error marking post as useful: $e');
    }
  }

  Future<List<String>> getTags() async {
    try {
      var uri = Uri.parse('$baseUrl/tags');
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
        dynamic responseData = json.decode(utf8.decode(response.bodyBytes));

        List<dynamic> tagsData = responseData['details']['records'];
        List<String> tags = tagsData.map((e) => e.toString()).toList();

        print(tags);

        //logger.i("Tags loaded successfully");

        return tags;
      } else {
        throw Exception(
            'Failed to load tags: ${response.statusCode} /n ${response.body}');
      }
    } catch (e) {
      throw Exception('Error fetching tags: $e');
    }
  }
}
