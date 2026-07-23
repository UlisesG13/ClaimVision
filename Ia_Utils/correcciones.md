# Guía de Integración para el Desarrollo Móvil (Flutter)

Esta guía detalla los pasos que debe seguir el equipo frontend para conectar con la lógica optimizada de validación del backend en el flujo de Onboarding de la aplicación móvil.

---

## 1. Subida Directa de PDFs (Sin Procesamiento Local)

Ya **no es necesario** rasterizar el PDF a imágenes, ni aplicar preprocesamiento de contraste o brillo sobre el documento en el dispositivo del usuario. El backend se encarga de manera automática de ajustar el DPI y validar adecuadamente los PDFs de origen digital y escaneados.

* **Flujo del móvil:**
  1. El usuario selecciona el archivo PDF original de su póliza usando el selector de archivos.
  2. La app sube el archivo binario **directamente** al proxy/backend sin transformarlo.

---

## 2. Configuración de Parámetros de Red

Al realizar la petición multipart al endpoint `/ocr/extract-and-validate`, asegúrate de enviar los archivos con las cabeceras correctas:

| Campo Multiparte | Tipo de Archivo Aceptado | Content-Type Recomendado |
| :--- | :--- | :--- |
| `poliza` | PDF (`.pdf`) | `application/pdf` |
| `ine` | Imagen (`.jpg`, `.png`) o PDF | `image/jpeg` o `application/pdf` |

*Nota: Para la **INE**, puedes seguir enviando el PDF combinado que genera tu [InePdfService](file:///home/manu/Documentos/Clases/Proyecto%20Integrador/ClaimVision/lib/core/services/ine_pdf_service.dart), o la imagen directa si decides omitir la conversión a PDF en el móvil.*

---

## 3. Implementación de Opción "Foto de Póliza" (Cámara / Galería)

Si decides permitir al usuario fotografiar su póliza física en lugar de cargar un archivo PDF digital, debes empaquetar la foto dentro de un documento PDF de 1 página antes de realizar la subida, ya que el backend requiere estrictamente la póliza en formato PDF.

### Código de referencia para la conversión:

Puedes agregar esta función de apoyo en la carpeta de servicios de la app móvil:

```dart
import 'dart:io';
import 'package:pdf/widgets.dart' as pw;
import 'package:pdf/pdf.dart';

/// Convierte una imagen de póliza capturada por la cámara en un archivo PDF temporal
/// listo para ser enviado al backend.
Future<File> convertirFotoPolizaAPdf(File fotoPoliza) async {
  final pdf = pw.Document();
  final imageBytes = await fotoPoliza.readAsBytes();
  
  pdf.addPage(
    pw.Page(
      pageFormat: PdfPageFormat.letter,
      build: (context) => pw.Center(
        child: pw.Image(pw.MemoryImage(imageBytes)),
      ),
    ),
  );

  // Guardar en el directorio temporal del sistema
  final tempDir = Directory.systemTemp;
  final tempFile = File('${tempDir.path}/poliza_temporal_${DateTime.now().millisecondsSinceEpoch}.pdf');
  await tempFile.writeAsBytes(await pdf.save());
  return tempFile;
}
```

---

## 4. Estructura del Flujo en el Controlador

El flujo dentro de tu [onboarding_controller.dart](file:///home/manu/Documentos/Clases/Proyecto%20Integrador/ClaimVision/lib/features/auth/presentation/state/onboarding_controller.dart) se simplifica de la siguiente manera:

* **INE:** Capturar fotos $\rightarrow$ Combinar fotos a PDF usando `InePdfService.combine` $\rightarrow$ Enviar.
* **Póliza:**
  * **Opción A (Archivo PDF):** Seleccionar archivo $\rightarrow$ Enviar PDF directamente sin cambios.
  * **Opción B (Fotografía):** Capturar foto $\rightarrow$ Convertir foto a PDF usando `convertirFotoPolizaAPdf` $\rightarrow$ Enviar PDF generado.