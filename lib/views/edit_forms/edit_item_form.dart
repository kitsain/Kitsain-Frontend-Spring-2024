import 'package:flutter/material.dart';
import 'package:kitsain_frontend_spring2023/app_colors.dart';
import 'package:kitsain_frontend_spring2023/app_typography.dart';
import 'package:kitsain_frontend_spring2023/database/item.dart';
import 'package:kitsain_frontend_spring2023/database/openfoodfacts.dart';
import 'package:kitsain_frontend_spring2023/controller/pantry_controller.dart';

const List<String> categories = <String>[
  'No category',
  'Meat',
  'Seafood',
  'Fruit',
  'Vegetables',
  'Frozen',
  'Drinks',
  'Bread',
  'Sweets',
  'Dairy',
  'Ready meals',
  'Dry & canned goods',
  'Other'
];

Map catEnglish = {
  0: 'No category',
  1: 'Meat',
  2: 'Seafood',
  3: 'Fruit',
  4: 'Vegetables',
  5: 'Frozen',
  6: 'Drinks',
  7: 'Bread',
  8: 'Treats',
  9: 'Dairy', 
  10: 'Ready meals',
  11: 'Dry & canned goods',
  12: 'Other'
};

// ignore: must_be_immutable
class EditItemForm extends StatefulWidget {
  EditItemForm({super.key, required this.item});

  late Item item;

  @override
  // ignore: library_private_types_in_public_api
  _EditItemFormState createState() => _EditItemFormState();
}

@override
class _EditItemFormState extends State<EditItemForm> {
  final _formKey = GlobalKey<FormState>();
  final _EANCodeField = TextEditingController();
  final _itemName = TextEditingController();
  final _itemAmount = TextEditingController();
  final _pantryController = PantryController();

  // These dates control the date string user sees in the form
  final _expDateString = TextEditingController();
  final _openDateString = TextEditingController();

  // These values are actually saved to the db as DateTime
  var _openDateDT;
  var _expDateDT;
  var _googleTaskId;

  bool _favorite = false;
  String _category = 'No category';
  var _catInt = 0;
  var _hasExpiryDate;
  final _details = TextEditingController();

  var _offData;
  final UnfocusDisposition _disposition = UnfocusDisposition.scope;

  bool _noEditsWereMade() {
    bool noEditsOnBarcode = _EANCodeField.text == widget.item.barcode ||
        (_EANCodeField.text == "" && widget.item.barcode == null);

    return noEditsOnBarcode &&
        _itemName.text == widget.item.name &&
        _details.text == widget.item.details &&
        _expDateDT == widget.item.expiryDate &&
        _openDateDT == widget.item.openedDate &&
        _catInt == widget.item.mainCat &&
        _googleTaskId == widget.item.googleTaskId;
  }

  void _discardChangesDialog(bool discardForm) {
    if (discardForm ||
        _noEditsWereMade() ||
        (_itemName.text.isEmpty &&
            _EANCodeField.text.isEmpty &&
            _openDateString.text.isEmpty &&
            _expDateString.text.isEmpty)) {
      Navigator.pop(context);
    } else {
      showDialog(
        context: context,
        builder: (BuildContext context) => AlertDialog(
          content: const Text(
            'Discard changes?',
            style: AppTypography.paragraph,
          ),
          actions: <Widget>[
            TextButton(
              style: ButtonStyle(
                foregroundColor: MaterialStateProperty.resolveWith(
                    (states) => AppColors.cancelGrey),
              ),
              child: const Text(
                'CANCEL',
                style: AppTypography.category,
              ),
              onPressed: () {
                Navigator.pop(context);
              },
            ),
            TextButton(
              style: ButtonStyle(
                foregroundColor: MaterialStateProperty.resolveWith(
                    (states) => AppColors.main1),
              ),
              child: const Text(
                'DISCARD',
                style: AppTypography.category,
              ),
              onPressed: () {
                Navigator.pop(context);
                _discardChangesDialog(true);
              },
            ),
          ],
        ),
      );
    }
  }

