// ignore_for_file: prefer_const_constructors, sort_child_properties_last

import 'package:flutter/material.dart';
import 'package:kitsain_frontend_spring2023/app_typography.dart';
import 'package:kitsain_frontend_spring2023/database/item.dart';
import 'package:kitsain_frontend_spring2023/database/openaibackend.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:kitsain_frontend_spring2023/controller/recipe_controller.dart';
import 'package:realm/realm.dart';

class LoadingDialogWithTimeout extends StatefulWidget {
  const LoadingDialogWithTimeout({super.key});

  @override
  _LoadingDialogWithTimeoutState createState() =>
      _LoadingDialogWithTimeoutState();
}

class _LoadingDialogWithTimeoutState extends State<LoadingDialogWithTimeout> {
  @override
  Widget build(BuildContext context) {
    return const AlertDialog(
      backgroundColor: Colors.transparent,
      elevation: 0,
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          SpinKitWanderingCubes(color: Colors.white, size: 50),
          SizedBox(height: 16),
          Text('Modifying recipe...', style: TextStyle(color: Colors.white)),
        ],
      ),
    );
  }
}

const double borderWidth = 30.0;
const Color nullStatusColor = Color(0xffF0EBE5);
const Color nullTextColor = Color(0xff979797);

class RecipeCard extends StatefulWidget {
  const RecipeCard({super.key, required this.recipe});

  final Recipe recipe;
  @override
  State<RecipeCard> createState() => _RecipeCardState();
}

class _RecipeCardState extends State<RecipeCard> {
  bool showAbbreviation = true;
  final _recipeController = RecipeController();

  @override
  Widget build(BuildContext context) {
    return LongPressDraggable<Recipe>(
      data: widget.recipe,
      onDragCompleted: () {},
      feedback: _buildFeedbackWidget(),
      child: _buildRecipeCardWidget(),
    );
  }

