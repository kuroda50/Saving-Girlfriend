class SettingsState {
  final bool notificationsEnabled;
  final double bgmVolume;
  final int targetSavingAmount;
  final int dailyBudget;

  SettingsState({
    required this.notificationsEnabled,
    required this.bgmVolume,
    required this.targetSavingAmount,
    required this.dailyBudget,
  });

  SettingsState copyWith({
    bool? notificationsEnabled,
    double? bgmVolume,
    int? targetSavingAmount,
    int? dailyBudget,
  }) {
    return SettingsState(
      notificationsEnabled: notificationsEnabled ?? this.notificationsEnabled,
      bgmVolume: bgmVolume ?? this.bgmVolume,
      targetSavingAmount: targetSavingAmount ?? this.targetSavingAmount,
      dailyBudget: dailyBudget ?? this.dailyBudget,
    );
  }
}
