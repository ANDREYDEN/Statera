part of 'debt_redirection_cubit.dart';

abstract class DebtRedirectionState {}

class DebtRedirectionLoaded extends DebtRedirectionState {
  final String uid;
  final Group group;
  late final String owerUid;
  late final String receiverUid;
  late List<String> owerUids;
  late List<String> receiverUids;
  late final double newOwerDebt;
  late final double newAuthorDebt;

  DebtRedirectionLoaded.initial({
    required this.uid,
    required this.group
  }) {
    owerUids = group.getMembersThatOweToUser(uid);
    receiverUids = group.getMembersThatUserOwesTo(uid);

    final (bestOwerUid, bestReceiverUid) = group.getBestRedirect(uid);
    owerUid = bestOwerUid;
    receiverUid = bestReceiverUid;

    final (newOwerDebt, newAuthorDebt, _) = group.estimateRedirect(
      authorUid: uid,
      owerUid: owerUid,
      receiverUid: receiverUid,
    );
    this.newAuthorDebt = newAuthorDebt;
    this.newOwerDebt = newOwerDebt;
  }

  DebtRedirectionLoaded({
    required this.uid,
    required this.group,
    required this.owerUid,
    required this.receiverUid,
    required this.owerUids,
    required this.receiverUids,
    required this.newOwerDebt,
    required this.newAuthorDebt,
  });

  DebtRedirectionLoaded copyWith({
    String? owerUid,
    String? receiverUid,
    double? newOwerDebt,
    double? newAuthorDebt,
  }) {
    return DebtRedirectionLoaded(
      uid: uid,
      group: group,
      owerUid: owerUid ?? this.owerUid,
      receiverUid: receiverUid ?? this.receiverUid,
      owerUids: owerUids,
      receiverUids: receiverUids,
      newOwerDebt: newOwerDebt ?? this.newOwerDebt,
      newAuthorDebt: newAuthorDebt ?? this.newAuthorDebt,
    );
  }

  CustomUser get ower => group.getMember(owerUid);
  CustomUser get author => group.getMember(uid);
  CustomUser get receiver => group.getMember(receiverUid);

  double get owerDebt => group.balance[owerUid]![uid]!;
  double get authorDebt => group.balance[uid]![receiverUid]!;
}

class DebtRedirectionImpossible extends DebtRedirectionState {}

class DebtRedirectionOff extends DebtRedirectionState {}