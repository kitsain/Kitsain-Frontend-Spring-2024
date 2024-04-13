import 'package:get/get.dart';
import 'package:kitsain_frontend_spring2023/database/item.dart';
import 'package:kitsain_frontend_spring2023/controller/tasklist_controller.dart';
import 'package:kitsain_frontend_spring2023/controller/task_controller.dart';
import 'package:kitsain_frontend_spring2023/database/pantry_proxy.dart';
import 'package:realm/realm.dart';

class PantryController {
  final _taskListController = Get.put(TaskListController());
  final _taskController = Get.put(TaskController());
  final _pantryProxy = PantryProxy();

  /// Finds the Google Tasks index of My Pantry tasklist
  ///
  /// Returns the index of the My Pantry tasklist
  Future findPantryIndex() async {
    await _taskListController.getTaskLists();
    var pantryIndex = "not";
    if (_taskListController.taskLists.value?.items != null) {
      int length = _taskListController.taskLists.value?.items!.length as int;
      for (var i = 0; i < length; i++) {
        print("$i: ${_taskListController.taskLists.value?.items?[i].title}");
        if (_taskListController.taskLists.value?.items?[i].title ==
            "My Pantry") {
          pantryIndex =
              _taskListController.taskLists.value?.items?[i].id as String;
          break;
        }
      }
    }
    return pantryIndex;
  }

  Future completePantryItem(Item item) async {
    await editItemTasks(item, complete: true);
  }

  Future deletePantryItemFromTasks(Item item) async {
    var pantryIndex = await findPantryIndex();
    await _taskController.deleteTask(pantryIndex, item.googleTaskId!, 0);
  }

  /// Checks if pantry item exists as a task in the My Pantry tasklist.
  ///
  /// [pantryItemGoogleTaskIndex] is the google task index of the Pantry Item
  /// and [taskListIndex] is the google tasklist index of the My Pantry tasklist.
  Future checkIfPantryItemExists(
      String pantryItemGoogleTaskIndex, String taskListIndex) async {
    await _taskListController.getTaskLists();
    if (_taskListController.taskLists.value?.items != null) {
      int length = _taskListController.taskLists.value?.items!.length as int;
      for (var i = 0; i < length; i++) {
        if (_taskListController.taskLists.value?.items?[i].id as String ==
            taskListIndex) {
          break;
        }
      }
    }
  }

  /// Changes format of item's expiry date so that it's recognized by Google Tasks.
  ///
  /// [expiryDate] is the expiry date of the pantry item. Returns correct format of expiry date.
  changeFormatOfExpiryDate(String expiryDate) {
    return expiryDate.replaceAll(' ', 'T');
  }

  /// Checks if My Pantry tasklist exists.
  ///
  /// Returns the Google Tasks index of My Pantry tasklist. Returns String "not" if it doesn't exist.
  Future checkIfPantryListExists() async {
    await _taskListController.getTaskLists();
    var pantryIndex = "not";
    if (_taskListController.taskLists.value?.items != null) {
      int length = _taskListController.taskLists.value?.items!.length as int;
      for (var i = 0; i < length; i++) {
        print("$i: ${_taskListController.taskLists.value?.items?[i].title}");
        if (_taskListController.taskLists.value?.items?[i].title ==
            "My Pantry") {
          pantryIndex =
              _taskListController.taskLists.value?.items?[i].id as String;
          break;
        }
      }
    }
    return pantryIndex;
  }

  /// Creates a task of pantry item to be added and upserts it to Realm.
  ///
  /// [pantryItem] is the pantry item to be added.
  Future<void> createPantryItemTask(Item pantryItem) async {
    final valuesString = createStringOfPantryItemValues(pantryItem);
    final taskListIndex = await checkIfPantryListExists();
    String? expiryDateAsString;
    if (pantryItem.expiryDate != null) {
      expiryDateAsString =
          changeFormatOfExpiryDate(pantryItem.expiryDate.toString());
    }
    var googleTaskId = await _taskController.createTask(
        pantryItem.name,
        valuesString,
        taskListIndex.toString(),
        expiryDateAsString,
        pantryItem.amount);
    pantryItem.googleTaskId = googleTaskId;
    PantryProxy().upsertItem(pantryItem);
  }

