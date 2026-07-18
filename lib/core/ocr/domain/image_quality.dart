class ImageQuality {
  const ImageQuality({
    required this.width,
    required this.height,
    required this.sharpness,
    required this.brightness,
    this.aspectRatio = 0.0,
  });

  final int width;
  final int height;
  final double sharpness;
  final double brightness;
  final double aspectRatio;

  List<String> checkErrors(int minW, int minH, double sharpThresh,
      double brightMin, double brightMax) {
    final errors = <String>[];
    if (width < minW || height < minH) {
      errors.add('Resolución insuficiente: ${width}x$height '
          '(mínimo ${minW}x$minH)');
    }
    if (sharpness < sharpThresh) {
      errors.add('Imagen borrosa (nitidez: ${sharpness.toStringAsFixed(0)}, '
          'mínima: $sharpThresh)');
    }
    if (brightness < brightMin || brightness > brightMax) {
      errors.add('Iluminación incorrecta (brillo: '
          '${brightness.toStringAsFixed(0)}, '
          'rango: $brightMin-$brightMax)');
    }
    return errors;
  }

  bool get passesMinimum => width > 0 && height > 0 && sharpness > 0;
}
