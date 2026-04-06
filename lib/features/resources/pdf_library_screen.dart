import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:tcf_canada_preparation/core/telemetry/app_analytics.dart';
import 'package:tcf_canada_preparation/core/widgets/app_motion.dart';
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

  Widget _buildPdfHeader(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            cs.errorContainer.withValues(alpha: 0.5),
            cs.surfaceContainerHighest.withValues(alpha: 0.4),
          ],
        ),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: cs.error.withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(
              Icons.picture_as_pdf_rounded,
              color: cs.error,
              size: 24,
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Bibliotheque PDF',
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.w900,
                    letterSpacing: -0.3,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  'Ressources et documents de reference',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: cs.onSurface.withValues(alpha: 0.7),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
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
            return ListView.separated(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              itemCount: 8,
              separatorBuilder: (_, index) => const SizedBox(height: 12),
              itemBuilder: (_, index) => const ShimmerSkeleton(height: 72),
            );
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
                  'Ajoutez des fichiers dans `assets/pdfs/` puis mettez a jour `assets/data/pdf_catalog.json`.',
            );
          }

          return ListView(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            children: [
              _buildPdfHeader(context),
              ...items.asMap().entries.map((entry) {
                final item = entry.value;
                return Padding(
                  padding: const EdgeInsets.only(bottom: 12),
                  child: InkWell(
                    borderRadius: BorderRadius.circular(18),
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
                        borderRadius: BorderRadius.circular(18),
                        color: cs.surface,
                        border: Border.all(
                          color: cs.outlineVariant.withValues(alpha: 0.35),
                        ),
                      ),
                      child: Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(10),
                            decoration: BoxDecoration(
                              color: cs.errorContainer.withValues(alpha: 0.3),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Icon(
                              Icons.picture_as_pdf_rounded,
                              color: cs.error,
                            ),
                          ),
                          const SizedBox(width: 14),
                          Expanded(
                            child: Text(
                              item.title,
                              style: const TextStyle(
                                fontWeight: FontWeight.w800,
                                fontSize: 14.5,
                              ),
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          const SizedBox(width: 10),
                          Icon(
                            Icons.chevron_right_rounded,
                            color: cs.onSurface.withValues(alpha: 0.5),
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              }),
            ],
          );
        },
      ),
    );
  }
}
