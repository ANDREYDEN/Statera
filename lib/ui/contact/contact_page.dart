import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:statera/business_logic/user/user_cubit.dart';
import 'package:statera/data/services/services.dart';
import 'package:statera/ui/authentication/user_builder.dart';
import 'package:statera/ui/contact/contact_header/contact_header.dart';
import 'package:statera/ui/widgets/page_scaffold.dart';

class ContactPage extends StatelessWidget {
  static String name = 'ContactPage';

  const ContactPage({super.key});

  static Widget init(String? contactId) {
    return MultiBlocProvider(
      providers: [
        BlocProvider<UserCubit>(
          create: (context) => UserCubit(
            context.read<UserRepository>(),
            context.read<ErrorService>(),
          )..load(contactId),
        ),
      ],
      child: ContactPage(),
    );
  }

  @override
  Widget build(BuildContext context) {
    return PageScaffold(
      titleBuilder: (context, titleWidgetBuilder) => UserBuilder(
        loadingWidget: Text('... Payments'),
        builder: (context, user) {
          return titleWidgetBuilder('${user.name} Payments');
        },
        errorBuilder: (context, error) => titleWidgetBuilder('Error'),
      ),
      child: ContactHeader(),
    );
  }
}
