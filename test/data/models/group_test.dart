import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:statera/data/models/group.dart';

class MockUser extends Mock implements User {}

void main() {
  var mockUser = MockUser();

  setUp(() {
    when(() => mockUser.uid).thenReturn("145");
  });

  test("can add a member to the group", () {
    var group = Group.empty();

    group.addUser(mockUser);

    expect(group.members, hasLength(1));
    expect(group.members.first.uid, mockUser.uid);
  });
}
