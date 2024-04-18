import 'package:get/get.dart';
import 'package:googleapis/tasks/v1.dart';
import 'package:kitsain_frontend_spring2023/login_controller.dart';

class TaskListController extends GetxController {
  var taskLists = Rx<TaskLists?>(null);
  final loginController = Get.put(LoginController());

  getTaskLists() async {
    var tskList =
        await loginController.taskApiAuthenticated.value?.tasklists.list();
    taskLists.value = tskList;
    print("Length: ${taskLists.value?.items?.length}");
  }

  createTaskLists(String name) async {
    // print(tskList?.items?.first.title);
    print(taskLists.value?.items?.length);
    await loginController.taskApiAuthenticated.value!.tasklists
        .insert(TaskList(title: name), $fields: '')
        .then((value) => {
              taskLists.value?.items?.add(value),
              taskLists.refresh(),
              print(taskLists.value?.items?.length),
            });
  }

  deleteTaskLists(String id, int index) async {
    await loginController.taskApiAuthenticated.value!.tasklists
        .delete(id)
        .then((value) => {
              print('done'),
              taskLists.value?.items?.removeAt(index),
              taskLists.refresh(),
            });
  }

  editTaskLists(String name, String id, int index) async {
    var newTaskList = TaskList(title: name, id: id);
    print(id);
    await loginController.taskApiAuthenticated.value!.tasklists
        .update(newTaskList, id)
        .then((value) {
      print('done');
      taskLists.value?.items?[index] = newTaskList;
      taskLists.refresh();
    });
  }

 deleteRecipeTaskList() async {
  final id = await checkIfRecipeListExists();
  if (id != "not") {
    var tasks = await loginController.taskApiAuthenticated.value!.tasks.list(id);
    for (var task in tasks.items!) {
      await loginController.taskApiAuthenticated.value!.tasks.delete(id, task.id!);
    }
    taskLists.refresh();
  }
}

  Future checkIfRecipeListExists() async {
    await getTaskLists();
    var recipeIndex = "not";
    if (taskLists.value?.items != null) {
      int length = taskLists.value?.items!.length as int;
      for (var i = 0; i < length; i++) {
        if (taskLists.value?.items?[i].title == "My Recipes") {
          recipeIndex = taskLists.value?.items?[i].id as String;
          break;
        }
      }
    }
    return recipeIndex;
  }
}
