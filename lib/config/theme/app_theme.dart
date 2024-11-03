import 'package:flutter/material.dart';

const colorLists = <Color>[
  Colors.blue,
  Colors.red,
  Colors.green,
  Colors.purple,
  Colors.deepPurple,
  Colors.orange,
  Colors.pink,
  Colors.yellow,
];

class AppTheme {
  final int selectedColor;
  final bool darkMode;

  AppTheme({this.selectedColor = 0, this.darkMode = false})
      : assert(selectedColor >= 0, 'Selected color must be greater then 0'),
        assert(selectedColor < colorLists.length,
            'Selected color must be lees or equal than ${colorLists.length - 1}');

  ThemeData getTheme() => ThemeData(
      useMaterial3: true,
      brightness: darkMode ? Brightness.dark : Brightness.light,
      colorSchemeSeed: colorLists[selectedColor],
      appBarTheme: const AppBarTheme(centerTitle: true));
}
