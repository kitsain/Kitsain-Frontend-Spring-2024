import 'package:flutter_test/flutter_test.dart';
import 'package:kitsain_frontend_spring2023/assets/pantry_builder_recipe_generation.dart';
import 'package:kitsain_frontend_spring2023/database/item.dart';
import 'package:mockito/mockito.dart';
import 'package:realm/realm.dart';
import 'package:integration_test/integration_test.dart';
import 'package:flutter/material.dart';

/// Function to run all integration tests to test the pantry_builder_recipe_generation.dart file
/// Tests different interactions when generating the recipe
/// [mockRealmResults] (Acts as items from Realm database)
/// [mockItems] (ingredients used in [mockRealmResults])
/// [thisMustHaveItems] (must have items used in the pantryBuilderWidget, includes items that are required to be in the recipe)
/// [thisOptionalItems] (optional items used in the pantryBuilderWidget, includes items that could be used in the recipe)
/// [widget] (Pantry builder widget that is tested)
void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();
  late MockRealmResults<Item> mockRealmResults;
  late List<Item> mockItems;
  late List thisMustHaveItems;
  late List thisOptionalItems;
  late Widget widget;

  group('end-to-end test', () {
    /// Setups the variables used in testing
    setUp(() {
      mockItems = <Item>[
        Item(ObjectId().toString(), "Apple", "Pantry", 3),
        Item(ObjectId().toString(), "Banana", "Pantry", 3)
      ];
      mockRealmResults = MockRealmResults<Item>(mockItems);
      // Must have items in the pantryBuilder widget
      thisMustHaveItems = <String>[];
      thisOptionalItems = <String>[];
      // Load app widget with the mocked RealmResults
      widget = PantryBuilderTestWrapper(
        sortMethod: "az",
        items: mockRealmResults,
        onMustHaveItemsChanged: (mustHaveItems) {
          thisMustHaveItems = mustHaveItems;
        },
        onOptionalItemsChanged: (optionalItems) {
          thisOptionalItems = optionalItems;
        },
      );
    });

    testWidgets(
        'When adding pantry items to the ingredient list for recipe they are put into the optional items list at first',
        (tester) async {
      await tester.pumpWidget(widget);
      await tester.pumpAndSettle(); // Wait for animations to complete

      expect(find.text(mockItems[0].name),
          findsOneWidget); // Finds a widget which has a "Text" field "Apple"

      await tester.tap(find.text(
          mockItems[0].name)); // Tap on the first item on rest on the list
      await tester.pumpAndSettle(); // Wait for animations to complete

      // Verify that the item is moved to the appropriate list
      expect(thisMustHaveItems.contains('${mockItems[0].name};'), false);
      expect(thisOptionalItems.contains('${mockItems[0].name};'), true);
    });

    testWidgets(
        """When adding a new ingredient to the recipe by typing it to the text box by must have items
    it is added to the must have items, when pressing it again it is moved to the optional items list""",
        (tester) async {
      await tester.pumpWidget(widget);
      await tester.pumpAndSettle(); // Wait for animations to complete
      // Find the TextField widget by its type
      final textFieldFinder = find.byType(TextField).first;
      // Verify that the TextField widget is found
      expect(textFieldFinder, findsOneWidget);
      // Enter a grape ingredient to mustHaveItems item card
      await tester.enterText(textFieldFinder, "grape");
      await tester.pumpAndSettle(); // Wait for animations to complete
      await tester.testTextInput.receiveAction(TextInputAction.done);
      // Check if now the grape is in a right list (thisMustHaveItems)
      expect(thisMustHaveItems.contains("grape;"), true);
      expect(thisOptionalItems.contains("grape;"), false);
      await tester.pumpAndSettle();
      // Tap the ingredient and see if it switches lists correctly
      await tester.tap(find.text("grape"));
      expect(thisMustHaveItems.contains("grape;"), false);
      expect(thisOptionalItems.contains("grape;"), true);
    });

    testWidgets("""When pressing the select all button,
      every item from the pantry is selected into the recipe,
      Then when pressing the deselect button after they are deselected""",
        (tester) async {
      await tester.pumpWidget(widget);
      await tester.pumpAndSettle(); // Wait for animations to complete

      await tester.tap(find.text("Select all"));
      await tester.pumpAndSettle(); // Wait for animations to complete
      expect(thisOptionalItems.contains('${mockItems[0].name};'), true);
      expect(thisOptionalItems.contains('${mockItems[1].name};'), true);
      await tester.tap(find.text("Deselect all"));
      await tester.pumpAndSettle(); // Wait for animations to complete
      expect(thisOptionalItems.contains('${mockItems[0].name};'), false);
      expect(thisOptionalItems.contains('${mockItems[1].name};'), false);
    });
  });
}

class PantryBuilderTestWrapper extends StatelessWidget {
  final RealmResults<Item> items;
  final String sortMethod;
  final Function(List<String>) onOptionalItemsChanged;
  final Function(List<String>) onMustHaveItemsChanged;

  const PantryBuilderTestWrapper({
    super.key,
    required this.sortMethod,
    required this.items,
    required this.onOptionalItemsChanged,
    required this.onMustHaveItemsChanged,
  });

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: PantryBuilder(
        items: items,
        sortMethod: sortMethod,
        onMustHaveItemsChanged: onMustHaveItemsChanged,
        onOptionalItemsChanged: onOptionalItemsChanged,
      ),
    );
  }
}

class MockRealmResults<T> extends Mock implements RealmResults<T> {
  List<T> items;

  MockRealmResults(this.items);

  @override
  int get length => items.length;

  @override
  Iterator<T> get iterator => items.iterator;

  @override
  T operator [](int index) {
    if (index >= 0 && index < items.length) {
      return items[index];
    }
    throw Exception('Index out of range: $index');
  }
}
