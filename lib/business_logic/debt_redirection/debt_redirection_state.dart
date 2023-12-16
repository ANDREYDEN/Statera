part of 'debt_redirection_cubit.dart';

abstract class DebtRedirectionState {}

class DebtRedirectionLoaded extends DebtRedirectionState {
  late final Group group;
  late List<String> owerUids;
  late List<String> receiverUids;
  late Redirect redirect;

  DebtRedirectionLoaded({
    required this.group,
    required this.owerUids,
    required this.receiverUids,
    required this.redirect,
  });

  DebtRedirectionLoaded.initial({uid, required this.group}) {
    owerUids = group.getMembersThatOweToUser(uid);
    receiverUids = group.getMembersThatUserOwesTo(uid);

    final (bestOwerUid, bestReceiverUid) = group.getBestRedirect(uid);

    redirect = group.estimateRedirect(
      authorUid: uid,
      owerUid: bestOwerUid,
      receiverUid: bestReceiverUid,
    );
  }

  DebtRedirectionLoaded.fake({
    this.owerUids = const [],
    this.receiverUids = const [],
  }) {
    this.group = Group(
      name: 'group',
      members: ['uid', 'owerUid', 'receiverUid']
          .map((e) => CustomUser(name: e, uid: e))
          .toList(),
    );
    this.redirect = Redirect('owerUid', 0, 'uid', 0, 'receiverUid', 0);
  }

  String get owerUid => redirect.owerUid;
  String get receiverUid => redirect.receiverUid;
  String get authorUid => redirect.authorUid;

  CustomUser get ower => group.getMember(redirect.owerUid);
  CustomUser get author => group.getMember(redirect.authorUid);
  CustomUser get receiver => group.getMember(redirect.receiverUid);

  double get owerDebt => group.balance[redirect.owerUid]![redirect.authorUid]!;
  double get authorDebt =>
      group.balance[redirect.authorUid]![redirect.receiverUid]!;

  DebtRedirectionLoaded copyWith({Redirect? redirect}) {
    return DebtRedirectionLoaded(
      group: group,
      owerUids: owerUids,
      receiverUids: receiverUids,
      redirect: redirect ?? this.redirect,
    );
  }
}

class DebtRedirectionLoading extends DebtRedirectionState {}

class DebtRedirectionImpossible extends DebtRedirectionState {}

class DebtRedirectionOff extends DebtRedirectionState {}
