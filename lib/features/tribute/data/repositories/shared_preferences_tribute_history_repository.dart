// Project imports:
import 'package:saving_girlfriend/common/services/local_storage_service.dart';
import 'package:saving_girlfriend/features/tribute/domain/repositories/tribute_history_repository.dart';
import 'package:saving_girlfriend/features/tribute/models/tribute_history_state.dart';

class SharedPreferencesTributeHistoryRepository
    implements TributeHistoryRepository {
  final LocalStorageService _localStorageService;
  SharedPreferencesTributeHistoryRepository(this._localStorageService);

  @override
  Future<void> saveTributionHistory(List<TributeState> history) async {
    await _localStorageService.saveTributionHistory(history);
  }

  @override
  Future<List<TributeState>> getTributionHistory() async {
    return _localStorageService.getTributionHistory();
  }
}
