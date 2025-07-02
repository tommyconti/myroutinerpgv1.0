// Repository per la gestione delle statistiche utente
import '../models/user_stats.dart';
import '../services/storage_service.dart';

class UserStatsRepository {
  Future<UserStats> loadUserStats() async {
    return await StorageService.getUserStats();
  }

  Future<void> saveUserStats(UserStats stats) async {
    await StorageService.saveUserStats(stats);
  }
} 