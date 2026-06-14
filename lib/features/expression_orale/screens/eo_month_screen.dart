import 'package:flutter/material.dart';
import '../models/eo_month.dart';
import '../models/eo_party.dart';

class EOMonthScreen extends StatelessWidget {
  final EOMonth month;

  const EOMonthScreen({super.key, required this.month});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(month.examTitle),
        centerTitle: true,
      ),
      body: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: month.parties.length,
        itemBuilder: (context, index) {
          final party = month.parties[index];
          return _PartyCard(party: party, index: index);
        },
      ),
    );
  }
}

class _PartyCard extends StatefulWidget {
  final EOParty party;
  final int index;

  const _PartyCard({required this.party, required this.index});

  @override
  State<_PartyCard> createState() => _PartyCardState();
}

class _PartyCardState extends State<_PartyCard> {
  bool _expanded = false;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Material(
        color: cs.surfaceContainerLow,
        borderRadius: BorderRadius.circular(16),
        child: InkWell(
          onTap: () => setState(() => _expanded = !_expanded),
          borderRadius: BorderRadius.circular(16),
          child: Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: cs.outlineVariant.withValues(alpha: 0.4),
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: const EdgeInsets.all(16),
                  child: Row(
                    children: [
                      Container(
                        width: 40,
                        height: 40,
                        decoration: BoxDecoration(
                          color: cs.primaryContainer.withValues(alpha: 0.5),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Center(
                          child: Text(
                            '${widget.index + 1}',
                            style: TextStyle(
                              fontWeight: FontWeight.w900,
                              color: cs.primary,
                              fontSize: 16,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 14),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              widget.party.title,
                              style: const TextStyle(
                                fontWeight: FontWeight.w800,
                                fontSize: 14,
                              ),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              '${widget.party.sujets.length} sujets',
                              style: TextStyle(
                                fontSize: 12,
                                color: cs.onSurface.withValues(alpha: 0.6),
                              ),
                            ),
                          ],
                        ),
                      ),
                      Icon(
                        _expanded
                            ? Icons.expand_less_rounded
                            : Icons.expand_more_rounded,
                        color: cs.primary,
                      ),
                    ],
                  ),
                ),
                if (_expanded) ...[
                  Divider(
                    height: 1,
                    color: cs.outlineVariant.withValues(alpha: 0.3),
                  ),
                  Padding(
                    padding: const EdgeInsets.fromLTRB(16, 12, 16, 16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: widget.party.sujets.map((sujet) {
                        final isHeader = sujet.startsWith('Sujet') ||
                            sujet.startsWith('👉') ||
                            sujet.startsWith('🎙️') ||
                            sujet.startsWith('🦊') ||
                            sujet.startsWith('🎤');
                        final isSectionBreak = sujet.startsWith('👉') ||
                            sujet.startsWith('🎙️') ||
                            sujet.startsWith('🎤');

                        if (isSectionBreak) {
                          return Padding(
                            padding: const EdgeInsets.only(top: 12, bottom: 4),
                            child: Text(
                              sujet,
                              style: TextStyle(
                                fontWeight: FontWeight.w800,
                                fontSize: 13,
                                color: cs.secondary,
                              ),
                            ),
                          );
                        }

                        if (isHeader) {
                          return Padding(
                            padding: const EdgeInsets.only(bottom: 4),
                            child: Text(
                              sujet,
                              style: TextStyle(
                                fontWeight: FontWeight.w700,
                                fontSize: 13,
                                color: cs.primary,
                              ),
                            ),
                          );
                        }

                        return Padding(
                          padding: const EdgeInsets.only(bottom: 10),
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Padding(
                                padding: const EdgeInsets.only(top: 4, right: 8),
                                child: Icon(
                                  Icons.fiber_manual_record_rounded,
                                  size: 8,
                                  color: cs.primary.withValues(alpha: 0.6),
                                ),
                              ),
                              Expanded(
                                child: Text(
                                  sujet,
                                  style: TextStyle(
                                    fontSize: 13,
                                    color: cs.onSurface.withValues(alpha: 0.85),
                                    height: 1.4,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        );
                      }).toList(),
                    ),
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }
}
