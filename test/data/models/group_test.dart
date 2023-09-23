import 'package:flutter_test/flutter_test.dart';
import 'package:statera/data/models/models.dart';

void main() {
  const mockUserId = '145';
  CustomUser mockUser = CustomUser(uid: mockUserId, name: 'Foo');

  test('should generate code if not provided', () {
    final group = Group.empty();

    expect(group.code, isNotNull);
  });

  test('can get owings for user', () {
    final firstMember = CustomUser(uid: 'first', name: 'First');
    final secondMember = CustomUser(uid: 'second', name: 'Second');
    final thirdMember = CustomUser(uid: 'third', name: 'Third');

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
      final existingMember = CustomUser.fake();
      var group = Group.empty(members: [existingMember]);

      group.addMember(mockUser);

      expect(group.balance.keys.toList(), contains(mockUserId));
      expect(group.balance[existingMember.uid], contains(mockUserId));
      expect(group.balance[mockUserId], contains(existingMember.uid));
    });
  });

  group('admin', () {
    test('if set, retrieves matching member information', () {
      final firstMember = CustomUser(uid: 'first', name: 'First');
      final secondMember = CustomUser(uid: 'second', name: 'Second');

      final group = Group.empty(
        members: [firstMember, secondMember],
        adminId: secondMember.uid,
      );

      expect(group.admin, equals(secondMember));
    });

    test('if not set, defaults to the first member', () {
      final firstMember = CustomUser(uid: 'first', name: 'First');
      final secondMember = CustomUser(uid: 'second', name: 'Second');

      final group = Group.empty(members: [firstMember, secondMember]);

      expect(group.admin, equals(firstMember));
    });

    test('can be checked', () {
      final firstMember = CustomUser(uid: 'first', name: 'First');
      final secondMember = CustomUser(uid: mockUserId, name: 'Second');

      final group = Group.empty(
        members: [firstMember, secondMember],
        adminId: secondMember.uid,
      );

      expect(group.isAdmin(mockUserId), isTrue);
    });
  });

  group('redirects', () {
    final member = CustomUser(uid: 'mem', name: 'member');
    final otherMember = CustomUser(uid: 'omem', name: 'other member');
    final anotherMember = CustomUser(uid: 'amem', name: 'another member');

    test('can get memebers who owe to a given user', () {

      final group = Group.empty(
        members: [member, otherMember, anotherMember],
      );

      group.balance[member.uid]![otherMember.uid] = 10;
      group.balance[otherMember.uid]![member.uid] = -10;
      group.balance[anotherMember.uid]![member.uid] = 5;
      group.balance[member.uid]![anotherMember.uid] = -5;

      final owers = group.getMembersThatOweToUser(member.uid);

      expect(owers, hasLength(1));
      expect(owers, contains(anotherMember.uid));
    });

    test('can get memebers who a given user owes to', () {
      final group = Group.empty(
        members: [member, otherMember, anotherMember],
      );

      group.balance[member.uid]![otherMember.uid] = 10;
      group.balance[otherMember.uid]![member.uid] = -10;
      group.balance[anotherMember.uid]![member.uid] = 5;
      group.balance[member.uid]![anotherMember.uid] = -5;

      final receivers = group.getMembersThatUserOwesTo(member.uid);

      expect(receivers, hasLength(1));
      expect(receivers, contains(otherMember.uid));
    });

    test('can check if redirect is possible', () {
      final group = Group.empty(
        members: [member, otherMember, anotherMember],
      );

      expect(group.canRedirect(member.uid), isFalse);

      group.balance[member.uid]![otherMember.uid] = 10;
      group.balance[otherMember.uid]![member.uid] = -10;

      expect(group.canRedirect(member.uid), isFalse);

      group.balance[anotherMember.uid]![member.uid] = 5;
      group.balance[member.uid]![anotherMember.uid] = -5;

      expect(group.canRedirect(member.uid), isTrue);
    });

    test('can redirect when ower debt is smaller than member debt', () {
      final group = Group.empty(
        members: [member, otherMember, anotherMember],
      );

      group.balance[anotherMember.uid]![member.uid] = 3;
      group.balance[member.uid]![anotherMember.uid] = -3;
      group.balance[member.uid]![otherMember.uid] = 5;
      group.balance[otherMember.uid]![member.uid] = -5;

      group.redirect(
        authorUid: member.uid,
        owerUid: anotherMember.uid,
        receiverUid: otherMember.uid,
      );

      expect(group.balance[anotherMember.uid]![member.uid], equals(0));
      expect(group.balance[member.uid]![anotherMember.uid], equals(0));
      expect(group.balance[member.uid]![otherMember.uid], equals(2));
      expect(group.balance[otherMember.uid]![member.uid], equals(-2));
      expect(group.balance[anotherMember.uid]![otherMember.uid], equals(3));
      expect(group.balance[otherMember.uid]![anotherMember.uid], equals(-3));
    });

    test('can redirect when ower debt is bigger than member debt', () {
      final group = Group.empty(
        members: [member, otherMember, anotherMember],
      );

      group.balance[anotherMember.uid]![member.uid] = 5;
      group.balance[member.uid]![anotherMember.uid] = -5;
      group.balance[member.uid]![otherMember.uid] = 3;
      group.balance[otherMember.uid]![member.uid] = -3;

      group.redirect(
        authorUid: member.uid,
        owerUid: anotherMember.uid,
        receiverUid: otherMember.uid,
      );

      expect(group.balance[anotherMember.uid]![member.uid], equals(2));
      expect(group.balance[member.uid]![anotherMember.uid], equals(-2));
      expect(group.balance[member.uid]![otherMember.uid], equals(0));
      expect(group.balance[otherMember.uid]![member.uid], equals(-0));
      expect(group.balance[anotherMember.uid]![otherMember.uid], equals(3));
      expect(group.balance[otherMember.uid]![anotherMember.uid], equals(-3));
    });
  });

  group('conversion', () {
    test('to Firestore maps member ids', () {
      final firstMember = CustomUser(uid: 'first', name: 'First');
      final secondMember = CustomUser(uid: 'second', name: 'Second');
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
