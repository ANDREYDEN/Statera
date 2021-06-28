import 'package:statera/models/item.dart';

class Expense {
  List<Item> expenseItems = [];
  String name;

  Expense({required this.name});
}