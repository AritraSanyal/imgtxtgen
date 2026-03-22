import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/ad_models.dart';
import '../providers/providers.dart';
import '../widgets/section_card.dart';
import 'preview_screen.dart';

class CreateScreen extends ConsumerStatefulWidget {
  const CreateScreen({super.key});

  @override
  ConsumerState<CreateScreen> createState() => _CreateScreenState();
}

class _CreateScreenState extends ConsumerState<CreateScreen> {
  final _promptCtrl = TextEditingController();

  @override
  void dispose() {
    _promptCtrl.dispose();
    super.dispose();
  }

  Future<void> _generate() async {
    final prompt = _promptCtrl.text.trim();
    if (prompt.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter a prompt first')),
      );
      return;
    }

    final profile = ref.read(profileProvider);
    if (!profile.isComplete) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please complete your business profile first'),
        ),
      );
      return;
    }

    final request = ref.read(adRequestProvider);
    final fullRequest = AdRequest(
      prompt: prompt,
      platform: request.platform,
      format: request.format,
      includeHashtags: request.includeHashtags,
      generateImagePrompt: request.generateImagePrompt,
      applyBrandTone: request.applyBrandTone,
    );

    final ad = await ref
        .read(generationProvider.notifier)
        .generate(fullRequest);

    if (ad != null && mounted) {
      Navigator.of(context).push(
        MaterialPageRoute(builder: (_) => PreviewScreen(ad: ad)),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final request = ref.watch(adRequestProvider);
    final genState = ref.watch(generationProvider);
    final isLoading = genState.status == GenerationStatus.loading;

    return Scaffold(
      appBar: AppBar(title: const Text('Create Ad')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // Prompt input
          SectionCard(
            title: 'Ad Prompt',
            children: [
              TextField(
                controller: _promptCtrl,
                maxLines: 5,
                decoration: InputDecoration(
                  hintText:
                      'Describe what you want to promote — the more detail, the better the ad.',
                  border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10)),
                  contentPadding: const EdgeInsets.all(12),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),

          // Platform
          SectionCard(
            title: 'Platform',
            children: [
              Wrap(
                spacing: 8,
                children: AdPlatform.values.map((p) {
                  final selected = request.platform == p;
                  return ChoiceChip(
                    label: Text(p.label),
                    selected: selected,
                    onSelected: (_) =>
                        ref.read(adRequestProvider.notifier).setPlatform(p),
                    selectedColor: const Color(0xFF6C63FF),
                    labelStyle: TextStyle(
                      color: selected ? Colors.white : null,
                    ),
                  );
                }).toList(),
              ),
            ],
          ),
          const SizedBox(height: 12),

          // Format
          SectionCard(
            title: 'Format',
            children: [
              Wrap(
                spacing: 8,
                children: AdFormat.values.map((f) {
                  final selected = request.format == f;
                  return ChoiceChip(
                    label: Text(f.label),
                    selected: selected,
                    onSelected: (_) =>
                        ref.read(adRequestProvider.notifier).setFormat(f),
                    selectedColor: const Color(0xFF6C63FF),
                    labelStyle: TextStyle(
                      color: selected ? Colors.white : null,
                    ),
                  );
                }).toList(),
              ),
            ],
          ),
          const SizedBox(height: 12),

          // Options toggles
          SectionCard(
            title: 'Options',
            children: [
              SwitchListTile(
                title: const Text('Include hashtags'),
                value: request.includeHashtags,
                onChanged: ref.read(adRequestProvider.notifier).setIncludeHashtags,
                activeColor: const Color(0xFF6C63FF),
                dense: true,
              ),
              SwitchListTile(
                title: const Text('Generate image prompt'),
                value: request.generateImagePrompt,
                onChanged: ref
                    .read(adRequestProvider.notifier)
                    .setGenerateImagePrompt,
                activeColor: const Color(0xFF6C63FF),
                dense: true,
              ),
            ],
          ),
          const SizedBox(height: 24),

          // Error
          if (genState.status == GenerationStatus.error)
            Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.red.shade50,
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: Colors.red.shade200),
                ),
                child: Text(
                  genState.errorMessage ?? 'Unknown error',
                  style: const TextStyle(color: Colors.red),
                ),
              ),
            ),

          // Generate button
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: isLoading ? null : _generate,
              icon: isLoading
                  ? const SizedBox(
                      width: 18,
                      height: 18,
                      child: CircularProgressIndicator(
                          strokeWidth: 2, color: Colors.white),
                    )
                  : const Icon(Icons.bolt),
              label: Text(isLoading ? 'Generating…' : 'Generate Ad'),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF6C63FF),
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12)),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
