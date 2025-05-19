// ignore_for_file: deprecated_member_use

import 'package:flutter/material.dart';
import 'package:flutter_application_1/shopping_item.dart';
import 'package:flutter_application_1/shopping_listPage.dart';

class InfoListPage extends StatefulWidget {
  final String title;
  final List<ShoppingItem> items;
  final void Function(ShoppingItem, bool) onItemToggle;

  const InfoListPage({
    super.key,
    required this.title,
    required this.items,
    required this.onItemToggle,
  });

  @override
  State<InfoListPage> createState() => _InfoListPageState();
}

class _InfoListPageState extends State<InfoListPage> {
  late List<ShoppingItem> items;

  @override
  void initState() {
    super.initState();
    items = widget.items;
  }

  Color _getColorForTitle(String title) {
    switch (title) {
      case 'Today':
        return Colors.blueAccent;
      case 'Scheduled':
        return Colors.orange;
      case 'Completed':
        return Colors.green;
      default:
        return Colors.deepPurpleAccent;
    }
  }

  @override
  Widget build(BuildContext context) {
    final color = _getColorForTitle(widget.title);

    return WillPopScope(
      onWillPop: () async{
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => ShoppingListPage()),
      );
      return false;
    },
      child: Scaffold(
        appBar: AppBar(
          leading: IconButton(
            icon: Icon(Icons.arrow_back),
            onPressed: () {
               Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (_) => ShoppingListPage()),
              );

            },
          ),
          title: Text(widget.title),
          flexibleSpace: Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [color.withOpacity(0.8), color.withOpacity(0.5)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
            ),
          ),
        ),
        body: items.isEmpty
            ? Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.list, size: 64, color: color.withOpacity(0.3)),
                    const SizedBox(height: 16),
                    Text(
                      'No ${widget.title.toLowerCase()} items',
                      style: TextStyle(
                        fontSize: 18,
                        color: Colors.grey.shade400,
                      ),
                    ),
                  ],
                ),
              )
            : ListView.builder(
                itemCount: items.length,
                itemBuilder: (context, i) {
                  final item = items[i];
                  return Card(
                    margin: const EdgeInsets.symmetric(
                      vertical: 4,
                      horizontal: 8,
                    ),
                    color: Colors.grey[850],
                    child: ListTile(
                      contentPadding: const EdgeInsets.symmetric(
                        vertical: 8,
                        horizontal: 16,
                      ),
                      title: Text(
                        item.name,
                        style: TextStyle(
                          fontSize: 16,
                          decoration: item.isCompleted
                              ? TextDecoration.lineThrough
                              : null,
                          color: item.isCompleted
                              ? Colors.grey.shade600
                              : Colors.white,
                        ),
                      ),
                      subtitle: widget.title == 'Scheduled' &&
                              item.scheduledDate != null
                          ? Text(
                              'Scheduled: ${item.scheduledDate!.toLocal().toString().split(' ')[0]}',
                              style: TextStyle(color: Colors.grey.shade400),
                            )
                          : widget.title == 'Today'
                              ? Text(
                                  'Today: ${DateTime.now().toLocal().toString().split(' ')[0]}',
                                  style: TextStyle(color: Colors.grey.shade400),
                                )
                              : null,
                      trailing: widget.title == 'Completed'
                          ? IconButton(
                              icon: const Icon(
                                Icons.delete,
                                color: Colors.redAccent,
                              ),
                              onPressed: () => widget.onItemToggle(item, true),
                            )
                          : Checkbox(
                              value: item.isCompleted,
                              onChanged: (bool? value) {
                                widget.onItemToggle(item, value ?? false);
                                setState(() {
                                  item.isCompleted = value ?? false;
                                });
                              },
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(4),
                              ),
                              fillColor:
                                  MaterialStateProperty.resolveWith<Color>(
                                      (Set<MaterialState> states) {
                                if (states.contains(MaterialState.selected)) {
                                  return Colors.green;
                                }
                                return Colors.grey.shade600;
                              }),
                            ),
                    ),
                  );
                },
              ),
      ),
    );
  }
}
