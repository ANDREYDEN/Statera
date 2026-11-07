import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:statera/business_logic/auth/auth_bloc.dart';
import 'package:statera/business_logic/payments/new_payments_cubit.dart';
import 'package:statera/data/models/models.dart';
import 'package:statera/data/services/contact_repository.dart';
import 'package:statera/ui/contacts/add_contact_button.dart';
import 'package:statera/ui/contacts/contact_list_item.dart';
import 'package:statera/ui/contacts/empty_contacts_list.dart';
import 'package:statera/ui/styling/index.dart';
import 'package:statera/ui/widgets/edge_fade.dart';

class ContactsList extends StatelessWidget {
  const ContactsList({super.key});

  @override
  Widget build(BuildContext context) {
    final contactsRepository = context.read<ContactRepository>();
    final uid = context.select<AuthBloc, String>((authBloc) => authBloc.uid);
    const padding = Spacing.l_20;

    return StreamBuilder(
      stream: contactsRepository.listenForContacts(uid),
      builder: (context, snap) {
        if (snap.error != null) {
          return Center(child: Text(snap.error.toString()));
        }

        final contacts = snap.data ?? [];

        final nameHeight = contacts.isEmpty ? 0 : 15;

        return Container(
          height: ContactListItem.dimention + nameHeight + 2 * padding,
          padding: const EdgeInsets.symmetric(vertical: padding),
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.surfaceContainer,
            borderRadius: BorderRad.m_20,
          ),
          child: contacts.isEmpty
              ? const Padding(
                  padding: EdgeInsets.symmetric(horizontal: padding),
                  child: EmptyContactsList(),
                )
              : BlocBuilder<NewPaymentsCubit, NewPaymentsState>(
                  builder: (context, paymentsState) {
                    final sortedContacts = _sortByMostRecentNewPayment(
                      contacts,
                      paymentsState.mostRecentPaymentMap,
                    );
                    final newPaymentCount = paymentsState.paymentCount;

                    return EdgeFade(
                      builder: (context, controller) => ListView.builder(
                        controller: controller,
                        scrollDirection: Axis.horizontal,
                        itemCount: sortedContacts.length + 1,
                        itemBuilder: (context, i) {
                          if (i == 0) {
                            return Padding(
                              padding: const EdgeInsets.only(
                                left: Spacing.m_10,
                              ),
                              child: AddContactButton(),
                            );
                          }

                          final contact = sortedContacts[i - 1];
                          return ContactListItem(
                            contact: contact,
                            newPaymentsCount: newPaymentCount[contact.uid] ?? 0,
                          );
                        },
                      ),
                    );
                  },
                ),
        );
      },
    );
  }

  List<Contact> _sortByMostRecentNewPayment(
    List<Contact> contacts,
    Map<String, DateTime> mostRecentPayments,
  ) {
    final result = [...contacts];
    result.sort((a, b) {
      final aDate = mostRecentPayments[a.uid];
      final bDate = mostRecentPayments[b.uid];

      if (aDate == null && bDate != null) return 1;
      if (aDate != null && bDate == null) return -1;
      if (aDate != null && bDate != null) {
        final dateComparison = bDate.compareTo(aDate);
        if (dateComparison != 0) return dateComparison;
      }

      return a.name.toLowerCase().compareTo(b.name.toLowerCase());
    });

    return result;
  }
}
