import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:get/get.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:googleapis/tasks/v1.dart';
import 'package:extension_google_sign_in_as_googleapis_auth/extension_google_sign_in_as_googleapis_auth.dart';

class LoginController extends GetxController {
  // GoogleSignInAccount? _user;
  // GoogleSignInAccount get user => _user!;
  var googleUser = Rx<GoogleSignInAccount?>(null);
  var googleSignInUser = Rx<GoogleSignIn?>(null);
  var accessToken = Rx<String?>(null);
  var taskApiAuthenticated = Rx<TasksApi?>(null);

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

      // Print the response
      accessToken.value = responseData['accessToken'].toString();
    } catch (error) {
      print("error");
      // Handle any errors that occur during the request
    }
  }

  Future googleLogin() async {
    final googleSignIn = GoogleSignIn(
        scopes: [TasksApi.tasksScope],
        clientId:
            "709026956129-nt0ged8nsm2hq70ha2n4sne6j2rcplsr.apps.googleusercontent.com");
    googleUser.value = await googleSignIn.signIn();

    googleSignInUser.value = googleSignIn;

    final GoogleSignInAuthentication googleAuth =
        await googleUser.value!.authentication;
    final String? googleIdToken = googleAuth.idToken;

    verifyToken(googleIdToken!);

    var httpClient = (await googleSignIn.authenticatedClient())!;

    TasksApi taskapi = TasksApi(httpClient);

    taskApiAuthenticated.value = taskapi;

    // var tstlistCount = await taskApiAuthenticated.value?.tasklists.list();

    print(taskApiAuthenticated.value?.tasklists.list());
    print(taskapi.tasklists.list());
    var tskList = await taskApiAuthenticated.value?.tasklists.list();
    // taskLists.value = tskList;

    print('ok');
    print(tskList?.items!.last.title);

    ///extra

    // print(tskList.items!.last.id);

    // await taskapi.tasklists
    //     .insert(TaskList(title: 'task12', id: 'task12id'), $fields: '');

    // final googleUser = await googleSignIn.signIn();

    // if (googleUser == null) return;
    // _user = googleUser;

    // final googleAuth = await googleUser.authentication;

    // final credential = GoogleAuthProvider.credential(
    //     accessToken: googleAuth.accessToken, idToken: googleAuth.idToken);

    // await FirebaseAuth.instance.signInWithCredential(credential);
  }
}