  /// Creates a string of all pantry item details.
  ///
  /// [pantryItem] is the pantry item that contains the details to be stringified.
  createStringOfPantryItemValues(Item pantryItem,
      {bool returnToPantry = false}) {
    var valuesString = "";
    valuesString += "amount: ${pantryItem.amount}\n";
    valuesString += "location: ${pantryItem.location}\n";
    valuesString += "category: ${pantryItem.mainCat}\n";
    valuesString += "favorite: ${pantryItem.favorite}\n";
    valuesString += "opened date: ${pantryItem.openedDate}\n";
    valuesString += "added date: ${pantryItem.addedDate}\n";
    valuesString += "details: ${pantryItem.details}\n";
    return valuesString;
  }

  /// Edits the pantry item in Google Tasks with provided changes.
  ///
  /// [item] is the pantry item with its updated properties.
  Future<void> editItemTasks(Item item,
      {bool complete = false,
      bool returnToPantry = false,
      bool favoritedFromPantryView = false}) async {
    print("opening date 3: ${item.openedDate}");
    final valuesString = createStringOfPantryItemValues(item);
    final taskListIndex = await checkIfPantryListExists();
    String? expiryDateAsString;
    if (item.expiryDate != null) {
      expiryDateAsString = changeFormatOfExpiryDate(item.expiryDate.toString());
    }
    print("MOI!!!!");
    await _taskController.editTask(
        item.name,
        valuesString,
        taskListIndex.toString(),
        item.googleTaskId!,
        0,
        expiryDateAsString,
        item.amount,
        complete);
    if (!complete && !returnToPantry && !favoritedFromPantryView) {
      PantryProxy().upsertItem(item);
    }
  }

  String _ignoreSubMicro(String s) {
    // Makes the rfc timestamp able to be parsed through DateTime parser
    if (s.length > 27) return s.substring(0, 26) + s[s.length - 1];
    return s;
  }

  DateTime convertToRealmDateTime(String dateString) {
    // Parse the date string into a DateTime object
    DateTime dateTime = DateTime.parse(_ignoreSubMicro(dateString));
    return dateTime;
  }

  Item parseDescriptionStringFromGoogleTask(String description, Item item) {
    // Split the valuesString by newline characters
    List<String> lines = description.split('\n');

    // Loop through each line
    for (var line in lines) {
      // Split each line by colon (:) to separate property name and value
      List<String> parts = line.split(':');

      // Trim any leading or trailing whitespaces from property name and value
      String propertyName = parts[0].trim();
      String propertyValue = parts.length > 1 ? parts[1].trim() : '';

      // Assign values to item properties based on property name
      switch (propertyName) {
        case 'location':
          if (propertyValue != "null") {
            item.location = propertyValue;
          }
          break;
        case 'amount':
          if (propertyValue != "null") {
            item.amount = propertyValue;
          }
          break;
        case 'category':
          if (propertyValue != "null") {
            item.mainCat = int.parse(propertyValue);
          }
          break;
        case 'favorite':
          if (propertyValue != "null") {
            bool favorite = propertyValue == 'true';
            item.favorite = favorite;
          }
          break;
        case 'opened date':
          if (propertyValue != "null") {
            item.openedDate = DateTime.parse(propertyValue);
          }
          break;
        case 'added date':
          if (propertyValue != "null") {
            item.addedDate = DateTime.parse(propertyValue);
          }
          break;
        case 'details':
          if (propertyValue != "null") {
            item.details = propertyValue;
          }
          break;
      }
    }
    return item;
  }

  bool checkIfItemInrealm(String googleTaskId, RealmResults<Item> realmItems) {
    var googleTaskIdList = realmItems.map((e) => e.googleTaskId);
    if (googleTaskIdList.contains(googleTaskId)) {
      return true;
    } else {
      return false;
    }
  }

  bool checkIfItemInGoogleTasks(String? googleTaskId, tasks) {
    var googleTaskIdList = tasks.items.map((e) => e.id);
    if (googleTaskIdList.contains(googleTaskId)) {
      return true;
    } else {
      return false;
    }
  }

