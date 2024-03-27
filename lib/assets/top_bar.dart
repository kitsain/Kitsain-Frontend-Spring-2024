import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:kitsain_frontend_spring2023/app_colors.dart';
import 'package:kitsain_frontend_spring2023/app_typography.dart';
import 'package:kitsain_frontend_spring2023/LoginController.dart';
import 'package:kitsain_frontend_spring2023/views/homepage2.dart';
import 'package:kitsain_frontend_spring2023/database/pantry_proxy.dart';
import 'package:kitsain_frontend_spring2023/database/recipes_proxy.dart';
import 'package:kitsain_frontend_spring2023/controller/recipe_controller.dart';

class TopBar extends StatefulWidget implements PreferredSizeWidget {
  const TopBar({
    super.key,
    required this.title,
    this.addFunction,
    this.addIcon = Icons.add,
    required this.helpFunction,
    required this.backgroundImageName,
    required this.titleBackgroundColor,
  });

  final String title;
  final Function? addFunction;
  final IconData addIcon;
  final Function helpFunction;
  final String backgroundImageName;
  final Color titleBackgroundColor;
  

  @override
  State<TopBar> createState() => _TopBarState();

  @override
  Size get preferredSize => const Size.fromHeight(100);
}

class _TopBarState extends State<TopBar> {
  final _loginController = Get.put(LoginController());
  VisualDensity _topIconsDensity =
      VisualDensity(horizontal: -4.0, vertical: -4.0);
  final _recipeController = RecipeController();
  final _pantryProxy = PantryProxy();
  _openAccountSettings(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text(
            'Signed in as',
            style: AppTypography.paragraph.copyWith(color: AppColors.main1),
          ),
          content: Text(
            '${_loginController.googleUser.value?.email}',
            textAlign: TextAlign.center,
            style: AppTypography.paragraph,
          ),
          actions: <Widget>[
            TextButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: Text(
                'CANCEL',
                style: AppTypography.category.copyWith(color: Colors.black38),
              ),
            ),
            TextButton(
              onPressed: () {
                _signOut();
              },
              child: Text(
                'LOG OUT',
                style: AppTypography.category.copyWith(color: AppColors.main1),
              ),
            ),
          ],
        );
      },
    );
  }

  _openSettings(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text(
            'Settings',
            style: AppTypography.paragraph.copyWith(color: AppColors.main1),
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              /* TextButton(
                onPressed: () {
                showDialog(
                  context: context,
                  builder: (confirmationContext) {
                    return AlertDialog(
                      title: Text("Clear Pantry"),
                      content: Text("Are you sure you want to clear the pantry?"),
                      actions: <Widget>[
                        TextButton(
                          onPressed: () {
                            Navigator.pop(confirmationContext); 
                            _pantryProxy.deleteAll();
                            Navigator.pop(context); 
                          },
                          child: Text("Yes"),
                        ),
                        TextButton(
                          onPressed: () {
                            Navigator.pop(confirmationContext);
                          },
                          child: Text("No"),
                        ),
                      ],
                    );
                  },
                );
              },
                child: Text(
                  'CLEAR PANTRY()',
                  style: AppTypography.category.copyWith(color: AppColors.main1),
                ),
              ), */
              TextButton(
                onPressed: () {
                showDialog(
                  context: context,
                  builder: (confirmationContext) {
                    return AlertDialog(
                      title: Text("Clear Recipes"),
                      content: Text("Are you sure you want to clear the recipes?"),
                      actions: <Widget>[
                        TextButton(
                          onPressed: () {
                            Navigator.pop(confirmationContext);
                              _recipeController.deleteAllRecipes();
                            Navigator.pop(context); 
                          },
                          child: Text("Yes"),
                        ),
                        TextButton(
                          onPressed: () {
                            Navigator.pop(confirmationContext);
                          },
                          child: Text("No"),
                        ),
                      ],
                    );
                  },
                );
              },
                child: Text(
                  'CLEAR RECIPES',
                  style: AppTypography.category.copyWith(color: AppColors.main1),
                ),
              ),
            ],
          ),
          actions: <Widget>[
            TextButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: Text(
                'CANCEL',
                style: TextStyle(
                  color: Colors.black54,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        );
      },
    );
  }


  _signOut() async {
    await _loginController.googleSignInUser.value?.signOut();
    Navigator.of(context, rootNavigator: true).pushAndRemoveUntil(
        MaterialPageRoute(builder: (context) => HomePage2()), (route) => false);
  }

  @override
  Widget build(BuildContext context) {
    return PreferredSize(
      preferredSize: widget.preferredSize,
      child: Container(
        height: MediaQuery.of(context).size.height * 0.2,
        padding: const EdgeInsets.only(left: 15, top: 0, bottom: 1, right: 15),
        decoration: BoxDecoration(
          image: DecorationImage(
            //image: AssetImage("assets/images/pantry_banner_2.jpg"),
            //image: AssetImage("assets/images/ue_banner_darker_3.png"),
            image: AssetImage(widget.backgroundImageName),
            fit: BoxFit.cover,
            alignment: Alignment.bottomCenter,
          ),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Container(
              width: MediaQuery.of(context).size.width * 0.64,
              child: Text(
                ' ${widget.title} ${'\u200e'}',
                style: AppTypography.whiteHeading2.copyWith(
                  backgroundColor: widget.titleBackgroundColor,
                ),
              ),
            ),
            const Spacer(),
            Column(
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                Row(
                  children: [
                    IconButton(
                      visualDensity: _topIconsDensity,
                      padding: EdgeInsets.zero,
                      onPressed: () => widget.helpFunction(),
                      icon: const Icon(
                        Icons.help_outline,
                        color: AppColors.main2,
                      ),
                    ),
                    IconButton(
                      visualDensity: _topIconsDensity,
                      padding: EdgeInsets.zero,
                      onPressed: () => _openSettings(context),
                      icon: const Icon(
                        Icons.settings,
                        color: AppColors.main2,
                      ),
                    ),
                    IconButton(
                      visualDensity: _topIconsDensity,
                      padding: EdgeInsets.zero,
                      onPressed: () => _openAccountSettings(context),
                      icon: const Icon(
                        Icons.account_circle,
                        color: AppColors.main2,
                      ),
                    ),
                  ],
                ),
                if (widget.addFunction != null)
                  Container(
                    height: 44,
                    width: 44,
                    child: FloatingActionButton(
                      onPressed: () => widget.addFunction!(),
                      backgroundColor: AppColors.main2,
                      child: Icon(
                        widget.addIcon,
                        color: AppColors.main1,
                      ),
                    ),
                  ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
