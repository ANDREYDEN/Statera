import '../models/models.dart';

class Redirect {
  final String owerUid;
  final double newOwerDebt;
  final String authorUid;
  final double newAuthorDebt;
  final String receiverUid;
  final double redirectedBalance;

  Redirect(
    this.owerUid,
    this.newOwerDebt,
    this.authorUid,
    this.newAuthorDebt,
    this.receiverUid,
    this.redirectedBalance,
  );

  void execute(Group group) {
    group.balance[owerUid]![authorUid] = newOwerDebt;
    group.balance[authorUid]![owerUid] = -newOwerDebt;

    group.balance[authorUid]![receiverUid] = newAuthorDebt;
    group.balance[receiverUid]![authorUid] = -newAuthorDebt;

    group.balance[owerUid]![receiverUid] =
        group.balance[owerUid]![receiverUid]! + redirectedBalance;
    group.balance[receiverUid]![owerUid] =
        group.balance[receiverUid]![owerUid]! - redirectedBalance;
  }
}
