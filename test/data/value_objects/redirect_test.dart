import 'package:flutter_test/flutter_test.dart';
import 'package:statera/data/models/models.dart';
import 'package:statera/data/value_objects/redirect.dart';

void main() {
  group('Redirect', () {
    final ower = CustomUser.fake(uid: 'ower');
    final member = CustomUser.fake(uid: 'member');
    final receiver = CustomUser.fake(uid: 'receiver');

    test('should not execute a redirect that is not valid', () {
      final group = Group.empty(members: [ower, member, receiver]);
      group.balance[ower.uid]![member.uid] = 2;
      group.balance[member.uid]![ower.uid] = -2;
      group.balance[member.uid]![receiver.uid] = 5;
      group.balance[receiver.uid]![member.uid] = -5;

      final redirect = Redirect(ower.uid, 10, member.uid, 10, receiver.uid, 10);

      expect(() => redirect.execute(group), throwsException);
    });
  });
}
