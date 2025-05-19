// ignore_for_file: deprecated_member_use

import 'package:flutter/material.dart';
import 'package:flutter_application_1/shoppingList.dart';
import 'package:flutter_application_1/shopping_item.dart';
import 'package:hive/hive.dart';
import 'package:overlay_support/overlay_support.dart';

class CategoryPage extends StatefulWidget {
  final int index;
  const CategoryPage({super.key, required this.index});

  @override
  State<CategoryPage> createState() => _CategoryPageState();
}

class _CategoryPageState extends State<CategoryPage> {
  var allLists;

  @override
  void initState() {
    super.initState();
    allLists = Hive.box<ShoppingList>('shopping_lists').values.toList();
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

  void _addItem() {
    var box = Hive.box<ShoppingList>('shopping_lists');
    showDialog(
      context: context,
      builder: (context) {
        final controller = TextEditingController();
        bool isScheduled = false;
        DateTime? selectedDate;

        return StatefulBuilder(
          builder: (context, setStateDialog) {
            return AlertDialog(
              title: const Text(
                'Add Item',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextField(
                    controller: controller,
                    decoration: InputDecoration(
                      labelText: 'Item Name',
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
                  const SizedBox(height: 16),
                  CheckboxListTile(
                    title: const Text('Schedule this item'),
                    value: isScheduled,
                    onChanged:
                        (v) => setStateDialog(() => isScheduled = v ?? false),
                    activeColor: Colors.deepPurple,
                  ),
                  if (isScheduled)
                    Padding(
                      padding: const EdgeInsets.only(top: 8),
                      child: TextButton(
                        onPressed: () async {
                          final d = await showDatePicker(
                            context: context,
                            initialDate: DateTime.now(),
                            firstDate: DateTime.now(),
                            lastDate: DateTime(2100),
                            builder: (context, child) {
                              return Theme(
                                data: Theme.of(context).copyWith(
                                  colorScheme: const ColorScheme.dark(
                                    primary: Colors.deepPurple,
                                    onPrimary: Colors.white,
                                    surface: Color(0xFF121212),
                                    onSurface: Colors.white,
                                  ),
                                  dialogBackgroundColor: const Color(
                                    0xFF121212,
                                  ),
                                ),
                                child: child!,
                              );
                            },
                          );
                          if (d != null) {
                            setStateDialog(() => selectedDate = d);
                          }
                        },
                        style: TextButton.styleFrom(
                          backgroundColor: Colors.deepPurple.withOpacity(0.1),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        child: Text(
                          selectedDate == null
                              ? 'Pick a date'
                              : 'Date: ${selectedDate!.toLocal().toString().split(' ')[0]}',
                          style: TextStyle(
                            color:
                                selectedDate == null
                                    ? Colors.grey
                                    : Colors.deepPurple,
                          ),
                        ),
                      ),
                    ),
                ],
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text(
                    'Cancel',
                    style: TextStyle(color: Colors.grey),
                  ),
                ),
                ElevatedButton(
                  onPressed: () {
                    if (controller.text.isEmpty) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text("Item name cannot be empty"),
                        ),
                      );
                    } else if (isScheduled && selectedDate == null) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text(
                            "Please select a date for scheduled item",
                          ),
                        ),
                      );
                    } else {
                      final newItem = ShoppingItem(
                        name: controller.text,
                        isScheduled: isScheduled,
                        scheduledDate: selectedDate,
                      );
                      setState(() {
                        ShoppingList updated = box.getAt(widget.index)!;
                        updated.items.add(newItem);
                        box.putAt(widget.index, updated);
                        loadAndUpdateLists();
                      });
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
                          child: Row(
                            children: [
                              const Icon(
                                Icons.check_circle,
                                color: Colors.white,
                              ),
                              const SizedBox(width: 8),
                              Expanded(
                                child: Text(
                                  "Item '${controller.text}' added!",
                                  style: const TextStyle(color: Colors.white),
                                ),
                              ),
                            ],
                          ),
                        ),
                        background: Colors.transparent,
                        elevation: 0,
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
                    'Add',
                    style: TextStyle(color: Colors.white),
                  ),
                ),
              ],
            );
          },
        );
      },
    );
  }

  void _updateItem(int i) {
    var box = Hive.box<ShoppingList>('shopping_lists');
    final item = box.getAt(widget.index)!.items[i];
    final controller = TextEditingController(text: item.name);
    bool isScheduled = item.isScheduled;
    DateTime? selectedDate = item.scheduledDate;

    showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setStateDialog) {
            return AlertDialog(
              title: const Text(
                'Update Item',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextField(
                    controller: controller,
                    decoration: InputDecoration(
                      labelText: 'Item Name',
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
                  const SizedBox(height: 16),
                  CheckboxListTile(
                    title: const Text('Schedule this item'),
                    value: isScheduled,
                    onChanged:
                        (v) => setStateDialog(() => isScheduled = v ?? false),
                    activeColor: Colors.deepPurple,
                  ),
                  if (isScheduled)
                    Padding(
                      padding: const EdgeInsets.only(top: 8),
                      child: TextButton(
                        onPressed: () async {
                          final d = await showDatePicker(
                            context: context,
                            initialDate: selectedDate ?? DateTime.now(),
                            firstDate: DateTime.now(),
                            lastDate: DateTime(2100),
                            builder: (context, child) {
                              return Theme(
                                data: Theme.of(context).copyWith(
                                  colorScheme: const ColorScheme.dark(
                                    primary: Colors.deepPurple,
                                    onPrimary: Colors.white,
                                    surface: Color(0xFF121212),
                                    onSurface: Colors.white,
                                  ),
                                  dialogBackgroundColor: const Color(
                                    0xFF121212,
                                  ),
                                ),
                                child: child!,
                              );
                            },
                          );
                          if (d != null) {
                            setStateDialog(() => selectedDate = d);
                          }
                        },
                        style: TextButton.styleFrom(
                          backgroundColor: Colors.deepPurple.withOpacity(0.1),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        child: Text(
                          selectedDate == null
                              ? 'Pick a date'
                              : 'Date: ${selectedDate!.toLocal().toString().split(' ')[0]}',
                          style: TextStyle(
                            color:
                                selectedDate == null
                                    ? Colors.grey
                                    : Colors.deepPurple,
                          ),
                        ),
                      ),
                    ),
                ],
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text(
                    'Cancel',
                    style: TextStyle(color: Colors.grey),
                  ),
                ),
                ElevatedButton(
                  onPressed: () {
                    if (controller.text.isEmpty) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text("Item name cannot be empty"),
                        ),
                      );
                    } else if (isScheduled && selectedDate == null) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text(
                            "Please select a date for scheduled item",
                          ),
                        ),
                      );
                    } else {
                      setState(() {
                        ShoppingList updated = box.getAt(widget.index)!;
                        updated.items[i] = ShoppingItem(
                          name: controller.text,
                          isScheduled: isScheduled,
                          scheduledDate: selectedDate,
                          isCompleted: item.isCompleted,
                        );
                        box.putAt(widget.index, updated);
                        loadAndUpdateLists();
                      });
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
                          child: Row(
                            children: [
                              const Icon(
                                Icons.check_circle,
                                color: Colors.white,
                              ),
                              const SizedBox(width: 8),
                              Expanded(
                                child: Text(
                                  "Item updated successfully!",
                                  style: const TextStyle(color: Colors.white),
                                ),
                              ),
                            ],
                          ),
                        ),
                        background: Colors.transparent,
                        elevation: 0,
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
      },
    );
  }

  void _deleteItem(int i) {
    var box = Hive.box<ShoppingList>('shopping_lists');
    final itemName = box.getAt(widget.index)!.items[i].name;
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text(
            'Delete Item',
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
          content: Text('Are you sure you want to delete "$itemName"?'),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel', style: TextStyle(color: Colors.grey)),
            ),
            ElevatedButton(
              onPressed: () {
                setState(() {
                  ShoppingList updated = box.getAt(widget.index)!;
                  updated.items.removeAt(i);
                  box.putAt(widget.index, updated);
                  loadAndUpdateLists();
                });
                Navigator.pop(context);
                showSimpleNotification(
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.redAccent,
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: const Row(
                      children: [
                        Icon(Icons.delete, color: Colors.white),
                        SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            "Item deleted successfully!",
                            style: TextStyle(color: Colors.white),
                          ),
                        ),
                      ],
                    ),
                  ),
                  background: Colors.transparent,
                  elevation: 0,
                );
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: const Text(
                'Delete',
                style: TextStyle(color: Colors.white),
              ),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    var box = Hive.box<ShoppingList>('shopping_lists');
    final list = box.getAt(widget.index)!;

    return Scaffold(
      appBar: AppBar(
        title: Text(list.name),
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
      body:
          list.items.isEmpty
              ? Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.list_alt,
                      size: 64,
                      color: Colors.deepPurple.withOpacity(0.3),
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'No items in this list',
                      style: TextStyle(
                        fontSize: 18,
                        color: Colors.grey.shade400,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Tap the + button to add one',
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.grey.shade600,
                      ),
                    ),
                  ],
                ),
              )
              : ListView.builder(
                itemCount: list.items.length,
                itemBuilder: (context, i) {
                  final item = list.items[i];
                  return Card(
                    margin: const EdgeInsets.symmetric(
                      vertical: 4,
                      horizontal: 8,
                    ),
                    child: ListTile(
                      title: Text(
                        item.name,
                        style: TextStyle(
                          decoration:
                              item.isCompleted
                                  ? TextDecoration.lineThrough
                                  : null,
                          color:
                              item.isCompleted
                                  ? Colors.grey.shade600
                                  : Colors.white,
                        ),
                      ),
                      subtitle:
                          item.scheduledDate != null
                              ? Text(
                                'Scheduled: ${item.scheduledDate!.toLocal().toString().split(' ')[0]}',
                                style: TextStyle(color: Colors.grey.shade400),
                              )
                              : null,
                      trailing: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          IconButton(
                            icon: Icon(Icons.edit, color: Colors.grey.shade400),
                            onPressed: () => _updateItem(i),
                          ),
                          IconButton(
                            icon: const Icon(
                              Icons.delete,
                              color: Colors.redAccent,
                            ),
                            onPressed: () => _deleteItem(i),
                          ),
                          Checkbox(
                            value: item.isCompleted,
                            onChanged: (bool? value) {
                              setState(() {
                                ShoppingList updated = box.getAt(widget.index)!;
                                updated.items[i].isCompleted = value ?? false;
                                box.putAt(widget.index, updated);
                              });
                            },
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(4),
                            ),
                            fillColor: MaterialStateProperty.resolveWith<Color>(
                              (Set<MaterialState> states) {
                                if (states.contains(MaterialState.selected)) {
                                  return Colors.green;
                                }
                                return Colors.grey.shade600;
                              },
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
      floatingActionButton: FloatingActionButton(
        child: const Icon(Icons.add),
        onPressed: _addItem,
      ),
    );
  }
}
