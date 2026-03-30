// ignore_for_file: avoid_web_libraries_in_flutter, deprecated_member_use
// Same-origin asset URL avoids Blob + Uint8List JS interop issues on Flutter web.
import 'dart:html' as html;
import 'dart:ui_web' as ui_web;

import 'package:flutter/material.dart';

/// Embeds the PDF using the browser — [assetPath] is the bundle key, e.g.
/// `assets/pdfs/ecrite.pdf` → served at `assets/assets/pdfs/ecrite.pdf`.
class PdfViewerWebBody extends StatefulWidget {
  const PdfViewerWebBody({super.key, required this.assetPath});

  final String assetPath;

  @override
  State<PdfViewerWebBody> createState() => _PdfViewerWebBodyState();
}

class _PdfViewerWebBodyState extends State<PdfViewerWebBody> {
  late final String _viewType;
  late final String _iframeSrc;

  @override
  void initState() {
    super.initState();
    _viewType =
        'mapletcf-pdf-${identityHashCode(this)}-${DateTime.now().microsecondsSinceEpoch}';
    _iframeSrc = Uri.base.resolve('assets/${widget.assetPath}').toString();
    ui_web.platformViewRegistry.registerViewFactory(_viewType, (int viewId) {
      return html.IFrameElement()
        ..src = _iframeSrc
        ..style.border = 'none'
        ..style.width = '100%'
        ..style.height = '100%'
        ..style.display = 'block';
    });
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final h = constraints.hasBoundedHeight
            ? constraints.maxHeight
            : MediaQuery.sizeOf(context).height;
        return SizedBox(
          width: constraints.maxWidth,
          height: h,
          child: HtmlElementView(viewType: _viewType),
        );
      },
    );
  }
}
