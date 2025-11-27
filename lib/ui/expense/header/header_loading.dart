import 'package:flutter/material.dart';
import 'package:statera/data/models/models.dart';
import 'package:statera/ui/widgets/loading_text.dart';
import 'package:statera/ui/widgets/user_avatar.dart';

class HeaderLoading extends StatelessWidget {
  const HeaderLoading({super.key});

  @override
  Widget build(BuildContext context) {
    return Card(
      clipBehavior: Clip.antiAlias,
      margin: EdgeInsets.symmetric(horizontal: 20, vertical: 10),
      child: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [Colors.grey, Theme.of(context).colorScheme.surface],
            stops: [0, 0.8],
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.all(15),
          child: Column(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  LoadingText(height: 24, width: 150),
                  LoadingText(height: 20, width: 60, radius: 20),
                ],
              ),
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 10.0),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Icon(Icons.calendar_month, size: 20, color: Colors.black),
                    SizedBox(width: 10),
                    LoadingText(height: 15, width: 70),
                  ],
                ),
              ),
              Row(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Expanded(
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        UserAvatar(author: CustomUser.fake(), loading: true),
                        Icon(Icons.arrow_forward, color: Colors.black),
                        ...List.generate(
                          3,
                          (_) => UserAvatar(
                            author: CustomUser.fake(),
                            loading: true,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
