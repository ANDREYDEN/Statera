import 'package:flutter/material.dart';

class CustomFilterChip extends StatelessWidget {
  final Color color;
  final bool selected;
  final String label;
  final Function(bool)? onSelected;

  const CustomFilterChip({
    Key? key,
    required this.color,
    required this.label,
    this.selected = false,
    this.onSelected,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(right: 8.0),
      child: FilterChip(
        label: Text(this.label),
        labelStyle: TextStyle(color: Colors.black),
        checkmarkColor: Colors.black,
        selected: this.selected,
        backgroundColor: this.color,
        selectedColor: this.color,
        onSelected: this.onSelected,
      ),
    );
  }
}