  // Prepopulating form fields with item data
  @override
  void initState() {
    super.initState();

    // Mandatory fields
    _itemName.text = widget.item.name;
    _category = catEnglish[widget.item.mainCat];
    _favorite = widget.item.favorite;
    _catInt = widget.item.mainCat;
    _googleTaskId = widget.item.googleTaskId;

    // Optional fields
    if (widget.item.barcode != null) {
      _EANCodeField.text = widget.item.barcode!;
    }

    if (widget.item.amount != null) {
      _itemAmount.text = widget.item.amount!;
    }

    if (widget.item.openedDate != null) {
      _openDateDT = widget.item.openedDate!;
      String openedDate =
          "${_openDateDT.day}.${_openDateDT.month}.${_openDateDT.year}";
      _openDateString.text = openedDate;
    }

    if (widget.item.expiryDate != null) {
      _expDateDT = widget.item.expiryDate!.toLocal();
      String expirationDate =
          "${_expDateDT.day}.${_expDateDT.month}.${_expDateDT.year}";
      _expDateDT = widget.item.expiryDate!.toLocal();
      _expDateString.text = expirationDate;
    }

    if (widget.item.details != null) {
      _details.text = widget.item.details!;
    }

    _hasExpiryDate = widget.item.hasExpiryDate;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.main2,
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(8),
          children: <Widget>[
            SizedBox(height: MediaQuery.of(context).size.height * 0.05),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                SizedBox(
                  height: MediaQuery.of(context).size.height * 0.04,
                  child: FloatingActionButton(
                    foregroundColor: AppColors.main2,
                    backgroundColor: AppColors.main3,
                    child: const Icon(Icons.close),
                    onPressed: () => _discardChangesDialog(false),
                  ),
                )
              ],
            ),
            SizedBox(height: MediaQuery.of(context).size.height * 0.01),
            Text(
              'EDIT ITEM',
              textAlign: TextAlign.center,
              style: AppTypography.heading2.copyWith(color: AppColors.main3),
            ),
            SizedBox(height: MediaQuery.of(context).size.height * 0.05),
            Padding(
              padding: const EdgeInsets.only(left: 7, right: 7),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  TextFormField(
                    style: AppTypography.paragraph,
                    controller: _EANCodeField,
                    decoration: InputDecoration(
                      filled: true,
                      fillColor: Colors.white,
                      border: const OutlineInputBorder(),
                      labelText: 'EAN CODE',
                      suffixIcon: SizedBox(
                        width: 80,
                        height: 60,
                        child: ElevatedButton(
                          style: ButtonStyle(
                              foregroundColor:
                                  MaterialStateProperty.resolveWith(
                                      (states) => AppColors.main2),
                              backgroundColor:
                                  MaterialStateProperty.resolveWith(
                                      (states) => AppColors.main3),
                              shape: const MaterialStatePropertyAll<
                                      RoundedRectangleBorder>(
                                  RoundedRectangleBorder(
                                      borderRadius:
                                          BorderRadiusDirectional.only(
                                              topEnd: Radius.circular(5),
                                              bottomEnd: Radius.circular(5))))),
                          onPressed: () async {
                            if (_EANCodeField.text.isNotEmpty) {
                              ScaffoldMessenger.of(context)
                                  .showSnackBar(const SnackBar(
                                content: Text('Fetching item data...'),
                                duration: Duration(seconds: 2),
                              ));
                              try {
                                primaryFocus!
                                    .unfocus(disposition: _disposition);
                                _offData =
                                    await getFromJson(_EANCodeField.text);
                                _itemName.text =
                                    _offData.productName.toString();
                              } catch (e) {
                                ScaffoldMessenger.of(context)
                                    .hideCurrentSnackBar();
                                ScaffoldMessenger.of(context)
                                    .showSnackBar(const SnackBar(
                                  content:
                                      Text('Item not found. Input manually.'),
                                  duration: Duration(seconds: 2),
                                ));
                              }
                              if (_itemName.text.isNotEmpty) {
                                ScaffoldMessenger.of(context)
                                    .hideCurrentSnackBar();
                                ScaffoldMessenger.of(context)
                                    .showSnackBar(const SnackBar(
                                  content: Text('Item found!'),
                                  duration: Duration(seconds: 2),
                                ));
                              }
                            } else {
                              showDialog(
                                context: context,
                                builder: (BuildContext context) => SizedBox(
                                  width: 10,
                                  height: 10,
                                  child: AlertDialog(
                                    content: const Text(
                                      'Please input EAN-code',
                                      style: AppTypography.paragraph,
                                    ),
                                    actions: <Widget>[
                                      TextButton(
                                        child: Text(
                                          'OK',
                                          style: AppTypography.category
                                              .copyWith(color: AppColors.main1),
                                        ),
                                        onPressed: () {
                                          Navigator.pop(context);
                                        },
                                      ),
                                    ],
                                  ),
                                ),
                              );
                            }
                          },
                          child: const Text(
                            'FETCH\n ITEM',
                            style: AppTypography.smallTitle,
                          ),
                        ),
                      ),
                    ),
                  ),
                  SizedBox(height: MediaQuery.of(context).size.height * 0.03),
                  Stack(children: [
                    TextFormField(
                      style: AppTypography.paragraph,
                      controller: _itemName,
                      maxLength: 60,
                      decoration: const InputDecoration(
                        filled: true,
                        fillColor: Colors.white,
                        border: OutlineInputBorder(),
                        labelText: 'ITEM NAME',
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return "Please enter item name";
                        }
                        return null;
                      },
                    ),
                    const Positioned(
                        right: 27,
                        top: 15,
                        child: Icon(
                          Icons.keyboard_alt_outlined,
                          color: AppColors.main3,
                        ))
                  ]),
                  SizedBox(height: MediaQuery.of(context).size.height * 0.03),
                  Stack(children: [
                    TextFormField(
                      style: AppTypography.paragraph,
                      controller: _itemAmount,
                      maxLength: 10,
                      decoration: const InputDecoration(
                        filled: true,
                        fillColor: Colors.white,
                        border: OutlineInputBorder(),
                        labelText: 'AMOUNT / QUANTITY',
                      ),
                    ),
                    const Positioned(
                        right: 27,
                        top: 15,
                        child: Icon(
                          Icons.keyboard_alt_outlined,
                          color: AppColors.main3,
                        ))
                  ]),
                  SizedBox(height: MediaQuery.of(context).size.height * 0.03),
                  Container(
                    decoration: BoxDecoration(
                      color: Colors.white,
                      border: Border.all(color: Colors.grey),
                      borderRadius: BorderRadius.circular(5),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: DropdownButtonFormField<String>(
                        style: AppTypography.smallTitle
                            .copyWith(color: Colors.black),
                        menuMaxHeight: 200,
                        value: _category,
                        icon: const Icon(Icons.arrow_drop_down),
                        decoration:
                            const InputDecoration.collapsed(hintText: ''),
                        onChanged: (String? value) {
                          setState(
                            () {
                              _category = value!;
                              _catInt = catEnglish.keys.firstWhere(
                                      (k) => categories[k] == value);
                            },
                          );
                        },
                        items: categories.map<DropdownMenuItem<String>>(
                          (String value) {
                            return DropdownMenuItem<String>(
                              value: value,
                              child: Text(value),
                            );
                          },
                        ).toList(),
                      ),
                    ),
                  ),
                  SizedBox(height: MediaQuery.of(context).size.height * 0.04),
                  SizedBox(
                    child: TextButton.icon(
                      onPressed: () {
                        setState(() {
                          _favorite = !_favorite;
                        });
                      },
                      icon: Icon(
                        _favorite ? Icons.favorite : Icons.favorite_border,
                        color: Colors.black,
                      ),
                      label: Text(
                        'Mark as favorite',
                        style: AppTypography.paragraph
                            .copyWith(color: Colors.black),
                      ),
                    ),
                  ),
                  TextFormField(
                    style: AppTypography.smallTitle,
                    controller: _openDateString,
                    decoration: const InputDecoration(
                        icon: Icon(Icons.calendar_today),
                        labelText: "OPENING DATE"),
                    readOnly: true,
                    onTap: () async {
                      DateTime? pickedDate = await showDatePicker(
                        context: context,
                        initialDate: DateTime.now(),
                        firstDate: DateTime(2000),
                        lastDate: DateTime(2101),
                        builder: (context, child) {
                          return Theme(
                            data: Theme.of(context).copyWith(
                                colorScheme: const ColorScheme.light(
                                  primary: AppColors.main1,
                                  onPrimary: AppColors.main2,
                                  onSurface: AppColors.main3,
                                ),
                                textButtonTheme: TextButtonThemeData(
                                    style: TextButton.styleFrom(
                                  foregroundColor: Colors.black,
                                ))),
                            child: child!,
                          );
                        },
                      );
                      if (pickedDate != null) {
                        String openedDate =
                            "${pickedDate.day}.${pickedDate.month}.${pickedDate.year}";
                        _openDateString.text = openedDate;
                        _openDateDT = pickedDate;
                      } else {
                        _openDateString.text = "";
                      }
                    },
                  ),
                  TextFormField(
                    style: AppTypography.smallTitle,
                    controller: _expDateString,
                    decoration: const InputDecoration(
                        icon: Icon(Icons.calendar_today),
                        labelText: "EXPIRATION DATE"),
                    readOnly: true,
                    onTap: () async {
                      DateTime? pickedDate = await showDatePicker(
                        context: context,
                        initialDate: DateTime.now(),
                        firstDate: DateTime(2000),
                        lastDate: DateTime(2101),
                        builder: (context, child) {
                          return Theme(
                            data: Theme.of(context).copyWith(
                                colorScheme: const ColorScheme.light(
                                  primary: AppColors.main1,
                                  onPrimary: AppColors.main2,
                                  onSurface: AppColors.main3,
                                ),
                                textButtonTheme: TextButtonThemeData(
                                    style: TextButton.styleFrom(
                                  foregroundColor: Colors.black,
                                ))),
                            child: child!,
                          );
                        },
                      );
                      if (pickedDate != null) {
                        String expirationDate =
                            "${pickedDate.day}.${pickedDate.month}.${pickedDate.year}";
                        _expDateString.text = expirationDate;
                        _expDateDT = pickedDate.toLocal();
                        _hasExpiryDate = true;
                      } else {
                        _expDateString.text = "";
                        _expDateDT = null;
                        _hasExpiryDate = false;
                      }
                    },
                  ),
                  SizedBox(height: MediaQuery.of(context).size.height * 0.05),
                  TextFormField(
                    style: AppTypography.paragraph,
                    controller: _details,
                    decoration: const InputDecoration(
                      filled: true,
                      fillColor: Colors.white,
                      border: OutlineInputBorder(),
                      hintText: 'Details',
                    ),
                    maxLines: 5,
                  ),
                  SizedBox(height: MediaQuery.of(context).size.height * 0.05),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      SizedBox(
                        height: MediaQuery.of(context).size.height * 0.07,
                        width: MediaQuery.of(context).size.height * 0.15,
                        child: ElevatedButton(
                          style: ButtonStyle(
                            foregroundColor: MaterialStateProperty.resolveWith(
                                (states) => AppColors.main3),
                            backgroundColor: MaterialStateProperty.resolveWith(
                                (states) => Colors.white),
                            side: MaterialStateProperty.resolveWith((states) =>
                                const BorderSide(
                                    width: 3, color: AppColors.main3)),
                          ),
                          onPressed: () => _discardChangesDialog(false),
                          child: const Text(
                            'CANCEL',
                            style: AppTypography.category,
                          ),
                        ),
                      ),
                      SizedBox(width: MediaQuery.of(context).size.width * 0.05),
                      SizedBox(
                        height: MediaQuery.of(context).size.height * 0.07,
                        width: MediaQuery.of(context).size.height * 0.15,
                        child: ElevatedButton(
                          style: ButtonStyle(
                            foregroundColor: MaterialStateProperty.resolveWith(
                                (states) => Colors.white),
                            backgroundColor: MaterialStateProperty.resolveWith(
                                (states) => AppColors.main3),
                          ),
                          onPressed: () {
                            if (_formKey.currentState!.validate()) {
                              var addedDate = DateTime.now();
                              var item = Item(widget.item.id, _itemName.text,
                                  widget.item.location, _catInt,
                                  favorite: _favorite,
                                  openedDate: _openDateDT,
                                  addedDate: addedDate,
                                  expiryDate: _expDateDT,
                                  hasExpiryDate: _hasExpiryDate,
                                  details: _details.text,
                                  googleTaskId: _googleTaskId,
                                  amount: _itemAmount.text);

                              ///PantryProxy().upsertItem(item);
                              _pantryController.editItemTasks(item);
                              setState(() {});
                              Navigator.pop(context);
                            }
                          },
                          child: const Text(
                            ' DONE ',
                            style: AppTypography.category,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            )
          ],
        ),
      ),
    );
  }
}
