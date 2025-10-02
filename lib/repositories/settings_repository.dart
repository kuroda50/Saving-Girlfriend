import 'package:saving_girlfriend/models/settings_state.dart';
import '../services/local_storage_service.dart';

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