  Widget _buildFeedbackWidget() {
    return SizedBox(
      height: 85,
      width: 320,
      child: Card(
        elevation: 7,
        shape: RoundedRectangleBorder(
          side: BorderSide(
            color: Colors.grey,
          ),
          borderRadius: BorderRadius.all(
            Radius.circular(5),
          ),
        ),
        child: ClipPath(
          child: Container(
            decoration: BoxDecoration(
              border: Border(
                left: BorderSide(
                  color: nullStatusColor,
                  width: borderWidth,
                ),
              ),
            ),
            child: ListTile(
              title: Text(
                widget.recipe.name.toUpperCase(),
                style: AppTypography.heading3,
              ),
            ),
          ),
          clipper: ShapeBorderClipper(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(5),
            ),
          ),
        ),
      ),
    );
  }

  /// Builds the template for the recipe card.
  ///
  /// Returns the template.
  Widget _buildRecipeCardWidget() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(15, 0, 15, 0),
      child: GestureDetector(
        onTap: () {
          showDialog(
            context: context,
            builder: (BuildContext context) =>
                _buildDetailsScreen(context, widget.recipe),
          );
        },
        child: Card(
          elevation: 7,
          shape: RoundedRectangleBorder(
            side: BorderSide(
              color: Colors.grey,
            ),
            borderRadius: BorderRadius.all(
              Radius.circular(5),
            ),
          ),
          child: ClipPath(
            clipper: ShapeBorderClipper(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(5),
              ),
            ),
            child: Stack(
              children: [
                Container(
                  decoration: BoxDecoration(
                    border: Border(
                      left: BorderSide(
                        color: nullStatusColor,
                        width: borderWidth,
                      ),
                    ),
                  ),
                  child: Align(
                    alignment: Alignment.center,
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Padding(
                          padding: const EdgeInsets.only(top: 16.0),
                          child: Text(
                            widget.recipe.name.toUpperCase(),
                            style: AppTypography.heading3
                                .copyWith(color: Colors.black),
                          ),
                        ),
                        SizedBox(
                          height: MediaQuery.of(context).size.height * 0.02,
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  /// Builds the button to change the recipe.
  ///
  /// Includes [text] describing what the button does, [color] indicates the button's color
  /// and [recipeName] indicates the recipe that's being changed. Returns the button.
  Widget _buildChangeButton(String text, Color? color, String recipeName) {
    return ElevatedButton(
        child: Text(text),
        style: ElevatedButton.styleFrom(
          backgroundColor: color,
        ),
        onPressed: () {
          showDialog(
            context: context,
            builder: (BuildContext context) =>
                _buildChangeAlert(context, recipeName),
          );
        });
  }

  /// Builds the button to delete the recipe.
  ///
  /// Includes [text] describing what the button does, [color] indicates the button's color
  /// and [recipeName] indicates the recipe that's being deleted. Returns the button.
  Widget _buildDeleteButton(String text, Color? color, String recipeName) {
    return ElevatedButton(
        child: Text(text),
        style: ElevatedButton.styleFrom(
          backgroundColor: color,
        ),
        onPressed: () {
          showDialog(
            context: context,
            builder: (BuildContext context) =>
                _buildDeleteAlert(context, recipeName),
          );
        });
  }

  /// Builds the details screen for the recipe.
  ///
  /// Includes [details] presenting the details of the recipe. [recipeName] describes the name of the recipe whose details
  /// are shown. Returns the details screen as alert dialog.

  Widget _buildDetailsScreen(BuildContext context, Recipe recipe) {
    TextEditingController recipeNameController =
        TextEditingController(text: recipe.name);
    String ingredientsString = recipe.ingredients.entries
        .map((entry) => '${entry.key}: ${entry.value}')
        .join('\n');
    TextEditingController ingredientsController =
        TextEditingController(text: ingredientsString);
    TextEditingController instructionsController =
        TextEditingController(text: recipe.instructions.join('\n'));

    return AlertDialog(
      title: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: Text(
              'Recipe',
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
          ),
          IconButton(
            icon: Icon(Icons.close),
            onPressed: () {
              Navigator.of(context).pop();
            },
          ),
        ],
      ),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            TextFormField(
              controller: recipeNameController,
              decoration: InputDecoration(labelText: 'Recipe Name'),
            ),
            TextFormField(
              controller: ingredientsController,
              decoration: InputDecoration(labelText: 'Ingredients'),
              maxLines: null, // Allow multiple lines for ingredients
            ),
            TextFormField(
              controller: instructionsController,
              decoration: InputDecoration(labelText: 'Instructions'),
              maxLines: null, // Allow multiple lines for instructions
            ),
          ],
        ),
      ),
      actions: <Widget>[
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            ElevatedButton(
              onPressed: () {
                var navigator = Navigator.of(context);
                String name = recipeNameController.text;

                print("icontroller ${ingredientsController.text}");
                Map<String, String> ingredients = {
                  for (var line in ingredientsController.text.split('\n'))
                    line.split(':')[0].trim(): line.split(':')[1].trim()
                };

                List<String> instructions =
                    instructionsController.text.split('\n');

                var recipe = Recipe(
                  ObjectId().toString(),
                  name,
                  ingredients: ingredients,
                  instructions: instructions,
                );

                RecipeController().createRecipeTask(recipe);
                navigator.pop();
                // Close the dialog
              },
              child: Text('Save'),
            ),
            _buildChangeButton("Change", Colors.grey[200], recipe.name),
            _buildDeleteButton("Delete", Colors.grey[200], recipe.name),
          ],
        ),
      ],
    );
  }

  /// Builds the view asking for the wanted changes to the recipe.
  ///
  /// [recipeName] indicates the recipe on which the changes are applied.
  /// Returns the change view as alert dialog.
  Widget _buildChangeAlert(BuildContext context, String recipeName) {
    final changesController = TextEditingController(); //
    return AlertDialog(
      title: Text('Change recipe'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Please enter wanted changes to'),
          Text(recipeName, style: const TextStyle(fontWeight: FontWeight.bold)),
          Card(
              color: Colors.white,
              child: Padding(
                padding: EdgeInsets.all(8.0),
                child: TextField(
                  controller: changesController,
                  maxLines: 8,
                  decoration: InputDecoration.collapsed(
                      hintText: "Enter your text here"),
                ),
              ))
        ],
      ),
      actions: <Widget>[
        Row(mainAxisAlignment: MainAxisAlignment.spaceEvenly, children: [
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.blue,
            ),
            onPressed: () async {
              var navigator = Navigator.of(context);
              String changes = changesController.text;

              showDialog(
                context: context,
                barrierDismissible:
                    false, // Prevent closing the dialog by tapping outside
                builder: (BuildContext context) {
                  return LoadingDialogWithTimeout(); // Loading spinner
                },
              );

              // the recipe details and changes are sent as parameters
              var changedRecipe = await changeRecipe(widget.recipe, changes);

              navigator.pop();

              _recipeController.createRecipeTask(changedRecipe);
              changesController.clear();
              navigator.pop();
              navigator.pop();
            },
            child: const Text('Change'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.of(context).pop();
            },
            child: const Text('Cancel'),
          ),
        ]),
      ],
    );
  }

  /// Builds the view asking whether the user wants to delete the recipe.
  ///
  /// [recipeName] indicates the recipe which is to be deleted.
  /// Returns the delete view as alert dialog.
  Widget _buildDeleteAlert(BuildContext context, String recipeName) {
    return AlertDialog(
      title: Text('Delete recipe'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [Text('Are you sure you want to delete $recipeName')],
      ),
      actions: <Widget>[
        Row(mainAxisAlignment: MainAxisAlignment.spaceEvenly, children: [
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
            ),
            onPressed: () {
              _recipeController.deleteRecipe(widget.recipe);
              Navigator.of(context).pop();
            },
            child: const Text('Delete'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.of(context).pop();
            },
            child: const Text('Cancel'),
          ),
        ]),
      ],
    );
  }

  /* Widget _buildDetailsContainer(String details, {Color? color}) {
    print(details);
    dynamic parsedJson = jsonDecode(details);

    // Separate the two parts
    Map<String, dynamic> ingredients = parsedJson[0];
    List<dynamic> steps = parsedJson[1];

    // Create a widget for ingredients
    Widget ingredientsWidget = Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Ingredients:', style: TextStyle(fontWeight: FontWeight.bold)),
        for (var entry in ingredients.entries)
          Text('${entry.key}: ${entry.value}'),
      ],
    );

    // Create a widget for steps
    Widget stepsWidget = Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(height: 10),
        Text('Steps:', style: TextStyle(fontWeight: FontWeight.bold)),
        for (int i = 0; i < steps.length; i++) Text('${i + 1}. ${steps[i]}'),
      ],
    );

    return Container(
      width: 100,
      decoration: BoxDecoration(
        border: Border.all(color: color ?? Colors.black),
      ),
      child: Padding(
        padding: const EdgeInsets.all(5.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ingredientsWidget,
            stepsWidget,
          ],
        ),
      ),
    );
  } */
}
