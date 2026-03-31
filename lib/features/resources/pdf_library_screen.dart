import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:tcf_canada_preparation/core/telemetry/app_analytics.dart';
import 'package:tcf_canada_preparation/core/widgets/responsive_frame.dart';
import 'package:tcf_canada_preparation/core/navigation/app_routes.dart';
import 'package:tcf_canada_preparation/core/layout/responsive.dart';
import 'package:tcf_canada_preparation/core/widgets/premium_ui.dart';

import 'pdf_viewer_screen.dart';

class PdfCatalogItem {
  final String id;
  final String title;
  final String assetPath;

  const PdfCatalogItem({
    required this.id,
    required this.title,
    required this.assetPath,
  });

  factory PdfCatalogItem.fromJson(Map<String, dynamic> json) {
    return PdfCatalogItem(
      id: (json['id'] ?? '').toString(),
      title: (json['title'] ?? '').toString(),
      assetPath: (json['assetPath'] ?? '').toString(),
    );
  }
}

class PdfLibraryScreen extends StatelessWidget {
  const PdfLibraryScreen({super.key});

  Future<List<PdfCatalogItem>> _loadCatalog() async {
    final jsonStr = await rootBundle.loadString('assets/data/pdf_catalog.json');
    final decoded = jsonDecode(jsonStr);
    if (decoded is! List) return const [];

    return decoded
        .whereType<Map<String, dynamic>>()
        .map(PdfCatalogItem.fromJson)
        .toList();
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    return ResponsiveFrame(
      expandToViewport: true,
      padding: Responsive.pagePadding(context, vertical: 16),
      child: FutureBuilder<List<PdfCatalogItem>>(
        future: _loadCatalog(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return Center(
              child: Text(
                'Erreur de chargement des PDF: ${snapshot.error}',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: cs.onSurface.withValues(alpha: 0.7),
                  fontWeight: FontWeight.w600,
                ),
              ),
            );
          }

          final items = snapshot.data ?? const <PdfCatalogItem>[];

          if (items.isEmpty) {
            return PremiumEmptyState(
              icon: Icons.picture_as_pdf_rounded,
              title: 'Aucun PDF pour le moment',
              subtitle:
                  'Ajoutez des fichiers dans `assets/pdfs/` puis mettez à jour `assets/data/pdf_catalog.json`.',
            );
          }

          return ListView.separated(
            padding: EdgeInsets.zero,
            itemCount: items.length,
            separatorBuilder: (_, __) => const SizedBox(height: 12),
            itemBuilder: (context, index) {
              final item = items[index];

              return InkWell(
                borderRadius: BorderRadius.circular(22),
                onTap: () {
                  AppAnalytics.logPdfOpened(pdfId: item.id);
                  Navigator.push(
                    context,
                    AppRoutes.fadeSlide(
                      PdfViewerScreen(
                        assetPath: item.assetPath,
                        title: item.title,
                      ),
                    ),
                  );
                },
                child: Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(22),
                    color: cs.surface,
                    border: Border.all(
                      color: cs.outlineVariant.withValues(alpha: 0.35),
                    ),
                  ),
                  child: Row(
                    children: [
                      Icon(Icons.picture_as_pdf_rounded, color: cs.primary),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          item.title,
                          style: const TextStyle(
                            fontWeight: FontWeight.w900,
                            fontSize: 14.5,
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      const SizedBox(width: 10),
                      Icon(
                        Icons.chevron_right_rounded,
                        color: cs.onSurface.withValues(alpha: 0.6),
                      ),
                    ],
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}

