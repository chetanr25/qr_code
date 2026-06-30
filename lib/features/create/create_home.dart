import 'package:flutter/material.dart';

import '../../core/qr_kind.dart';
import '../../widgets/ui_kit.dart';
import 'create_form.dart';

class CreateHome extends StatelessWidget {
  const CreateHome({super.key});

  static const _kinds = [
    QrKind.url,
    QrKind.upi,
    QrKind.wifi,
    QrKind.contact,
    QrKind.text,
    QrKind.email,
    QrKind.phone,
    QrKind.sms,
    QrKind.geo,
    QrKind.event,
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      body: AuroraBackground(
        child: SafeArea(
          child: CustomScrollView(
            slivers: [
              const SliverPadding(
                padding: EdgeInsets.fromLTRB(20, 18, 20, 6),
                sliver: SliverToBoxAdapter(child: _Header()),
              ),
              SliverPadding(
                padding: const EdgeInsets.fromLTRB(16, 10, 16, 120),
                sliver: SliverGrid(
                  gridDelegate:
                      const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    mainAxisSpacing: 14,
                    crossAxisSpacing: 14,
                    childAspectRatio: 1.15,
                  ),
                  delegate: SliverChildBuilderDelegate(
                    (context, i) => _KindTile(kind: _kinds[i]),
                    childCount: _kinds.length,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _Header extends StatelessWidget {
  const _Header();

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Create',
          style: TextStyle(
            fontSize: 30,
            fontWeight: FontWeight.w800,
            letterSpacing: -1,
            color: Theme.of(context).colorScheme.onSurface,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          'Pick a type to generate a QR code',
          style: TextStyle(
            fontSize: 14,
            color: Theme.of(context)
                .colorScheme
                .onSurface
                .withValues(alpha: 0.6),
          ),
        ),
      ],
    );
  }
}

class _KindTile extends StatelessWidget {
  const _KindTile({required this.kind});
  final QrKind kind;

  @override
  Widget build(BuildContext context) {
    return GlassCard(
      padding: const EdgeInsets.all(18),
      onTap: () {
        Navigator.of(context).push(
          MaterialPageRoute(builder: (_) => CreateForm(kind: kind)),
        );
      },
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  kind.color,
                  kind.color.withValues(alpha: 0.6),
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: kind.color.withValues(alpha: 0.4),
                  blurRadius: 16,
                  offset: const Offset(0, 6),
                ),
              ],
            ),
            child: Icon(kind.icon, color: Colors.white, size: 26),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                kind.label,
                style: const TextStyle(
                    fontSize: 16, fontWeight: FontWeight.w700),
              ),
              const SizedBox(height: 2),
              Text(
                _subtitle(kind),
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
        ],
      ),
    );
  }

  String _subtitle(QrKind k) => switch (k) {
        QrKind.url => 'Website or link',
        QrKind.upi => 'Pay via phone / UPI ID',
        QrKind.wifi => 'Share your network',
        QrKind.contact => 'vCard from contacts',
        QrKind.text => 'Any plain text',
        QrKind.email => 'Pre-filled email',
        QrKind.phone => 'Tap to call',
        QrKind.sms => 'Pre-filled message',
        QrKind.geo => 'Drop a pin',
        QrKind.event => 'Calendar invite',
      };
}
