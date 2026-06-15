import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:tcf_canada_preparation/services/dotenv_service.dart';

class GroqSTTService {
  GroqSTTService._();

  static const String _baseUrl =
      'https://api.groq.com/openai/v1/audio/transcriptions';

  static Future<String> transcribe(List<int> audioBytes) async {
    final apiKey = DotenvService.openRouterApiKey;
    if (apiKey.isEmpty) {
      throw Exception(
        'Clé API Groq non configurée. Ajoutez GROQ_API_KEY.',
      );
    }

    final uri = Uri.parse(_baseUrl);
    final request = http.MultipartRequest('POST', uri);

    request.headers['Authorization'] = 'Bearer $apiKey';
    request.fields['model'] = 'whisper-large-v3-turbo';
    request.fields['response_format'] = 'json';
    request.fields['language'] = 'fr';

    request.files.add(http.MultipartFile.fromBytes(
      'file',
      audioBytes,
      filename: 'audio.wav',
    ));

    final streamed = await request.send();
    final response = await http.Response.fromStream(streamed);

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body) as Map<String, dynamic>;
      return data['text'] as String? ?? '';
    } else {
      throw Exception(
        'Erreur de transcription (${response.statusCode}): ${response.body}',
      );
    }
  }
}
