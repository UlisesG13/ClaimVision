import 'dart:io';
import 'dart:math';

import 'package:image/image.dart' as img;

import '../ocr/domain/document_type.dart';
import '../ocr/domain/image_quality.dart';
import '../ocr/domain/image_validator.dart';

class ImageQualityService implements ImageValidator {
  @override
  Future<ImageQuality> validate(File image, DocumentType type) async {
    final bytes = await image.readAsBytes();
    final decoded = img.decodeImage(bytes);
    if (decoded == null) {
      return const ImageQuality(
        width: 0, height: 0, sharpness: 0, brightness: 0,
      );
    }

    final w = decoded.width;
    final h = decoded.height;
    final ratio = w / h;
    final brightness = _computeBrightness(decoded);
    final sharpness = _computeSharpness(decoded);

    return ImageQuality(
      width: w,
      height: h,
      sharpness: sharpness,
      brightness: brightness,
      aspectRatio: ratio,
    );
  }

  double _computeBrightness(img.Image image) {
    var total = 0.0;
    var count = 0;
    final step = max(1, image.width ~/ 20);

    for (var y = 0; y < image.height; y += step) {
      for (var x = 0; x < image.width; x += step) {
        final pixel = image.getPixel(x, y);
        total += pixel.r * 0.299 + pixel.g * 0.587 + pixel.b * 0.114;
        count++;
      }
    }

    return count > 0 ? total / count : 0;
  }

  double _computeSharpness(img.Image image) {
    final gray = img.grayscale(image);
    final lap = _laplacian3x3(gray);
    var sumSq = 0.0;
    var count = 0;

    for (final p in lap) {
      sumSq += p * p;
      count++;
    }

    return count > 0 ? sqrt(sumSq / count) : 0;
  }

  List<double> _laplacian3x3(img.Image gray) {
    const kernel = [-1, -1, -1, -1, 8, -1, -1, -1, -1];
    final w = gray.width;
    final h = gray.height;
    final result = List<double>.filled(w * h, 0);

    for (var y = 1; y < h - 1; y++) {
      for (var x = 1; x < w - 1; x++) {
        var acc = 0.0;
        var ki = 0;
        for (var ky = -1; ky <= 1; ky++) {
          for (var kx = -1; kx <= 1; kx++) {
            acc += kernel[ki] * gray.getPixel(x + kx, y + ky).r;
            ki++;
          }
        }
        result[y * w + x] = acc;
      }
    }

    return result;
  }
}
