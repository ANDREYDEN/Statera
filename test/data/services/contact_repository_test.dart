import 'package:fake_cloud_firestore/fake_cloud_firestore.dart';
import 'package:flutter_test/flutter_test.dart';
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

    test('does not duplicate a contact that already exists', () async {
      final firestore = FakeFirebaseFirestore();
      final friend = CustomUser.fake(uid: 'friend', name: 'Friend');

      await firestore
          .collection('users')
          .doc(friend.uid)
          .set(friend.toFirestore());

      final contactRepository = ContactRepository(firestore);

      await contactRepository.addContact(uid, friend.uid);
      await contactRepository.addContact(uid, friend.uid);

      final contacts = await contactRepository.listenForContacts(uid).first;
      expect(contacts, hasLength(1));
    });
  });
}