  moveIncompleteTasksToPantry(tasks) {
    var usedItems = _pantryProxy.getUsedItems();
    var completedTasks =
        tasks.items.where((i) => i.status == "completed").toList();
    for (var i = 0; i < usedItems.length; i++) {
      if (!completedTasks.contains(usedItems[i])) {
        _pantryProxy.changeLocation(usedItems[i], "Pantry");
      }
    }
  }

  /// Saves whatever is in Google Tasks to realm
  ///
  /// [realmItems] are the items that are in realm and [tasks] are the items that are in Google Tasks
  saveGoogleTasksToRealm(realmItems, tasks) {
    var notes = "";
    var usedItems = _pantryProxy.getUsedItems();
    var usedItemsTasksIds = usedItems.map((i) => i.googleTaskId).toList();
    var completedTasks =
        tasks.items.where((i) => i.status == "completed").toList();
    var completedTasksIds = completedTasks.map((i) => i.id).toList();

    moveIncompleteTasksToPantry(tasks);

    var itemBothIds = {};
    realmItems.forEach((item) {
      itemBothIds[item.googleTaskId] = item.id;
    });

    tasks.items.forEach((item) {
      if (!checkIfItemInrealm(item.id, realmItems)) {
        var newItem = Item(ObjectId().toString(), item.title, "Pantry", 1,
            googleTaskId: item.id);
        if (item.due != null) {
          newItem.expiryDate = convertToRealmDateTime(item.due);
        }
        if (item.notes != null) {
          notes = item.notes;
        }
        item = parseDescriptionStringFromGoogleTask(notes, newItem);

        if (!usedItemsTasksIds.contains(newItem.googleTaskId)) {
          _pantryProxy.upsertItem(newItem);
        }

        if (completedTasksIds.contains(newItem.googleTaskId) &&
            !usedItemsTasksIds.contains(newItem.googleTaskId)) {
          _pantryProxy.changeLocation(newItem, "Used");
        }
      } else {
        if (itemBothIds.keys.contains(item.id)) {
          var newItem = Item(itemBothIds[item.id], item.title, "Pantry", 1,
              googleTaskId: item.id);
          if (item.due != null) {
            newItem.expiryDate = convertToRealmDateTime(item.due);
          }
          if (item.notes != null) {
            notes = item.notes;
          }
          item = parseDescriptionStringFromGoogleTask(notes, newItem);

          if (!usedItemsTasksIds.contains(newItem.googleTaskId)) {
            _pantryProxy.upsertItem(newItem);
          }

          if (completedTasksIds.contains(newItem.googleTaskId) &&
              !usedItemsTasksIds.contains(newItem.googleTaskId)) {
            _pantryProxy.changeLocation(newItem, "Used");
          }
        }
      }
    });
  }

  /// Deletes items from Realm that aren't in Google Tasks
  ///
  /// [realmItems] are the items that are in realm and [tasks] are the items that are in Google Tasks
  deleteMissingGoogleTasksFromRealm(
      RealmResults<Item> realmItems, tasks) async {
    for (var i = 0; i < realmItems.length; i++) {
      if (!checkIfItemInGoogleTasks(realmItems[i].googleTaskId, tasks)) {
        _pantryProxy.deleteItem(realmItems[i]);
      }
    }
  }

  /// Does the syncing between Google Tasks and Realm
  ///
  /// [index] is the My Pantry tasklist index
  syncPantryTasksWithRealm(index) async {
    var realmItems = PantryProxy().getPantryItems();
    var tasks = await _taskController.getTasksList(index, pantryList: true);
    saveGoogleTasksToRealm(realmItems, tasks);
    deleteMissingGoogleTasksFromRealm(realmItems, tasks);
  }

  /// Gets the tasks(=pantry items) from My Pantry tasklist
  getPantryTasks() async {
    await _taskListController.getTaskLists();
    var index = await checkIfPantryListExists();
    if (index == "not") {
      await _taskListController.createTaskLists("My Pantry");
      index = await checkIfPantryListExists();
    }
    await syncPantryTasksWithRealm(index);
  }
}
