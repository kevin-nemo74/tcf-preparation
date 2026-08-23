import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:tcf_canada_preparation/services/dotenv_service.dart';
import '../models/eo_evaluation.dart';

class EoEvaluationService {
  EoEvaluationService._();

  static const String _baseUrl =
      'https://api.groq.com/openai/v1/chat/completions';

  static const List<Map<String, String>> _models = [
    {'id': 'openai/gpt-oss-120b', 'name': 'GPT-OSS 120B'},
    {'id': 'openai/gpt-oss-20b', 'name': 'GPT-OSS 20B'},
  ];

  static String _taskDescription(int tache) {
    switch (tache) {
      case 1:
        return 'Tâche 1 : Entretien dirigé (2 min, questions personnelles)';
      case 2:
        return 'Tâche 2 : Exercice en interaction (5 min 30, jeu de rôle)';
      case 3:
        return 'Tâche 3 : Expression d\'un point de vue (4 min 30, argumentation)';
      default:
        return 'Tâche $tache';
    }
  }

  static String _contentCriterion(int tache) {
    switch (tache) {
      case 1:
        return '''
   - L'étudiant répond-il de façon naturelle et spontanée ?
   - Les réponses sont-elles développées (pas de réponses trop courtes) ?
   - L'étudiant montre-t-il une capacité à échanger sur des sujets personnels ?''';
      case 2:
        return '''
   - L'étudiant pose-t-il des questions pertinentes par rapport à la situation ?
   - Les questions sont-elles variées et appropriées ?
   - L'étudiant réagit-il bien aux réponses de l'interlocuteur ?''';
      case 3:
        return '''
   - L'étudiant exprime-t-il clairement son point de vue ?
   - Les arguments sont-ils pertinents et bien développés ?
   - Le discours est-il convaincant ?''';
      default:
        return '';
    }
  }

  static Future<EOEvaluation> evaluate({
    required String sujet,
    required String transcription,
    int tache = 2,
  }) async {
    final apiKey = DotenvService.openRouterApiKey;
    if (apiKey.isEmpty) {
      throw Exception(
        'Clé API Groq non configurée. Ajoutez GROQ_API_KEY.',
      );
    }

    final taskDesc = _taskDescription(tache);
    final contentCriterion = _contentCriterion(tache);

    final systemPrompt = '''
Tu es un évaluateur expert du TCF Canada pour l'épreuve d'Expression Orale ($taskDesc).

Évalue la production orale de l'étudiant selon les critères suivants :

1. **Contenu et pertinence** (noté sur 7) :
$contentCriterion

2. **Vocabulaire** (noté sur 5) :
   - Le vocabulaire est-il varié et adapté au contexte ?
   - Y a-t-il des répétitions excessives ?

3. **Grammaire** (noté sur 5) :
   - La grammaire est-elle correcte ?
   - La conjugaison et la syntaxe sont-elles justes ?

4. **Cohérence et aisance** (noté sur 3) :
   - Le discours est-il bien structuré ?
   - Les idées s'enchaînent-elles logiquement ?

Le score total est sur 20 points.

Réponds UNIQUEMENT avec un objet JSON valide (sans markdown, sans texte avant/après) :
{
  "overall_score": 0.0,
  "max_score": 20.0,
  "content_score": 0.0,
  "vocabulary_score": 0.0,
  "grammar_score": 0.0,
  "coherence_score": 0.0,
  "general_feedback": "Commentaire général en français",
  "corrections": "Corrections détaillées des erreurs",
  "suggestions": "Suggestions pour améliorer"
}
''';

    final userPrompt = '''
Sujet : $sujet

Transcription de la réponse de l'étudiant :
$transcription

Évalue cette production orale selon les critères du TCF Canada.
''';

    for (final model in _models) {
      try {
        final body = jsonEncode({
          'model': model['id'],
          'messages': [
            {'role': 'system', 'content': systemPrompt},
            {'role': 'user', 'content': userPrompt},
          ],
          'temperature': 0.3,
          'max_tokens': 1500,
        });

        final response = await http.post(
          Uri.parse(_baseUrl),
          headers: {
            'Authorization': 'Bearer $apiKey',
            'Content-Type': 'application/json',
          },
          body: body,
        );

        if (response.statusCode == 200) {
          final data = jsonDecode(response.body) as Map<String, dynamic>;
          final choices = data['choices'] as List?;
          if (choices != null && choices.isNotEmpty) {
            final message = choices[0]['message'] as Map<String, dynamic>;
            final content = message['content'] as String? ?? '';
            final jsonStr = _extractJson(content);
            final parsed = _parseJson(jsonStr);
            parsed['transcription'] = transcription;
            return EOEvaluation.fromJson(parsed);
          }
        } else if (response.statusCode == 429 ||
            response.statusCode == 404 ||
            response.statusCode == 503) {
          continue;
        } else {
          throw Exception(
            'Erreur API (${response.statusCode}): ${response.body}',
          );
        }
      } catch (e) {
        if (model == _models.last) rethrow;
      }
    }

    throw Exception('Aucun modèle disponible pour l\'évaluation');
  }

  static String _extractJson(String content) {
    final start = content.indexOf('{');
    final end = content.lastIndexOf('}');
    if (start == -1 || end == -1 || end < start) return content;
    return content.substring(start, end + 1);
  }

  static Map<String, dynamic> _parseJson(String jsonStr) {
    jsonStr = jsonStr.replaceAll(RegExp(r',(\s*[}\]])'), r'$1');
    jsonStr = jsonStr.replaceAll(RegExp(r'//[^\n]*'), '');
    return jsonDecode(jsonStr) as Map<String, dynamic>;
  }
}
