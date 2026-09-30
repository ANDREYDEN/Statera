import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:statera/business_logic/auth/auth_bloc.dart';
import 'package:statera/data/exceptions/exceptions.dart';
import 'package:statera/data/models/models.dart';
import 'package:statera/data/services/services.dart';
import 'package:statera/ui/group/members/actions/member_action.dart';
import 'package:statera/utils/utils.dart';

class AddContactAction extends MemberAction {
  final Group group;
  AddContactAction(this.group, super.user);

  @override
  IconData get icon => Icons.person_add;

  @override
  String get name => 'Add to Contacts';

  @override
  Future<void> handle(BuildContext context) async {
    final contactRepository = context.read<ContactRepository>();
    final authBloc = context.read<AuthBloc>();
    final errorService = context.read<ErrorService>();

    await snackbarCatch(context, () async {
      try {
        await contactRepository.addContact(authBloc.uid, user.uid);
      } on EntityNotFoundException catch (_) {
        throw Exception('Contact already exists');
      } catch (e) {
        final errorMessage = 'Failed to add contact';
        await errorService.recordError(e, reason: errorMessage);
        throw Exception(errorMessage);
      }
    }, successMessage: 'Contact added successfully');
  }
}
