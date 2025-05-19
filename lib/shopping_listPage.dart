// ignore_for_file: use_build_context_synchronously, deprecated_member_use

import 'package:flutter/material.dart';
import 'package:flutter_application_1/category_page.dart';
import 'package:flutter_application_1/info_card.dart';
import 'package:flutter_application_1/infolist_page.dart';
import 'package:flutter_application_1/shoppingList.dart';
import 'package:flutter_application_1/shopping_item.dart';
import 'package:hive/hive.dart';
import 'package:hive_flutter/adapters.dart';
import 'package:overlay_support/overlay_support.dart';

class ShoppingListPage extends StatefulWidget {
  const ShoppingListPage({super.key});

  @override
  State<ShoppingListPage> createState() => _ShoppingListPageState();
}

class _ShoppingListPageState extends State<ShoppingListPage> {
  final Map<String, List<ShoppingItem>> categoryMap = {};
  late String listName;
  List<ShoppingList> lists = [];

  @override
  void initState() {
    super.initState();
    lists = Hive.box<ShoppingList>('shopping_lists').values.toList();
    loadAndUpdateLists();
  }

  List<ShoppingItem> todayItems = [];
  List<ShoppingItem> completedItems = [];
  List<ShoppingItem> scheduledItems = [];
  List<ShoppingItem> allItems = [];

  void updateMainLists(List<ShoppingList> allShoppingLists) {
    todayItems.clear();
    completedItems.clear();
    scheduledItems.clear();
    allItems.clear();

    for (var list in allShoppingLists) {
      for (var item in list.items) {
        allItems.add(item);

        if (item.isCompleted) {
          completedItems.add(item);
        }

        if (item.scheduledDate != null) {
          final now = DateTime.now();
          final scheduledDate = item.scheduledDate!;
          if (scheduledDate.year == now.year &&
              scheduledDate.month == now.month &&
              scheduledDate.day == now.day) {
            todayItems.add(item);
          } else {
            scheduledItems.add(item);
          }
        }
      }
    }
  }

  Future<void> loadAndUpdateLists() async {
    final box = Hive.box<ShoppingList>('shopping_lists');
    final allShoppingLists = box.values.toList();
    updateMainLists(allShoppingLists);
    setState(() {});
  }

  Future<bool> checkIfListNameExists(String listName) async {
    var box = Hive.box<ShoppingList>('shopping_lists');
    return box.values.any((list) => list.name == listName);
  }

