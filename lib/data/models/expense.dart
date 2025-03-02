import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import 'package:statera/data/enums/enums.dart';
import 'package:statera/data/models/models.dart';

class Expense {
  String id = '';
  String? groupId;
  List<Item> items = [];
  List<String> assigneeUids = [];
  String name;
  String authorUid;
  DateTime? date;
  DateTime? finalizedDate;
  late ExpenseSettings settings;

  Expense({
    required this.name,
    required this.authorUid,
    this.groupId,
    ExpenseSettings? settings,
  }) {
    this.assigneeUids = [authorUid];
    this.date = DateTime.now();
    this.settings = settings ?? ExpenseSettings();
  }

  Expense.empty({String? groupId})
      : this(
          name: 'Empty',
          authorUid: '',
          groupId: groupId,
        );

  bool wasEarlierThan(Expense other) {
    if (this.date == null) return true;
    if (other.date == null) return false;

    return this.date!.compareTo(other.date!) < 0;
  }

  bool get hasTax => settings.tax != null;

  bool get hasTip => settings.tip != null;

  double get total {
    final subtotal = items.fold(0.0, (prev, item) => prev + item.total);
    final taxValue = items.fold(
      0.0,
      (prev, item) => prev + item.getTaxValue(this.settings.tax),
    );
    final tipValue = subtotal * (this.settings.tip ?? 0);
    return subtotal + taxValue + tipValue;
  }

  bool get finalized => finalizedDate != null;

  bool get completed =>
      items.isNotEmpty && items.every((item) => item.completed);

  bool get canReceiveAssignees => !finalized;

  bool isMarkedBy(String uid) => items.every((item) => item.isMarkedBy(uid));

  bool isAuthoredBy(String? uid) => this.authorUid == uid;

  bool canBeUpdatedBy(String uid) => this.isAuthoredBy(uid) && !this.finalized;

  bool canBeFinalizedBy(String uid) =>
      !this.finalized && this.completed && this.isAuthoredBy(uid);

  bool canBeMarkedBy(String uid) =>
      !this.finalized && this.assigneeUids.contains(uid);

  int get definedAssignees => assigneeUids.fold(
        0,
        (previousValue, assigneeUid) =>
            previousValue + (isMarkedBy(assigneeUid) ? 1 : 0),
      );

  void addItem(Item newItem) {
    newItem.assignees = this
        .assigneeUids
        .map((assigneeUid) => AssigneeDecision(uid: assigneeUid))
        .toList();
    this.items.add(newItem);
  }

  void updateItem(Item newItem) {
    var itemIdx = this.items.indexWhere((item) => item.id == newItem.id);
    this.items[itemIdx] = newItem;
  }

  get hasNoItems => this.items.isEmpty;
  get hasItems => this.items.isNotEmpty;

  void addAssignee(String newAssigneeUid) {
    this.items.forEach((item) {
      item.assignees.add(AssigneeDecision(uid: newAssigneeUid));
    });
    this.assigneeUids.add(newAssigneeUid);
  }

  void removeAssignee(String assigneeUid) {
    this.items.forEach((item) {
      item.assignees.removeWhere((a) => a.uid == assigneeUid);
    });
    this.assigneeUids.remove(assigneeUid);
  }

  void updateAssignees(List<String> selectedUids) {
    if (selectedUids.isEmpty)
      throw new Exception('Assignee list can not be empty');

    this.assigneeUids = [...selectedUids];

    this.items.forEach((item) {
      item.assignees = selectedUids.map((uid) {
        try {
          return item.assignees.firstWhere((assignee) => assignee.uid == uid);
        } catch (e) {
          return AssigneeDecision(uid: uid);
        }
      }).toList();
    });
  }

  double getConfirmedTotalForUser(String uid) {
    final subtotal = getConfirmedSubtotalForUser(uid);
    final tax = getConfirmedTaxForUser(uid);
    final tip = getConfirmedTipForUser(uid);

    return subtotal + tax + tip;
  }

