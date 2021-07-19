import 'dart:convert';

import 'package:flutter/foundation.dart';

class Foo {
  Map<String, Map<String, double>> balance;
  Foo({
    required this.balance,
  });

  Foo copyWith({
    Map<String, Map<String, double>>? balance,
  }) {
    return Foo(
      balance: balance ?? this.balance,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'balance': balance,
    };
  }

  factory Foo.fromMap(Map<String, dynamic> map) {
    return Foo(
      balance: Map<String, Map<String, double>>.from(map['balance']),
    );
  }

  String toJson() => json.encode(toMap());

  factory Foo.fromJson(String source) => Foo.fromMap(json.decode(source));

  @override
  String toString() => 'Foo(balance: $balance)';

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
  
    return other is Foo &&
      mapEquals(other.balance, balance);
  }

  @override
  int get hashCode => balance.hashCode;
}
