import 'dart:math';

import 'package:flutter/material.dart';
import 'package:statera/ui/widgets/buttons/ok_button.dart';
import 'package:statera/ui/widgets/section_title.dart';

class DebtRedirectExplainerDialog extends StatelessWidget {
  const DebtRedirectExplainerDialog({super.key});

  get _alice => TextSpan(
        text: ' Alice',
        style: TextStyle(color: Colors.blue),
      );

  get _bob => TextSpan(
        text: ' Bob',
        style: TextStyle(color: Colors.red),
      );

  @override
  Widget build(BuildContext context) {
    final isLightMode =
        Theme.of(context).colorScheme.brightness == Brightness.light;

    return AlertDialog(
      title: Text('Debt Redirection'),
      content: SizedBox(
        width: min(600, MediaQuery.of(context).size.width - 100),
        child: ListView(
          shrinkWrap: true,
          children: [
            Text(
              'Debt redirection allows you to eliminate transactions when there are people that owe you and you have some debt of your own.',
            ),
            SizedBox(height: 10),
            SectionTitle('Example 1'),
            SizedBox(height: 10),
            Text.rich(
              TextSpan(
                text: "Let's say",
                children: [
                  _alice,
                  TextSpan(text: ' owes you \$5 and you owe'),
                  _alice,
                  TextSpan(
                    text:
                        ', which means that she can pay Bob directly and also owe you less:',
                  ),
                  _bob,
                  TextSpan(
                    text:
                        ' \$3. You can remove yourself as the middleman by redirecting \$3 of your debt to',
                  ),
                  _alice,
                  TextSpan(text: ' which means that she can pay'),
                  _bob,
                  TextSpan(text: ' directly and also owe you less:'),
                ],
              ),
            ),
            SizedBox(height: 10),
            ClipRRect(
              borderRadius: BorderRadius.circular(10),
              child: Image.asset(
                isLightMode
                    ? 'images/debt_redirect_example1_light.png'
                    : 'images/debt_redirect_example1_dark.png',
              ),
            ),
            SizedBox(height: 20),
            SectionTitle('Example 2'),
            SizedBox(height: 10),
            Text.rich(
              TextSpan(
                text: 'This time',
                children: [
                  _alice,
                  TextSpan(text: ' owes you \$40 and you owe'),
                  _bob,
                  TextSpan(
                      text: ' \$100. Here you can completely redirect all of'),
                  _alice,
                  TextSpan(text: "'s debt to"),
                  _bob,
                  TextSpan(text: ', so that you pay'),
                  _bob,
                  TextSpan(text: ' less and'),
                  _alice,
                  TextSpan(text: " doesn't owe you at all:"),
                ],
              ),
            ),
            SizedBox(height: 10),
            ClipRRect(
              borderRadius: BorderRadius.circular(10),
              child: Image.asset(
                isLightMode
                    ? 'images/debt_redirect_example2_light.png'
                    : 'images/debt_redirect_example2_dark.png',
              ),
            ),
            SizedBox(height: 10),
            Text.rich(
              TextSpan(
                text: 'Note that in both examples',
                children: [
                  _alice,
                  TextSpan(text: ' might have existing debt to'),
                  _bob,
                  TextSpan(
                    text:
                        ', in that case the redirected debt is simply added to the existing debt.',
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
      actions: [OkButton()],
    );
  }
}
