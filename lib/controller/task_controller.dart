import 'package:get/get.dart';
import 'package:googleapis/tasks/v1.dart';
import 'package:kitsain_frontend_spring2023/login_controller.dart';
import 'package:kitsain_frontend_spring2023/models/ShoppingListItemModel.dart';
import 'dart:async';

class TaskController extends GetxController {
  var tasksListRemove = Rx<List<int>?>([]);
  var shoppingListItem = Rx<List<ShoppingListItemModel>?>([]);

  final loginController = Get.put(LoginController());
  final _tasksStreamController = StreamController<List<ShoppingListItemModel>>.broadcast();

  Stream<List<ShoppingListItemModel>> get tasksStream => _tasksStreamController.stream;

  /// Returns list of created tasks in a task list
  ///
  /// [taskListId] is the google tasks id of the task list.
  /// Returns the contents (= tasks) of the task list as Tasks object
  getTasksList(String taskListId, {bool pantryList = false}) async {
    var tskList = await loginController.taskApiAuthenticated.value?.tasks
        .list(taskListId, showHidden: true);

    tskList?.items?.forEach((element) {
      var newItem = ShoppingListItemModel(
          '${element.title}',
          element.notes == null ? '' : '${element.notes}',
          false,
          '${element.id}');
      shoppingListItem.value?.add(newItem);
    });

    shoppingListItem.refresh();

    return tskList;
  }

  getTasksListStream(String taskListId) async {
    var tskList = await loginController.taskApiAuthenticated.value?.tasks
        .list(taskListId, showHidden: true);
    shoppingListItem.value?.clear();
    tskList?.items?.forEach((element) {
      if (element.parent == null) {
        print(element);
        var newItem = ShoppingListItemModel(
            element.title ?? '',
            element.notes ?? '',
            false,
            element.id ?? '');
        shoppingListItem.value?.add(newItem);
      }
    });
    _tasksStreamController.add(shoppingListItem.value ?? []);
    shoppingListItem.refresh();

    return tskList;
  }

  @override
  void onClose() {
    _tasksStreamController.close();
    super.onClose();
  }

  /// Sends created task to the google tasks API
  ///
  /// [itemName] is the task's, e.g. pantry item's, name. [description] is the details of the task.
  /// [taskListId] is the google tasks id of the task list. [due] is the optional expiry date of a pantry item task.
  /// Returns the google tasks id of the task list in which the task is inserted.
  createTask(String itemName, String description, String taskListId,
      [String? due, String? amount]) async {
    var itemAmount = amount;
    if (amount == null) {
      itemAmount = "";
    }
    var newTask =
        Task(title: itemName, notes: description, status: "needsAction");

    if (due != null) {
      // Parse due date
      DateTime dueDateTime = DateTime.parse(due);
      // Add one day more to prevent the UTC conversion problem
      dueDateTime =
          DateTime(dueDateTime.year, dueDateTime.month, dueDateTime.day + 1);
      // Convert to UTC
      DateTime dueUtcDateTime = dueDateTime.toUtc();

      // Format as ISO 8601 string
      String formattedDueDate = dueUtcDateTime.toIso8601String();

      // Assign formatted due date to newTask
      newTask.due = formattedDueDate;
    }

    var googleTaskId;
    await loginController.taskApiAuthenticated.value!.tasks
        .insert(newTask, taskListId)
        .then((value) async {
      // print('ok ${value.id}');
      googleTaskId = value.id;
      var newItem =
          ShoppingListItemModel(itemName, description, false, '${value.id}');
      shoppingListItem.value?.add(newItem);
      await getTasksList(taskListId);
      // tasksList.value?.items?.add(value);
      shoppingListItem.refresh();
    });
    return googleTaskId;
  }

  /// Edits a task in a task list.
  ///
  /// [title] is the task's, e.g. pantry item's, name. [description] is the details of the task.
  /// [taskListId] is the google tasks id of the task list that includes the task being edited.
  /// [taskId] is the google task id of the task that's edited.
  /// [due] is the optional expiry date of a pantry item task.
  editTask(String itemName, String description, String taskListId,
      String taskId, int index,
      [String? due, String? amount, bool? completed]) async {
    var itemAmount = amount;
    print("editAmount: ${amount}");
    if (amount == null) {
      itemAmount = "";
    }
    var newItem = ShoppingListItemModel(itemName, description, false, taskId);
    shoppingListItem.value?.insert(index, newItem);

    print("completed: ${completed}");

    var newTask = Task(
        title: itemName,
        notes: description,
        status: completed! ? "completed" : "needsAction",
        id: taskId);

    if (due != null) {
      DateTime dueDateTime = DateTime.parse(due);
      // Add one day more to prevent the UTC conversion problem
      dueDateTime =
          DateTime(dueDateTime.year, dueDateTime.month, dueDateTime.day + 1);
      // Convert to UTC
      DateTime dueUtcDateTime = dueDateTime.toUtc();
      // Format as ISO 8601 string
      String formattedDueDate = dueUtcDateTime.toIso8601String();
      // Assign formatted due date to newTask
      newTask.due = formattedDueDate;
    }

    // print('tlid ' + taskListId + ' tid ' + taskId);
    var googleTaskId;
    await loginController.taskApiAuthenticated.value!.tasks
        .update(
      newTask,
      taskListId,
      taskId,
    )
        .then((value) async {
      googleTaskId = value.id;
      await getTasksList(taskListId);
      // tasksList.value?.items?[index] = newTask;
      shoppingListItem.refresh();
    });
  }

  /// Deletes a task in a task list.
  ///
  /// [taskListId] is the google tasks id of the task list that includes the task being edited.
  /// [taskId] is the google task id of the task that's deleted.
  deleteTask(String taskListId, String taskId, int index) async {
    // print(' $taskListId    $taskId     $index     ');

    await loginController.taskApiAuthenticated.value!.tasks
        .delete(
      taskListId,
      taskId,
    )
        .then((value) async {
      await getTasksList(taskListId);
      shoppingListItem.refresh();

      // tasksList.value?.items?.removeAt(index);
    });
  }
}
