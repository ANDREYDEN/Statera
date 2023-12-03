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
    final receiverMember = CustomUser(uid: 'omem', name: 'other member');
    final owerMember = CustomUser(uid: 'amem', name: 'another member');

    test('can get memebers who owe to a given user', () {
      final group = Group.empty(
        members: [member, receiverMember, owerMember],
      );

      group.balance[member.uid]![receiverMember.uid] = 10;
      group.balance[receiverMember.uid]![member.uid] = -10;
      group.balance[owerMember.uid]![member.uid] = 5;
      group.balance[member.uid]![owerMember.uid] = -5;

      final owers = group.getMembersThatOweToUser(member.uid);

      expect(owers, hasLength(1));
      expect(owers, contains(owerMember.uid));
    });

    test('can get memebers who a given user owes to', () {
      final group = Group.empty(
        members: [member, receiverMember, owerMember],
      );

      group.balance[member.uid]![receiverMember.uid] = 10;
      group.balance[receiverMember.uid]![member.uid] = -10;
      group.balance[owerMember.uid]![member.uid] = 5;
      group.balance[member.uid]![owerMember.uid] = -5;

      final receivers = group.getMembersThatUserOwesTo(member.uid);

      expect(receivers, hasLength(1));
      expect(receivers, contains(receiverMember.uid));
    });

    test('can check if redirect is possible', () {
      final group = Group.empty(
        members: [member, receiverMember, owerMember],
      );

      expect(group.canRedirect(member.uid), isFalse);

      group.balance[member.uid]![receiverMember.uid] = 10;
      group.balance[receiverMember.uid]![member.uid] = -10;

      expect(group.canRedirect(member.uid), isFalse);

      group.balance[owerMember.uid]![member.uid] = 5;
      group.balance[member.uid]![owerMember.uid] = -5;

      expect(group.canRedirect(member.uid), isTrue);
    });

    test('can estimate redirect', () {
      final group = Group.empty(
        members: [member, receiverMember, owerMember],
      );

      group.balance[owerMember.uid]![member.uid] = 3;
      group.balance[member.uid]![owerMember.uid] = -3;
      group.balance[member.uid]![receiverMember.uid] = 5;
      group.balance[receiverMember.uid]![member.uid] = -5;

      final (newOwerDebt, newAuthorDebt, redirectedDebt) =
          group.estimateRedirect(
        authorUid: member.uid,
        owerUid: owerMember.uid,
        receiverUid: receiverMember.uid,
      );

      expect(newOwerDebt, equals(0));
      expect(newAuthorDebt, equals(2));
      expect(redirectedDebt, equals(3));
    });

    test('can redirect when ower debt is smaller than member debt', () {
      final group = Group.empty(
        members: [member, receiverMember, owerMember],
      );

      group.balance[owerMember.uid]![member.uid] = 3;
      group.balance[member.uid]![owerMember.uid] = -3;
      group.balance[member.uid]![receiverMember.uid] = 5;
      group.balance[receiverMember.uid]![member.uid] = -5;

      group.redirect(
        authorUid: member.uid,
        owerUid: owerMember.uid,
        receiverUid: receiverMember.uid,
      );

      expect(group.balance[owerMember.uid]![member.uid], equals(0));
      expect(group.balance[member.uid]![owerMember.uid], equals(0));
      expect(group.balance[member.uid]![receiverMember.uid], equals(2));
      expect(group.balance[receiverMember.uid]![member.uid], equals(-2));
      expect(group.balance[owerMember.uid]![receiverMember.uid], equals(3));
      expect(group.balance[receiverMember.uid]![owerMember.uid], equals(-3));
    });

    test('can redirect when ower debt is bigger than member debt', () {
      final group = Group.empty(
        members: [member, receiverMember, owerMember],
      );

      group.balance[owerMember.uid]![member.uid] = 5;
      group.balance[member.uid]![owerMember.uid] = -5;
      group.balance[member.uid]![receiverMember.uid] = 3;
      group.balance[receiverMember.uid]![member.uid] = -3;

      group.redirect(
        authorUid: member.uid,
        owerUid: owerMember.uid,
        receiverUid: receiverMember.uid,
      );

      expect(group.balance[owerMember.uid]![member.uid], equals(2));
      expect(group.balance[member.uid]![owerMember.uid], equals(-2));
      expect(group.balance[member.uid]![receiverMember.uid], equals(0));
      expect(group.balance[receiverMember.uid]![member.uid], equals(-0));
      expect(group.balance[owerMember.uid]![receiverMember.uid], equals(3));
      expect(group.balance[receiverMember.uid]![owerMember.uid], equals(-3));
    });

    test('can suggest best redirect for a given user', () {
      final anotherOwer = CustomUser(uid: 'third', name: 'Third');
      final anotherReceiver = CustomUser(uid: 'fourth', name: 'Fourth');

      final group = Group.empty(
        members: [
          member,
          receiverMember,
          owerMember,
          anotherOwer,
          anotherReceiver
        ],
      );

      group.balance[owerMember.uid]![member.uid] = 5;
      group.balance[member.uid]![owerMember.uid] = -5;
      group.balance[anotherOwer.uid]![member.uid] = 10;
      group.balance[member.uid]![anotherOwer.uid] = -10;
      group.balance[member.uid]![receiverMember.uid] = 3;
      group.balance[receiverMember.uid]![member.uid] = -3;
      group.balance[member.uid]![anotherReceiver.uid] = 7;
      group.balance[anotherReceiver.uid]![member.uid] = -7;

      final (bestOwerUid, bestReceiverUid) = group.getBestRedirect(member.uid);

      expect(bestOwerUid, equals(anotherOwer.uid));
      expect(bestReceiverUid, equals(anotherReceiver.uid));
    });
  });

  group('conversion', () {
    group('to Firestore', () {
      test('maps member ids', () {
        final firstMember = CustomUser(uid: 'first', name: 'First');
        final secondMember = CustomUser(uid: 'second', name: 'Second');
        var group = Group.empty(members: [firstMember, secondMember]);

        var firestoreData = group.toFirestore();

        var memberIds = [firstMember.uid, secondMember.uid];
        expect(firestoreData['memberIds'], equals(memberIds));
      });

      final balanceCases = [(1 / 3, 0.33), (0.999999, 1), (0.000001, 0)];
      for (final (actualBalance, expectedBalance) in balanceCases) {
        test('maps balance from ${actualBalance} to ${expectedBalance}', () {
          final firstMember = CustomUser(uid: 'first', name: 'First');
          final secondMember = CustomUser(uid: 'second', name: 'Second');
          var group = Group.empty(members: [firstMember, secondMember]);
          group.balance[firstMember.uid]![secondMember.uid] = actualBalance;

          final firestoreData = group.toFirestore();

          final firestoreBalance = firestoreData['balance'];

          expect(
            firestoreBalance[firstMember.uid]![secondMember.uid],
            equals(expectedBalance),
          );
        });
      }
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
