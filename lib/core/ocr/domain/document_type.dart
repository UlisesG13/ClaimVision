enum DocumentType {
  ineFront,
  ineBack,
  policy,
}

extension DocumentTypeX on DocumentType {
  String get label {
    return switch (this) {
      DocumentType.ineFront => 'INE - Frente',
      DocumentType.ineBack => 'INE - Reverso',
      DocumentType.policy => 'Póliza de Seguro',
    };
  }

  String get hint {
    return switch (this) {
      DocumentType.ineFront => 'Cara frontal con foto y CURP',
      DocumentType.ineBack => 'Cara posterior con código de barras',
      DocumentType.policy => 'Documento completo de la póliza',
    };
  }

  int get minWidth {
    return switch (this) {
      DocumentType.ineFront || DocumentType.ineBack => 800,
      DocumentType.policy => 1000,
    };
  }

  int get minHeight {
    return switch (this) {
      DocumentType.ineFront || DocumentType.ineBack => 500,
      DocumentType.policy => 700,
    };
  }

  double get sharpnessThreshold {
    return switch (this) {
      DocumentType.ineFront || DocumentType.ineBack => 50.0,
      DocumentType.policy => 30.0,
    };
  }

  double get brightnessMin => 50.0;
  double get brightnessMax => 200.0;
}
