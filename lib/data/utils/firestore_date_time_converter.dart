import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:json_annotation/json_annotation.dart';

class FirestoreDateTimeConverter implements JsonConverter<DateTime?, Object?> {
  const FirestoreDateTimeConverter();

  @override
  DateTime? fromJson(Object? json) => json == null
      ? null
      : DateTime.parse((json as Timestamp).toDate().toString());

  @override
  Object? toJson(DateTime? date) => date;
}
