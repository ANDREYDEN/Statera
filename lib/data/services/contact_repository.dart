import 'package:mockito/annotations.dart';
import 'package:statera/data/exceptions/not_found_exception.dart';
import 'package:statera/data/models/contact.dart';
import 'package:statera/data/services/services.dart';

@GenerateNiceMocks([MockSpec<ContactRepository>()])
class ContactRepository extends Firestore {
  ContactRepository(super.firestoreInstance);

  Stream<List<Contact>> listenForContacts(String uid) {
    return getContactsCollection(uid).snapshots().map(
      (snapshot) => snapshot.docs.map((doc) => doc.data()).toList(),
    );
  }

  Future<void> addContact(String uid, String newContactUid) async {
    final contactsCollection = getContactsCollection(uid);
    final existingContactDocSnap = await contactsCollection
        .doc(newContactUid)
        .get();
    final contactExists = existingContactDocSnap.exists;
    if (contactExists) return;

    final userDocSnap = await usersCollection.doc(newContactUid).get();
    if (!userDocSnap.exists)
      throw new EntityNotFoundException(newContactUid, name: 'User');

    final newContactUser = userDocSnap.data()!;
    await contactsCollection
        .doc(newContactUid)
        .set(
          Contact(
            uid: newContactUid,
            name: newContactUser.name,
            photoURL: newContactUser.photoURL,
          ),
        );
  }
}
