import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_gemini/flutter_gemini.dart';
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
  String aiFeedback = '';

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

  Future<void> _getAIFeedback() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String logs = (prefs.getStringList('${widget.habit}_logs') ?? []).join('\n');

    try {
      final response = await Gemini.instance.prompt(parts: [
        Part.text('Provide a short, encouraging, and motivational feedback on these habit logs for the habit "${widget.habit}":\n$logs\nAlso suggest improvements. (2-3 sentences only)'),
      ]);

      setState(() {
        aiFeedback = response?.output ?? 'No feedback available';
      });
    } catch (e) {
      setState(() {
        aiFeedback = 'Failed to get feedback: $e';
      });
    }
  }


  @override
  Widget build(BuildContext context) {
    TextEditingController logController = TextEditingController();

    return Scaffold(
      appBar: AppBar(
        title: Text(widget.habit),
        backgroundColor: Colors.yellowAccent,
      ),
      backgroundColor: Colors.teal,
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
              decoration: InputDecoration(
                labelText: 'Add log',
                filled: true,
                fillColor: Colors.white,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8.0),
                  borderSide: BorderSide.none,
                ),
              ),
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                _addLog(logController.text);
                logController.clear();
              },
              child: Text('Save Log'),
            ),
            ElevatedButton(
              onPressed: _getAIFeedback,
              child: Text('Get AI Feedback'),
            ),
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Text(aiFeedback),
            ),
          ],
        ),
      ),
    );
  }
}
