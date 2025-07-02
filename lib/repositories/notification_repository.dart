import 'package:flutter/material.dart';
import 'package:awesome_notifications/awesome_notifications.dart';
import '../services/storage_service.dart';

// Repository per la gestione delle notifiche
class NotificationRepository {
  Future<List<TimeOfDay>> loadNotificationTimes() async {
    return await StorageService.getNotificationTimes();
  }

  Future<void> saveNotificationTimes(List<TimeOfDay> times) async {
    await StorageService.saveNotificationTimes(times);
  }

  Future<bool> checkAndRequestPermission() async {
    bool isAllowed = await AwesomeNotifications().isNotificationAllowed();
    if (!isAllowed) {
      isAllowed = await AwesomeNotifications().requestPermissionToSendNotifications();
    }
    return isAllowed;
  }
} 