import 'package:realm/realm.dart';
import 'item.dart';

Realm realm = RealmSetup()._initializeRealm();

class RealmSetup {
  Realm _initializeRealm() {
    var config = Configuration.local([Item.schema, Recipe.schema],
        shouldDeleteIfMigrationNeeded: true);
    return Realm(config);
  }

  static Realm getRealm() {
    realm.write(() {
      realm.deleteAll<Item>();
    }); // use this if you want to delete all recipes from database
    return realm;
  }
}
