import 'package:flutter/material.dart';

class AddHabitScreen extends StatelessWidget {
  static const String id = 'add_habit_screen';

  final TextEditingController habitController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Add Habit'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            TextField(
              controller: habitController,
              decoration: InputDecoration(labelText: 'Habit Name'),
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                Navigator.pop(context, habitController.text);
              },
              child: Text('Save Habit'),
            ),
          ],
        ),
      ),
    );
  }
}
