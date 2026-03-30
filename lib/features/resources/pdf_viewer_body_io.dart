import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:pdfx/pdfx.dart';

/// Renders PDF with pdfx (mobile / desktop).
class PdfViewerBody extends StatefulWidget {
  const PdfViewerBody({
    super.key,
    required this.bytes,
    this.onPagesLoaded,
    this.onPageChanged,
  });

  final Uint8List bytes;
  final void Function(int pagesCount)? onPagesLoaded;
  final void Function(int page)? onPageChanged;

  @override
  State<PdfViewerBody> createState() => _PdfViewerBodyState();
}

class _PdfViewerBodyState extends State<PdfViewerBody> {
  late PdfController _controller;

  @override
  void initState() {
    super.initState();
    _controller = PdfController(
      document: PdfDocument.openData(Future.value(widget.bytes)),
      initialPage: 1,
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return PdfView(
      controller: _controller,
      onDocumentLoaded: (document) {
        widget.onPagesLoaded?.call(document.pagesCount);
      },
      onPageChanged: widget.onPageChanged,
    );
  }
}
