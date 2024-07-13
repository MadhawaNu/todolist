import 'package:flutter/material.dart';
import 'package:flutter_slidable/flutter_slidable.dart'; // For swipe-to-delete functionality
import 'package:intl/intl.dart'; // For date formatting
import 'package:to_do_list/database/db_helper.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  List<Map<String, dynamic>> tasks = [];
  final _formKey = GlobalKey<FormState>();
  String _title = '';
  String _description = '';
  DateTime _selectedDate = DateTime.now();
  TimeOfDay _selectedTime = TimeOfDay.now();
  bool _isChecked = false;
  Set<int> _selectedCheckboxIndexes = Set();
  TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    loadTasks();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void loadTasks() async {
    final fetchedTasks = await DBHelper.getTasks(tasks);
    setState(() {
      tasks = fetchedTasks;
    });
  }

  void addTask(String title, String description, DateTime dateTime) async {
    await DBHelper.addTask({
      'title': title,
      'description': description,
      'dateTime': dateTime.toIso8601String(),
    });
    loadTasks();
  }

  void updateTask(Map<String, dynamic> task) async {
    DBHelper dbHelper = DBHelper();
    await dbHelper.updateTask(
      task['id'],
      task['title'],
      task['description'],
      task['dateTime'],
    );
    loadTasks();
  }

  void deleteTask(int id) async {
    try {
      await DBHelper.deleteTask(id);

      setState(() {
        tasks = List.from(tasks)..removeWhere((task) => task['id'] == id);
      });
    } catch (e) {
      print('Error deleting task: $e');
    }
  }

  void showTaskDetailsDialog(Map<String, dynamic> task) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(task['title']),
          content: SingleChildScrollView(
            child: ListBody(
              children: <Widget>[
                Text('Description: ${task['description']}'),
                Text(
                    'Date: ${DateFormat('yyyy-MM-dd').format(DateTime.parse(task['dateTime']))}'),
                Text(
                    'Time: ${TimeOfDay.fromDateTime(DateTime.parse(task['dateTime'])).format(context)}'),
              ],
            ),
          ),
          actions: <Widget>[
            TextButton(
              child: const Text('Edit'),
              onPressed: () {
                Navigator.of(context).pop();
                showEditTaskDialog(task);
              },
            ),
            TextButton(
              child: const Text('Close'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  void showAddTaskDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Add Task'),
          content: SingleChildScrollView(
            child: Form(
              key: _formKey,
              child: Column(
                children: <Widget>[
                  TextFormField(
                    decoration: InputDecoration(hintText: 'Title'),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter a title';
                      }
                      return null;
                    },
                    onSaved: (value) => _title = value!,
                  ),
                  TextFormField(
                    decoration: InputDecoration(hintText: 'Description'),
                    onSaved: (value) => _description = value!,
                  ),
                  ListTile(
                    title: Text(
                        'Date: ${DateFormat('yyyy-MM-dd').format(_selectedDate)}'),
                    trailing: Icon(Icons.calendar_today),
                    onTap: () async {
                      final DateTime? picked = await showDatePicker(
                        context: context,
                        initialDate: _selectedDate,
                        firstDate: DateTime(2000),
                        lastDate: DateTime(2025),
                      );
                      if (picked != null && picked != _selectedDate) {
                        setState(() {
                          _selectedDate = picked;
                        });
                      }
                    },
                  ),
                  ListTile(
                    title: Text('Time: ${_selectedTime.format(context)}'),
                    trailing: Icon(Icons.access_time),
                    onTap: () async {
                      final TimeOfDay? picked = await showTimePicker(
                        context: context,
                        initialTime: _selectedTime,
                      );
                      if (picked != null && picked != _selectedTime) {
                        setState(() {
                          _selectedTime = picked;
                        });
                      }
                    },
                  ),
                ],
              ),
            ),
          ),
          actions: <Widget>[
            TextButton(
              child: Text('Save'),
              onPressed: () async {
                if (_formKey.currentState!.validate()) {
                  _formKey.currentState!.save();
                  DateTime finalDateTime = DateTime(
                    _selectedDate.year,
                    _selectedDate.month,
                    _selectedDate.day,
                    _selectedTime.hour,
                    _selectedTime.minute,
                  );

                  addTask(_title, _description, finalDateTime);
                  Navigator.of(context).pop();
                }
              },
            ),
          ],
        );
      },
    );
  }

  Map<String, dynamic> task = {};

  void showEditTaskDialog(Map<String, dynamic> task) {
    final TextEditingController _titleController =
        TextEditingController(text: task['title']);
    final TextEditingController _descriptionController =
        TextEditingController(text: task['description']);

    final TextEditingController _dateController = TextEditingController(
        text:
            DateFormat('yyyy-MM-dd').format(DateTime.parse(task['dateTime'])));
    final TextEditingController _timeController = TextEditingController(
        text: TimeOfDay.fromDateTime(DateTime.parse(task['dateTime']))
            .format(context));

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Edit Task'),
          content: SingleChildScrollView(
            child: ListBody(
              children: <Widget>[
                TextField(
                    controller: _titleController,
                    decoration: InputDecoration(labelText: 'Title')),
                TextField(
                    controller: _descriptionController,
                    decoration: InputDecoration(labelText: 'Description')),
                TextField(
                    controller: _dateController,
                    decoration: InputDecoration(labelText: 'Date')),
                TextField(
                    controller: _timeController,
                    decoration: InputDecoration(labelText: 'Time')),
              ],
            ),
          ),
          actions: <Widget>[
            TextButton(
              child: const Text('Save'),
              onPressed: () {
                updateTask(task);
                Navigator.of(context).pop();
              },
            ),
            TextButton(
              child: const Text('Cancel'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            //const Text('To-Do List'),

            Expanded(
              child: TextField(
                controller: _searchController,
                decoration: InputDecoration(
                  hintText: 'Search Task',
                  border: InputBorder.none,
                ),
                style: TextStyle(color: Colors.white),
              ),
            ),
          ],
        ),
        actions: [
          IconButton(
            icon: Icon(Icons.search),
            onPressed: () {
              String searchQuery = _searchController.text.toLowerCase();
              Map<String, dynamic>? searchedTask = tasks.firstWhere(
                (task) => task['title'].toLowerCase().contains(searchQuery),
                orElse: () => <String, dynamic>{},
              );

              if (searchedTask != null) {
                showDialog(
                  context: context,
                  builder: (context) => AlertDialog(
                    title: Text(searchedTask['title']),
                    content: Text(searchedTask['description']),
                    actions: [
                      TextButton(
                        child: Text('OK'),
                        onPressed: () => Navigator.of(context).pop(),
                      ),
                    ],
                  ),
                );
              } else {
                showDialog(
                  context: context,
                  builder: (context) => AlertDialog(
                    title: Text('Not Found'),
                    content: Text('No task found with that title.'),
                    actions: [
                      TextButton(
                        child: Text('OK'),
                        onPressed: () => Navigator.of(context).pop(),
                      ),
                    ],
                  ),
                );
              }
            },
          ),
        ],
      ),
      body: tasks.isEmpty
          ? Center(
              child: Image.asset('assets/animations/no-items.gif'),
            )
          : ListView.builder(
              itemCount: tasks.length,
              itemBuilder: (context, index) {
                final originalTask = tasks[index];

                Map<String, dynamic> task = Map.from(originalTask);
                return Slidable(
                  endActionPane: ActionPane(
                    motion: const DrawerMotion(),
                    children: [
                      SlidableAction(
                        onPressed: (context) {
                          showDialog(
                            context: context,
                            builder: (BuildContext context) {
                              return AlertDialog(
                                title: const Text('Confirm'),
                                content: const Text(
                                    'Are you sure you want to delete this task?'),
                                actions: <Widget>[
                                  TextButton(
                                    onPressed: () =>
                                        Navigator.of(context).pop(),
                                    child: const Text('Cancel'),
                                  ),
                                  TextButton(
                                    onPressed: () {
                                      deleteTask(task['id']);
                                      Navigator.of(context).pop();
                                    },
                                    child: const Text('Delete'),
                                  ),
                                ],
                              );
                            },
                          );
                        },
                        backgroundColor: Colors.red,
                        foregroundColor: Colors.white,
                        icon: Icons.delete,
                        label: 'Delete',
                      ),
                    ],
                  ),
                  child: ListTile(
                    leading: Checkbox(
                      value: _selectedCheckboxIndexes.contains(index),
                      onChanged: (bool? newValue) {
                        setState(() {
                          if (newValue == true) {
                            _selectedCheckboxIndexes.add(index);
                          } else {
                            _selectedCheckboxIndexes.remove(index);
                          }
                        });
                      },
                      checkColor: Colors.white,
                      activeColor: Colors.green,
                    ),
                    title: Text(task['title']),
                    subtitle: Text(DateFormat('yyyy-MM-dd – kk:mm')
                        .format(DateTime.parse(task['dateTime']))),
                    onTap: () => showTaskDetailsDialog(task),
                  ),
                );
              },
            ),
      floatingActionButton: FloatingActionButton(
        onPressed: showAddTaskDialog,
        child: const Icon(Icons.add),
      ),
    );
  }
}
