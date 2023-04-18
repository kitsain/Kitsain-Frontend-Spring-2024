import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:get/get.dart';
import 'package:kitsain_frontend_spring2023/database/pantry_proxy.dart';
import 'package:kitsain_frontend_spring2023/item_controller.dart';
import 'package:kitsain_frontend_spring2023/views/add_new_item_form.dart';
import 'package:kitsain_frontend_spring2023/views/add_new_shopping_list_item_form.dart';
import 'package:kitsain_frontend_spring2023/views/add_new_shopping_list_form.dart';
import 'package:kitsain_frontend_spring2023/views/main_menu_pages/history_ella.dart';
import 'package:kitsain_frontend_spring2023/views/main_menu_pages/shopping_list.dart';
import 'package:kitsain_frontend_spring2023/views/main_menu_pages/pantryview.dart';
import 'package:kitsain_frontend_spring2023/views/main_menu_pages/used_and_expired.dart';
import 'package:kitsain_frontend_spring2023/l10n/l10n.dart';
import 'package:flutter_gen/gen_l10n/app-localizations.dart';
import 'package:kitsain_frontend_spring2023/views/main_menu_pages/shopping_list_navigation.dart';
import 'package:realm/realm.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  //PantryProxy().deleteAll();
  runApp(const MaterialApp(home: MyApp()));
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Kitsain 2023 MVP',
      theme: ThemeData(
        primarySwatch: Colors.lightGreen,
      ),
      home: const HomePage(title: 'Kitsain MVP 2023'),
      supportedLocales: L10n.all,
      localizationsDelegates: [
        AppLocalizations.delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
      ],
    );
  }
}

class HomePage extends StatefulWidget {
  const HomePage({super.key, required this.title});

  final String title;

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final stateController = Get.put(ItemController());

  @override
  void initState() {
    // TODO: implement initState
    stateController.addData();
    super.initState();
  }

  int _navigationMenuIndex = 0;
  final _pages = [
    PantryView(),
    const ShoppingListNavigation(),
    const History(),
  ];

  void _navMenuItemSelected(int index) {
    setState(
      () {
        _navigationMenuIndex = index;
      },
    );
  }

  void _addNewItem() {
    if (_navigationMenuIndex == 0) {
      showModalBottomSheet(
        context: context,
        isScrollControlled: true,
        builder: (BuildContext context) {
          return const FractionallySizedBox(
            heightFactor: 0.7,
            child: NewItemForm(),
          );
        },
      );
    } else if (_navigationMenuIndex == 1) {
      showModalBottomSheet(
        context: context,
        isScrollControlled: true,
        builder: (BuildContext context) {
          return const FractionallySizedBox(
            heightFactor: 0.7,
            child: NewShoppingListForm(),
          );
        },
      );
    } else if (_navigationMenuIndex == 2) {
      showModalBottomSheet(
        context: context,
        isScrollControlled: true,
        builder: (BuildContext context) {
          return const FractionallySizedBox(
            heightFactor: 0.7,
            child: NewShoppingListItemForm(),
          );
        },
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Material(
      child: Scaffold(
        appBar: AppBar(
          title: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(widget.title),
              const Image(
                image: AssetImage('assets/images/Kitsain_logo.png'),
                width: 150,
                height: 150,
              )
            ],
          ),
          toolbarHeight: MediaQuery.of(context).size.height * 0.25,
        ),
        body: Center(
          child: _pages[_navigationMenuIndex],
        ),
        floatingActionButton: FloatingActionButton(
          onPressed: _addNewItem,
          tooltip: AppLocalizations.of(context)!.addNewItem,
          child: const Icon(Icons.add),
        ), // This trailing comma makes auto-formatting nicer for build methods.
        bottomNavigationBar: NavigationBar(
          selectedIndex: _navigationMenuIndex,
          onDestinationSelected: (index) => _navMenuItemSelected(index),
          destinations: [
            DragTarget(
              builder: (
                BuildContext context,
                List<dynamic> accepted,
                List<dynamic> rejected,
              ) {
                return NavigationDestination(
                    icon: const Icon(Icons.house),
                    label: AppLocalizations.of(context)!.pantryScreen);
              },
              onMove: (details) {
                _navigationMenuIndex = 0;
                _navMenuItemSelected(0);
              },
            ),
            DragTarget(
              builder: (
                BuildContext context,
                List<dynamic> accepted,
                List<dynamic> rejected,
              ) {
                return NavigationDestination(
                    icon: const Icon(Icons.shopping_cart),
                    label: AppLocalizations.of(context)!.shoppingListScreen);
              },
              onMove: (details) {
                _navigationMenuIndex = 1;
                _navMenuItemSelected(1);
              },
            ),
            DragTarget(
              builder: (
                BuildContext context,
                List<dynamic> accepted,
                List<dynamic> rejected,
              ) {
                return NavigationDestination(
                    icon: const Icon(Icons.recycling),
                    label: AppLocalizations.of(context)!.historyScreen);
              },
              onMove: (details) {
                _navigationMenuIndex = 2;
                _navMenuItemSelected(2);
              },
            ),
          ],
        ),
      ),
    );
  }
}
