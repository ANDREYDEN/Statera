import 'package:flutter/material.dart';

class CustomFilterChip extends StatelessWidget {
  final Color color;
  final List<String> filtersList;
  final String label;
  final Function(bool)? onSelected;

  const CustomFilterChip({
    Key? key,
    required this.color,
    required this.filtersList,
    required this.label,
    this.onSelected,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(left: 8.0),
      child: FilterChip(
        label: Text(this.label),
        selected: this.filtersList.contains(this.label),
        backgroundColor: this.color,
        selectedColor: this.color,
        onSelected: (selected) {
          if (selected) {
            this.filtersList.add(this.label);
          } else if (this.filtersList.length > 1) {
            this.filtersList.remove(this.label);
          }
          
          if (this.onSelected != null) {
            this.onSelected!(selected);
          }
        },
      ),
    );
  }
}
