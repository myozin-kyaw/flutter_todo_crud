import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class AddToDoPage extends StatefulWidget {
  const AddToDoPage({super.key});

  @override
  State<AddToDoPage> createState() => _AddToDoPageState();
}

class _AddToDoPageState extends State<AddToDoPage> {
  final _todoFormKey = GlobalKey<FormState>();
  TextEditingController titleController = TextEditingController();
  TextEditingController descriptionController = TextEditingController();
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Add new todo'),
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
                  submitData();
                  showAlertMessage(
                    'Submitting new todos...',
                    Colors.blueGrey,
                    Colors.white,
                  );
                }
              },
              child: const Text('Write'),
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

    const url = 'https://api.nstack.in/v1/todos';
    final uri = Uri.parse(url);
    final response = await http.post(
      uri,
      body: jsonEncode(body),
      headers: {
        'Content-Type': 'application/json',
      },
    );

    if (response.statusCode == 201) {
      print(response.body);
      showAlertMessage(
        'Successfully created new todo.',
        Colors.deepPurple,
        Colors.white,
      );
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
