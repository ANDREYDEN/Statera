import 'package:fake_cloud_firestore/fake_cloud_firestore.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:statera/data/services/services.dart';

main() {
  group('UserRepository', () {
    late FakeFirebaseFirestore firestore;
    late UserRepository userRepository;

    setUp(() {
      firestore = FakeFirebaseFirestore();
      userRepository = UserRepository(firestore);
    });

    group('tryCreateUser', () {
      test('creates a user that can be read back', () async {
        await userRepository.tryCreateUser(
          uid: 'uid',
          name: 'John',
          photoURL: 'url',
        );

        final user = await userRepository.getUser('uid');
        expect(user.uid, 'uid');
        expect(user.name, 'John');
        expect(user.photoURL, 'url');
      });

      test('does not override an existing user', () async {
        await userRepository.tryCreateUser(uid: 'uid', name: 'John');
        await userRepository.tryCreateUser(uid: 'uid', name: 'Other');

        final user = await userRepository.getUser('uid');
        expect(user.name, 'John');
      });
    });

    group('updateUser', () {
      test('updates only the provided fields', () async {
        await userRepository.tryCreateUser(uid: 'uid', name: 'John');

        await userRepository.updateUser(uid: 'uid', paymentInfo: 'my info');

        final user = await userRepository.getUser('uid');
        expect(user.name, 'John');
        expect(user.paymentInfo, 'my info');
      });
    });
  });
}
