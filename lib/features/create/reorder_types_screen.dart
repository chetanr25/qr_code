import 'package:flutter/material.dart';

import '../../core/app_prefs.dart';
import '../../core/qr_kind.dart';
import '../../widgets/ui_kit.dart';

/// Drag-to-rearrange the order of QR types on the Create grid. Persists
/// immediately to [AppPrefs.kindOrder].
class ReorderTypesScreen extends StatefulWidget {
  const ReorderTypesScreen({super.key});

  @override
  State<ReorderTypesScreen> createState() => _ReorderTypesScreenState();
}

class _ReorderTypesScreenState extends State<ReorderTypesScreen> {
  late List<QrKind> _order = List.of(AppPrefs.instance.kindOrder.value);

  void _onReorder(int oldIndex, int newIndex) {
    setState(() {
      final item = _order.removeAt(oldIndex);
      _order.insert(newIndex, item);
    });
    AppPrefs.instance.setKindOrder(_order);
  }

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Scaffold(
      backgroundColor: Colors.transparent,
      appBar: AppBar(
        title: const Text('Rearrange types'),
        actions: [
          TextButton(
            onPressed: () {
              AppPrefs.instance.setKindOrder(kCreateKinds);
              setState(() => _order = List.of(kCreateKinds));
            },
            child: const Text('Reset'),
          ),
        ],
      ),
      body: AuroraBackground(
        child: SafeArea(
          top: false,
          child: ReorderableListView.builder(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 32),
            itemCount: _order.length,
            onReorderItem: _onReorder,
            proxyDecorator: (child, index, animation) => Material(
              color: Colors.transparent,
              child: child,
            ),
            itemBuilder: (context, i) {
              final kind = _order[i];
              return Padding(
                key: ValueKey(kind),
                padding: const EdgeInsets.only(bottom: 10),
                child: GlassCard(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 14, vertical: 6),
                  child: Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(9),
                        decoration: BoxDecoration(
                          color: kind.color.withValues(alpha: 0.16),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Icon(kind.icon, color: kind.color, size: 20),
                      ),
                      const SizedBox(width: 14),
                      Expanded(
                        child: Text(
                          kind.label,
                          style: const TextStyle(
                              fontWeight: FontWeight.w600, fontSize: 15),
                        ),
                      ),
                      ReorderableDragStartListener(
                        index: i,
                        child: Icon(Icons.drag_handle_rounded,
                            color: scheme.onSurface.withValues(alpha: 0.5)),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        ),
      ),
    );
  }
}
