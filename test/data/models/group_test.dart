import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:statera/data/models/models.dart';

class MockUser extends Mock implements User {}

void main() {
  var mockUser = MockUser();

  setUp(() {
    when(() => mockUser.uid).thenReturn('145');
  });

  test('can add a member to the group', () {
    var group = Group.empty();

    group.addUser(mockUser);

    expect(group.members, hasLength(1));
    expect(group.members.first.uid, mockUser.uid);
  });

  group('admin', () {
    test('if set, retrieves matching member information', () {
      final firstMember = Author(uid: 'first', name: 'First');
      final secondMember = Author(uid: 'second', name: 'Second');

      final group = Group.empty(
        members: [firstMember, secondMember],
        adminId: secondMember.uid,
      );

      expect(group.admin, equals(secondMember));
    });

    test('if not set, defaults to the first member', () {
      final firstMember = Author(uid: 'first', name: 'First');
      final secondMember = Author(uid: 'second', name: 'Second');

      final group = Group.empty(members: [firstMember, secondMember]);

      expect(group.admin, equals(firstMember));
    });
  });

  group('conversion', () {
    test('to Firestore maps member ids', () {
      final firstMember = Author(uid: 'first', name: 'First');
      final secondMember = Author(uid: 'second', name: 'Second');
      var group = Group.empty(members: [firstMember, secondMember]);

      var firestoreData = group.toFirestore();

      var memberIds = [firstMember.uid, secondMember.uid];
      expect(firestoreData['memberIds'], equals(memberIds));
    });

    test('parses Firestore document data', () {
      const id = 'foo';
      const name = 'Foo';
      const adminId = 'FooAdmin';

      Map<String, dynamic> firestoreData = {
        'name': name,
        'adminId': adminId
      };

      final group = Group.fromFirestore(firestoreData, id: id);
      expect(group.id, equals(id));
      expect(group.name, equals(name));
      expect(group.adminId, equals(adminId));
    });
  });
}
