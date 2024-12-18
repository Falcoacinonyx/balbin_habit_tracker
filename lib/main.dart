import 'package:flutter/material.dart';
import 'package:flutter_gemini/flutter_gemini.dart';
import 'screens/home_screen.dart';
import 'screens/add_habit_screen.dart';
import 'screens/habit_detail_screen.dart';

const apiKey = 'AIzaSyB0WKuzeLNpqSWwkL06WQB9XZjBuE3TnMQ';

void main() {
  Gemini.init(apiKey: apiKey);
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Habit Tracker App',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      initialRoute: HomeScreen.id,
      onGenerateRoute: (settings) {
        if (settings.name == HabitDetailScreen.id) {
          final String habit = settings.arguments as String;
          return MaterialPageRoute(
            builder: (context) => HabitDetailScreen(habit: habit),
          );
        }
        switch (settings.name) {
          case HomeScreen.id:
            return MaterialPageRoute(builder: (context) => HomeScreen());
          case AddHabitScreen.id:
            return MaterialPageRoute(builder: (context) => AddHabitScreen());
          default:
            return null;
        }
      },
    );
  }
}
