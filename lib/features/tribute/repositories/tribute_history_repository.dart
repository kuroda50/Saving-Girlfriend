// Project imports:
import 'package:saving_girlfriend/common/services/local_storage_service.dart';
import 'package:saving_girlfriend/features/tribute/models/tribute_history_state.dart';

class TributeHistoryRepository {
  final LocalStorageService _localStorageService;
  TributeHistoryRepository(this._localStorageService);

  Future<void> saveTributionHistory(List<TributeState> history) async {
    await _localStorageService.saveTributionHistory(history);
  }

  Future<List<TributeState>> getTributionHistory() async {
    return _localStorageService.getTributionHistory();
  }
}
