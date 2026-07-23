import 'dart:io';

import 'package:image/image.dart' as img;
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;

class InePdfService {
  Future<File> combine({required File frente, required File reverso}) async {
    final frenteBytes = await frente.readAsBytes();
    final reversoBytes = await reverso.readAsBytes();

    final frenteImg = img.decodeImage(frenteBytes);
    final reversoImg = img.decodeImage(reversoBytes);

    final pdf = pw.Document();

    if (frenteImg != null) {
      pdf.addPage(
        pw.Page(
          pageFormat: PdfPageFormat(
            frenteImg.width.toDouble(),
            frenteImg.height.toDouble(),
          ),
          build: (context) => pw.Center(
            child: pw.Image(pw.MemoryImage(frenteBytes)),
          ),
        ),
      );
    }

    if (reversoImg != null) {
      pdf.addPage(
        pw.Page(
          pageFormat: PdfPageFormat(
            reversoImg.width.toDouble(),
            reversoImg.height.toDouble(),
          ),
          build: (context) => pw.Center(
            child: pw.Image(pw.MemoryImage(reversoBytes)),
          ),
        ),
      );
    }

    final outDir = Directory.systemTemp;
    final outFile = File(
      '${outDir.path}/ine_${DateTime.now().millisecondsSinceEpoch}.pdf',
    );
    await outFile.writeAsBytes(await pdf.save());
    return outFile;
  }

  /// Envuelve una imagen (foto de póliza) en un PDF de 1 página, formato carta.
  /// El backend exige la póliza en PDF; esta es la ruta cuando el usuario la
  /// fotografía en vez de cargar el PDF digital del asegurador.
  Future<File> fromImage(File image) async {
    final imageBytes = await image.readAsBytes();

    final pdf = pw.Document();
    pdf.addPage(
      pw.Page(
        pageFormat: PdfPageFormat.letter,
        build: (context) => pw.Center(
          child: pw.Image(pw.MemoryImage(imageBytes)),
        ),
      ),
    );

    final outDir = Directory.systemTemp;
    final outFile = File(
      '${outDir.path}/poliza_${DateTime.now().millisecondsSinceEpoch}.pdf',
    );
    await outFile.writeAsBytes(await pdf.save());
    return outFile;
  }
}
