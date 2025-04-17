import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:google_generative_ai/google_generative_ai.dart';
import 'user_data_service.dart';

class NexusAIService {
  late final GenerativeModel _model;
  final List<Content> _history = [];
  final UserDataService _userDataService = UserDataService();

  NexusAIService() {
    final apiKey = dotenv.env['NEXUSAI_API_KEY'] ?? '';
    if (apiKey.isEmpty) {
      throw Exception('NexusAI API key not found');
    }
    _model = GenerativeModel(
      model: 'gemini-2.5-pro-exp-03-25',
      apiKey: apiKey,
      generationConfig: GenerationConfig(),
    );
  }

  Future<String> generateText(String prompt) async {
    try {
      // Create a user message
      final userMessage = Content.text(prompt);

      // Store user data
      await _userDataService.storeUserMessage(
        prompt,
        metadata: {
          'timestamp': DateTime.now().toIso8601String(),
          'input_type': 'text',
        },
      );

      // For the request we'll use only the immediate message
      // because the NexusAI API has limits on history length
      final response = await _model.generateContent([userMessage]);
      final responseText = response.text ?? 'No response generated';

      // Store both the user message and response in our local history
      // for context tracking (not sent to API, just for UI display)
      _history.add(userMessage);
      _history.add(Content.text(responseText));

      return responseText;
    } catch (e) {
      return 'Error: ${e.toString()}';
    }
  }

  Future<List<String>> generateCompletion(
    String prompt,
    int numberOfCompletions,
  ) async {
    List<String> completions = [];

    try {
      for (int i = 0; i < numberOfCompletions; i++) {
        final result = await generateText(
          '$prompt\nGeneration attempt ${i + 1}.',
        );
        completions.add(result);
      }
      return completions;
    } catch (e) {
      return ['Error generating completions: ${e.toString()}'];
    }
  }

  Future<String> exportUserData() async {
    return _userDataService.exportUserData();
  }

  Future<void> clearUserData() async {
    await _userDataService.clearUserData();
  }
}
