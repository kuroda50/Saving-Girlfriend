import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:saving_girlfriend/services/local_storage_service.dart';

part 'current_girlfriend_provider.g.dart';

@Riverpod(keepAlive: true)
class CurrentGirlfriend extends _$CurrentGirlfriend {
  @override
  Future<String> build() async {
    final localStorageService =
        await ref.watch(localStorageServiceProvider.future);
    return localStorageService.getCurrentCharacter();
  }

  Future<void> selectGirlfriend(String characterId) async {
    final localStorageService =
        await ref.read(localStorageServiceProvider.future);
    await localStorageService.saveCurrentCharacter(characterId);
    state = AsyncData(characterId);
  }
}
