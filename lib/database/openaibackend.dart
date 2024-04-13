import 'dart:convert';
import 'package:kitsain_frontend_spring2023/database/item.dart';
import 'package:http/http.dart' as http;
import 'package:realm/realm.dart';

/// Generates a recipe using the parameters
/// [pantry] (list of ingredients),
/// [recipeType] (the type of recipe (eg. vegan)),
/// [requiredItems] (list of must have items in the recipe)
/// [specialSupplies] (list of kitchen supplies available for use in the recipe),
/// [pantryOnly] (boolean value whether the recipe only uses items from the pantry or adds new ingredients)
/// [language] (in which language is the recipe generated in)
/// [options] (how many different recipe options are to be generated)
/// Returns a Recipe object with the generated recipe from ChatGPT
Future<List<Recipe>> generateRecipe(
    Map<String, String> pantry,
    String recipeType,
    Map<String, String> requiredItems,
    List<String> specialSupplies,
    bool pantryOnly,
    String language,
    int options) async {
  var url = Uri.https(
      'kitsain-backend-test-ohtuprojekti-staging.apps.ocp-test-0.k8s.it.helsinki.fi',
      '/generate');
  var headers = {"Content-Type": "application/json"};
  var requestBody = json.encode({
    'required_items': requiredItems,
    'pantry': pantry,
    'pantry_only': pantryOnly,
    'recipe_type': recipeType,
    'special_supplies': specialSupplies,
    'language': language,
    'options': options
  });
  print('Request body: $requestBody');

  var response = await http.post(url, headers: headers, body: requestBody);

  print('Response status: ${response.statusCode}');
  print('Response body: ${response.body}');

  var responseMap = json.decode(response.body);
  List<Recipe> recipes = [];

  for (var recipe in responseMap['recipes']) {
    // Convert ingredients to string values
    Map<String, String> convertedIngredients = Map<String, String>.fromIterable(
      recipe["ingredients"].keys,
      value: (key) => recipe["ingredients"][key].toString(),
    );

    // Convert instructions to a list of strings
    List<String> convertedInstructions = recipe["instructions"].cast<String>();

    // Create a Recipe object and add it to the recipes list
    recipes.add(Recipe(
      ObjectId().toString(),
      recipe["recipe_name"],
      ingredients: convertedIngredients,
      instructions: convertedInstructions,
    ));
  }
  return recipes;
}

/// Changes a recipe with the following values
/// [ingredients] (list of ingredients),
/// [recipeType] (the type of recipe (eg. vegan)),
/// [expSoon] (list of must have items in the recipe)
/// [supplies] (list of kitchen supplies available for use in the recipe),
/// [pantryOnly] (boolean value whether the recipe only uses items from the pantry or adds new ingredients)
/// Returns the new modified recipe in a Recipe object
Future<Recipe> changeRecipe(Recipe recipe, String change) async {
  var url = Uri.https(
      'kitsain-backend-test-ohtuprojekti-staging.apps.ocp-test-0.k8s.it.helsinki.fi',
      '/change');
  var headers = {"Content-Type": "application/json"};

  var requestRecipe = {
    'recipe_name': recipe.name,
    'ingredients': recipe.ingredients,
    'instructions': recipe.instructions
  };
  var requestBody = json.encode({'recipe': requestRecipe, 'change': change});
  print('Request body: $requestBody');

  var response = await http.post(url, headers: headers, body: requestBody);

  print('Response status: ${response.statusCode}');
  print('Response body: ${response.body}');

  var responseMap = json.decode(response.body);

  // Amounts in the ingredients map may be strings or numbers, so converting them all to strings
  Map<String, String> convertedIngredients = Map<String, String>.fromIterable(
    responseMap["ingredients"].keys,
    value: (key) => responseMap["ingredients"][key].toString(),
  );

  List<String> convertedInstructions = [];
  for (var step in responseMap["instructions"]) {
    convertedInstructions.add(step);
  }

  return Recipe(ObjectId().toString(), responseMap["recipe_name"],
      ingredients: convertedIngredients, instructions: convertedInstructions);
}
