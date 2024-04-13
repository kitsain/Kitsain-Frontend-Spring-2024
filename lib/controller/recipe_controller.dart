import 'package:get/get.dart';
import 'package:kitsain_frontend_spring2023/database/item.dart';
import 'package:kitsain_frontend_spring2023/controller/tasklist_controller.dart';
import 'package:kitsain_frontend_spring2023/controller/task_controller.dart';
import 'package:kitsain_frontend_spring2023/database/recipes_proxy.dart';
import 'package:realm/realm.dart';

class RecipeController {
  final _taskListController = Get.put(TaskListController());
  final _taskController = Get.put(TaskController());
  final _recipeProxy = RecipeProxy();

  createRecipeTaskList() async {
    var recipesFound = await checkIfRecipeListExists();
    print("recipesfound: $recipesFound");
    if (recipesFound == "not") {
      _taskListController.createTaskLists("My Recipes");
    }
    await getRecipeTasks();
  }

  Future checkIfRecipeListExists() async {
    await _taskListController.getTaskLists();
    var recipeIndex = "not";
    if (_taskListController.taskLists.value?.items != null) {
      int length = _taskListController.taskLists.value?.items!.length as int;
      for (var i = 0; i < length; i++) {
        if (_taskListController.taskLists.value?.items?[i].title ==
            "My Recipes") {
          recipeIndex =
              _taskListController.taskLists.value?.items?[i].id as String;
          break;
        }
      }
    }
    return recipeIndex;
  }

  bool checkIfRecipeInrealm(
      String googleTaskId, RealmResults<Recipe> realmItems) {
    var googleTaskIdList = realmItems.map((e) => e.googleTaskId);
    if (googleTaskIdList.contains(googleTaskId)) {
      return true;
    } else {
      return false;
    }
  }

  bool checkIfRecipeInGoogleTasks(String? googleTaskId, tasks) {
    var googleTaskIdList = tasks.items.map((e) => e.id);
    if (googleTaskIdList.contains(googleTaskId)) {
      return true;
    } else {
      return false;
    }
  }

  saveRecipeTasksToRealm(
    realmItems,
    tasks,
  ) async {
    for (var i = 0; i < tasks.items.length; i++) {
      if (!checkIfRecipeInrealm(tasks.items[i].id, realmItems)) {
        var item = Recipe(
          ObjectId().toString(),
          tasks.items[i].title,
          instructions: getInstructions(tasks.items[i].notes),
          ingredients: getIngredients(tasks.items[i].notes),
          googleTaskId: tasks.items[i].id,
        );
        _recipeProxy.upsertRecipe(item);
      }
    }
  }

  List<String> getInstructions(String notes) {
    List<String> recipeParts = notes.split('\n\n');
    String instructionsSection = recipeParts[1];
    List<String> instructions = parseInstructions(instructionsSection);

    return instructions;
  }

  List<String> parseInstructions(String instructionsSection) {
    List<String> lines = instructionsSection.split('\n');
    List<String> steps = [];
    for (String line in lines.skip(1)) {
      steps.add(line.trim());
    }
    return steps;
  }

  Map<String, String> getIngredients(String notes) {
    List<String> recipeParts = notes.split('\n\n');
    String ingredientspart = recipeParts[0];
    Map<String, String> ingredients = parseIngredients(ingredientspart);
    return ingredients;
  }

  Map<String, String> parseIngredients(String ingredientsSection) {
    List<String> lines = ingredientsSection.split('\n');
    Map<String, String> ingredients = {};
    for (String line in lines.skip(1)) {
      List<String> parts = line.split(': ');
      ingredients[parts[0]] = parts[1];
    }
    return ingredients;
  }

  deleteMissingGoogleTasksFromRealm(
      RealmResults<Recipe> realmItems, tasks) async {
    for (var i = 0; i < realmItems.length; i++) {
      if (!checkIfRecipeInGoogleTasks(realmItems[i].googleTaskId, tasks)) {
        _recipeProxy.deleteRecipe(realmItems[i]);
      }
    }
  }

  syncRecipeTasksWithRealm(index) async {
    var realmItems = RecipeProxy().getRecipes();
    var tasks = await _taskController.getTasksList(index);
    print("testing");
    saveRecipeTasksToRealm(realmItems, tasks);
    deleteMissingGoogleTasksFromRealm(realmItems, tasks);
  }

  getRecipeTasks() async {
    await _taskListController.getTaskLists();
    var index = await checkIfRecipeListExists();
    if (index == "not") {
      await _taskListController.createTaskLists("My Recipes");
      index = await checkIfRecipeListExists();
    }
    await syncRecipeTasksWithRealm(index);
    var realmItems = RecipeProxy().getItems();
    print(realmItems);
  }

  String createStringOfRecipeValues(Recipe recipe) {
    var valuesString = "";
    valuesString += "Ingredients:\n";
    recipe.ingredients.forEach((key, value) {
      valuesString += "$key: $value\n";
    });
    valuesString += "\nInstructions:\n";
    for (var instruction in recipe.instructions) {
      valuesString += "$instruction\n";
    }
    return valuesString;
  }

  Future<void> createRecipeTask(Recipe recipe) async {
    final valuesString = createStringOfRecipeValues(recipe);
    final taskListIndex = await checkIfRecipeListExists();
    var googleTaskId = await _taskController.createTask(
        recipe.name, valuesString, taskListIndex.toString());
    recipe.googleTaskId = googleTaskId;
    RecipeProxy().upsertRecipe(recipe);
  }

  deleteRecipeFromTasks(Recipe recipe) async {
    final taskListIndex = await findRecipeIndex();
    _taskController.deleteTask(taskListIndex, recipe.googleTaskId as String, 0);
  }

  void deleteRecipe(Recipe recipe) async {
    await deleteRecipeFromTasks(recipe);
    realm.write(() {
      realm.delete(recipe);
    });
  }

  deleteAllRecipesFromTasks() async {
    _taskListController.deleteRecipeTaskList();
  }

  void deleteAllRecipes() async {
    await deleteAllRecipesFromTasks();
    realm.write(() {
      realm.deleteAll<Recipe>();
    });
  }

  Future findRecipeIndex() async {
    await _taskListController.getTaskLists();
    var recipeIndex = "not";
    if (_taskListController.taskLists.value?.items != null) {
      int length = _taskListController.taskLists.value?.items!.length as int;
      for (var i = 0; i < length; i++) {
        print("$i: ${_taskListController.taskLists.value?.items?[i].title}");
        if (_taskListController.taskLists.value?.items?[i].title ==
            "My Recipes") {
          recipeIndex =
              _taskListController.taskLists.value?.items?[i].id as String;
          break;
        }
      }
    }
    return recipeIndex;
  }
}
