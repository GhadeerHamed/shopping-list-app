import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:shopping_list/data/categories.dart';
import 'package:shopping_list/models/category.dart';
import 'package:shopping_list/models/grocery_item.dart';
import 'package:shopping_list/widgets/new_item.dart';
import 'package:http/http.dart' as http;

class GroceryList extends StatefulWidget {
  const GroceryList({super.key});

  @override
  State<GroceryList> createState() => _GroceryListState();
}

class _GroceryListState extends State<GroceryList> {
  List<GroceryItem> _groceryItems = [];
  var _isLoading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _loadItems();
  }

  void _loadItems() async {
    final url = Uri.https(
      'faker-app-flutter-fireba-72e85-default-rtdb.firebaseio.com',
      '/grocery-items.json',
    );

    try {
      final response = await http.get(url);
      if (response.statusCode >= 400) {
        setState(() {
          _error = 'Failed to fetch data. Please try again later.';
          _isLoading = false;
        });
        return;
      }

      if (response.body == 'null') {
        setState(() {
          _isLoading = false;
        });
        return;
      }

      final Map<String, dynamic> data = json.decode(response.body);

      final List<GroceryItem> loadedItems = [];
      for (final item in data.entries) {
        final category = categories.entries
            .firstWhere(
              (cat) => cat.value.title == item.value['category'],
              orElse: () =>
                  MapEntry(Categories.other, categories[Categories.other]!),
            )
            .value;

        loadedItems.add(
          GroceryItem(
            id: item.key,
            name: item.value['name'],
            quantity: item.value['quantity'],
            category: category,
          ),
        );
      }

      setState(() {
        _groceryItems = loadedItems;
        _isLoading = false;
      });
    } catch (error) {
      setState(() {
        _error = 'An error occurred. Please try again later.';
        _isLoading = false;
      });
    }
  }

  void _addItem() async {
    // Navigate to the NewItem screen
    final newItem = await Navigator.of(context).push<GroceryItem>(
      MaterialPageRoute(
        builder: (ctx) => const NewItem(),
      ),
    );

    if (newItem == null) {
      return;
    }

    setState(() {
      _groceryItems.add(newItem);
    });
  }

  void _removeItem(GroceryItem item) async {
    var index = _groceryItems.indexOf(item);
    setState(() {
      _groceryItems.remove(item);
    });

    final url = Uri.https(
      'faker-app-flutter-fireba-72e85-default-rtdb.firebaseio.com',
      '/grocery-items/${item.id}.json',
    );

    final response = await http.delete(url);

    if (response.statusCode >= 400) {
      setState(() {
        _groceryItems.insert(index, item);
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Failed to delete the item. Please try again.',
            style: TextStyle(color: Colors.red),
          ),
        ),
      );
      return;
    }

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text(
          'Item deleted successfully.',
          style: TextStyle(color: Colors.green),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    Widget content = const Center(
      child: Text(
        'No items added yet.',
        style: TextStyle(fontSize: 18),
      ),
    );

    if (_isLoading) {
      content = const Center(
        child: CircularProgressIndicator(),
      );
    }

    if (_groceryItems.isNotEmpty) {
      content = ListView.builder(
        itemCount: _groceryItems.length,
        itemBuilder: (ctx, index) => Dismissible(
          key: ValueKey(_groceryItems[index].id),
          onDismissed: (direction) {
            _removeItem(_groceryItems[index]);
          },
          background: Container(
            color: Theme.of(context).colorScheme.error.withValues(alpha: 0.75),
            margin: const EdgeInsets.symmetric(
              horizontal: 15,
              vertical: 4,
            ),
            alignment: Alignment.centerRight,
            padding: const EdgeInsets.only(right: 20),
            child: const Icon(
              Icons.delete,
              color: Colors.white,
              size: 40,
            ),
          ),
          child: ListTile(
            leading: Container(
              width: 24,
              height: 24,
              decoration: BoxDecoration(
                color: _groceryItems[index].category.colorValue,
                borderRadius: BorderRadius.circular(4),
              ),
            ),
            title: Text(_groceryItems[index].name),
            trailing: Text('x${_groceryItems[index].quantity}'),
          ),
        ),
      );
    }

    if (_error != null) {
      content = Center(
        child: Text(
          _error!,
          style: const TextStyle(
            color: Colors.red,
            fontSize: 18,
          ),
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Grocery List'),
        actions: [
          IconButton(
            onPressed: _addItem,
            icon: const Icon(Icons.add),
          ),
        ],
      ),
      body: content,
    );
  }
}
