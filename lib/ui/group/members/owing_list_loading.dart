import 'package:flutter/material.dart';
import 'package:statera/ui/group/members/owing_list_item_loading.dart';

class OwingListLoading extends StatelessWidget {
  const OwingListLoading({super.key});

  @override
  Widget build(BuildContext context) {
    return ListView.separated(
      itemCount: 3,
      itemBuilder: ((context, index) => OwingListItemLoading()),
      separatorBuilder: (context, index) => Divider(height: 10),
    );
  }
}
