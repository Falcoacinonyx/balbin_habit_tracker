import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:intl/intl.dart';

class HabitDetailScreen extends StatefulWidget {
  static const String id = 'habit_detail_screen';

  final String habit;

  HabitDetailScreen({required this.habit});

  @override
  _HabitDetailScreenState createState() => _HabitDetailScreenState();
}

class _HabitDetailScreenState extends State<HabitDetailScreen> {
  List<String> logs = [];

  @override
  void initState() {
    super.initState();
    _loadLogs();
  }

  void _loadLogs() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      logs = (prefs.getStringList('${widget.habit}_logs') ?? []);
    });
  }

  void _saveLogs() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.setStringList('${widget.habit}_logs', logs);
  }

  void _addLog(String log) {
    DateTime now = DateTime.now();
    String formattedDate = DateFormat('yyyy-MM-dd – hh:mm a').format(now);
    setState(() {
      logs.add('$log - $formattedDate');
      _saveLogs();
    });
  }

  void _removeLog(int index) {
    setState(() {
      logs.removeAt(index);
      _saveLogs();
    });
  }

  void _showRemoveLogDialog(int index) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Confirm Removal'),
          content: Text('Are you sure you want to remove this log entry?'),
          actions: <Widget>[
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Text('Cancel'),
            ),
            TextButton(
              onPressed: () {
                _removeLog(index);
                Navigator.of(context).pop();
              },
              child: Text('Remove'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    TextEditingController logController = TextEditingController();

    return Scaffold(
      appBar: AppBar(
        title: Text(widget.habit),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Expanded(
              child: ListView.builder(
                itemCount: logs.length,
                itemBuilder: (context, index) {
                  return ListTile(
                    title: Text(logs[index]),
                    trailing: IconButton(
                      icon: Icon(Icons.delete),
                      onPressed: () {
                        _showRemoveLogDialog(index);
                      },
                    ),
                  );
                },
              ),
            ),
            TextField(
              controller: logController,
              decoration: InputDecoration(labelText: 'Add log'),
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                _addLog(logController.text);
                logController.clear();
              },
              child: Text('Save Log'),
            ),
          ],
        ),
      ),
    );
  }
}
