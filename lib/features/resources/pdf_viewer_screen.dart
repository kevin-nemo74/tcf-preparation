import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'pdf_viewer_body_io.dart';
import 'pdf_viewer_body_web.dart' if (dart.library.io) 'pdf_viewer_body_web_stub.dart'
    as web_pdf;

class PdfViewerScreen extends StatefulWidget {
  final String assetPath;
  final String title;

  const PdfViewerScreen({
    super.key,
    required this.assetPath,
    required this.title,
  });

  @override
  State<PdfViewerScreen> createState() => _PdfViewerScreenState();
}

class _PdfViewerScreenState extends State<PdfViewerScreen> {
  int? _pagesCount;
  int _actualPage = 1;

  late final Future<Uint8List> _bytesFuture = rootBundle
      .load(widget.assetPath)
      .then(
        (data) => data.buffer.asUint8List(
          data.offsetInBytes,
          data.lengthInBytes,
        ),
      );

  @override
  Widget build(BuildContext context) {
    final appBar = AppBar(
      title: Text(widget.title),
      actions: [
        if (!kIsWeb && _pagesCount != null)
          Padding(
            padding: const EdgeInsets.only(right: 16),
            child: Center(
              child: Text(
                '$_actualPage/${_pagesCount!}',
                style: const TextStyle(fontWeight: FontWeight.w900),
              ),
            ),
          ),
      ],
    );

    if (kIsWeb) {
      return Scaffold(
        appBar: appBar,
        body: web_pdf.PdfViewerWebBody(assetPath: widget.assetPath),
      );
    }

    return Scaffold(
      appBar: appBar,
      body: FutureBuilder<Uint8List>(
        future: _bytesFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState != ConnectionState.done) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Text(
                  'Impossible de charger le PDF: ${snapshot.error}',
                  textAlign: TextAlign.center,
                ),
              ),
            );
          }
          final bytes = snapshot.data!;
          return PdfViewerBody(
            bytes: bytes,
            onPagesLoaded: (count) => setState(() => _pagesCount = count),
            onPageChanged: (page) => setState(() => _actualPage = page),
          );
        },
      ),
    );
  }
}
