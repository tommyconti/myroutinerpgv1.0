import 'package:flutter/material.dart';
import '../repositories/notification_repository.dart';

class NotificationViewModel extends ChangeNotifier {
  final NotificationRepository repository;
  List<TimeOfDay> _notificationTimes = [];
  bool _isLoading = false;
  String? _error;
  bool _isAllowed = false;

  NotificationViewModel({required this.repository});

  List<TimeOfDay> get notificationTimes => _notificationTimes;
  bool get isLoading => _isLoading;
  String? get error => _error;
  bool get isAllowed => _isAllowed;

  Future<void> loadNotificationTimes() async {
    _isLoading = true;
    _error = null;
    notifyListeners();
    try {
      _notificationTimes = await repository.loadNotificationTimes();
    } catch (e) {
      _error = e.toString();
    }
    _isLoading = false;
    notifyListeners();
  }

  Future<void> saveNotificationTimes(List<TimeOfDay> times) async {
    _isLoading = true;
    notifyListeners();
    try {
      await repository.saveNotificationTimes(times);
      _notificationTimes = times;
    } catch (e) {
      _error = e.toString();
    }
    _isLoading = false;
    notifyListeners();
  }

  Future<void> checkAndRequestPermission() async {
    _isLoading = true;
    notifyListeners();
    try {
      _isAllowed = await repository.checkAndRequestPermission();
    } catch (e) {
      _error = e.toString();
    }
    _isLoading = false;
    notifyListeners();
  }
} 