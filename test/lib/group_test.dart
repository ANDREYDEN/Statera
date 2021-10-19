import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:statera/data/models/group.dart';

class MockUser extends Mock implements User {
  MockUser();

  @override
  String get uid => "145";
}

void main() {
  test("can add a member to the group", () {
    var group = Group.fake();
    var mockUser = MockUser();

    group.addUser(mockUser);

    expect(group.members, hasLength(1));
    expect(group.members.first.uid, mockUser.uid);
  });
}