import 'package:flutter_test/flutter_test.dart';
import 'package:statera/data/models/models.dart';

void main() {
  const mockUserId = '145';
  Author mockUser = Author(uid: mockUserId, name: 'Foo');

  test('should generate code if not provided', () {
    final group = Group.empty();

    expect(group.code, isNotNull);
  });

  test('can get owings for user', () {
    final firstMember = Author(uid: 'first', name: 'First');
    final secondMember = Author(uid: 'second', name: 'Second');
    final thirdMember = Author(uid: 'third', name: 'Third');

    final group = Group.empty(
      members: [firstMember, secondMember, thirdMember],
    );

    final owings = group.getOwingsForUser(secondMember.uid);

    expect(owings, contains(firstMember));
    expect(owings, isNot(contains(secondMember)));
    expect(owings, contains(thirdMember));
  });

  group('when adding a new member', () {
    test('adds them to the members list', () {
      final group = Group.empty();

      group.addMember(mockUser);

      expect(group.members, hasLength(1));
      expect(group.members.first.uid, equals(mockUser.uid));
    });

    test('adds new balance entries', () {
      final existingMember = Author.fake();
      var group = Group.empty(members: [existingMember]);

      group.addMember(mockUser);

      expect(group.balance.keys.toList(), contains(mockUserId));
      expect(group.balance[existingMember.uid], contains(mockUserId));
      expect(group.balance[mockUserId], contains(existingMember.uid));
    });
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

    test('can be checked', () {
      final firstMember = Author(uid: 'first', name: 'First');
      final secondMember = Author(uid: mockUserId, name: 'Second');

      final group = Group.empty(
        members: [firstMember, secondMember],
        adminId: secondMember.uid,
      );

      expect(group.isAdmin(mockUserId), isTrue);
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
        'adminId': adminId,
        'members': [
          {'uid': adminId, 'name': 'admin'}
        ]
      };

      final group = Group.fromFirestore(firestoreData, id: id);
      expect(group.id, equals(id));
      expect(group.name, equals(name));
      expect(group.admin.uid, equals(adminId));
    });
  });
}
