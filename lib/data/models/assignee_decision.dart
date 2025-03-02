import 'dart:math';

class AssigneeDecision {
  String uid;
  int? _parts; // if the value is null, then the decision has not been taken yet

  AssigneeDecision({required this.uid, int? parts}) {
    this._parts = parts;
  }

  int? get parts => _parts;
  set parts(int? value) => _parts = value == null ? null : max(value, 0);

  bool get madeDecision => _parts != null;

  Map<String, dynamic> toFirestore() {
    return {
      'uid': uid,
      'parts': _parts,
    };
  }

  static AssigneeDecision from(AssigneeDecision other) {
    return AssigneeDecision(
      uid: other.uid,
      parts: other._parts,
    );
  }

  static AssigneeDecision fromFirestore(Map<String, dynamic> data) {
    return AssigneeDecision(
      uid: data['uid'],
      parts: data['parts'],
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
  
    return other is AssigneeDecision &&
      other.uid == uid &&
      other._parts == _parts;
  }

  @override
  int get hashCode => uid.hashCode ^ _parts.hashCode;
}
