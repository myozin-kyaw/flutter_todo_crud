import 'dart:convert';

import 'package:blog/screens/home_page.dart';
import 'package:blog/secret.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class AddToDoPage extends StatefulWidget {
  final Map? todo;
  const AddToDoPage({
    super.key,
    this.todo,
  });

  @override
  State<AddToDoPage> createState() => _AddToDoPageState();
}

class _AddToDoPageState extends State<AddToDoPage> {
  final _todoFormKey = GlobalKey<FormState>();
  TextEditingController titleController = TextEditingController();
  TextEditingController descriptionController = TextEditingController();
  bool isEdit = false;

  @override
  void initState() {
    super.initState();

    if (widget.todo != null) {
      isEdit = true;
      titleController.text = widget.todo!['title'].toString();
      descriptionController.text = widget.todo!['description'].toString();

      print(widget.todo);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(isEdit ? 'Edit Todo' : 'Add new todo'),
      ),
      body: Form(
        key: _todoFormKey,
        child: ListView(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          children: [
            TextFormField(
              controller: titleController,
              decoration: const InputDecoration(hintText: 'Title'),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'This field can\'t be empty';
                }
                return null;
              },
            ),
            const SizedBox(height: 14),
            TextFormField(
              controller: descriptionController,
              decoration: const InputDecoration(hintText: 'Description'),
              keyboardType: TextInputType.multiline,
              minLines: 5,
              maxLines: 14,
            ),
            const SizedBox(height: 14),
            ElevatedButton(
              onPressed: () {
                if (_todoFormKey.currentState!.validate()) {
                  // If the form is valid, display a snackbar. In the real world,
                  // you'd often call a server or save the information in a database.
                  isEdit ? saveData(widget.todo!['_id']) : submitData;
                  showAlertMessage(
                    isEdit ? 'Saving todo...' : 'Submitting new todos...',
                    Colors.blueGrey,
                    Colors.white,
                  );
                }
              },
              child: Text(isEdit ? 'Save' : 'Write'),
            )
          ],
        ),
      ),
    );
  }

  Future<void> submitData() async {
    final title = titleController.text;
    final description = descriptionController.text;
    final body = {
      "title": title,
      "description": description,
      "is_completed": true,
    };

    final uri = Uri.parse(todoRemoteUrl);
    final response = await http.post(
      uri,
      body: jsonEncode(body),
      headers: {
        'Content-Type': 'application/json',
      },
    );

    if (response.statusCode == 201) {
      showAlertMessage(
        'Successfully created new todo.',
        Colors.deepPurple,
        Colors.white,
      );

      navigateToAddTodoRoute();
    } else {
      showAlertMessage(
        'Something went wrong.',
        Colors.red,
        Colors.white,
      );
    }
  }

  Future<void> saveData(String? id) async {
    if (id == null) {
      showAlertMessage(
        'Todo missing.',
        Colors.red,
        Colors.white,
      );

      return;
    }

    final title = titleController.text;
    final description = descriptionController.text;
    final body = {
      "title": title,
      "description": description,
      "is_completed": true,
    };

    final uri = Uri.parse('$todoRemoteUrl/$id');
    final response = await http.put(
      uri,
      body: jsonEncode(body),
      headers: {
        'Content-Type': 'application/json',
      },
    );

    if (response.statusCode == 200) {
      showAlertMessage(
        'Successfully saved todo.',
        Colors.deepPurple,
        Colors.white,
      );

      navigateToAddTodoRoute();
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

  void navigateToAddTodoRoute() {
    final route = MaterialPageRoute(
      builder: (context) => const HomePage(),
    );
    Navigator.push(context, route);
  }
}
