import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/ad_models.dart';
import '../providers/providers.dart';
import '../widgets/ad_preview_card.dart';

class PreviewScreen extends ConsumerStatefulWidget {
  final GeneratedAd ad;
  const PreviewScreen({super.key, required this.ad});

  @override
  ConsumerState<PreviewScreen> createState() => _PreviewScreenState();
}

class _PreviewScreenState extends ConsumerState<PreviewScreen> {
  late GeneratedAd _ad;

  @override
  void initState() {
    super.initState();
    _ad = widget.ad;
  }

  void _copyAll() {
    final text = '${_ad.headline}\n\n${_ad.body}\n\n'
        '${_ad.hashtags.map((h) => '#$h').join(' ')}';
    Clipboard.setData(ClipboardData(text: text));
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Ad copy copied to clipboard!')),
    );
  }

  Future<void> _markExported() async {
    final exported = _ad.copyWith(status: AdStatus.exported);
    await ref.read(adHistoryProvider.notifier).addOrUpdate(exported);
    setState(() => _ad = exported);
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Ad marked as exported!')),
      );
    }
  }

  Future<void> _regenerate() async {
    final request = AdRequest(
      prompt: _ad.originalPrompt,
      platform: _ad.platform,
      format: _ad.format,
      includeHashtags: _ad.hashtags.isNotEmpty,
      generateImagePrompt: _ad.imagePrompt != null,
    );
    final newAd =
        await ref.read(generationProvider.notifier).generate(request);
    if (newAd != null && mounted) {
      setState(() => _ad = newAd);
    }
  }

  @override
  Widget build(BuildContext context) {
    final isLoading =
        ref.watch(generationProvider).status == GenerationStatus.loading;

    return Scaffold(
      appBar: AppBar(
        title: Text('${_ad.platform.label} · ${_ad.format.label}'),
        actions: [
          IconButton(
            icon: const Icon(Icons.copy),
            tooltip: 'Copy all',
            onPressed: _copyAll,
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          AdPreviewCard(ad: _ad),
          const SizedBox(height: 16),

          // Image prompt section
          if (_ad.imagePrompt != null && _ad.imagePrompt!.isNotEmpty) ...[
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.amber.shade50,
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: Colors.amber.shade200),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('Image Prompt',
                      style: TextStyle(
                          fontWeight: FontWeight.w600, fontSize: 12)),
                  const SizedBox(height: 6),
                  Text(_ad.imagePrompt!,
                      style: const TextStyle(fontSize: 13)),
                  const SizedBox(height: 8),
                  GestureDetector(
                    onTap: () {
                      Clipboard.setData(
                          ClipboardData(text: _ad.imagePrompt!));
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                            content: Text('Image prompt copied!')),
                      );
                    },
                    child: const Text('Copy image prompt →',
                        style: TextStyle(
                            color: Color(0xFF6C63FF), fontSize: 12)),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
          ],

          // Action buttons
          Row(
            children: [
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: isLoading ? null : _regenerate,
                  icon: isLoading
                      ? const SizedBox(
                          width: 14,
                          height: 14,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : const Icon(Icons.refresh),
                  label: const Text('Regenerate'),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: _markExported,
                  icon: const Icon(Icons.ios_share),
                  label: const Text('Export'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF6C63FF),
                    foregroundColor: Colors.white,
                  ),
                ),
              ),
            ],
          ),

          const SizedBox(height: 12),
          SizedBox(
            width: double.infinity,
            child: TextButton.icon(
              onPressed: _copyAll,
              icon: const Icon(Icons.copy),
              label: const Text('Copy all ad copy'),
            ),
          ),
        ],
      ),
    );
  }
}
