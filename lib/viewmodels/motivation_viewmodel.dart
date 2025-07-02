import 'package:flutter/material.dart';
import '../services/motivation_service.dart';

class MotivationViewModel extends ChangeNotifier {
  String? _quote;
  bool _isLoading = false;
  String? _error;

  String? get quote => _quote;
  bool get isLoading => _isLoading;
  String? get error => _error;

  Future<void> fetchMotivationalQuote() async {
    _isLoading = true;
    _error = null;
    notifyListeners();
    try {
      _quote = await MotivationService.fetchMotivationalQuote();
    } catch (e) {
      _error = e.toString();
    }
    _isLoading = false;
    notifyListeners();
  }
} 