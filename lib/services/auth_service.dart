import 'dart:convert';

import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'package:logger/logger.dart';

/// The [AuthService] class is responsible for handling authentication-related operations.
class AuthService extends GetxController {
  var logger = Logger(printer: PrettyPrinter());

  var accessToken = Rx<String?>(null);

  /// Verifies the provided token by making a POST request to the authentication server.
  ///
  /// The [token] parameter is the access token to be verified.
  /// Returns a [Future] that completes with no return value.
  Future verifyToken(String token) async {
    try {
      http.Response response = await http.post(
        Uri.parse("http://nocng.id.vn:9090/api/v1/auth/verifyToken"),
        headers: {
          'Content-Type': 'application/json',
          'accept': '*/*',
        },
        body: jsonEncode({'accessToken': token}),
      );

      // Decode the response JSON
      Map<String, dynamic> responseData = jsonDecode(response.body);

      accessToken.value = responseData['accessToken'].toString();
      // Log the access token if needed in development
      //logger.i(responseData['accessToken'].toString());
    } catch (error) {
      logger.e("error");
      // Handle any errors that occur during the request
    }
  }
}