  Future<void> _addCategory() async {
    var box = Hive.box<ShoppingList>('shopping_lists');
    showDialog(
      context: context,
      builder: (context) {
        final controller = TextEditingController();
        return AlertDialog(
          title: const Text(
            'Add List',
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
          content: TextField(
            controller: controller,
            decoration: InputDecoration(
              labelText: 'List Name',
              labelStyle: const TextStyle(color: Colors.deepPurple),
              focusedBorder: OutlineInputBorder(
                borderSide: const BorderSide(color: Colors.deepPurple),
                borderRadius: BorderRadius.circular(12),
              ),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel', style: TextStyle(color: Colors.grey)),
            ),
            ElevatedButton(
              onPressed: () async {
                listName = controller.text.trim();
                if (listName.isNotEmpty &&
                    !await checkIfListNameExists(listName)) {
                  final newList = ShoppingList(
                    name: controller.text,
                    items: [],
                  );
                  await box.add(newList);
                  loadAndUpdateLists();
                  Navigator.pop(context);
                  showSimpleNotification(
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(
                          colors: [Colors.deepPurple, Colors.deepPurpleAccent],
                        ),
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Row(
                        children: [
                          const Icon(Icons.check_circle, color: Colors.white),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              "List '${controller.text}' added!",
                              style: const TextStyle(color: Colors.white),
                            ),
                          ),
                        ],
                      ),
                    ),
                    background: Colors.transparent,
                    elevation: 0,
                  );
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text("List name already exists or is empty"),
                    ),
                  );
                }
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.deepPurple,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: const Text('Add', style: TextStyle(color: Colors.white)),
            ),
          ],
        );
      },
    );
  }

  Future<void> _updateCategory(String oldListName) async {
    final controller = TextEditingController(text: oldListName);
    final box = await Hive.openBox<ShoppingList>('shopping_lists');
    final listIndex = box.values.toList().indexWhere(
      (item) => item.name == oldListName,
    );

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text(
            'Update List',
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
          content: TextField(
            controller: controller,
            decoration: InputDecoration(
              labelText: 'List Name',
              labelStyle: const TextStyle(color: Colors.deepPurple),
              focusedBorder: OutlineInputBorder(
                borderSide: const BorderSide(color: Colors.deepPurple),
                borderRadius: BorderRadius.circular(12),
              ),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel', style: TextStyle(color: Colors.grey)),
            ),
            ElevatedButton(
              onPressed: () async {
                if (controller.text.isNotEmpty) {
                  if (!await checkIfListNameExists(controller.text)) {
                    final itemToUpdate = box.getAt(listIndex);
                    itemToUpdate?.name = controller.text;
                    await itemToUpdate?.save();
                    loadAndUpdateLists();
                    Navigator.pop(context);
                    showSimpleNotification(
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          gradient: const LinearGradient(
                            colors: [
                              Colors.deepPurple,
                              Colors.deepPurpleAccent,
                            ],
                          ),
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: const Row(
                          children: [
                            Icon(Icons.check_circle, color: Colors.white),
                            SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                "List updated successfully!",
                                style: TextStyle(color: Colors.white),
                              ),
                            ),
                          ],
                        ),
                      ),
                      background: Colors.transparent,
                      elevation: 0,
                    );
                  } else {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text("List name already exists")),
                    );
                  }
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text("List name cannot be empty")),
                  );
                }
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.deepPurple,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: const Text(
                'Update',
                style: TextStyle(color: Colors.white),
              ),
            ),
          ],
        );
      },
    );
  }

 Future<void> _openInfoPage(String title, List<ShoppingItem> items) async {
  final box = await Hive.openBox<ShoppingList>('shopping_lists');
  await Navigator.push(
    context,
    MaterialPageRoute(
      builder: (_) => InfoListPage(
        title: title,
        items: items,
        onItemToggle: (item, value) async {
          if (title == 'Completed') {
            final confirm = await showDialog<bool>(
              context: context,
              builder: (_) => AlertDialog(
                title: const Text('Delete Item'),
                content: Text('Delete "${item.name}" permanently?'),
                actions: [
                  TextButton(
                    onPressed: () => Navigator.pop(context, false),
                    child: const Text('No'),
                  ),
                  ElevatedButton(
                    onPressed: () => Navigator.pop(context, true),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.red,
                    ),
                    child: const Text('Yes'),
                  ),
                ],
              ),
            );
            if (confirm == true) {
              for (var list in box.values) {
                list.items.removeWhere((i) => i.name == item.name);
                await list.save();
                _openInfoPage('Completed', completedItems);
              }
              // Update the local state immediately
              setState(() {
                items.removeWhere((i) => i.name == item.name);
                completedItems.removeWhere((i) => i.name == item.name);
                allItems.removeWhere((i) => i.name == item.name);
              });
            }
          } else {
            if (value) {
              for (var list in box.values) {
                final itemToUpdate = list.items.firstWhere(
                  (i) => i.name == item.name,
                  orElse: () => item,
                );
                if (list.items.contains(itemToUpdate)) {
                  itemToUpdate.isCompleted = value;
                  await list.save();
                }
              }
              // Update the local state immediately
              setState(() {
                item.isCompleted = value;
              });
            }
          }
        },
      ),
    ),
  );
  loadAndUpdateLists();
}

  Future<void> _goToCategoryPage(int index) async {
    await Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => CategoryPage(index: index)),
    );
    loadAndUpdateLists();
  }

  int get totalCount => allItems.length;
  int get todayCount => todayItems.length;
  int get scheduledCount => scheduledItems.length;
  int get completedCount => completedItems.length;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Shopping List'),
        flexibleSpace: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [Colors.deepPurple, Colors.deepPurpleAccent],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            SizedBox(
              height: 150,
              child: ListView.separated(
                scrollDirection: Axis.horizontal,
                itemCount: 4,
                separatorBuilder: (_, __) => const SizedBox(width: 16),
                itemBuilder: (context, index) {
                  switch (index) {
                    case 0:
                      return InfoCard(
                        title: 'Today',
                        count: todayCount,
                        onTap: () => _openInfoPage('Today', todayItems),
                        color: Colors.blueAccent,
                      );
                    case 1:
                      return InfoCard(
                        title: 'Scheduled',
                        count: scheduledCount,
                        onTap: () => _openInfoPage('Scheduled', scheduledItems),
                        color: Colors.orange,
                      );
                    case 2:
                      return InfoCard(
                        title: 'All',
                        count: totalCount,
                        onTap: () => _openInfoPage('All', allItems),
                        color: Colors.deepPurpleAccent,
                      );
                    default:
                      return InfoCard(
                        title: 'Completed',
                        count: completedCount,
                        onTap: () => _openInfoPage('Completed', completedItems),
                        color: Colors.green,
                      );
                  }
                },
              ),
            ),
            const SizedBox(height: 24),
            Expanded(
              child: ValueListenableBuilder(
                valueListenable:
                    Hive.box<ShoppingList>('shopping_lists').listenable(),
                builder: (context, Box<ShoppingList> box, _) {
                  if (box.isEmpty) {
                    return Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.shopping_cart,
                            size: 64,
                            color: Colors.deepPurple.withOpacity(0.3),
                          ),
                          const SizedBox(height: 16),
                          Text(
                            'No shopping lists yet',
                            style: TextStyle(
                              fontSize: 18,
                              color: Colors.grey.shade400,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'Tap the + button to create one',
                            style: TextStyle(
                              fontSize: 14,
                              color: Colors.grey.shade600,
                            ),
                          ),
                        ],
                      ),
                    );
                  }

                  lists = box.values.toList();
                  return ListView.builder(
                    itemCount: lists.length,
                    itemBuilder: (context, idx) {
                      final listName = lists[idx].name;
                      final items = lists[idx].items;
                      return Card(
                        margin: const EdgeInsets.symmetric(vertical: 8),
                        child: ListTile(
                          title: Text(
                            listName,
                            style: const TextStyle(fontWeight: FontWeight.bold),
                          ),
                          subtitle: Text(
                            '${items.length} ${items.length == 1 ? 'item' : 'items'}',
                            style: TextStyle(color: Colors.grey.shade400),
                          ),
                          leading: CircleAvatar(
                            backgroundColor: Colors.deepPurple.withOpacity(0.2),
                            child: const Icon(
                              Icons.shopping_basket,
                              color: Colors.deepPurple,
                            ),
                          ),
                          trailing: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              IconButton(
                                icon: Icon(
                                  Icons.edit,
                                  color: Colors.grey.shade400,
                                ),
                                onPressed: () => _updateCategory(listName),
                              ),
                              IconButton(
                                icon: const Icon(
                                  Icons.delete,
                                  color: Colors.redAccent,
                                ),
                                onPressed: () async {
                                  await box.deleteAt(idx);
                                  loadAndUpdateLists();
                                  showSimpleNotification(
                                    Container(
                                      padding: const EdgeInsets.all(12),
                                      decoration: BoxDecoration(
                                        color: Colors.redAccent,
                                        borderRadius: BorderRadius.circular(16),
                                      ),
                                      child: const Row(
                                        children: [
                                          Icon(
                                            Icons.delete,
                                            color: Colors.white,
                                          ),
                                          SizedBox(width: 8),
                                          Expanded(
                                            child: Text(
                                              "List deleted successfully!",
                                              style: TextStyle(
                                                color: Colors.white,
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                    background: Colors.transparent,
                                    elevation: 0,
                                  );
                                },
                              ),
                            ],
                          ),
                          onTap: () => _goToCategoryPage(idx),
                        ),
                      );
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _addCategory,
        child: const Icon(Icons.add),
      ),
    );
  }
}
