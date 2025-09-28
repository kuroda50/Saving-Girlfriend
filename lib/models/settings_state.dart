class SettingsState {
  final int targetSavingAmount;
  final int defaultContributionAmount;
  final bool notificationsEnabled;
  final double bgmVolume;

  SettingsState(
      {required this.targetSavingAmount,
      required this.defaultContributionAmount,
      required this.notificationsEnabled,
      required this.bgmVolume});

  SettingsState copyWith({
    int? targetSavingAmount,
    int? defaultContributionAmount,
    bool? notificationsEnabled,
    double? bgmVolume,
  }) {
    return SettingsState(
      targetSavingAmount: targetSavingAmount ?? this.targetSavingAmount,
      defaultContributionAmount:
          defaultContributionAmount ?? this.defaultContributionAmount,
      notificationsEnabled: notificationsEnabled ?? this.notificationsEnabled,
      bgmVolume: bgmVolume ?? this.bgmVolume,
    );
  }
}