  double getConfirmedTipForUser(String uid) {
    final subtotal = getConfirmedSubtotalForUser(uid);
    return subtotal * (settings.tip ?? 0);
  }

  double getConfirmedTaxForUser(String uid) {
    if (!this.hasAssignee(uid)) return 0;

    return items.fold<double>(
      0,
      (prev, item) =>
          prev +
          item.getConfirmedTaxForUser(
            uid,
            tax: settings.tax,
          ),
    );
  }

  double getConfirmedSubtotalForUser(String uid) {
    if (!this.hasAssignee(uid)) return 0;

    return items.fold<double>(
      0,
      (prev, item) => prev + item.getConfirmedSubtotalForUser(uid),
    );
  }

  bool hasAssignee(String uid) {
    return this.assigneeUids.contains(uid);
  }

  bool get hasItemsDeniedByAll => items.any((item) => item.isDeniedByAll);

  ExpenseStage getStage(String uid) {
    if (finalized) return ExpenseStage.Finalized;
    if (isMarkedBy(uid)) return ExpenseStage.Pending;
    return ExpenseStage.Not_Marked;
  }

  Map<String, dynamic> toFirestore() {
    return {
      'name': name,
      'groupId': groupId,
      'authorUid': authorUid,
      'assigneeIds': assigneeUids,
      'items': items.map((item) => item.toFirestore()).toList(),
      'unmarkedAssigneeIds': assigneeUids
          .where((assigneeUid) => !isMarkedBy(assigneeUid))
          .toList(),
      'date': date,
      'finalizedDate': finalizedDate,
      'settings': settings.toFirestore(),
    };
  }

  static Expense from(Expense other) {
    return Expense(
      name: other.name,
      authorUid: other.authorUid,
      groupId: other.groupId,
      settings: ExpenseSettings.from(other.settings),
    )
      ..id = other.id
      ..date = other.date
      ..finalizedDate = other.finalizedDate
      ..assigneeUids = [...other.assigneeUids]
      ..items = other.items.map((item) => Item.from(item)).toList();
  }

  static Expense fromFirestore(Map<String, dynamic> data, String id) {
    final authorUid = data['authorUid'];
    final settings = data['settings'] == null
        ? null
        : ExpenseSettings.fromFirestore(data['settings']);

    var expense = new Expense(
      authorUid: authorUid,
      name: data['name'],
      groupId: data['groupId'],
      settings: settings,
    );
    expense.id = id;
    expense.date = data['date'] == null
        ? null
        : DateTime.parse(data['date'].toDate().toString());
    expense.finalizedDate = data['finalizedDate'] == null
        ? null
        : DateTime.parse(data['finalizedDate'].toDate().toString());
    expense.assigneeUids = (data['assigneeIds'] as List<dynamic>)
        .map((a) => a.toString())
        .toList();
    data['items'].forEach(
        (itemData) => {expense.items.add(Item.fromFirestore(itemData))});
    return expense;
  }

  static Expense fromSnapshot(DocumentSnapshot snap) {
    final data = snap.data() as Map<String, dynamic>;
    return fromFirestore(data, snap.id);
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    return other is Expense &&
        other.id == id &&
        other.groupId == groupId &&
        listEquals(other.items, items) &&
        listEquals(other.assigneeUids, assigneeUids) &&
        other.name == name &&
        other.authorUid == authorUid &&
        other.date == date &&
        other.finalizedDate == finalizedDate &&
        other.settings == settings;
  }

  int get itemsHash => items.fold(0, (cur, e) => cur ^ e.hashCode);

  int get assigneesHash => assigneeUids.fold(0, (cur, e) => cur ^ e.hashCode);

  @override
  int get hashCode {
    return id.hashCode ^
        groupId.hashCode ^
        itemsHash ^
        assigneesHash ^
        name.hashCode ^
        authorUid.hashCode ^
        date.hashCode ^
        finalizedDate.hashCode ^
        settings.hashCode;
  }

  @override
  String toString() {
    return 'Expense "$name"';
  }
}
