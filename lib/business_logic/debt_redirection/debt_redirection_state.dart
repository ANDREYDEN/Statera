part of 'debt_redirection_cubit.dart';

abstract class DebtRedirectionState {}

class DebtRedirectionLoaded extends DebtRedirectionState {
  late final String uid;
  late final Group group;
  late final String owerUid;
  late final String receiverUid;
  late List<String> owerUids;
  late List<String> receiverUids;
  late Redirect redirect;

  DebtRedirectionLoaded(
      {required this.uid,
      required this.group,
      required this.owerUid,
      required this.receiverUid,
      required this.owerUids,
      required this.receiverUids,
      required this.redirect});

  DebtRedirectionLoaded.initial({required this.uid, required this.group}) {
    owerUids = group.getMembersThatOweToUser(uid);
    receiverUids = group.getMembersThatUserOwesTo(uid);

    final (bestOwerUid, bestReceiverUid) = group.getBestRedirect(uid);
    owerUid = bestOwerUid;
    receiverUid = bestReceiverUid;

    redirect = group.estimateRedirect(
      authorUid: uid,
      owerUid: owerUid,
      receiverUid: receiverUid,
    );
  }

  DebtRedirectionLoaded.fake({
    this.owerUids = const [],
    this.receiverUids = const [],
  }) {
    this.uid = 'uid';
    this.owerUid = 'owerUid';
    this.receiverUid = 'receiverUid';
    this.group = Group(
      name: 'group',
      members: [uid, owerUid, receiverUid]
          .map((e) => CustomUser(name: e, uid: e))
          .toList(),
    );
    this.redirect = Redirect('owerUid', 0, 'uid', 0, 'receiverUid', 0);
  }

  DebtRedirectionLoaded copyWith({
    String? owerUid,
    String? receiverUid,
    Redirect? redirect,
  }) {
    return DebtRedirectionLoaded(
      uid: uid,
      group: group,
      owerUid: owerUid ?? this.owerUid,
      receiverUid: receiverUid ?? this.receiverUid,
      owerUids: owerUids,
      receiverUids: receiverUids,
      redirect: redirect ?? this.redirect,
    );
  }

  CustomUser get ower => group.getMember(owerUid);
  CustomUser get author => group.getMember(uid);
  CustomUser get receiver => group.getMember(receiverUid);

  double get owerDebt => group.balance[owerUid]![uid]!;
  double get authorDebt => group.balance[uid]![receiverUid]!;
}

class DebtRedirectionLoading extends DebtRedirectionState {}

class DebtRedirectionImpossible extends DebtRedirectionState {}

class DebtRedirectionOff extends DebtRedirectionState {}
