import '../../core/utils/json_map.dart';

class BasicsSubItem {
  const BasicsSubItem({
    required this.order,
    required this.title,
    required this.description,
  });

  final int order;
  final String title;
  final String description;

  factory BasicsSubItem.fromJson(Map<String, dynamic> json) {
    return BasicsSubItem(
      order: JsonMap.integer(json['order']),
      title: JsonMap.str(json['title']),
      description: JsonMap.str(json['description']),
    );
  }
}

class BasicsExample {
  const BasicsExample({
    this.arabic = '',
    this.text = '',
    this.meaning = '',
    this.reference = '',
    this.label = '',
  });

  final String arabic;
  final String text;
  final String meaning;
  final String reference;
  final String label;

  bool get hasContent =>
      arabic.trim().isNotEmpty ||
      text.trim().isNotEmpty ||
      meaning.trim().isNotEmpty;

  factory BasicsExample.fromJson(Map<String, dynamic> json) {
    return BasicsExample(
      arabic: JsonMap.str(json['arabic']),
      text: JsonMap.str(json['text']),
      meaning: JsonMap.str(json['meaning']),
      reference: JsonMap.str(json['reference']),
      label: JsonMap.str(json['label']),
    );
  }
}

class BasicsItem {
  const BasicsItem({
    required this.id,
    required this.title,
    required this.shortDescription,
    required this.content,
    required this.icon,
    this.arabic = '',
    this.transliteration = '',
    this.meaning = '',
    this.audio = '',
    this.keyPoints = const [],
    this.items = const [],
    this.example,
  });

  final int id;
  final String title;
  final String shortDescription;
  final String content;
  final String icon;
  final String arabic;
  final String transliteration;
  final String meaning;
  final String audio;
  final List<String> keyPoints;
  final List<BasicsSubItem> items;
  final BasicsExample? example;

  bool get hasArabic => arabic.trim().isNotEmpty;

  factory BasicsItem.fromJson(Map<String, dynamic> json) {
    final audio = json['audio'];
    final exampleRaw = json['example'];
    return BasicsItem(
      id: JsonMap.integer(json['id']),
      title: JsonMap.str(json['title']),
      shortDescription: JsonMap.str(json['short_description']),
      content: JsonMap.str(json['content']),
      icon: JsonMap.str(json['icon']),
      arabic: JsonMap.str(json['arabic']),
      transliteration: JsonMap.str(json['transliteration']),
      meaning: JsonMap.str(json['meaning']),
      audio: audio == null ? '' : JsonMap.str(audio),
      keyPoints: JsonMap.strings(json['key_points']),
      items: JsonMap.extractList(json, itemsKey: 'items')
          .map(BasicsSubItem.fromJson)
          .toList(growable: false),
      example: exampleRaw is Map
          ? BasicsExample.fromJson(JsonMap.object(exampleRaw))
          : null,
    );
  }
}

class BasicsCatalog {
  const BasicsCatalog({
    required this.title,
    required this.description,
    required this.items,
  });

  final String title;
  final String description;
  final List<BasicsItem> items;

  BasicsItem? itemById(int id) {
    for (final item in items) {
      if (item.id == id) return item;
    }
    return null;
  }

  List<BasicsItem> itemsForIds(List<int> ids) {
    return [
      for (final id in ids)
        if (itemById(id) != null) itemById(id)!,
    ];
  }
}
