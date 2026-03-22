import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/providers.dart';

class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      appBar: AppBar(title: const Text('Settings')),
      body: ListView(
        children: [
          const _SectionHeader('AI Model'),
          ListTile(
            leading: const Icon(Icons.smart_toy_outlined),
            title: const Text('Text model'),
            subtitle: const Text('claude-sonnet-4-20250514'),
            trailing: const Icon(Icons.check, color: Color(0xFF6C63FF)),
          ),
          const Divider(),
          const _SectionHeader('API Keys'),
          ListTile(
            leading: const Icon(Icons.key),
            title: const Text('Anthropic API key'),
            subtitle: const Text('Set in .env file'),
            trailing: const Icon(Icons.info_outline, size: 18),
          ),
          const Divider(),
          const _SectionHeader('Data'),
          ListTile(
            leading: const Icon(Icons.delete_outline, color: Colors.red),
            title: const Text('Clear all data',
                style: TextStyle(color: Colors.red)),
            subtitle: const Text('Deletes profile and ad history'),
            onTap: () async {
              final confirm = await showDialog<bool>(
                context: context,
                builder: (_) => AlertDialog(
                  title: const Text('Clear all data?'),
                  content: const Text(
                      'This will delete your business profile and all ad history.'),
                  actions: [
                    TextButton(
                        onPressed: () => Navigator.pop(context, false),
                        child: const Text('Cancel')),
                    TextButton(
                        onPressed: () => Navigator.pop(context, true),
                        child: const Text('Clear',
                            style: TextStyle(color: Colors.red))),
                  ],
                ),
              );
              if (confirm == true) {
                await ref.read(storageServiceProvider).clearAll();
                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('All data cleared')),
                  );
                }
              }
            },
          ),
          const Divider(),
          const _SectionHeader('About'),
          const ListTile(
            leading: Icon(Icons.info_outline),
            title: Text('AdGen AI'),
            subtitle: Text('v1.0.0 — Powered by Claude'),
          ),
        ],
      ),
    );
  }
}

class _SectionHeader extends StatelessWidget {
  final String title;
  const _SectionHeader(this.title);

  @override
  Widget build(BuildContext context) => Padding(
        padding: const EdgeInsets.fromLTRB(16, 16, 16, 4),
        child: Text(title.toUpperCase(),
            style: const TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w600,
                color: Color(0xFF6C63FF),
                letterSpacing: 0.8)),
      );
}
