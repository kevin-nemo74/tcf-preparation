import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:tcf_canada_preparation/services/dotenv_service.dart';
import '../models/ee_evaluation.dart';

class _RetryableException implements Exception {
  final String message;
  _RetryableException(this.message);

  @override
  String toString() => message;
}

class OpenRouterService {
  OpenRouterService._();

  static const String _baseUrl =
      'https://api.groq.com/openai/v1/chat/completions';

  static const List<Map<String, String>> _models = [
    {'id': 'llama-3.3-70b-versatile', 'name': 'Llama 3.3 70B'},
    {'id': 'mixtral-8x7b-32768', 'name': 'Mixtral 8x7B'},
    {'id': 'llama3-8b-8192', 'name': 'Llama 3 8B'},
  ];

  static Future<EECombinaisonEvaluation> evaluate({
    required String tache1Instruction,
    required int tache1MinWords,
    required int tache1MaxWords,
    required String tache1Answer,
    required String tache2Instruction,
    required int tache2MinWords,
    required int tache2MaxWords,
    required String tache2Answer,
    required String tache3Instruction,
    required int tache3MinWords,
    required int tache3MaxWords,
    required String tache3Answer,
    String? tache3DocumentA,
    String? tache3DocumentB,
  }) async {
    final apiKey = DotenvService.openRouterApiKey;
    if (apiKey.isEmpty) {
      throw Exception(
        'Clé API Groq non configurée. Ajoutez GROQ_API_KEY au fichier .env.',
      );
    }

    const systemPrompt = '''
Tu es un évaluateur expert du TCF Canada pour l'épreuve d'Expression Écrite.

Évalue les 3 productions de l'étudiant selon les 4 critères officiels du TCF Canada :

1. **Respect de la consigne** (0-25 points par tâche) : 
   - L'étudiant a-t-il respecté le sujet demandé ?
   - Le format est-il approprié ?
   - Le nombre de mots est-il dans la plage demandée ?
   - Le registre de langue est-il adapté au destinataire ?

2. **Cohérence et cohésion** (0-25 points par tâche) :
   - Le texte est-il bien structuré ?
   - Les idées s'enchaînent-elles de manière logique ?
   - Les connecteurs logiques sont-ils bien utilisés ?

3. **Compétence lexicale** (0-25 points par tâche) :
   - Le vocabulaire est-il varié et approprié ?
   - Y a-t-il des répétitions excessives ?

4. **Compétence grammaticale** (0-25 points par tâche) :
   - La grammaire est-elle correcte ?
   - La conjugaison est-elle juste ?
   - L'orthographe est-elle acceptable ?

IMPORTANT : Chaque tâche est notée sur 25 points (100 points au total pour les 3 tâches).
Le score final est sur 20 points ((score/100) * 20).

Réponds UNIQUEMENT avec un objet JSON valide (sans markdown, sans texte avant/après) :
{
  "overall_score": 0,
  "max_score": 100,
  "word_counts": {
    "tache1": 0,
    "tache2": 0,
    "tache3": 0
  },
  "taches": {
    "tache1": {"score": 0, "max_score": 25, "feedback": ""},
    "tache2": {"score": 0, "max_score": 25, "feedback": ""},
    "tache3": {"score": 0, "max_score": 25, "feedback": ""}
  },
  "general_feedback": "",
  "corrections": "",
  "suggestions": ""
}

Sois objectif, précis et constructif. Le feedback doit être en français.
''';

    String tache3WithDocs = tache3Instruction;
    if (tache3DocumentA != null && tache3DocumentB != null) {
      tache3WithDocs +=
          '\n\nDocument A : $tache3DocumentA\n\nDocument B : $tache3DocumentB';
    }

    final userPrompt =
        '''
TÂCHE 1 : $tache1Instruction
Nombre de mots attendu : $tache1MinWords à $tache1MaxWords mots
Réponse de l'étudiant :
$tache1Answer

---

TÂCHE 2 : $tache2Instruction
Nombre de mots attendu : $tache2MinWords à $tache2MaxWords mots
Réponse de l'étudiant :
$tache2Answer

---

TÂCHE 3 : $tache3WithDocs
Nombre de mots attendu : $tache3MinWords à $tache3MaxWords mots
Réponse de l'étudiant :
$tache3Answer
''';

    String? lastError;

    for (final modelInfo in _models) {
      final model = modelInfo['id']!;
      final modelName = modelInfo['name']!;

      try {
        final response = await http.post(
          Uri.parse(_baseUrl),
          headers: {
            'Content-Type': 'application/json',
            'Authorization': 'Bearer $apiKey',
          },
          body: jsonEncode({
            'model': model,
            'messages': [
              {'role': 'system', 'content': systemPrompt},
              {'role': 'user', 'content': userPrompt},
            ],
            'temperature': 0.3,
            'max_tokens': 2500,
          }),
        );

        if (response.statusCode != 200) {
          String errorMsg = 'Erreur API: ${response.statusCode}';
          try {
            final errorBody = jsonDecode(response.body) as Map<String, dynamic>;
            final error = errorBody['error'] as Map<String, dynamic>?;
            if (error != null) {
              errorMsg = error['message']?.toString() ?? errorMsg;
            }
          } catch (_) {}

          if (response.statusCode == 429) {
            lastError =
                'Rate limit atteint pour $modelName. Essai avec un autre modèle...';
            continue;
          }
          if (response.statusCode >= 500) {
            lastError = 'Serveur indisponible ($modelName): $errorMsg';
            continue;
          }
          throw Exception(errorMsg);
        }

        Map<String, dynamic> data;
        try {
          data = jsonDecode(response.body) as Map<String, dynamic>;
        } catch (_) {
          throw _RetryableException(
            'Réponse invalide du serveur. Essai avec un autre modèle...',
          );
        }

        final error = data['error'] as Map<String, dynamic>?;
        if (error != null) {
          final message = error['message']?.toString() ?? 'Erreur inconnue';
          throw Exception(message);
        }

        final choices = data['choices'] as List<dynamic>?;
        if (choices == null || choices.isEmpty) {
          throw _RetryableException(
            'Réponse du modèle incomplète. Essai avec un autre modèle...',
          );
        }

        final content = choices[0]['message']?['content'] as String?;

        if (content == null || content.isEmpty) {
          throw _RetryableException(
            'Aucune réponse de l\'IA. Veuillez réessayer.',
          );
        }

        String jsonStr;
        try {
          jsonStr = _extractJson(content);
          final parsed = _parseJson(jsonStr);
          return EECombinaisonEvaluation.fromJson(parsed);
        } catch (_) {
          throw _RetryableException(
            'Le modèle a retourné un format inattendu. Essai avec un autre modèle...',
          );
        }
      } on _RetryableException {
        continue;
      } catch (e) {
        rethrow;
      }
    }

    throw Exception(
      lastError ??
          'Tous les modèles sont indisponibles. Veuillez réessayer plus tard.',
    );
  }

  static String _extractJson(String content) {
    String cleaned = content.trim();

    cleaned = cleaned.replaceAll(RegExp(r'^```json\s*'), '```');
    cleaned = cleaned.replaceAll(RegExp(r'^```\s*'), '');
    cleaned = cleaned.replaceAll(RegExp(r'\s*```$'), '');

    final start = cleaned.indexOf('{');
    final end = cleaned.lastIndexOf('}');
    if (start == -1 || end == -1 || end <= start) {
      throw Exception('Réponse JSON invalide');
    }
    return cleaned.substring(start, end + 1);
  }

  static Map<String, dynamic> _parseJson(String jsonStr) {
    try {
      return jsonDecode(jsonStr) as Map<String, dynamic>;
    } catch (_) {
      String fixed = jsonStr;

      fixed = fixed.replaceAll(RegExp(r",\s*([}\]])"), r"$1");

      try {
        return jsonDecode(fixed) as Map<String, dynamic>;
      } catch (_) {
        throw Exception('Réponse JSON invalide');
      }
    }
  }
}
