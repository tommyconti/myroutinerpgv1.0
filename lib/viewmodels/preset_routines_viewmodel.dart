import 'package:flutter/material.dart';
import '../models/routine.dart';
import '../repositories/preset_routines_repository.dart';

class PresetRoutinesViewModel extends ChangeNotifier {
  final PresetRoutinesRepository repository;
  List<Routine> _presetRoutines = [];
  bool _isLoading = false;
  String? _error;

  PresetRoutinesViewModel({required this.repository});

  List<Routine> get presetRoutines => _presetRoutines;
  bool get isLoading => _isLoading;
  String? get error => _error;

  Future<void> loadPresetRoutines() async {
    _isLoading = true;
    _error = null;
    notifyListeners();
    try {
      _presetRoutines = repository.getPresetRoutines();
    } catch (e) {
      _error = e.toString();
    }
    _isLoading = false;
    notifyListeners();
  }
} 