import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mocktail/mocktail.dart';
import 'package:provider/provider.dart';
import 'package:statera/business_logic/auth/auth_bloc.dart';
import 'package:statera/business_logic/group/group_cubit.dart';
import 'package:statera/business_logic/layout/layout_state.dart';
import 'package:statera/custom_theme_builder.dart';
import 'package:statera/data/models/models.dart';
import 'package:statera/ui/group/settings/group_settings.dart';

main() {
  runApp(GroupSettingsPreview());
}

class GroupCubitMock extends Mock implements GroupCubit {}

class AuthBlocMock extends Mock implements AuthBloc {}

class GroupSettingsPreview extends StatelessWidget {
  const GroupSettingsPreview({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final uid = 'foo';
    final authBloc = AuthBlocMock();
    when(() => authBloc.uid).thenReturn(uid);
    when(() => authBloc.stream).thenAnswer((_) => Stream.fromIterable([]));

    final groupCubit = GroupCubitMock();
    when(() => groupCubit.update(any())).thenAnswer((_) async {});
    when(() => groupCubit.removeMember(any()))
        .thenAnswer((_) => Future.value(null));
    when(() => groupCubit.delete()).thenAnswer((_) {});
    when(() => groupCubit.stream).thenAnswer((_) => Stream.fromIterable([]));
    when(() => groupCubit.state).thenReturn(GroupLoaded(group: Group.empty()));

    return CustomThemeBuilder(
      builder: (lightTheme, darkTheme) {
        return MaterialApp(
          theme: lightTheme,
          darkTheme: darkTheme,
          themeMode: ThemeMode.system,
          home: LayoutBuilder(
            builder: (context, constraints) {
              return Provider<LayoutState>.value(
                value: LayoutState(constraints),
                child: MultiBlocProvider(
                  providers: [
                    BlocProvider<AuthBloc>.value(value: authBloc),
                    BlocProvider<GroupCubit>.value(value: groupCubit),
                  ],
                  child: Scaffold(body: GroupSettings()),
                ),
              );
            },
          ),
        );
      },
    );
  }
}
