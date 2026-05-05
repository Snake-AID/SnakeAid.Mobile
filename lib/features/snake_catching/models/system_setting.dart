/// Model for a system setting
class SystemSetting {
  final String settingKey;
  final String value;
  final String? description;
  final String? valueType;

  const SystemSetting({
    required this.settingKey,
    required this.value,
    this.description,
    this.valueType,
  });

  factory SystemSetting.fromJson(Map<String, dynamic> json) {
    return SystemSetting(
      settingKey: json['settingKey']?.toString() ?? '',
      value: json['value']?.toString() ?? '',
      description: json['description']?.toString(),
      valueType: json['valueType']?.toString(),
    );
  }
}
