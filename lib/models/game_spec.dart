class GameSpec {
  final String title;
  final String genre;
  final String mood;
  final String difficulty;
  final WorldSpec world;
  final PlayerSpec player;
  final ObjectiveSpec objective;
  final List<GameObjectSpec> objects;
  final GameRules rules;
  final WinCondition winCondition;
  final LoseCondition loseCondition;

  

  GameSpec({
    required this.title,
    required this.genre,
    required this.mood,
    required this.difficulty,
    required this.world,
    required this.player,
    required this.objective,
    required this.objects,
    required this.rules,
    required this.winCondition,
    required this.loseCondition,
  });

  factory GameSpec.fromJson(Map<String, dynamic> json) {
    return GameSpec(
      title: json['title'] ?? 'Untitled Game',
      genre: json['genre'] ?? 'adventure',
      mood: json['mood'] ?? 'epic',
      difficulty: json['difficulty'] ?? 'medium',
      world: WorldSpec.fromJson(json['world'] ?? {}),
      player: PlayerSpec.fromJson(json['player'] ?? {}),
      objective: ObjectiveSpec.fromJson(json['objective'] ?? {}),
      objects: (json['objects'] as List? ?? [])
          .map(
            (object) => GameObjectSpec.fromJson(
              Map<String, dynamic>.from(object),
            ),
          )
          .toList(),
      rules: GameRules.fromJson(json['rules'] ?? {}),
      winCondition:
          WinCondition.fromJson(json['win_condition'] ?? {}),
      loseCondition:
          LoseCondition.fromJson(json['lose_condition'] ?? {}),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'title': title,
      'genre': genre,
      'mood': mood,
      'difficulty': difficulty,
      'world': world.toJson(),
      'player': player.toJson(),
      'objective': objective.toJson(),
      'objects': objects.map((object) => object.toJson()).toList(),
      'rules': rules.toJson(),
      'win_condition': winCondition.toJson(),
      'lose_condition': loseCondition.toJson(),
    };
  }
}


/// Describes the game environment.
class WorldSpec {
  final String theme;
  final String background;
  final String lighting;

  WorldSpec({
    required this.theme,
    required this.background,
    required this.lighting,
  });

  factory WorldSpec.fromJson(Map<String, dynamic> json) {
    return WorldSpec(
      theme: json['theme'] ?? '',
      background: json['background'] ?? '',
      lighting: json['lighting'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'theme': theme,
      'background': background,
      'lighting': lighting,
    };
  }
}


/// Describes the player.
class PlayerSpec {
  final String type;
  final String movement;

  PlayerSpec({
    required this.type,
    required this.movement,
  });

  factory PlayerSpec.fromJson(Map<String, dynamic> json) {
    return PlayerSpec(
      type: json['type'] ?? 'character',
      movement: json['movement'] ?? 'keyboard',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'type': type,
      'movement': movement,
    };
  }
}


/// Describes what the player needs to accomplish.
class ObjectiveSpec {
  final String type;
  final String description;

  ObjectiveSpec({
    required this.type,
    required this.description,
  });

  factory ObjectiveSpec.fromJson(Map<String, dynamic> json) {
    return ObjectiveSpec(
      type: json['type'] ?? '',
      description: json['description'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'type': type,
      'description': description,
    };
  }
}


/// Any interactive object inside the game.
class GameObjectSpec {
  final String name;
  final String type;
  final int count;

  GameObjectSpec({
    required this.name,
    required this.type,
    required this.count,
  });

  factory GameObjectSpec.fromJson(Map<String, dynamic> json) {
    return GameObjectSpec(
      name: json['name'] ?? '',
      type: json['type'] ?? 'interactive',
      count: json['count'] ?? 1,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'type': type,
      'count': count,
    };
  }
}


/// General gameplay rules.
class GameRules {
  final int? timeLimit;
  final int scorePerItem;

  GameRules({
    this.timeLimit,
    required this.scorePerItem,
  });

  factory GameRules.fromJson(Map<String, dynamic> json) {
    return GameRules(
      timeLimit: json['time_limit'],
      scorePerItem: json['score_per_item'] ?? 100,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'time_limit': timeLimit,
      'score_per_item': scorePerItem,
    };
  }
}


/// Defines how the player wins.
class WinCondition {
  final String type;

  WinCondition({
    required this.type,
  });

  factory WinCondition.fromJson(Map<String, dynamic> json) {
    return WinCondition(
      type: json['type'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'type': type,
    };
  }
}


/// Defines how the player loses.
class LoseCondition {
  final String type;

  LoseCondition({
    required this.type,
  });

  factory LoseCondition.fromJson(Map<String, dynamic> json) {
    return LoseCondition(
      type: typeFromJson(json),
    );
  }

  static String typeFromJson(Map<String, dynamic> json) {
    return json['type'] ?? '';
  }

  Map<String, dynamic> toJson() {
    return {
      'type': type,
    };
  }
}