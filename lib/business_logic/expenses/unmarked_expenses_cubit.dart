import 'dart:async';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:statera/data/services/services.dart';

class UnmarkedExpensesCubit extends Cubit<int?> {
  StreamSubscription? _unmarkedExpensesSubscription;

  UnmarkedExpensesCubit(
    GroupService groupService, {
    required String? groupId,
    required String uid,
  }) : super(null) {
    _unmarkedExpensesSubscription = groupService
        .listenForUnmarkedExpenses(groupId, uid)
        .map((unmarkedExpenses) => unmarkedExpenses.length)
        .listen(emit);
  }

  @override
  Future<void> close() {
    _unmarkedExpensesSubscription?.cancel();
    return super.close();
  }
}
