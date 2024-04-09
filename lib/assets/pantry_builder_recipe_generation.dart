import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:kitsain_frontend_spring2023/database/item.dart';
import 'package:realm/realm.dart';
import 'package:kitsain_frontend_spring2023/app_typography.dart';

/// Class for creating a new temporary ingredient
class NewItem {
  String name;
  NewItem(this.name);
}

/// Class for handling the logic for pantry items selecting
class PantryBuilderLogic extends State<PantryBuilder> {
  /// Builds the widget tree for the UI
  @override
  Widget build(BuildContext context) => PantryBuilderWidgets(this);

  /// Initializes selectedItems list
  @override
  void initState() {
    super.initState();
    isSelectedAll = List.generate(widget.items.length, (index) {
      return {
        'item': widget.items[index],
        'isSelected': false,
      };
    });
  }

  late int expirationTimeInDays = 4;
  late List<Map<String, dynamic>> isSelectedAll;
  late List expiringItems = getExpiringItems();
  late List notExpiringItems = getNotExpiringItems();
  late DateFormat formatter = DateFormat('yyyy-dd-MM');
  late List mustHaveItems = [];
  late List optionalItems = [];
  late List<String> optionalItemsNames = [];
  late List<String> mustHaveItemsNames = [];

  /// Gets the names of optional items
  ///
  /// Returns the names of optional items
  List<String> getOptionalItemsNames() {
    optionalItemsNames = [];
    for (var item in optionalItems) {
      if (item is NewItem) {
        optionalItemsNames.add('${item.name};');
      } else {
        optionalItemsNames.add(item.name + ';' + item.amount ?? '');
      }
    }
    return optionalItemsNames;
  }

  /// Gets the names of must have items
  ///
  /// Returns the names of must have items
  List<String> getMustHaveItemsNames() {
    mustHaveItemsNames = [];
    for (var item in mustHaveItems) {
      if (item is NewItem) {
        mustHaveItemsNames.add('${item.name};');
      } else {
        mustHaveItemsNames.add(item.name + ';' + item.amount);
      }
    }

    return mustHaveItemsNames;
  }

  /// Gets a part of the list items (all items in pantry),
  /// only the items that are expiring in less than 4 days are added to this list
  ///
  /// Returns the list with expiring items
  List getExpiringItems() {
    final DateTime currentDate = DateTime.now();
    final expiringItems = [];

    for (var item in widget.items) {
      if (item.expiryDate == null) {
        continue;
      }

      if (item.expiryDate!.difference(currentDate).inDays <
          expirationTimeInDays) {
        expiringItems.add(item);
      }
    }
    return expiringItems;
  }

  /// Gets a part of the list items (all items in pantry),
  /// only the items that are NOT expiring in less than 4 days are added to this list
  ///
  /// Returns the list with items that are NOT expiring
  List getNotExpiringItems() {
    final DateTime currentDate = DateTime.now();
    final notExpiringItems = [];

    for (var item in widget.items) {
      if (item.expiryDate == null) {
        notExpiringItems.add(item);
        continue;
      }

      if (item.expiryDate!.difference(currentDate).inDays >=
          expirationTimeInDays) {
        notExpiringItems.add(item);
      }
    }
    return notExpiringItems;
  }

  /// Selects and deselects all items to be added into the optional items list,
  /// if the param [select] is true all the items are selected, if false they are deselected
  void toggleSelectAll(bool select) {
    setState(() {
      for (var item in isSelectedAll) {
        item['isSelected'] = select;
      }
      for (var item in isSelectedAll) {
        if (item['isSelected'] &&
            !optionalItems.contains(item['item']) &&
            !mustHaveItems.contains(item['item'])) {
          optionalItems.add(item['item']);
        } else if (!item['isSelected']) {
          if (optionalItems.contains(item['item'])) {
            optionalItems.remove(item['item']);
          }
          if (mustHaveItems.contains(item['item'])) {
            mustHaveItems.remove(item['item']);
          }
        }
      }
      widget.onOptionalItemsChanged(getOptionalItemsNames());
      widget.onMustHaveItemsChanged(getMustHaveItemsNames());
    });
    setState(() {
      for (var item in isSelectedAll) {
        item['isSelected'] = select;
      }
      for (var item in isSelectedAll) {
        if (item['isSelected'] &&
            !optionalItems.contains(item['item']) &&
            !mustHaveItems.contains(item['item'])) {
          optionalItems.add(item['item']);
        } else if (!item['isSelected']) {
          if (optionalItems.contains(item['item'])) {
            optionalItems.remove(item['item']);
          }
          if (mustHaveItems.contains(item['item'])) {
            mustHaveItems.remove(item['item']);
          }
        }
      }
      widget.onOptionalItemsChanged(getOptionalItemsNames());
      widget.onMustHaveItemsChanged(getMustHaveItemsNames());
    });
  }

