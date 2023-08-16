import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:statera/data/services/services.dart';

class SeedColorCubit extends Cubit<Color> {
  PreferencesService _preferencesService;

  SeedColorCubit(this._preferencesService) : super(const Color(0xFFffd100));

  Future<void> load() async {
    final color = await _preferencesService.checkPrimaryColor();
    if (color != null) emit(color);
  }

  Future<void> setColor(Color color) async {
    await _preferencesService.setPrimaryColor(color);
    emit(color);
  }
}
