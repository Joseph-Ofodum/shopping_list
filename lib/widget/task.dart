import 'package:flutter/material.dart';
import 'package:shopping_list/data/dummy_items.dart';


class Task extends StatelessWidget {
  const Task({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Your grocery list'),
      ),

      body: ListView.builder(
        itemCount: groceryItems.length,
        itemBuilder: (ctx, index)=> ListTile(
          title: Text(groceryItems[index].name),
          leading: Container(
            width: 24,
            height: 24,
            color: groceryItems[index].category.color,
            ),
            trailing: Text(
              groceryItems[index].quantity.toString(),),
        )),
    );
  }
}
  