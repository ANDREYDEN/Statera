import 'package:mockito/annotations.dart';
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
}
