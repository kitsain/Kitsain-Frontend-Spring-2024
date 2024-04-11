import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:flutter_gen/gen_l10n/app-localizations.dart';
import 'package:kitsain_frontend_spring2023/app_colors.dart';
import 'package:kitsain_frontend_spring2023/app_typography.dart';
import 'package:kitsain_frontend_spring2023/assets/top_bar.dart';
import 'package:kitsain_frontend_spring2023/views/help_pages/shopping_lists_help_page.dart';
import 'package:kitsain_frontend_spring2023/login_controller.dart';
import 'package:kitsain_frontend_spring2023/controller/task_controller.dart';
import 'package:kitsain_frontend_spring2023/controller/tasklist_controller.dart';
import 'package:kitsain_frontend_spring2023/views/main_menu_pages/user_shopping_list.dart';
import 'package:kitsain_frontend_spring2023/views/edit/edit_shopping_list.dart';
import 'package:kitsain_frontend_spring2023/views/add_forms/add_new_shopping_list_form.dart';
import 'package:kitsain_frontend_spring2023/database/item.dart';
import 'package:kitsain_frontend_spring2023/models/ShoppingListItemModel.dart';

class ShoppingLists extends StatefulWidget {
  const ShoppingLists({super.key, required this.setActiveShoppingListIndex});

  final Function setActiveShoppingListIndex;

  @override
  State<ShoppingLists> createState() => _ShoppingListsState();
}


class _ShoppingListsState extends State<ShoppingLists> {
  final taskListController = Get.put(TaskListController());

  final taskController = Get.put(TaskController());

  final loginController = Get.put(LoginController());
  var tskList;

  @override
  void initState() {
    super.initState();
    fetchTasks();
  }

  Future<void> fetchTasks() async {
    var taskListIndex = await findShopIndex();
    print("taskListIndex: $taskListIndex");
    tskList = await taskController.getTasksListStream(taskListIndex);
    print("Tasks: $tskList");
    setState(() {});
  }


  void _deleteListDialog(int index) {
    showDialog(
      context: context,
      builder: (BuildContext context) => AlertDialog(
        content: const Text(
          'Delete shopping list?',
          style: AppTypography.paragraph,
        ),
        actions: <Widget>[
          TextButton(
            child: Text(
              'CANCEL',
              style: AppTypography.category.copyWith(color: Colors.black38),
            ),
            onPressed: () {
              Navigator.pop(context);
            },
          ),
          TextButton(
            child: Text(
              'DELETE',
              style: AppTypography.category.copyWith(color: AppColors.main1),
            ),
            onPressed: () {
              taskListController.deleteTaskLists(
                  '${taskListController.taskLists.value?.items?[index].id}',
                  index);
              Navigator.pop(context);
            },
          ),
        ],
      ),
    );
  }

  void _editList(String listId, int listIndex) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (BuildContext context) {
        return FractionallySizedBox(
          heightFactor: 1,
          child: EditShoppingListForm(listId: listId, listIndex: listIndex),
        );
      },
    );
  }

  _receiveItem(int index, Item data) {
    String taskListId =
        '${taskListController.taskLists.value?.items?[index].id}';
    String title = data.name;
    String? details = data.details;

    taskController.createTask(title, details ?? '', taskListId);

    setState(
      () {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text("$title added"),
          duration: const Duration(seconds: 2),
        ));
      },
    );

    _openShoppingList(index);
  }

  _openShoppingList(index) async {
    await taskController.getTasksList(
        '${taskListController.taskLists.value?.items?[index].id}');

    Navigator.push(
        context,
        MaterialPageRoute(
            builder: ((context) => UserShoppingList(
                  taskListIndex: index,
                  taskListId:
                      '${taskListController.taskLists.value?.items?[index].id}',
                  taskListName:
                      '${taskListController.taskLists.value?.items?[index].title}',
                ))));
  }

  void _addNewItem() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (BuildContext context) {
        return const FractionallySizedBox(
          heightFactor: 1.0,
          child: NewShoppingListForm(),
        );
      },
    );
  }

  void _help() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (BuildContext context) {
        return const FractionallySizedBox(
          child: ShoppingListsHelp(),
        );
      },
    );
  }
  Future findShopIndex() async {
    await taskListController.getTaskLists();
    var shopIndex = "not";
    if (taskListController.taskLists.value?.items != null) {
      int length = taskListController.taskLists.value?.items!.length as int;
      for (var i = 0; i < length; i++) {
        print("$i: ${taskListController.taskLists.value?.items?[i].title}");
        if (taskListController.taskLists.value?.items?[i].title ==
            "Shopping lists") {
          shopIndex =
              taskListController.taskLists.value?.items?[i].id as String;
          break;
        }
      }
    }
    return shopIndex;
  }

  


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.main2,
      appBar: TopBar(
        title: AppLocalizations.of(context)!.shoppingListsScreenTopBarTitle,
        addFunction: _addNewItem,
        addIcon: Icons.post_add,
        helpFunction: _help,
        backgroundImageName: 'assets/images/aisle-3105629_1280_B1.jpg',
        titleBackgroundColor: AppColors.titleBackgroundBrown,
      ),
      body: RefreshIndicator(onRefresh: () async {
        print("testingrefresh");
      },
       child: SingleChildScrollView(
        child: StreamBuilder<List<ShoppingListItemModel>>(
            stream: taskController.tasksStream,
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator());
              } else if (snapshot.hasError) {
                return Text('Error: ${snapshot.error}');
              } else {  
                final tasks = snapshot.data ?? [];
                return ListView.builder(
                  shrinkWrap: true,
                  scrollDirection: Axis.vertical,
                  itemCount: tasks.length,
                  physics: const NeverScrollableScrollPhysics(),
                  padding: const EdgeInsets.all(15),
                  itemBuilder: (context, index) {
                    final task = tasks[index];
                    return Column(
                      children: [
                        DragTarget<Item>(
                          onAcceptWithDetails: (data) => _receiveItem(index, data as Item),
                          builder: (context, candidateData, rejectedData) {
                            return Card(
                              elevation: 2,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(5),
                                side: BorderSide(
                                  width: candidateData.isNotEmpty ? 4 : 1,
                                  color: candidateData.isNotEmpty
                                      ? AppColors.main1
                                      : Colors.black38,
                                ),
                              ),
                              child: Padding(
                                padding: const EdgeInsets.only(
                                    left: 5, right: 0, top: 5, bottom: 5),
                                child: ListTile(
                                  title: Row(
                                    children: [
                                      Text(
                                        '${task.title}',
                                        style:
                                            const TextStyle(fontWeight: FontWeight.bold),
                                      ),
                                      const Spacer(),
                                      IconButton(
                                        onPressed: () {
                                          _deleteListDialog(index);
                                        },
                                        icon: const Icon(
                                          Icons.delete,
                                          color: AppColors.main1,
                                        ),
                                      ),
                                      IconButton(
                                        onPressed: () => _editList(
                                            '${task.id}',
                                            index),
                                        icon: const Icon(
                                          Icons.edit,
                                          color: AppColors.main1,
                                        ),
                                      ),
                                    ],
                                  ),
                                  onTap: () => _openShoppingList(index),
                                ),
                              ),
                            );
                          },
                        ),
                        const SizedBox(height: 5),
                      ],
                    );
                  },
                );
              }
            },
          ),
      ),
    ));
  }
}
