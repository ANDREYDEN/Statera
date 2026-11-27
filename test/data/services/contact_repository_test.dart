import 'package:fake_cloud_firestore/fake_cloud_firestore.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:statera/data/exceptions/exceptions.dart';
import 'package:statera/data/models/models.dart';
import 'package:statera/data/services/services.dart';

main() {
  group('ContactRepository', () {
    const uid = 'me';

    test('adds a contact and reads it back with the correct uid', () async {
      // arrange
      final firestore = FakeFirebaseFirestore();
      final friend = CustomUser.fake(uid: 'friend', name: 'Friend');

      await firestore
          .collection('users')
          .doc(friend.uid)
          .set(friend.toFirestore());

      final contactRepository = ContactRepository(firestore);

      // act
      await contactRepository.addContact(uid, friend.uid);
      final contacts = await contactRepository.listenForContacts(uid).first;

      // assert
      expect(contacts, hasLength(1));
      expect(contacts.first.uid, friend.uid);
      expect(contacts.first.name, friend.name);
    });

    test(
      'throws a ConflictException and does not duplicate an existing contact',
      () async {
        final firestore = FakeFirebaseFirestore();
        final friend = CustomUser.fake(uid: 'friend', name: 'Friend');

        await firestore
            .collection('users')
            .doc(friend.uid)
            .set(friend.toFirestore());

        final contactRepository = ContactRepository(firestore);

        await contactRepository.addContact(uid, friend.uid);
        await expectLater(
          contactRepository.addContact(uid, friend.uid),
          throwsA(isA<ConflictException>()),
        );

        final contacts = await contactRepository.listenForContacts(uid).first;
        expect(contacts, hasLength(1));
      },
    );

    test('throws an EntityNotFoundException when the user does not exist', () {
      final contactRepository = ContactRepository(FakeFirebaseFirestore());

      expect(
        contactRepository.addContact(uid, 'missing'),
        throwsA(isA<EntityNotFoundException>()),
      );
    });

    test('stores the contact uid in the contact document', () async {
      final firestore = FakeFirebaseFirestore();
      final friend = CustomUser.fake(uid: 'friend', name: 'Friend');
      await firestore
          .collection('users')
          .doc(friend.uid)
          .set(friend.toFirestore());

      await ContactRepository(firestore).addContact(uid, friend.uid);

      final contactDoc = await firestore
          .collection('users')
          .doc(uid)
          .collection('contacts')
          .doc(friend.uid)
          .get();
      expect(contactDoc.data()?['uid'], friend.uid);
    });
  });
}
