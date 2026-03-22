import 'dart:convert';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;
import '../models/ad_models.dart';
import '../models/business_profile.dart';

class ClaudeApiException implements Exception {
  final String message;
  const ClaudeApiException(this.message);
  @override
  String toString() => 'ClaudeApiException: $message';
}

class ClaudeService {
  static const _baseUrl = 'https://api.anthropic.com/v1/messages';
  static const _model = 'claude-sonnet-4-20250514';
  static const _apiVersion = '2023-06-01';

  String get _apiKey {
    final key = dotenv.env['ANTHROPIC_API_KEY'] ?? '';
    if (key.isEmpty || key == 'your_anthropic_api_key_here') {
      throw const ClaudeApiException(
          'ANTHROPIC_API_KEY not set in .env file');
    }
    return key;
  }

  // -----------------------------------------------------------------
  // Build the system prompt from the stored business profile
  // -----------------------------------------------------------------
  String _buildSystemPrompt(BusinessProfile profile) {
    final tones = profile.brandTones.isNotEmpty
        ? profile.brandTones.join(', ')
        : 'professional, engaging';

    final interests = profile.interests.isNotEmpty
        ? profile.interests.join(', ')
        : 'general audience';

    return '''
You are a world-class advertising copywriter for ${profile.businessName.isEmpty ? 'a business' : profile.businessName}.

BRAND CONTEXT:
- Business: ${profile.businessName}
- Industry: ${profile.industry}
- Tagline: "${profile.tagline}"
- Brand tone: $tones

TARGET AUDIENCE:
- Age range: ${profile.ageRange.isEmpty ? 'general' : profile.ageRange}
- Gender focus: ${profile.targetGender.isEmpty ? 'all genders' : profile.targetGender}
- Interests: $interests

Your job is to write compelling, on-brand advertisement copy that resonates with the target audience.
Always respond with ONLY a valid JSON object — no markdown, no code fences, no preamble.
''';
  }

  // -----------------------------------------------------------------
  // Build the user message from the AdRequest
  // -----------------------------------------------------------------
  String _buildUserMessage(AdRequest request, BusinessProfile profile) {
    final benefits = profile.keyBenefits.isNotEmpty
        ? profile.keyBenefits.join(', ')
        : 'not specified';

    return '''
Create an advertisement with these requirements:

CAMPAIGN PROMPT:
"${request.prompt}"

PRODUCT / SERVICE: ${profile.currentProduct.isEmpty ? 'see prompt' : profile.currentProduct}
KEY BENEFITS: $benefits
PLATFORM: ${request.platform.label}
FORMAT: ${request.format.label}
INCLUDE HASHTAGS: ${request.includeHashtags}
GENERATE IMAGE PROMPT: ${request.generateImagePrompt}

Respond ONLY with this exact JSON structure (no markdown, no explanation):
{
  "headline": "A punchy headline under 10 words",
  "body": "Ad body copy, 2-3 sentences, persuasive and on-brand",
  "cta": "Short call to action like Shop Now or Learn More",
  "hashtags": ["tag1", "tag2", "tag3", "tag4"],
  "image_prompt": "A detailed image generation prompt for this ad (or empty string if not requested)"
}
''';
  }

  // -----------------------------------------------------------------
  // Core generation method
  // -----------------------------------------------------------------
  Future<Map<String, dynamic>> generateAdCopy({
    required AdRequest request,
    required BusinessProfile profile,
  }) async {
    final systemPrompt = _buildSystemPrompt(profile);
    final userMessage = _buildUserMessage(request, profile);

    final response = await http.post(
      Uri.parse(_baseUrl),
      headers: {
        'Content-Type': 'application/json',
        'x-api-key': _apiKey,
        'anthropic-version': _apiVersion,
      },
      body: jsonEncode({
        'model': _model,
        'max_tokens': 1024,
        'system': systemPrompt,
        'messages': [
          {'role': 'user', 'content': userMessage},
        ],
      }),
    );

    if (response.statusCode != 200) {
      final err = jsonDecode(response.body);
      throw ClaudeApiException(
          err['error']?['message'] ?? 'API error ${response.statusCode}');
    }

    final data = jsonDecode(response.body);
    final rawText = (data['content'] as List)
        .where((b) => b['type'] == 'text')
        .map((b) => b['text'] as String)
        .join('');

    // Strip any accidental markdown fences
    final cleaned = rawText
        .replaceAll('```json', '')
        .replaceAll('```', '')
        .trim();

    try {
      return jsonDecode(cleaned) as Map<String, dynamic>;
    } catch (_) {
      throw ClaudeApiException(
          'Model returned invalid JSON. Raw: $cleaned');
    }
  }

  // -----------------------------------------------------------------
  // Regenerate a specific field only
  // -----------------------------------------------------------------
  Future<String> regenerateField({
    required String field,
    required GeneratedAd existingAd,
    required BusinessProfile profile,
  }) async {
    final response = await http.post(
      Uri.parse(_baseUrl),
      headers: {
        'Content-Type': 'application/json',
        'x-api-key': _apiKey,
        'anthropic-version': _apiVersion,
      },
      body: jsonEncode({
        'model': _model,
        'max_tokens': 256,
        'system': _buildSystemPrompt(profile),
        'messages': [
          {
            'role': 'user',
            'content':
                'Rewrite only the "$field" for this ad. Original prompt: "${existingAd.originalPrompt}". '
                    'Existing headline: "${existingAd.headline}". '
                    'Respond with ONLY the new $field text, no JSON, no explanation.',
          }
        ],
      }),
    );

    if (response.statusCode != 200) {
      throw const ClaudeApiException('Failed to regenerate field');
    }

    final data = jsonDecode(response.body);
    return (data['content'] as List)
        .where((b) => b['type'] == 'text')
        .map((b) => b['text'] as String)
        .join('')
        .trim();
  }
}
