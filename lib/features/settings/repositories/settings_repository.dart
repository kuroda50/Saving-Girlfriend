// Project imports:
import 'package:saving_girlfriend/common/services/local_storage_service.dart';
import 'package:saving_girlfriend/features/settings/models/settings_state.dart';

class SettingsRepository {
  final LocalStorageService _localStorageService;
  SettingsRepository(this._localStorageService);

  Future<SettingsState> getSettings() {
    return _localStorageService.getSettings();
  }

  Future<void> saveSettings(SettingsState settings) {
    return _localStorageService.saveSettings(settings);
  }
}
