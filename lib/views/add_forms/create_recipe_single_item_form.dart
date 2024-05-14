import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:kitsain_frontend_spring2023/database/item.dart';
import 'package:kitsain_frontend_spring2023/database/openaibackend.dart';
import 'package:kitsain_frontend_spring2023/app_colors.dart';
import 'package:kitsain_frontend_spring2023/app_typography.dart';
import 'package:kitsain_frontend_spring2023/controller/recipe_controller.dart';

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
          Text('Creating recipe...', style: TextStyle(color: Colors.white)),
        ],
      ),
    );
  }
}

class CreateRecipeSingleItemForm extends StatefulWidget {
  const CreateRecipeSingleItemForm({super.key});

  @override
  _CreateRecipeSingleItemFormState createState() =>
      _CreateRecipeSingleItemFormState();
}

class _CreateRecipeSingleItemFormState extends State<CreateRecipeSingleItemForm> {
  String _ingredient = '';

    /// Builds the loading dialog
  ///
  /// Returns the LoadingDialogWithTimeout widget
  Widget _loadingDialog(BuildContext context) {
    return const LoadingDialogWithTimeout();
  }

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Card(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  IconButton(
                    icon: const Icon(Icons.close),
                    onPressed: () {
                      Navigator.of(context).pop();
                    },
                  ),
                ],
              ),
              Text(
                'Create a recipe from a single ingredient',
                textAlign: TextAlign.center,
                style: AppTypography.heading3.copyWith(color: AppColors.main3),
              ),
              TextFormField(
                style: AppTypography.paragraph,
                decoration: const InputDecoration(
                  labelText: 'Ingredient',
                  filled: true,
                  fillColor: Colors.white,
                  border: OutlineInputBorder(),
                ),
                maxLines: null,
                validator: (value) {
                  if (value!.isEmpty) {
                    return 'Please enter an ingredient';
                  }
                  return null;
                },
                onSaved: (value) {
                  _ingredient = value!;
                },
              ),
              const SizedBox(height: 16),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.white,
                    foregroundColor: AppColors.main3),
                onPressed: () async {
                  showDialog(
              context: context,
              barrierDismissible: false,
              builder: (BuildContext context) {
                // Use a Builder widget to create a new valid BuildContext
                return Builder(
                  builder: (BuildContext context) {
                    return _loadingDialog(context);
                  },
                );
              },
            );
                    var logic = CreateSingleItemRecipeLogic();
                    try {
                      await logic.submitIngredient(_ingredient);
                  } finally {
                    Navigator.of(context, rootNavigator: true).pop();
                    Navigator.of(context).pop();
                  }
                    print('Submitted ingredient: $_ingredient');
                  
                },
                child: const Text('Submit'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class CreateSingleItemRecipeLogic {
  final _recipeController = RecipeController();

  Future<void> submitIngredient (String ingredient) async {
    var recipe = await generateSingleItemRecipe(ingredient);
    _saveRecipes(recipe[0]);
    print('Generated recipe: $recipe');
    print('Submitted ingredient: $ingredient');
  }

  _saveRecipes(Recipe recipe) async {{
      await _recipeController.createRecipeTask(recipe);
    }
  }
}