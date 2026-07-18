import 'dart:io';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/di/providers.dart';
import '../../../core/errors/failures.dart';
import '../domain/document_type.dart';
import '../domain/image_quality.dart';
import '../domain/ocr_extraction.dart';

class OcrCapture {
  const OcrCapture({
    required this.type,
    required this.file,
    required this.quality,
  });

  final DocumentType type;
  final File file;
  final ImageQuality quality;

  bool get isValid => quality.passesMinimum;
}

class OcrState {
  const OcrState({
    this.captures = const [],
    this.extraction,
    this.loading = false,
    this.submitting = false,
    this.errorMessage,
  });

  final List<OcrCapture> captures;
  final OcrExtraction? extraction;
  final bool loading;
  final bool submitting;
  final String? errorMessage;

  bool get hasAllRequired {
    final types = captures.map((c) => c.type).toSet();
    return types.contains(DocumentType.ineFront) &&
        types.contains(DocumentType.policy);
  }

  OcrCapture? captureFor(DocumentType type) {
    final idx = captures.indexWhere((c) => c.type == type);
    return idx >= 0 ? captures[idx] : null;
  }

  OcrState copyWith({
    List<OcrCapture>? captures,
    OcrExtraction? extraction,
    bool? loading,
    bool? submitting,
    String? errorMessage,
    bool clearError = false,
  }) {
    return OcrState(
      captures: captures ?? this.captures,
      extraction: extraction ?? this.extraction,
      loading: loading ?? this.loading,
      submitting: submitting ?? this.submitting,
      errorMessage: clearError ? null : (errorMessage ?? this.errorMessage),
    );
  }
}

class OcrController extends Notifier<OcrState> {
  @override
  OcrState build() => const OcrState();

  void addCapture(OcrCapture capture) {
    final updated = List<OcrCapture>.from(state.captures);
    final idx = updated.indexWhere((c) => c.type == capture.type);
    if (idx >= 0) {
      updated[idx] = capture;
    } else {
      updated.add(capture);
    }
    state = state.copyWith(captures: updated, clearError: true);
  }

  void removeCapture(DocumentType type) {
    final updated = List<OcrCapture>.from(state.captures)
      ..removeWhere((c) => c.type == type);
    state = state.copyWith(captures: updated);
  }

  Future<void> submitOcr() async {
    if (!state.hasAllRequired) return;

    final ineFront = state.captureFor(DocumentType.ineFront)!;
    final ineBack = state.captureFor(DocumentType.ineBack);
    final policy = state.captureFor(DocumentType.policy)!;

    state = state.copyWith(loading: true, clearError: true);
    try {
      final repo = ref.read(ocrRepositoryProvider);
      final extraction = await repo.extract(
        ineFront: ineFront.file,
        ineBack: ineBack?.file,
        policy: policy.file,
      );
      state = state.copyWith(
        loading: false,
        extraction: extraction,
      );
    } on Failure catch (f) {
      state = state.copyWith(loading: false, errorMessage: f.message);
    }
  }

  void reset() => state = const OcrState();
}

final ocrControllerProvider =
    NotifierProvider<OcrController, OcrState>(OcrController.new);
