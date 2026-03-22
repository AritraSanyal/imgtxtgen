import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/ad_models.dart';
import '../providers/providers.dart';
import 'preview_screen.dart';

class HistoryScreen extends ConsumerWidget {
  const HistoryScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final ads = ref.watch(adHistoryProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Ad History')),
      body: ads.isEmpty
          ? const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.history, size: 64, color: Colors.grey),
                  SizedBox(height: 12),
                  Text('No ads yet — go create one!',
                      style: TextStyle(color: Colors.grey)),
                ],
              ),
            )
          : ListView(
              padding: const EdgeInsets.all(16),
              children: [
                // Stats
                _StatsRow(ads: ads),
                const SizedBox(height: 16),
                const Text('Recent Ads',
                    style: TextStyle(
                        fontWeight: FontWeight.w600, fontSize: 15)),
                const SizedBox(height: 8),
                ...ads.map((ad) => _AdTile(
                      ad: ad,
                      onTap: () => Navigator.of(context).push(
                        MaterialPageRoute(
                            builder: (_) => PreviewScreen(ad: ad)),
                      ),
                      onDelete: () =>
                          ref.read(adHistoryProvider.notifier).delete(ad.id),
                    )),
              ],
            ),
    );
  }
}

class _StatsRow extends StatelessWidget {
  final List<GeneratedAd> ads;
  const _StatsRow({required this.ads});

  @override
  Widget build(BuildContext context) {
    final total = ads.length;
    final exported = ads.where((a) => a.status == AdStatus.exported).length;
    final platforms = ads.map((a) => a.platform).toSet().length;
    final drafts = ads.where((a) => a.status == AdStatus.draft).length;

    return GridView.count(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      crossAxisCount: 2,
      childAspectRatio: 2.4,
      mainAxisSpacing: 10,
      crossAxisSpacing: 10,
      children: [
        _StatCard(label: 'Total ads', value: '$total', color: const Color(0xFFEAE8FF)),
        _StatCard(label: 'Exported', value: '$exported', color: const Color(0xFFE8F5E9)),
        _StatCard(label: 'Platforms', value: '$platforms', color: const Color(0xFFFFF3E0)),
        _StatCard(label: 'Drafts', value: '$drafts', color: const Color(0xFFFCE4EC)),
      ],
    );
  }
}

class _StatCard extends StatelessWidget {
  final String label;
  final String value;
  final Color color;
  const _StatCard(
      {required this.label, required this.value, required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(10),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(value,
              style: const TextStyle(
                  fontSize: 24, fontWeight: FontWeight.w700)),
          Text(label,
              style: const TextStyle(fontSize: 11, color: Colors.black54)),
        ],
      ),
    );
  }
}

class _AdTile extends StatelessWidget {
  final GeneratedAd ad;
  final VoidCallback onTap;
  final VoidCallback onDelete;

  const _AdTile(
      {required this.ad, required this.onTap, required this.onDelete});

  @override
  Widget build(BuildContext context) {
    final colors = [
      [const Color(0xFF6C63FF), const Color(0xFFFF6584)],
      [const Color(0xFF11998e), const Color(0xFF38ef7d)],
      [const Color(0xFFf7971e), const Color(0xFFffd200)],
    ];
    final c = colors[ad.id.hashCode.abs() % colors.length];

    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: ListTile(
        onTap: onTap,
        leading: Container(
          width: 48,
          height: 48,
          decoration: BoxDecoration(
            gradient: LinearGradient(colors: c),
            borderRadius: BorderRadius.circular(8),
          ),
        ),
        title: Text(ad.headline,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(fontWeight: FontWeight.w600)),
        subtitle: Text(
          '${ad.platform.label} · ${_timeAgo(ad.createdAt)}',
          style: const TextStyle(fontSize: 12),
        ),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            _statusBadge(ad.status),
            IconButton(
              icon: const Icon(Icons.delete_outline, size: 18),
              onPressed: onDelete,
              color: Colors.grey,
            ),
          ],
        ),
      ),
    );
  }

  Widget _statusBadge(AdStatus status) {
    final (label, bg, fg) = switch (status) {
      AdStatus.exported => ('Exported', const Color(0xFFE8F5E9), const Color(0xFF2E7D32)),
      AdStatus.generated => ('Generated', const Color(0xFFE3F2FD), const Color(0xFF1565C0)),
      AdStatus.draft => ('Draft', const Color(0xFFFFF3E0), const Color(0xFFE65100)),
    };
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
          color: bg, borderRadius: BorderRadius.circular(8)),
      child: Text(label,
          style: TextStyle(
              fontSize: 10, fontWeight: FontWeight.w600, color: fg)),
    );
  }

  String _timeAgo(DateTime dt) {
    final diff = DateTime.now().difference(dt);
    if (diff.inDays > 0) return '${diff.inDays}d ago';
    if (diff.inHours > 0) return '${diff.inHours}h ago';
    return 'Just now';
  }
}
