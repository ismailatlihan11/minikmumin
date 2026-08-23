import '../../core/utils/json_map.dart';

class StoryScene {
  const StoryScene({
    required this.order,
    required this.title,
    required this.text,
    this.references = const [],
  });

  final int order;
  final String title;
  final String text;
  final List<String> references;

  factory StoryScene.fromJson(Map<String, dynamic> json) {
    return StoryScene(
      order: JsonMap.integer(json['order']),
      title: JsonMap.str(json['title']),
      text: JsonMap.str(json['text']),
      references: JsonMap.strings(json['references']),
    );
  }
}

class StoryCategory {
  const StoryCategory({
    required this.id,
    required this.title,
  });

  final String id;
  final String title;

  factory StoryCategory.fromJson(Map<String, dynamic> json) {
    return StoryCategory(
      id: JsonMap.str(json['id']),
      title: JsonMap.str(json['title']),
    );
  }
}

class StoryItem {
  const StoryItem({
    required this.id,
    required this.title,
    required this.summary,
    required this.category,
    this.order = 0,
    this.ageGroups = const [],
    this.scenes = const [],
    this.lessons = const [],
    this.reflection = '',
    this.quranReferences = const [],
    this.duaReference = '',
    this.image = '',
    this.audio = '',
  });

  final String id;
  final String title;
  final String summary;
  final String category;
  final int order;
  final List<String> ageGroups;
  final List<StoryScene> scenes;
  final List<String> lessons;
  final String reflection;
  final List<String> quranReferences;
  final String duaReference;
  final String image;
  final String audio;

  factory StoryItem.fromJson(Map<String, dynamic> json) {
    final scenes =
        JsonMap.extractList(json['scenes']).map(StoryScene.fromJson).toList();
    scenes.sort((a, b) => a.order.compareTo(b.order));
    return StoryItem(
      id: JsonMap.str(json['id']),
      title: JsonMap.str(json['title']),
      summary: JsonMap.str(json['summary']),
      category: JsonMap.str(json['category']),
      order: JsonMap.integer(json['order']),
      ageGroups: JsonMap.strings(json['ageGroups']),
      scenes: scenes,
      lessons: JsonMap.strings(json['lessons']),
      reflection: JsonMap.str(json['reflection']),
      quranReferences: JsonMap.strings(json['quranReferences']),
      duaReference: JsonMap.str(json['duaReference']),
      image: JsonMap.str(json['image']),
      audio: JsonMap.str(json['audio']),
    );
  }
}

class StoryCatalog {
  const StoryCatalog({
    required this.categories,
    required this.items,
    this.imtihanPairs = const [],
  });

  final List<StoryCategory> categories;
  final List<StoryItem> items;
  final List<ProphetTrialPair> imtihanPairs;

  List<StoryItem> forCategory(String categoryId) {
    return items
        .where((item) => item.category == categoryId)
        .toList(growable: false);
  }
}

class ProphetTrialPair {
  const ProphetTrialPair({
    required this.id,
    required this.name,
    required this.trial,
    this.storyId = '',
  });

  final String id;
  final String name;
  final String trial;
  final String storyId;

  factory ProphetTrialPair.fromJson(Map<String, dynamic> json) {
    return ProphetTrialPair(
      id: JsonMap.str(json['id']),
      name: JsonMap.str(json['name']),
      trial: JsonMap.str(json['trial']),
      storyId: JsonMap.str(json['storyId']),
    );
  }
}
