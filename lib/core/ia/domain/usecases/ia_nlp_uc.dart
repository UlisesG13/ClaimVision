import 'dart:io';

import '../../data/dtos/ia_nlp_dto.dart';
import '../ia_repository.dart';

class IaTranscribirAudio {
  const IaTranscribirAudio(this._repository);
  final IaRepository _repository;

  Future<IaTranscribirJobResponseDto> call({required File file}) {
    return _repository.transcribir(file: file);
  }
}

class IaTranscribirStatus {
  const IaTranscribirStatus(this._repository);
  final IaRepository _repository;

  Future<IaTranscribirJobStatusResponseDto> call(String jobId) {
    return _repository.transcribirStatus(jobId);
  }
}

class IaAnalizarTexto {
  const IaAnalizarTexto(this._repository);
  final IaRepository _repository;

  Future<IaAnalizarResponseDto> call(String texto) {
    return _repository.analizar(texto);
  }
}
