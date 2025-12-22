import 'package:flutter/material.dart';
import 'package:shopping_list/data/dummy_items.dart';

class GroceryList extends StatelessWidget {
  const GroceryList({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Grocery List'),
      ),
      body: ListView.builder(
        itemCount: groceryItems.length,
        itemBuilder: (context, index) {
          return ListTile(
            leading: Container(
              width: 24,
              height: 24,
              decoration: BoxDecoration(
                color: groceryItems[index].category.colorValue,
                borderRadius: BorderRadius.circular(4),
              ),
            ),
            title: Text(groceryItems[index].name),
            trailing: Text('x${groceryItems[index].quantity}'),
          );
        },
      ),
    );
  }
}
