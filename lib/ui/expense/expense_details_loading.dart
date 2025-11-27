import 'package:flutter/material.dart';
import 'package:statera/ui/expense/header/header_loading.dart';

class ExpenseDetailsLoading extends StatelessWidget {
  const ExpenseDetailsLoading({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(children: [HeaderLoading()]);
  }
}
