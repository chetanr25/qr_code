import 'package:flutter/material.dart';

import '../../core/history_store.dart';
import '../../widgets/ui_kit.dart';
import '../scan/result_sheet.dart';
import '../create/qr_preview.dart';

class HistoryScreen extends StatefulWidget {
  const HistoryScreen({super.key});

  @override
  State<HistoryScreen> createState() => _HistoryScreenState();
}

class _HistoryScreenState extends State<HistoryScreen> {
  int _filter = 0; // 0 all, 1 scanned, 2 created, 3 favorites

  List<QrEntry> _apply(List<QrEntry> all) {
    return switch (_filter) {
      1 => all.where((e) => e.source == 'scan').toList(),
      2 => all.where((e) => e.source == 'create').toList(),
      3 => all.where((e) => e.favorite).toList(),
      _ => all,
    };
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      body: AuroraBackground(
        child: SafeArea(
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(20, 18, 20, 8),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'History',
                      style: TextStyle(
                        fontSize: 30,
                        fontWeight: FontWeight.w800,
                        letterSpacing: -1,
                        color: Theme.of(context).colorScheme.onSurface,
                      ),
                    ),
                    ValueListenableBuilder<List<QrEntry>>(
                      valueListenable: HistoryStore.instance.entries,
                      builder: (context, list, _) => list.isEmpty
                          ? const SizedBox()
                          : IconButton(
                              tooltip: 'Clear all',
                              onPressed: _confirmClear,
                              icon: const Icon(Icons.delete_sweep_rounded),
                            ),
                    ),
                  ],
                ),
              ),
              _filterBar(),
              Expanded(
                child: ValueListenableBuilder<List<QrEntry>>(
                  valueListenable: HistoryStore.instance.entries,
                  builder: (context, all, _) {
                    final list = _apply(all);
                    if (list.isEmpty) return const _Empty();
                    return ListView.separated(
                      padding: const EdgeInsets.fromLTRB(16, 8, 16, 120),
                      itemCount: list.length,
                      separatorBuilder: (_, __) => const SizedBox(height: 10),
                      itemBuilder: (context, i) =>
                          _HistoryTile(entry: list[i], onChanged: _refresh),
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _refresh() => setState(() {});

  Widget _filterBar() {
    const labels = ['All', 'Scanned', 'Created', 'Favorites'];
    return SizedBox(
      height: 40,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 20),
        itemCount: labels.length,
        separatorBuilder: (_, __) => const SizedBox(width: 8),
        itemBuilder: (context, i) => ChoiceChip(
          label: Text(labels[i]),
          selected: _filter == i,
          onSelected: (_) => setState(() => _filter = i),
        ),
      ),
    );
  }

  Future<void> _confirmClear() async {
    final ok = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Clear history?'),
        content: const Text('This removes all saved scans and creations.'),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: const Text('Cancel')),
          FilledButton(
              onPressed: () => Navigator.pop(context, true),
              child: const Text('Clear')),
        ],
      ),
    );
    if (ok == true) await HistoryStore.instance.clear();
  }
}

class _HistoryTile extends StatelessWidget {
  const _HistoryTile({required this.entry, required this.onChanged});
  final QrEntry entry;
  final VoidCallback onChanged;

  @override
  Widget build(BuildContext context) {
    return Dismissible(
      key: ValueKey(entry.createdAt.microsecondsSinceEpoch.toString() + entry.value),
      direction: DismissDirection.endToStart,
      background: Container(
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: 24),
        decoration: BoxDecoration(
          color: Colors.red.withValues(alpha: 0.85),
          borderRadius: BorderRadius.circular(20),
        ),
        child: const Icon(Icons.delete_rounded, color: Colors.white),
      ),
      onDismissed: (_) async {
        await HistoryStore.instance.remove(entry);
        onChanged();
      },
      child: GlassCard(
        padding: const EdgeInsets.all(14),
        onTap: () => _open(context),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: entry.kind.color.withValues(alpha: 0.16),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(entry.kind.icon, color: entry.kind.color, size: 22),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    entry.value,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                        fontWeight: FontWeight.w600, fontSize: 14.5),
                  ),
                  const SizedBox(height: 3),
                  Text(
                    '${entry.kind.label} · ${entry.source == 'scan' ? 'Scanned' : 'Created'} · ${_ago(entry.createdAt)}',
                    style: TextStyle(
                      fontSize: 12,
                      color: Theme.of(context)
                          .colorScheme
                          .onSurface
                          .withValues(alpha: 0.55),
                    ),
                  ),
                ],
              ),
            ),
            IconButton(
              onPressed: () async {
                await HistoryStore.instance.toggleFavorite(entry);
                onChanged();
              },
              icon: Icon(
                entry.favorite
                    ? Icons.star_rounded
                    : Icons.star_border_rounded,
                color: entry.favorite ? Colors.amber : null,
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _open(BuildContext context) {
    if (entry.source == 'create') {
      Navigator.of(context).push(MaterialPageRoute(
        builder: (_) => QrPreview(data: entry.value, kind: entry.kind),
      ));
    } else {
      showModalBottomSheet(
        context: context,
        isScrollControlled: true,
        backgroundColor: Colors.transparent,
        builder: (_) => ResultSheet(value: entry.value, kind: entry.kind),
      );
    }
  }

  String _ago(DateTime t) {
    final d = DateTime.now().difference(t);
    if (d.inMinutes < 1) return 'just now';
    if (d.inHours < 1) return '${d.inMinutes}m ago';
    if (d.inDays < 1) return '${d.inHours}h ago';
    if (d.inDays < 7) return '${d.inDays}d ago';
    return '${t.day}/${t.month}/${t.year}';
  }
}

class _Empty extends StatelessWidget {
  const _Empty();

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.history_toggle_off_rounded,
              size: 64, color: scheme.onSurface.withValues(alpha: 0.25)),
          const SizedBox(height: 14),
          Text(
            'Nothing here yet',
            style: TextStyle(
              fontSize: 17,
              fontWeight: FontWeight.w700,
              color: scheme.onSurface.withValues(alpha: 0.6),
            ),
          ),
          const SizedBox(height: 4),
          Text(
            'Scanned and created codes show up here',
            style: TextStyle(
                fontSize: 13,
                color: scheme.onSurface.withValues(alpha: 0.4)),
          ),
        ],
      ),
    );
  }
}
