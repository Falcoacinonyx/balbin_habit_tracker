import 'package:flutter/material.dart';

class AddHabitScreen extends StatelessWidget {
  static const String id = 'add_habit_screen';

  final TextEditingController habitController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Add Habit'),
        backgroundColor: Colors.yellowAccent,
      ),
      backgroundColor: Colors.teal,
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            TextField(
              controller: habitController,
              decoration: InputDecoration(
                labelText: 'Habit Name',
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
                Navigator.pop(context, habitController.text);
              },
              child: Text('Save Habit'),
              style: ElevatedButton.styleFrom(
                foregroundColor: Colors.black, backgroundColor: Colors.yellowAccent,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
