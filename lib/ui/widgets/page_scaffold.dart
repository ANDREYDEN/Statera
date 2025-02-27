import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:statera/business_logic/layout/layout_state.dart';

class PageScaffold extends StatelessWidget {
  final Widget child;
  final String? title;
  final Widget? titleWidget;
  final Widget Function(BuildContext, Widget Function(String))? titleBuilder;
  final List<Widget>? actions;
  final Widget? bottomNavBar;
  final String? fabText;
  final void Function()? onFabPressed;
  final void Function(bool didPop)? onPop;
  final Widget? fab;

  const PageScaffold({
    Key? key,
    required this.child,
    this.title,
    this.titleWidget,
    this.actions,
    this.bottomNavBar,
    this.fabText,
    this.onFabPressed,
    this.onPop,
    this.fab,
    this.titleBuilder,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final isWide = context.select((LayoutState state) => state.isWide);

    final actualTitleBuilder = titleBuilder ??
        ((_, titleWidgetBuilder) => titleWidgetBuilder(this.title ?? ''));

    return PopScope(
      onPopInvokedWithResult:
          onPop == null ? null : (didPop, _) => onPop!.call(didPop),
      child: Scaffold(
        bottomNavigationBar: this.bottomNavBar,
        appBar: AppBar(
          title: titleWidget ??
              actualTitleBuilder(
                context,
                (titleText) => SelectableText(
                  titleText,
                  style: TextStyle(overflow: TextOverflow.ellipsis),
                ),
              ),
          actions: this.actions,
        ),
        floatingActionButton: fab ??
            (this.onFabPressed == null
                ? null
                : isWide
                    ? FloatingActionButton.extended(
                        onPressed: this.onFabPressed,
                        icon: Icon(Icons.add),
                        label: Text(fabText ?? 'Add'),
                      )
                    : FloatingActionButton(
                        onPressed: this.onFabPressed,
                        child: Icon(Icons.add),
                      )),
        floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
        body: child,
      ),
    );
  }
}
