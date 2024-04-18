import 'package:blog/screens/add_todo_page.dart';
import 'package:flutter/material.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Todo List'),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => navigateToAddTodoRoute(),
        label: const Text('Add'),
      ),
    );
  }

  void navigateToAddTodoRoute() {
    final route = MaterialPageRoute(
      builder: (context) => const AddToDoPage(),
    );
    Navigator.push(context, route);
  }
}
