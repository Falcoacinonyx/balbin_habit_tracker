import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_gemini/flutter_gemini.dart';
import 'dart:async';
import 'add_habit_screen.dart';
import 'habit_detail_screen.dart';

class HomeScreen extends StatefulWidget {
  static const String id = 'home_screen';

  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  List<String> habits = [];
  String aiFeedback = '';
  Color borderColor = Colors.red;
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _loadHabits();
    _startRainbowBorderAnimation();
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  void _loadHabits() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      habits = (prefs.getStringList('habits') ?? []);
    });
  }

  void _saveHabits() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.setStringList('habits', habits);
  }

  void _removeHabit(int index) {
    setState(() {
      habits.removeAt(index);
      _saveHabits();
    });
  }

  void _showRemoveHabitDialog(int index) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Confirm Removal'),
          content: Text('Are you sure you want to remove this habit?'),
          actions: <Widget>[
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Text('Cancel'),
            ),
            TextButton(
              onPressed: () {
                _removeHabit(index);
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
    String logs = '';
    for (String habit in habits) {
      logs += 'Habit: $habit\n' + (prefs.getStringList('${habit}_logs') ?? []).join('\n') + '\n';
    }

    try {
      final response = await Gemini.instance.prompt(parts: [
        Part.text('Provide a short, encouraging, and motivational feedback on these habit logs:\n$logs\nAlso suggest improvements. (2-3 sentences overall only)'),
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

  void _startRainbowBorderAnimation() {
    List<Color> colors = [
      Colors.red, Colors.orange, Colors.yellow,
      Colors.green, Colors.blue, Colors.indigo, Colors.purple
    ];
    int colorIndex = 0;

    _timer = Timer.periodic(Duration(milliseconds: 500), (timer) {
      setState(() {
        borderColor = colors[colorIndex];
        colorIndex = (colorIndex + 1) % colors.length;
      });
    });
  }

  void _clearAIFeedback() {
    setState(() {
      aiFeedback = '';
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Habit Tracker'),
        backgroundColor: Colors.yellowAccent, // Changed the app bar color
      ),
      backgroundColor: Colors.teal, // Changed the background color
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Expanded(
              child: ListView.builder(
                itemCount: habits.length,
                itemBuilder: (context, index) {
                  return Card(
                    margin: EdgeInsets.symmetric(vertical: 10.0),
                    child: ListTile(
                      title: Text(
                        habits[index],
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                      onTap: () {
                        Navigator.pushNamed(
                          context,
                          HabitDetailScreen.id,
                          arguments: habits[index],
                        );
                      },
                      trailing: IconButton(
                        icon: Icon(Icons.delete, color: Colors.red),
                        onPressed: () {
                          _showRemoveHabitDialog(index);
                        },
                      ),
                    ),
                  );
                },
              ),
            ),
            GestureDetector(
              onTap: _getAIFeedback,
              child: AnimatedContainer(
                duration: Duration(milliseconds: 500),
                decoration: BoxDecoration(
                  color: Colors.yellowAccent,
                  border: Border.all(color: borderColor, width: 3.0),
                  borderRadius: BorderRadius.circular(8.0),
                ),
                padding: EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
                child: Text(
                  'Get AI Feedback',
                  style: TextStyle(fontSize: 16.0, fontWeight: FontWeight.bold),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 16.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Text(
                      aiFeedback,
                      style: TextStyle(fontSize: 16.0),
                    ),
                  ),
                  Ink(
                    decoration: ShapeDecoration(
                      color: Colors.red,
                      shape: CircleBorder(),
                    ),
                    child: IconButton(
                      icon: Icon(Icons.close, color: Colors.white),
                      onPressed: _clearAIFeedback,
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(height: 80),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          final newHabit = await Navigator.pushNamed(context, AddHabitScreen.id);
          if (newHabit != null) {
            setState(() {
              habits.add(newHabit as String);
              _saveHabits();
            });
          }
        },
        child: Icon(Icons.add),
        backgroundColor: Colors.yellow,
      ),
    );
  }
}