  /// Toggles whether the ingredient is selected into the recipe
  ///
  /// Takes the ingredient [item] which can either be an Item class object from the pantry,
  /// or a temporary NewItem class object
  void toggleItemSelection(item) {
    setState(() {
      int indexToUpdate =
          isSelectedAll.indexWhere((element) => element['item'] == item);
      // If the item is found in the pantry items
      if (indexToUpdate != -1) {
        isSelectedAll[indexToUpdate]['isSelected'] =
            !isSelectedAll[indexToUpdate]['isSelected'];
      }
      // Else remove it from the two lists and leave the function
      else {
        removeFromList(item, optionalItems);
        removeFromList(item, mustHaveItems);
        return;
      }
      if (isSelectedAll[indexToUpdate]['isSelected']) {
        optionalItems.add(item);
      } else {
        // Find the index of the item to remove
        int indexToRemove =
            optionalItems.indexWhere((element) => element == item);
        if (indexToRemove != -1) {
          optionalItems.removeAt(indexToRemove);
        }
        indexToRemove = mustHaveItems.indexWhere((element) => element == item);
        if (indexToRemove != -1) {
          mustHaveItems.removeAt(indexToRemove);
        }
      }
      widget.onOptionalItemsChanged(getOptionalItemsNames());
      widget.onMustHaveItemsChanged(getMustHaveItemsNames());
    });
  }

  /// Gets the color for the highlightation
  ///
  /// Checks whether the [item] (ingredient) is selected,
  /// if it's selected the color is green ish, if not the color is same as background
  /// Returns the color
  getColor(item) {
    int index = isSelectedAll.indexWhere((element) => element['item'] == item);
    var color = isSelectedAll[index]['isSelected']
        ? const Color.fromARGB(255, 78, 117, 88)
        : null;
    return color;
  }

  /// Switches an [item] (ingredient) from [fromList] to [toList]
  void switchList(item, List fromList, List toList) {
    setState(() {
      fromList.remove(item);
      toList.add(item);
      widget.onOptionalItemsChanged(getOptionalItemsNames());
      widget.onMustHaveItemsChanged(getMustHaveItemsNames());
    });
  }

  /// Removes an [item] (ingredient) from [list]
  void removeFromList(item, List list) {
    setState(() {
      list.remove(item);
      widget.onOptionalItemsChanged(getOptionalItemsNames());
      widget.onMustHaveItemsChanged(getMustHaveItemsNames());
    });
  }

  /// Adds an [item] to [list]
  void addItemToList(item, List list) {
    setState(() {
      list.add(item);
      widget.onOptionalItemsChanged(getOptionalItemsNames());
      widget.onMustHaveItemsChanged(getMustHaveItemsNames());
    });
  }
}

/// Builds the choosing of ingredients part of the UI
class PantryBuilder extends StatefulWidget {
  final RealmResults<Item> items;
  const PantryBuilder({
    super.key,
    Key? widgetKey,
    required this.sortMethod,
    required this.items,
    required this.onOptionalItemsChanged,
    required this.onMustHaveItemsChanged,
  });
  final String sortMethod;
  final Function(List<String>) onOptionalItemsChanged;
  final Function(List<String>) onMustHaveItemsChanged;

  @override
  PantryBuilderLogic createState() => PantryBuilderLogic();
}

/// Builds the widget tree for the UI
class PantryBuilderWidgets extends StatelessWidget {
  final PantryBuilderLogic state;
  get widget => state.widget;

  /// Gets the state and logic handler class as an argument
  const PantryBuilderWidgets(this.state, {super.key});

