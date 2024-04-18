import 'dart:convert';

import 'package:blog/screens/add_todo_page.dart';
import 'package:blog/secret.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  List items = [];
  bool isLoading = false;
  @override
  void initState() {
    super.initState();
    fetchTodoList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Todo List'),
      ),
      body: Visibility(
        visible: isLoading,
        replacement: RefreshIndicator(
          onRefresh: () => fetchTodoList(),
          child: ListView.builder(
            padding: const EdgeInsets.symmetric(horizontal: 8),
            itemCount: items.length,
            itemBuilder: (context, index) {
              final item = items[index];
              final id = item['_id'].toString();
              return ListTile(
                leading: CircleAvatar(
                  child: Text('${index + 1}'),
                ),
                title: Text(item['title'].toString()),
                subtitle: Text(item['description'].toString()),
                trailing: PopupMenuButton(
                  onSelected: (value) {
                    if (value == 'edit') {
                      navigateToAddTodoRoute(item);
                    } else {
                      deleteById(id);
                    }
                  },
                  itemBuilder: (context) {
                    return [
                      const PopupMenuItem(
                        value: 'edit',
                        child: Text('Edit'),
                      ),
                      const PopupMenuItem(
                        value: 'delete',
                        child: Text('Delete'),
                      ),
                    ];
                  },
                ),
              );
            },
          ),
        ),
        child: const Center(child: CircularProgressIndicator()),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => navigateToAddTodoRoute(),
        label: const Text('Add'),
      ),
    );
  }

  void navigateToAddTodoRoute([Map? item]) {
    final route = MaterialPageRoute(
      builder: (context) => AddToDoPage(todo: item),
    );
    Navigator.push(context, route);
  }

  Future<void> fetchTodoList() async {
    setState(() {
      isLoading = true;
    });
    final uri = Uri.parse('$todoRemoteUrl?page=1&limit=10');
    final response = await http.get(
      uri,
      headers: {
        'accept': 'application/json',
      },
    );

    if (response.statusCode == 200) {
      final todoJson = jsonDecode(response.body) as Map;
      final result = todoJson['items'] as List;

      setState(() {
        items = result;
        isLoading = false;
      });
    }

    setState(() {
      isLoading = false;
    });
  }

  Future<void> deleteById(String id) async {
    final uri = Uri.parse('$todoRemoteUrl/$id');
    final response = await http.delete(
      uri,
      headers: {
        'accept': 'application/json',
      },
    );

    if (response.statusCode == 200) {
      showAlertMessage(
        'Successfully deleted.',
        Colors.deepPurple,
        Colors.white,
      );

      final filterItems =
          items.where((element) => element['_id'] != id).toList();

      setState(() {
        items = filterItems;
      });
    } else {
      showAlertMessage(
        'Something went wrong.',
        Colors.red,
        Colors.white,
      );
    }
  }

  void showAlertMessage(String message, Color bgColor, Color textColor) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          message.toString(),
          style: TextStyle(color: textColor),
        ),
        backgroundColor: bgColor,
      ),
    );
  }
}
