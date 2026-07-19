import 'dart:io';

import '../data/dtos/ia_nlp_dto.dart';
import '../data/dtos/ia_ocr_dto.dart';
import '../data/dtos/ia_predict_dto.dart';
import '../data/dtos/ia_v2_dto.dart';

abstract interface class IaRepository {
  // ── OCR ────────────────────────────────────────────────────────────────
  Future<IaOcrResponseDto> ocr({required File file});
  Future<Map<String, dynamic>> ocrHistory({int page, int limit});
  Future<IaPolizaExtractedDto> extractPoliza({required File file});
  Future<IaIneExtractedDto> extractIne({required File file});
  Future<IaExtractAndValidateDto> extractAndValidate({
    required File poliza,
    required File ine,
  });

  // ── Predict v1 (No Supervised) ─────────────────────────────────────────
  Future<IaPredictResponseDto> predict({required File file});
  Future<Map<String, dynamic>> history({int page, int limit});
  Future<IaRetrainResponseDto> retrain({
    required int k,
    required List<File> files,
  });
  Future<IaHealthResponseDto> health();

  // ── Predict v2 (Supervised) ────────────────────────────────────────────
  Future<IaV2PredictResponseDto> predictV2({required File file});
  Future<IaV2RetrainResponseDto> retrainV2({
    required String labels,
    required List<File> files,
    int epochs,
    double lr,
  });
  Future<IaV2RetrainStatusResponseDto> retrainV2Status(String jobId);
  Future<Map<String, dynamic>> historyV2({int page, int limit});
  Future<IaV2HealthResponseDto> healthV2();

  // ── NLP ────────────────────────────────────────────────────────────────
  Future<IaTranscribirJobResponseDto> transcribir({required File file});
  Future<IaTranscribirJobStatusResponseDto> transcribirStatus(String jobId);
  Future<IaAnalizarResponseDto> analizar(String texto);
  Future<Map<String, dynamic>> nlpHistory({int page, int limit});
  Future<IaTranscribirResponseDto> nlpDetail(String id);
}
