
import 'dart:convert';
import 'dart:io';

import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;

import '../models/game_spec.dart';

class GroqGameService {
  static const String _endpoint =
      'https://api.groq.com/openai/v1/chat/completions';

  static const String _model = 'qwen/qwen3.8-27b';

  Future<GameSpec> generateGame({
    required File image,
    required String genre,
    required String mood,
    required String difficulty,
    String? title,
    String? description,
  }) async {
    // ------------------------------------------------------------
    // 1. Get API key
    // ------------------------------------------------------------

    final apiKey = dotenv.env['GROQ_API_KEY'];

    if (apiKey == null || apiKey.isEmpty) {
      throw Exception('GROQ_API_KEY is missing from .env');
    }

    // ------------------------------------------------------------
    // 2. Convert image to Base64
    // ------------------------------------------------------------

    final imageBytes = await image.readAsBytes();
    final base64Image = base64Encode(imageBytes);

    // ------------------------------------------------------------
    // 3. User prompt
    // ------------------------------------------------------------

    final userPrompt = '''
You are the game designer for PixPlay.

PixPlay converts a user's photo into a small playable game.

Analyze the provided image and create a game specification.

USER SETTINGS:

Genre: $genre
Mood: $mood
Difficulty: $difficulty
Title: ${
      title?.trim().isNotEmpty == true
          ? title!.trim()
          : 'Not provided'
    }
Description: ${
      description?.trim().isNotEmpty == true
          ? description!.trim()
          : 'Not provided'
    }

RULES:

1. Analyze the image carefully.
2. Use the visible environment, objects, colors,
   and atmosphere to inspire the game.
3. Match the gameplay to the selected genre.
4. If the user provided a description, use it as
   the main gameplay direction.
5. If no description is provided, invent suitable gameplay.
6. If no title is provided, generate a suitable title.
7. Keep the game small and realistically playable.
8. Do not create unnecessarily complicated mechanics.
9. Return ONLY valid JSON.
10. Do not return markdown.
11. Do not return explanations.
''';

    // ------------------------------------------------------------
    // 4. Send request to Groq
    // ------------------------------------------------------------

    final response = await http.post(
      Uri.parse(_endpoint),
      headers: {
        'Authorization': 'Bearer $apiKey',
        'Content-Type': 'application/json',
      },
      body: jsonEncode({
        'model': _model,

        'messages': [
          {
            'role': 'system',
            'content': '''
You generate structured game specifications for PixPlay.

Return ONLY valid JSON.

The JSON must contain exactly these top-level fields:

title
genre
mood
difficulty
world
player
objective
objects
rules
win_condition
lose_condition

IMPORTANT JSON STRUCTURE:

"world" MUST be an object:
{
  "theme": "string",
  "background": "string",
  "lighting": "string"
}

"player" MUST be an object:
{
  "type": "string",
  "movement": "string"
}

"objective" MUST be an object:
{
  "type": "string",
  "description": "string"
}

"objects" MUST be an array of objects.

Each object inside "objects" MUST have:
{
  "name": "string",
  "type": "string",
  "count": number
}

"rules" MUST be an object:
{
  "time_limit": number or null,
  "score_per_item": number
}

"win_condition" MUST be an object:
{
  "type": "string"
}

"lose_condition" MUST be an object:
{
  "type": "string"
}

NEVER return these fields as strings containing JSON.

For example, this is WRONG:

"world": "{\\"theme\\":\\"forest\\"}"

This is CORRECT:

"world": {
  "theme": "forest",
  "background": "forest",
  "lighting": "bright"
}

Do not add explanations.
Do not use markdown.
Do not wrap the JSON in ```json.
''',
          },
          {
            'role': 'user',
            'content': [
              {
                'type': 'text',
                'text': userPrompt,
              },
              {
                'type': 'image_url',
                'image_url': {
                  'url': 'data:image/jpeg;base64,$base64Image',
                },
              },
            ],
          },
        ],

        'response_format': {
          'type': 'json_object',
        },

        'reasoning_effort': 'low',

        'temperature': 0.7,

        'max_completion_tokens': 3000,
      }),
    );

    // ------------------------------------------------------------
    // 5. Check HTTP response
    // ------------------------------------------------------------

    if (response.statusCode != 200) {
      throw Exception(
        'Groq API error ${response.statusCode}: ${response.body}',
      );
    }

    // ------------------------------------------------------------
    // 6. Decode Groq API response
    // ------------------------------------------------------------

    late final Map<String, dynamic> responseData;

    try {
      final decoded = jsonDecode(response.body);

      if (decoded is! Map<String, dynamic>) {
        throw Exception('Groq API returned an unexpected response.');
      }

      responseData = decoded;
    } catch (e) {
      throw Exception(
        'Failed to decode Groq API response: $e',
      );
    }

    // ------------------------------------------------------------
    // 7. Extract AI-generated content
    // ------------------------------------------------------------

    final choices = responseData['choices'];

    if (choices is! List || choices.isEmpty) {
      throw Exception('Groq returned no choices.');
    }

    final message = choices[0]['message'];

    if (message is! Map<String, dynamic>) {
      throw Exception('Groq returned an invalid message.');
    }

    final content = message['content'];

    if (content == null || content.toString().trim().isEmpty) {
      throw Exception('Groq returned an empty response.');
    }

    // ------------------------------------------------------------
    // 8. Decode generated GameSpec JSON
    // ------------------------------------------------------------

    late final dynamic decodedGame;

    try {
      decodedGame = jsonDecode(content.toString());
    } catch (e) {
      throw Exception(
        'Groq returned invalid JSON:\n$content\n\nError: $e',
      );
    }

    // ------------------------------------------------------------
    // 9. Make sure GameSpec is a JSON object
    // ------------------------------------------------------------

    if (decodedGame is! Map<String, dynamic>) {
      throw Exception(
        'Groq GameSpec must be a JSON object, '
        'but received ${decodedGame.runtimeType}.',
      );
    }

    // ------------------------------------------------------------
    // 10. Debug output
    // ------------------------------------------------------------

    print('========== GROQ GAME SPEC ==========');
    print(const JsonEncoder.withIndent('  ').convert(decodedGame));
    print('====================================');

    // ------------------------------------------------------------
    // 11. Validate important fields
    // ------------------------------------------------------------

    final requiredFields = [
      'title',
      'genre',
      'mood',
      'difficulty',
      'world',
      'player',
      'objective',
      'objects',
      'rules',
      'win_condition',
      'lose_condition',
    ];

    for (final field in requiredFields) {
      if (!decodedGame.containsKey(field)) {
        throw Exception(
          'Groq GameSpec is missing required field: $field',
        );
      }
    }

    // ------------------------------------------------------------
    // 12. Validate nested structures
    // ------------------------------------------------------------

    final mapFields = [
      'world',
      'player',
      'objective',
      'rules',
      'win_condition',
      'lose_condition',
    ];

    for (final field in mapFields) {
      if (decodedGame[field] is! Map) {
        throw Exception(
          'GameSpec field "$field" must be an object, '
          'but received ${decodedGame[field].runtimeType}:\n'
          '${decodedGame[field]}',
        );
      }
    }

    if (decodedGame['objects'] is! List) {
      throw Exception(
        'GameSpec field "objects" must be an array.',
      );
    }

    // ------------------------------------------------------------
    // 13. Convert JSON into GameSpec
    // ------------------------------------------------------------

    try {
      return GameSpec.fromJson(decodedGame);
    } catch (e) {
      throw Exception(
        'Failed to create GameSpec from Groq response: $e',
      );
    }
  }
}
