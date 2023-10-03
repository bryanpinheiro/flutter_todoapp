// ignore_for_file: unused_import, use_key_in_widget_constructors, library_private_types_in_public_api, prefer_const_constructors

import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:sqflite/sqflite.dart';
import '../database/mySQLite.dart';

class TodoScreen extends StatefulWidget {
  @override
  _TodoScreenState createState() => _TodoScreenState();
}

class _TodoScreenState extends State<TodoScreen> {
  final TextEditingController _taskController = TextEditingController();
  final List<Map<String, dynamic>> _tasks = [];

  @override
  void initState() {
    super.initState();
    _fetchTasks();
  }

  Future<void> _fetchTasks() async {
    final Database db = await DatabaseHelper.instance.database;
    final List<Map<String, dynamic>> tasks = await db.query('todo');
    setState(() {
      _tasks.clear();
      _tasks.addAll(tasks);
    });
  }

  Future<void> _addTask() async {
    String task = _taskController.text.trim();
    if (task.isNotEmpty) {
      final Database db = await DatabaseHelper.instance.database;
      await db.insert('todo', {'task': task});
      Fluttertoast.showToast(msg: 'Task added');
      _taskController.clear();
      _fetchTasks();
    }
  }

  Future<void> _deleteTask(int id) async {
    final Database db = await DatabaseHelper.instance.database;
    await db.delete('todo', where: 'id = ?', whereArgs: [id]);
    Fluttertoast.showToast(msg: 'Task deleted');
    _fetchTasks();
  }

@override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Todo App'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: <Widget>[
            TextField(
              controller: _taskController,
              decoration: InputDecoration(
                hintText: 'Enter a task',
              ),
            ),
            SizedBox(height: 16.0),
            ElevatedButton(
              onPressed: _addTask,
              child: Text('Add Task'),
            ),
            Expanded(
              child: ListView.builder(
                itemCount: _tasks.length,
                itemBuilder: (context, index) {
                  return ListTile(
                    title: Text(_tasks[index]['task']),
                    trailing: IconButton(
                      icon: Icon(Icons.delete),
                      onPressed: () {
                        _deleteTask(_tasks[index]['id']);
                      },
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
