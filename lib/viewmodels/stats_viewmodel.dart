import 'package:flutter/material.dart';
import '../models/user_stats.dart';
import '../repositories/user_stats_repository.dart';

class StatsViewModel extends ChangeNotifier {
  final UserStatsRepository repository;
  UserStats _userStats = UserStats.initial;
  bool _isLoading = false;
  String? _error;

  StatsViewModel({required this.repository});

  UserStats get userStats => _userStats;
  bool get isLoading => _isLoading;
  String? get error => _error;

  Future<void> loadUserStats() async {
    _isLoading = true;
    _error = null;
    notifyListeners();
    try {
      _userStats = await repository.loadUserStats();
    } catch (e) {
      _error = e.toString();
    }
    _isLoading = false;
    notifyListeners();
  }

  Future<void> saveUserStats(UserStats stats) async {
    _isLoading = true;
    notifyListeners();
    try {
      _userStats = stats;
      await repository.saveUserStats(stats);
    } catch (e) {
      _error = e.toString();
    }
    _isLoading = false;
    notifyListeners();
  }
} 