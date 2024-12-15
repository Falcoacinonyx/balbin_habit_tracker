import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'add_habit_screen.dart';
import 'habit_detail_screen.dart';

class HomeScreen extends StatefulWidget {
  static const String id = 'home_screen';

  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  List<String> habits = [];

  @override
  void initState() {
    super.initState();
    _loadHabits();
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Habit Tracker'),
      ),
      body: ListView.builder(
        itemCount: habits.length,
        itemBuilder: (context, index) {
          return ListTile(
            title: Text(habits[index]),
            onTap: () {
              Navigator.pushNamed(
                context,
                HabitDetailScreen.id,
                arguments: habits[index],
              );
            },
            trailing: IconButton(
              icon: Icon(Icons.delete),
              onPressed: () {
                _showRemoveHabitDialog(index);
              },
            ),
          );
        },
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
      ),
    );
  }
}
