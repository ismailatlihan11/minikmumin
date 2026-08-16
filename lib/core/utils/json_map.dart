class JsonMap {
  static Map<String, dynamic> object(dynamic value) {
    if (value is Map<String, dynamic>) return value;
    if (value is Map) return Map<String, dynamic>.from(value);
    return <String, dynamic>{};
  }

  static List<Map<String, dynamic>> extractList(
    dynamic data, {
    String itemsKey = 'items',
  }) {
    if (data is List) {
      return data.map(object).toList(growable: false);
    }
    if (data is Map) {
      final map = object(data);
      final list = map[itemsKey] ?? map['ayet'] ?? map['steps'];
      if (list is List) {
        return list.map(object).toList(growable: false);
      }
    }
    return const [];
  }

  static String str(dynamic value, [String fallback = '']) =>
      value == null ? fallback : value.toString();

  static int integer(dynamic value, [int fallback = 0]) {
    if (value is int) return value;
    if (value is num) return value.toInt();
    return int.tryParse(value?.toString() ?? '') ?? fallback;
  }

  static bool flag(dynamic value, [bool fallback = false]) {
    if (value is bool) return value;
    return fallback;
  }
}
