import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shopping_list/data/categories.dart';
import 'package:shopping_list/models/grocery_item.dart';
import 'package:shopping_list/widget/new_item.dart';
import 'package:http/http.dart' as http;

class GroceryList extends StatefulWidget {
  const GroceryList({super.key});

  @override
  State<GroceryList> createState() => _GroceryListState();
}

class _GroceryListState extends State<GroceryList> {
  List<GroceryItem> _groceryItems = [];
  var _isLoading = true;
  String ? _error;

  @override
  void initState() {
    super.initState();
    _loadItems();
  }

  void _loadItems() async {
    final url = Uri.https(
        'joeshoppinglistapp-default-rtdb.firebaseio.com', 'shopping-list.json');

        try{
          final response = await http.get(url);
           if(response.statusCode >= 400){
      setState(() {
        _error = 'Failed to load items. please try again';
      });
      
    }

    if(response.body == 'null'){
      setState(() {
        _isLoading = false;
      });
      return;
    }

    final Map<String, dynamic> listData = json.decode(response.body);
    final List<GroceryItem> loadedItems = [];

    for (final item in listData.entries) {
      final category = categories.entries
          .firstWhere(
              (catItem) => catItem.value.title == item.value['category'])
          .value;
      loadedItems.add(GroceryItem(
          id: item.key,
          name: item.value['name'],
          quantity: item.value['quantity'],
          category: category));
    }

    setState(() {
      _groceryItems = loadedItems;
      _isLoading = false;
    });

        }catch(error){
             setState(() {
        _error = 'Something went wrong! please try again';
      });
        }
    
   
  }

  void _addItem() async {
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
    final index = _groceryItems.indexOf(item);

     setState(() {
      _groceryItems.remove(item);
    });  

    final url = Uri.https(
        'joeshoppinglistapp-default-rtdb.firebaseio.com', 'shopping-list/${item.id}.json');
       final response = await  http.delete(url);

      if(response.statusCode >= 400){
        //optional you can show error message 
        setState(() {
      _groceryItems.insert(index, item);
      _error = 'Failed to delete item. Please try again latter.';

    });

    Future.delayed(const Duration(seconds: 1), () {
      setState(() {
        _error = null; // Clear error message
      });

    });

      }
   
  }

  @override
  Widget build(BuildContext context) {
    Widget content = const Center(
      child: Text(
        'No item added yet',
        style: TextStyle(
          fontSize: 25,
        ),
      ),
    );

    if(_isLoading){
      content = const Center(child: CircularProgressIndicator(),);
    }

    if (_groceryItems.isNotEmpty) {
      content = ListView.builder(
        itemCount: _groceryItems.length,
        itemBuilder: (ctx, index) => Dismissible(
          onDismissed: (direction) {
            _removeItem(_groceryItems[index]);
          },
          key: ValueKey(_groceryItems[index].id),
          child: ListTile(
            title: Text(_groceryItems[index].name),
            leading: Container(
              width: 24,
              height: 24,
              color: _groceryItems[index].category.color,
            ),
            trailing: Text(
              _groceryItems[index].quantity.toString(),
            ),
          ),
        ),
      );
    }

    if(_error != null){
      content = Center(
      child: Text(
        _error!,
      ),
    );
    }
    return Scaffold(
      appBar: AppBar(
        title: const Text('Your grocery list'),
        actions: [
          IconButton(
            onPressed: _addItem,
            icon: const Icon(Icons.add),
          )
        ],
      ),
      body: content,
    );
  }
}