import 'dart:convert';
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';

import '../../../../core/theme/app_colors.dart';

/// Controlador del [SignaturePad]: guarda los trazos y captura la firma a PNG
/// en base64 (lo que espera el backend en `firma_digital_ajustador`).
class SignatureController extends ChangeNotifier {
  final List<List<Offset>> _strokes = [];
  final GlobalKey boundaryKey = GlobalKey();

  List<List<Offset>> get strokes => _strokes;
  bool get isEmpty => _strokes.every((s) => s.isEmpty);

  void startStroke(Offset p) {
    _strokes.add([p]);
    notifyListeners();
  }

  void appendPoint(Offset p) {
    if (_strokes.isNotEmpty) {
      _strokes.last.add(p);
      notifyListeners();
    }
  }

  void clear() {
    _strokes.clear();
    notifyListeners();
  }

  /// Renderiza la firma a PNG y la devuelve como base64 (sin prefijo data:).
  Future<String?> toBase64() async {
    final boundary = boundaryKey.currentContext?.findRenderObject()
        as RenderRepaintBoundary?;
    if (boundary == null) return null;
    final image = await boundary.toImage(pixelRatio: 2);
    final bytes = await image.toByteData(format: ui.ImageByteFormat.png);
    if (bytes == null) return null;
    return base64Encode(bytes.buffer.asUint8List());
  }
}

/// Lienzo para firmar con el dedo. Dibuja con CustomPainter (sin librerías).
class SignaturePad extends StatelessWidget {
  const SignaturePad({super.key, required this.controller, this.height = 200});

  final SignatureController controller;
  final double height;

  @override
  Widget build(BuildContext context) {
    return RepaintBoundary(
      key: controller.boundaryKey,
      child: Container(
        height: height,
        decoration: BoxDecoration(
          color: AppColors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: const Color(0xFFC4C6CE)),
        ),
        clipBehavior: Clip.antiAlias,
        child: GestureDetector(
          onPanStart: (d) => controller.startStroke(d.localPosition),
          onPanUpdate: (d) => controller.appendPoint(d.localPosition),
          child: CustomPaint(
            painter: _SignaturePainter(controller),
            size: Size.infinite,
            child: const SizedBox.expand(),
          ),
        ),
      ),
    );
  }
}

class _SignaturePainter extends CustomPainter {
  _SignaturePainter(this.controller) : super(repaint: controller);

  final SignatureController controller;

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = AppColors.blueprint
      ..strokeWidth = 2.5
      ..strokeCap = StrokeCap.round
      ..style = PaintingStyle.stroke;

    for (final stroke in controller.strokes) {
      if (stroke.length < 2) {
        if (stroke.length == 1) {
          canvas.drawPoints(ui.PointMode.points, stroke, paint);
        }
        continue;
      }
      final path = Path()..moveTo(stroke.first.dx, stroke.first.dy);
      for (var i = 1; i < stroke.length; i++) {
        path.lineTo(stroke[i].dx, stroke[i].dy);
      }
      canvas.drawPath(path, paint);
    }
  }

  @override
  bool shouldRepaint(covariant _SignaturePainter oldDelegate) => false;
}