  /// Builds the UI element for select and deselect buttons
  Widget buildSelectButtons() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        ElevatedButton(
          onPressed: () => state.toggleSelectAll(true),
          child: const Text('Select all'),
        ),
        ElevatedButton(
          onPressed: () => state.toggleSelectAll(false),
          child: const Text('Deselect all'),
        ),
      ],
    );
  }

  Widget buildInstruction() {
    return const Column(
      children: [
        SizedBox(height: 20),
        Text('Tap items to switch between lists',
            style: AppTypography.heading5),
        SizedBox(height: 5),
      ], // children
    );
  }

  /// Builds the UI element for list of [expiringItems]
  Widget buildExpiringIngredients() {
    return Column(
      children: [
        const Text("Expiring ingredients", style: AppTypography.heading4),
        const SizedBox(height: 5),
        Padding(
          padding: const EdgeInsets.only(
            left: 8.0,
            right: 8.0,
            top: 16.0,
            bottom: 16.0,
          ),
          child: Align(
            alignment: Alignment.center,
            child: Wrap(
              direction: Axis.horizontal,
              spacing: 1.0,
              runSpacing: 8.0,
              children: List.generate(
                state.expiringItems.length,
                (index) => GestureDetector(
                  onTap: () =>
                      state.toggleItemSelection(state.expiringItems[index]),
                  child: Container(
                    padding: const EdgeInsets.all(8.0),
                    decoration: BoxDecoration(
                      color: state.getColor(state.expiringItems[index]),
                      borderRadius: BorderRadius.circular(8.0),
                    ),
                    child: Text(
                      (state.expiringItems[index].name +
                          " " +
                          state.formatter.format(state
                              .expiringItems[index].expiryDate!
                              .toLocal())),
                      style: AppTypography.heading5,
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }

  /// Builds the UI element for list of [notExpiringItems]
  Widget buildRestOfIngredients() {
    return Column(
      children: [
        const SizedBox(height: 30),
        const Text("Rest of the ingredients", style: AppTypography.heading4),
        const SizedBox(height: 1),
        Padding(
          padding: const EdgeInsets.only(
            left: 8.0,
            right: 8.0,
            top: 16.0,
            bottom: 30.0,
          ),
          child: Align(
            alignment: Alignment.center,
            child: Wrap(
              direction: Axis.horizontal,
              spacing: 1.0,
              runSpacing: 8.0,
              children: List.generate(
                state.notExpiringItems.length,
                (index) => GestureDetector(
                  onTap: () =>
                      state.toggleItemSelection(state.notExpiringItems[index]),
                  child: Container(
                    padding: const EdgeInsets.all(8.0),
                    decoration: BoxDecoration(
                      color: state.getColor(state.notExpiringItems[index]),
                      borderRadius: BorderRadius.circular(8.0),
                    ),
                    child: Text(
                      state.notExpiringItems[index].name,
                      style: AppTypography.heading5,
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }

  /// Builds the UI element for [optionalItems] and [mustHaveItems]
  Widget buildSelectedItemLists() {
    /// Row for the two lists to be shown next to eachother
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        /// Must have items element
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center, // Center the text
            children: [
              const SizedBox(height: 30),
              const Text('Must Have Items', // Title for the first list
                  style: AppTypography.heading4),
              SizedBox(
                  height: 200, // Adjust this value as needed
                  child: Scrollbar(
                    child: ListView.builder(
                      itemCount: state.mustHaveItems.length +
                          1, // Add 1 for the extra card
                      itemBuilder: (context, index) {
                        if (index == state.mustHaveItems.length) {
                          // Render the extra card for adding new items
                          return Card(
                            child: ListTile(
                              title: TextField(
                                onSubmitted: (value) {
                                  state.addItemToList(
                                      NewItem(value), state.mustHaveItems);
                                },
                                decoration: const InputDecoration(
                                  hintText: 'Enter item',
                                  border: InputBorder.none,
                                ),
                              ),
                            ),
                          );
                        } else {
                          // Render the existing items
                          return Card(
                            child: ListTile(
                              title: Row(
                                children: [
                                  Text(state.mustHaveItems[index].name),
                                  const Spacer(),
                                  GestureDetector(
                                    onTap: () {
                                      state.toggleItemSelection(
                                          state.mustHaveItems[index]);
                                    },
                                    child: const Icon(Icons.close),
                                  ),
                                ],
                              ),
                              onTap: () {
                                state.switchList(state.mustHaveItems[index],
                                    state.mustHaveItems, state.optionalItems);
                              },
                            ),
                          );
                        }
                      },
                    ),
                  )),
            ],
          ),
        ),

        /// Optional items element
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const SizedBox(height: 30),
              const Text('Optional Items', // Title for the second list
                  style: AppTypography.heading4),
              SizedBox(
                  height: 200, // Adjust this value as needed
                  child: Scrollbar(
                    child: ListView.builder(
                      itemCount: state.optionalItems.length +
                          1, // Add 1 for the extra card
                      itemBuilder: (context, index) {
                        if (index == state.optionalItems.length) {
                          // Render the extra card for adding new items
                          return Card(
                            child: ListTile(
                              title: TextField(
                                onSubmitted: (value) {
                                  state.addItemToList(
                                      NewItem(value), state.optionalItems);
                                },
                                decoration: const InputDecoration(
                                  hintText: 'Enter item',
                                  border: InputBorder.none,
                                ),
                              ),
                            ),
                          );
                        } else {
                          // Render the existing items
                          return Card(
                            child: ListTile(
                              title: Row(
                                children: [
                                  Text(state.optionalItems[index].name),
                                  const Spacer(),
                                  GestureDetector(
                                    onTap: () {
                                      state.toggleItemSelection(
                                          state.optionalItems[index]);
                                    },
                                    child: const Icon(Icons.close),
                                  ),
                                ],
                              ),
                              onTap: () {
                                state.switchList(state.optionalItems[index],
                                    state.optionalItems, state.mustHaveItems);
                              },
                            ),
                          );
                        }
                      },
                    ),
                  )),
            ],
          ),
        ),
      ],
    );
  }

  /// Builds all of the UI elements together to form this part of the page
  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Column(
        children: [
          buildExpiringIngredients(),
          buildRestOfIngredients(),
          buildSelectButtons(),
          buildInstruction(),
          buildSelectedItemLists(),
        ],
      ),
    );
  }
}
